/*
 * Copyright 2022 The Android Open Source Project
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

package android.hardware.bluetooth.audio;

import android.hardware.bluetooth.audio.AudioLocation;
import android.hardware.bluetooth.audio.CodecSpecificConfigurationLtv.AudioChannelAllocation;
import android.hardware.bluetooth.audio.CodecType;
import android.hardware.bluetooth.audio.Lc3Capabilities;

/**
 * Used to specify the le audio broadcast codec capabilities for hardware offload.
 */
@VintfStability
parcelable BroadcastCapability {
    @VintfStability
    parcelable VendorCapabilities {
        ParcelableHolder extension;
    }
    @VintfStability
    union LeAudioCodecCapabilities {
        @nullable Lc3Capabilities[] lc3Capabilities;
        @nullable VendorCapabilities[] vendorCapabillities;
    }
    CodecType codecType;
    // @deprecated use audioLocation if present.
    AudioLocation supportedChannel;
    // Supported channel count for each stream
    int channelCountPerStream;
    LeAudioCodecCapabilities leAudioCodecCapabilities;
    // The new audio location type, replacing supportedChannel
    @nullable AudioChannelAllocation audioLocation;
}
