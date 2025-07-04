/*
 * Copyright (C) 2022 The Android Open Source Project
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

/*
 * Autogenerated from camera metadata definitions in
 * /system/media/camera/docs/metadata_definitions.xml
 * *** DO NOT EDIT BY HAND ***
 */

package android.hardware.camera.metadata;

/**
 * Top level hierarchy definitions for camera metadata. *_INFO sections are for
 * the static metadata that can be retrieved without opening the camera device.
 */
@VintfStability
@Backing(type="int")
enum CameraMetadataSection {
    ANDROID_COLOR_CORRECTION,
    ANDROID_CONTROL,
    ANDROID_DEMOSAIC,
    ANDROID_EDGE,
    ANDROID_FLASH,
    ANDROID_FLASH_INFO,
    ANDROID_HOT_PIXEL,
    ANDROID_JPEG,
    ANDROID_LENS,
    ANDROID_LENS_INFO,
    ANDROID_NOISE_REDUCTION,
    ANDROID_QUIRKS,
    ANDROID_REQUEST,
    ANDROID_SCALER,
    ANDROID_SENSOR,
    ANDROID_SENSOR_INFO,
    ANDROID_SHADING,
    ANDROID_STATISTICS,
    ANDROID_STATISTICS_INFO,
    ANDROID_TONEMAP,
    ANDROID_LED,
    ANDROID_INFO,
    ANDROID_BLACK_LEVEL,
    ANDROID_SYNC,
    ANDROID_REPROCESS,
    ANDROID_DEPTH,
    ANDROID_LOGICAL_MULTI_CAMERA,
    ANDROID_DISTORTION_CORRECTION,
    ANDROID_HEIC,
    ANDROID_HEIC_INFO,
    ANDROID_AUTOMOTIVE,
    ANDROID_AUTOMOTIVE_LENS,
    ANDROID_EXTENSION,
    ANDROID_JPEGR,
    ANDROID_SHARED_SESSION,
    ANDROID_DESKTOP_EFFECTS,
    VENDOR_SECTION = 0x8000,
}
