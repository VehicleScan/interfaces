/*
 * Copyright (C) 2021 The Android Open Source Project
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

package android.hardware.radio.voice;

/**
 * CDMA Signal Information Record as defined in C.S0005 section 3.7.5.5
 * @hide
 */
@VintfStability
@JavaDerive(toString=true)
parcelable CdmaSignalInfoRecord {
    /**
     * True if signal information record is present
     * @deprecated Legacy CDMA is unsupported.
     */
    boolean isPresent;
    /**
     * Defined in 3.7.5.5-1
     * @deprecated Legacy CDMA is unsupported.
     */
    byte signalType;
    /**
     * Defined in 3.7.5.5-2
     * @deprecated Legacy CDMA is unsupported.
     */
    byte alertPitch;
    /**
     * Defined in 3.7.5.5-3, 3.7.5.5-4 or 3.7.5.5-5
     * @deprecated Legacy CDMA is unsupported.
     */
    byte signal;
}
