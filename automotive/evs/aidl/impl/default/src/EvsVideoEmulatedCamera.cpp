/*
 * Copyright (C) 2023 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "EvsVideoEmulatedCamera.h"

#include <aidl/android/hardware/automotive/evs/EvsResult.h>

#include <aidlcommonsupport/NativeHandle.h>
#include <android-base/logging.h>
#include <android-base/strings.h>
#include <media/stagefright/MediaCodecConstants.h>
#include <ui/GraphicBufferAllocator.h>
#include <utils/SystemClock.h>

#include <fcntl.h>
#include <libyuv.h>
#include <sys/types.h>
#include <unistd.h>

#include <chrono>
#include <cstddef>
#include <cstdint>
#include <tuple>
#include <utility>

// Uncomment below line to dump decoded frames.
// #define DUMP_FRAMES (1)

namespace aidl::android::hardware::automotive::evs::implementation {

namespace {

struct FormatDeleter {
    void operator()(AMediaFormat* format) const { AMediaFormat_delete(format); }
};

int fillRGBAFromNv12(const uint8_t* src_y, int src_stride_y, const uint8_t* src_uv,
                     int src_stride_uv, const uint8_t*, int, uint8_t* dst_abgr, int dst_stride_abgr,
                     int width, int height) {
    return libyuv::NV12ToABGR(src_y, src_stride_y, src_uv, src_stride_uv, dst_abgr, dst_stride_abgr,
                              width, height);
}

int fillRGBAFromNv21(const uint8_t* src_y, int src_stride_y, const uint8_t* src_vu,
                     int src_stride_vu, const uint8_t*, int, uint8_t* dst_abgr, int dst_stride_abgr,
                     int width, int height) {
    return libyuv::NV21ToABGR(src_y, src_stride_y, src_vu, src_stride_vu, dst_abgr, dst_stride_abgr,
                              width, height);
}

int fillRGBAFromYv12(const uint8_t* src_y, int src_stride_y, const uint8_t* src_u, int src_stride_u,
                     const uint8_t* src_v, int src_stride_v, uint8_t* dst_abgr, int dst_stride_abgr,
                     int width, int height) {
    return libyuv::I420ToABGR(src_y, src_stride_y, src_u, src_stride_u, src_v, src_stride_v,
                              dst_abgr, dst_stride_abgr, width, height);
}

int fillRGBAFromI420(const uint8_t* src_y, int src_stride_y, const uint8_t* src_u, int src_stride_u,
                     const uint8_t* src_v, int src_stride_v, uint8_t* dst_abgr, int dst_stride_abgr,
                     int width, int height) {
    return libyuv::I420ToABGR(src_y, src_stride_y, src_u, src_stride_u, src_v, src_stride_v,
                              dst_abgr, dst_stride_abgr, width, height);
}

}  // namespace

EvsVideoEmulatedCamera::EvsVideoEmulatedCamera(Sigil, const char* deviceName,
                                               std::unique_ptr<ConfigManager::CameraInfo>& camInfo)
    : mVideoFileName(deviceName), mCameraInfo(camInfo) {
    mDescription.id = mVideoFileName;

    /* set camera metadata */
    if (camInfo) {
        uint8_t* ptr = reinterpret_cast<uint8_t*>(camInfo->characteristics);
        const size_t len = get_camera_metadata_size(camInfo->characteristics);
        mDescription.metadata.insert(mDescription.metadata.end(), ptr, ptr + len);
    }

    initializeParameters();
}

bool EvsVideoEmulatedCamera::initialize() {
    // Open file.
    mVideoFd = open(mVideoFileName.c_str(), 0, O_RDONLY);
    if (mVideoFd < 0) {
        PLOG(ERROR) << __func__ << ": Failed to open video file \"" << mVideoFileName << "\".";
        return false;
    }

    // Initialize Media Extractor.
    {
        mVideoExtractor.reset(AMediaExtractor_new());
        off64_t filesize = lseek64(mVideoFd, 0, SEEK_END);
        lseek(mVideoFd, 0, SEEK_SET);
        const media_status_t status =
                AMediaExtractor_setDataSourceFd(mVideoExtractor.get(), mVideoFd, 0, filesize);
        if (status != AMEDIA_OK) {
            LOG(ERROR) << __func__
                       << ": Received error when initializing media extractor. Error code: "
                       << status << ".";
            return false;
        }
    }

    return initializeMediaCodec();
}

bool EvsVideoEmulatedCamera::initializeMediaCodec() {
    // Initialize Media Codec and file format.
    std::unique_ptr<AMediaFormat, FormatDeleter> format;
    const char* mime;
    bool selected = false;
    int numTracks = AMediaExtractor_getTrackCount(mVideoExtractor.get());
    for (int i = 0; i < numTracks; i++) {
        format.reset(AMediaExtractor_getTrackFormat(mVideoExtractor.get(), i));
        if (!AMediaFormat_getString(format.get(), AMEDIAFORMAT_KEY_MIME, &mime)) {
            LOG(ERROR) << __func__ << ": Error in fetching format string";
            continue;
        }
        if (!::android::base::StartsWith(mime, "video/")) {
            continue;
        }
        const media_status_t status = AMediaExtractor_selectTrack(mVideoExtractor.get(), i);
        if (status != AMEDIA_OK) {
            LOG(ERROR) << __func__
                       << ": Media extractor returned error to select track. Error Code: " << status
                       << ".";
            return false;
        }
        selected = true;
        break;
    }
    if (!selected) {
        LOG(ERROR) << __func__ << ": No video track in video file \"" << mVideoFileName << "\".";
        return false;
    }

    mVideoCodec.reset(AMediaCodec_createDecoderByType(mime));
    if (!mVideoCodec) {
        LOG(ERROR) << __func__ << ": Unable to create decoder.";
        return false;
    }

    mDescription.vendorFlags = 0xFFFFFFFF;  // Arbitrary test value
    mUsage = GRALLOC_USAGE_HW_TEXTURE | GRALLOC_USAGE_HW_CAMERA_WRITE |
             GRALLOC_USAGE_SW_READ_RARELY | GRALLOC_USAGE_SW_WRITE_RARELY;
    mFormat = HAL_PIXEL_FORMAT_RGBA_8888;
    AMediaFormat_setInt32(format.get(), AMEDIAFORMAT_KEY_COLOR_FORMAT, COLOR_FormatYUV420Flexible);
    {
        const media_status_t status =
                AMediaCodec_configure(mVideoCodec.get(), format.get(), nullptr, nullptr, 0);
        if (status != AMEDIA_OK) {
            LOG(ERROR) << __func__
                       << ": Received error in configuring mCodec. Error code: " << status << ".";
            return false;
        }
    }
    format.reset(AMediaCodec_getOutputFormat(mVideoCodec.get()));
    AMediaFormat_getInt32(format.get(), AMEDIAFORMAT_KEY_WIDTH, &mWidth);
    AMediaFormat_getInt32(format.get(), AMEDIAFORMAT_KEY_HEIGHT, &mHeight);

    switch (mCameraInfo->format) {
        default:
        case ConfigManager::CameraInfo::PixelFormat::NV12:
            mFillBuffer = fillRGBAFromNv12;
            mUvStride = mWidth;
            mDstStride = mWidth * 4;
            break;
        case ConfigManager::CameraInfo::PixelFormat::NV21:
            mFillBuffer = fillRGBAFromNv21;
            mUvStride = mWidth;
            mDstStride = mWidth * 4;
            break;
        case ConfigManager::CameraInfo::PixelFormat::YV12:
            mFillBuffer = fillRGBAFromYv12;
            mUvStride = mWidth / 2;
            mDstStride = mWidth * 4;
            break;
        case ConfigManager::CameraInfo::PixelFormat::I420:
            mFillBuffer = fillRGBAFromI420;
            mUvStride = mWidth / 2;
            mDstStride = mWidth * 4;
            break;
    }
    return true;
}

void EvsVideoEmulatedCamera::generateFrames() {
    while (true) {
        {
            std::lock_guard lock(mMutex);
            if (mStreamState != StreamState::RUNNING) {
                return;
            }
        }
        renderOneFrame();
    }
}

void EvsVideoEmulatedCamera::onCodecInputAvailable(const int32_t index) {
    const size_t sampleSize = AMediaExtractor_getSampleSize(mVideoExtractor.get());
    const int64_t presentationTime = AMediaExtractor_getSampleTime(mVideoExtractor.get());
    size_t bufferSize = 0;
    uint8_t* const codecInputBuffer =
            AMediaCodec_getInputBuffer(mVideoCodec.get(), index, &bufferSize);
    if (sampleSize > bufferSize) {
        LOG(ERROR) << __func__ << ": Buffer is not large enough.";
    }
    if (presentationTime < 0) {
        AMediaCodec_queueInputBuffer(mVideoCodec.get(), index, /* offset = */ 0,
                                     /* size = */ 0, presentationTime,
                                     AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM);
        LOG(INFO) << __func__ << ": Reaching the end of stream.";
        return;
    }
    const size_t readSize =
            AMediaExtractor_readSampleData(mVideoExtractor.get(), codecInputBuffer, sampleSize);
    const media_status_t status = AMediaCodec_queueInputBuffer(
            mVideoCodec.get(), index, /*offset = */ 0, readSize, presentationTime, /* flags = */ 0);
    if (status != AMEDIA_OK) {
        LOG(ERROR) << __func__
                   << ": Received error in queueing input buffer. Error code: " << status;
    }
}

void EvsVideoEmulatedCamera::onCodecOutputAvailable(const int32_t index,
                                                    const AMediaCodecBufferInfo& info) {
    using std::chrono::duration_cast;
    using std::chrono::microseconds;
    using std::chrono::nanoseconds;
    using AidlPixelFormat = ::aidl::android::hardware::graphics::common::PixelFormat;
    using ::aidl::android::hardware::graphics::common::BufferUsage;

    size_t decodedOutSize = 0;
    uint8_t* const codecOutputBuffer =
            AMediaCodec_getOutputBuffer(mVideoCodec.get(), index, &decodedOutSize) + info.offset;

    int color_format = 0;
    const auto outFormat = AMediaCodec_getOutputFormat(mVideoCodec.get());
    if (!AMediaFormat_getInt32(outFormat, AMEDIAFORMAT_KEY_COLOR_FORMAT, &color_format)) {
        LOG(ERROR) << "Failed to get the color format.";
        return;
    }

    int stride = 0;
    if (!AMediaFormat_getInt32(outFormat, AMEDIAFORMAT_KEY_STRIDE, &stride)) {
        LOG(WARNING) << "Cannot find stride in format. Set as frame width.";
        stride = mWidth;
    }

    int slice_height = 0;
    if (!AMediaFormat_getInt32(outFormat, AMEDIAFORMAT_KEY_SLICE_HEIGHT, &slice_height)) {
        LOG(WARNING) << "Cannot find slice-height in format. Set as frame height.";
        slice_height = mHeight;
    }

    LOG(DEBUG) << "COLOR FORMAT: " << color_format << " stride: " << stride
               << " height: " << slice_height;

    std::size_t renderBufferId = static_cast<std::size_t>(-1);
    buffer_handle_t renderBufferHandle = nullptr;
    {
        std::lock_guard lock(mMutex);
        if (mStreamState != StreamState::RUNNING) {
            return;
        }
        std::tie(renderBufferId, renderBufferHandle) = useBuffer_unsafe();
    }
    if (!renderBufferHandle) {
        LOG(DEBUG) << __func__ << ": Camera failed to get an available render buffer.";
        return;
    }
    std::vector<BufferDesc> renderBufferDescs;
    renderBufferDescs.push_back({
            .buffer =
                    {
                            .description =
                                    {
                                            .width = static_cast<int32_t>(mWidth),
                                            .height = static_cast<int32_t>(mHeight),
                                            .layers = 1,
                                            .format = static_cast<AidlPixelFormat>(mFormat),
                                            .usage = static_cast<BufferUsage>(mUsage),
                                            .stride = static_cast<int32_t>(mStride),
                                    },
                            .handle = ::android::dupToAidl(renderBufferHandle),
                    },
            .bufferId = static_cast<int32_t>(renderBufferId),
            .deviceId = mDescription.id,
            .timestamp = duration_cast<microseconds>(nanoseconds(::android::elapsedRealtimeNano()))
                                 .count(),
    });

    // Lock our output buffer for writing
    uint8_t* pixels = nullptr;
    auto& mapper = ::android::GraphicBufferMapper::get();
    mapper.lock(renderBufferHandle, GRALLOC_USAGE_SW_WRITE_OFTEN | GRALLOC_USAGE_SW_READ_NEVER,
                ::android::Rect(mWidth, mHeight), (void**)&pixels);

    // If we failed to lock the pixel buffer, we're about to crash, but log it first
    if (!pixels) {
        LOG(ERROR) << __func__ << ": Camera failed to gain access to image buffer for writing";
        return;
    }

    // Decoded output is in YUV4:2:0.
    std::size_t ySize = mHeight * mWidth;
    std::size_t uvSize = ySize / 4;

    uint8_t* u_head = codecOutputBuffer + ySize;
    uint8_t* v_head = u_head + uvSize;

#if DUMP_FRAMES
    // TODO: We may want to keep this "dump" option.
    static int dumpCount = 0;
    static bool dumpData = ++dumpCount < 10;
    if (dumpData) {
        std::string path = "/data/vendor/dump/";
        path += "dump_" + std::to_string(dumpCount) + ".bin";

        ::android::base::unique_fd fd(
                open(path.data(), O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP));
        if (fd < 0) {
            LOG(ERROR) << "Failed to open " << path;
        } else {
            auto len = write(fd.get(), codecOutputBuffer, info.size);
            LOG(ERROR) << "Write " << len << " to " << path;
        }
    }
#endif
    if (auto result = mFillBuffer(codecOutputBuffer, mWidth, u_head, mUvStride, v_head, mUvStride,
                                  pixels, mDstStride, mWidth, mHeight);
        result != 0) {
        LOG(ERROR) << "Failed to convert I420 to BGRA";
    }
#if DUMP_FRAMES
    else if (dumpData) {
        std::string path = "/data/vendor/dump/";
        path += "dump_" + std::to_string(dumpCount) + "_rgba.bin";

        ::android::base::unique_fd fd(
                open(path.data(), O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP));
        if (fd < 0) {
            LOG(ERROR) << "Failed to open " << path;
        } else {
            auto len = write(fd.get(), pixels, mStride * mHeight * 4);
            LOG(ERROR) << "Write " << len << " to " << path;
        }
    }
#endif

    // Release our output buffer
    mapper.unlock(renderBufferHandle);

    // Issue the (asynchronous) callback to the client -- can't be holding the lock
    if (mStream && mStream->deliverFrame(renderBufferDescs).isOk()) {
        LOG(DEBUG) << __func__ << ": Delivered " << renderBufferHandle
                   << ", id = " << renderBufferId;
    } else {
        // This can happen if the client dies and is likely unrecoverable.
        // To avoid consuming resources generating failing calls, we stop sending
        // frames.  Note, however, that the stream remains in the "STREAMING" state
        // until cleaned up on the main thread.
        LOG(ERROR) << __func__ << ": Frame delivery call failed in the transport layer.";
        doneWithFrame(renderBufferDescs);
    }
}

void EvsVideoEmulatedCamera::renderOneFrame() {
    using std::chrono::duration_cast;
    using std::chrono::microseconds;
    using namespace std::chrono_literals;

    // push to codec input
    while (true) {
        int codecInputBufferIdx =
                AMediaCodec_dequeueInputBuffer(mVideoCodec.get(), /* timeoutUs = */ 0);
        if (codecInputBufferIdx < 0) {
            if (codecInputBufferIdx != AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
                LOG(ERROR) << __func__
                           << ": Received error in AMediaCodec_dequeueInputBuffer. Error code: "
                           << codecInputBufferIdx;
            }
            break;
        }
        onCodecInputAvailable(codecInputBufferIdx);
        AMediaExtractor_advance(mVideoExtractor.get());
    }

    // pop from codec output

    AMediaCodecBufferInfo info;
    int codecOutputputBufferIdx = AMediaCodec_dequeueOutputBuffer(
            mVideoCodec.get(), &info, /* timeoutUs = */ duration_cast<microseconds>(1ms).count());
    if (codecOutputputBufferIdx < 0) {
        if (codecOutputputBufferIdx != AMEDIACODEC_INFO_TRY_AGAIN_LATER) {
            LOG(ERROR) << __func__
                       << ": Received error in AMediaCodec_dequeueOutputBuffer. Error code: "
                       << codecOutputputBufferIdx;
        }
        return;
    }
    onCodecOutputAvailable(codecOutputputBufferIdx, info);
    const auto release_status = AMediaCodec_releaseOutputBuffer(
            mVideoCodec.get(), codecOutputputBufferIdx, /* render = */ false);
    if (release_status != AMEDIA_OK) {
        LOG(ERROR) << __func__
                   << ": Received error in releasing output buffer. Error code: " << release_status;
    }

    if ((info.flags & AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM) != 0) {
        LOG(INFO) << "Start video playback from the beginning.";
        AMediaExtractor_seekTo(mVideoExtractor.get(), /* seekPosUs= */ 0,
                               AMEDIAEXTRACTOR_SEEK_CLOSEST_SYNC);
        AMediaCodec_flush(mVideoCodec.get());
    }
}

void EvsVideoEmulatedCamera::initializeParameters() {
    mParams.emplace(
            CameraParam::BRIGHTNESS,
            new CameraParameterDesc(/* min= */ 0, /* max= */ 255, /* step= */ 1, /* value= */ 255));
    mParams.emplace(
            CameraParam::CONTRAST,
            new CameraParameterDesc(/* min= */ 0, /* max= */ 255, /* step= */ 1, /* value= */ 255));
    mParams.emplace(
            CameraParam::SHARPNESS,
            new CameraParameterDesc(/* min= */ 0, /* max= */ 255, /* step= */ 1, /* value= */ 255));
}

::android::status_t EvsVideoEmulatedCamera::allocateOneFrame(buffer_handle_t* handle) {
    static auto& alloc = ::android::GraphicBufferAllocator::get();
    unsigned pixelsPerLine = 0;
    const auto result = alloc.allocate(mWidth, mHeight, HAL_PIXEL_FORMAT_RGBA_8888, 1, mUsage,
                                       handle, &pixelsPerLine, 0, "EvsVideoEmulatedCamera");
    if (mStride == 0) {
        // Gralloc defines stride in terms of pixels per line
        mStride = pixelsPerLine;
    } else if (mStride != pixelsPerLine) {
        LOG(ERROR) << "We did not expect to get buffers with different strides!";
    }
    return result;
}

bool EvsVideoEmulatedCamera::startVideoStreamImpl_locked(
        const std::shared_ptr<evs::IEvsCameraStream>& receiver, ndk::ScopedAStatus& /* status */,
        std::unique_lock<std::mutex>& /* lck */) {
    mStream = receiver;

    if (auto status = AMediaCodec_start(mVideoCodec.get()); status != AMEDIA_OK) {
        LOG(INFO) << __func__ << ": Received error in starting decoder. "
                  << "Trying again after resetting this emulated device.";

        if (!initializeMediaCodec()) {
            LOG(ERROR) << __func__ << ": Failed to re-configure the media codec.";
            return false;
        }

        AMediaExtractor_seekTo(mVideoExtractor.get(), /* seekPosUs= */ 0,
                               AMEDIAEXTRACTOR_SEEK_CLOSEST_SYNC);
        AMediaCodec_flush(mVideoCodec.get());

        if (auto status = AMediaCodec_start(mVideoCodec.get()); status != AMEDIA_OK) {
            LOG(ERROR) << __func__ << ": Received error again in starting decoder. "
                       << "Error code: " << status;
            return false;
        }
    }
    mCaptureThread = std::thread([this]() { generateFrames(); });

    return true;
}

bool EvsVideoEmulatedCamera::stopVideoStreamImpl_locked(ndk::ScopedAStatus& /* status */,
                                                        std::unique_lock<std::mutex>& lck) {
    const media_status_t status = AMediaCodec_stop(mVideoCodec.get());
    lck.unlock();
    if (mCaptureThread.joinable()) {
        mCaptureThread.join();
    }
    lck.lock();
    return status == AMEDIA_OK;
}

bool EvsVideoEmulatedCamera::postVideoStreamStop_locked(ndk::ScopedAStatus& status,
                                                        std::unique_lock<std::mutex>& lck) {
    if (!Base::postVideoStreamStop_locked(status, lck)) {
        return false;
    }

    EvsEventDesc event = {
            .aType = EvsEventType::STREAM_STOPPED,
    };
    if (auto result = mStream->notify(event); !result.isOk()) {
        LOG(WARNING) << "Failed to notify the end of the stream.";
    }

    mStream = nullptr;
    return true;
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::forcePrimaryClient(
        const std::shared_ptr<evs::IEvsDisplay>& /* display */) {
    /* Because EVS HW module reference implementation expects a single client at
     * a time, this returns a success code always.
     */
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getCameraInfo(evs::CameraDesc* _aidl_return) {
    *_aidl_return = mDescription;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getExtendedInfo(int32_t opaqueIdentifier,
                                                           std::vector<uint8_t>* value) {
    const auto it = mExtInfo.find(opaqueIdentifier);
    if (it == mExtInfo.end()) {
        return ndk::ScopedAStatus::fromServiceSpecificError(
                static_cast<int>(EvsResult::INVALID_ARG));
    } else {
        *value = mExtInfo[opaqueIdentifier];
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getIntParameter(evs::CameraParam id,
                                                           std::vector<int32_t>* value) {
    const auto it = mParams.find(id);
    if (it == mParams.end()) {
        return ndk::ScopedAStatus::fromServiceSpecificError(
                static_cast<int>(EvsResult::NOT_SUPPORTED));
    }
    value->push_back(it->second->value);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getIntParameterRange(evs::CameraParam id,
                                                                evs::ParameterRange* _aidl_return) {
    const auto it = mParams.find(id);
    if (it == mParams.end()) {
        return ndk::ScopedAStatus::fromServiceSpecificError(
                static_cast<int>(EvsResult::NOT_SUPPORTED));
    }
    _aidl_return->min = it->second->range.min;
    _aidl_return->max = it->second->range.max;
    _aidl_return->step = it->second->range.step;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getParameterList(
        std::vector<evs::CameraParam>* _aidl_return) {
    if (mCameraInfo) {
        _aidl_return->resize(mCameraInfo->controls.size());
        std::size_t idx = 0;
        for (const auto& [name, range] : mCameraInfo->controls) {
            (*_aidl_return)[idx++] = name;
        }
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::getPhysicalCameraInfo(const std::string& /* deviceId */,
                                                                 evs::CameraDesc* _aidl_return) {
    return getCameraInfo(_aidl_return);
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::setExtendedInfo(
        int32_t opaqueIdentifier, const std::vector<uint8_t>& opaqueValue) {
    mExtInfo.insert_or_assign(opaqueIdentifier, opaqueValue);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::setIntParameter(evs::CameraParam id, int32_t value,
                                                           std::vector<int32_t>* effectiveValue) {
    const auto it = mParams.find(id);
    if (it == mParams.end()) {
        return ndk::ScopedAStatus::fromServiceSpecificError(
                static_cast<int>(EvsResult::NOT_SUPPORTED));
    }
    // Rounding down to the closest value.
    int32_t candidate = value / it->second->range.step * it->second->range.step;
    if (candidate < it->second->range.min || candidate > it->second->range.max) {
        return ndk::ScopedAStatus::fromServiceSpecificError(
                static_cast<int>(EvsResult::INVALID_ARG));
    }
    it->second->value = candidate;
    effectiveValue->push_back(candidate);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::setPrimaryClient() {
    /* Because EVS HW module reference implementation expects a single client at
     * a time, this returns a success code always.
     */
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus EvsVideoEmulatedCamera::unsetPrimaryClient() {
    /* Because EVS HW module reference implementation expects a single client at
     * a time, there is no chance that this is called by the secondary client and
     * therefore returns a success code always.
     */
    return ndk::ScopedAStatus::ok();
}

std::shared_ptr<EvsVideoEmulatedCamera> EvsVideoEmulatedCamera::Create(const char* deviceName) {
    std::unique_ptr<ConfigManager::CameraInfo> nullCamInfo = nullptr;
    return Create(deviceName, nullCamInfo);
}

std::shared_ptr<EvsVideoEmulatedCamera> EvsVideoEmulatedCamera::Create(
        const char* deviceName, std::unique_ptr<ConfigManager::CameraInfo>& camInfo,
        const evs::Stream* /* streamCfg */) {
    std::shared_ptr<EvsVideoEmulatedCamera> c =
            ndk::SharedRefBase::make<EvsVideoEmulatedCamera>(Sigil{}, deviceName, camInfo);
    if (!c) {
        LOG(ERROR) << "Failed to instantiate EvsVideoEmulatedCamera.";
        return nullptr;
    }
    if (!c->initialize()) {
        LOG(ERROR) << "Failed to initialize EvsVideoEmulatedCamera.";
        return nullptr;
    }
    return c;
}

void EvsVideoEmulatedCamera::shutdown() {
    mVideoCodec.reset();
    mVideoExtractor.reset();
    close(mVideoFd);
    mVideoFd = 0;
    Base::shutdown();
}

}  // namespace aidl::android::hardware::automotive::evs::implementation
