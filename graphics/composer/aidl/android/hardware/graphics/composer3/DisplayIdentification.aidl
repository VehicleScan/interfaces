/**
 * Copyright (c) 2021, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package android.hardware.graphics.composer3;

import android.hardware.graphics.composer3.ScreenPartStatus;
/**
 * Output parameters for IComposerClient.getDisplayIdentificationData
 */
@VintfStability
parcelable DisplayIdentification {
    /**
     * The connector to which the display is connected.
     */
    byte port;
    /**
     * The EDID 1.3 blob identifying the display.
     */
    byte[] data;
    /**
     * Indicator for part originality of the screen
     */
    ScreenPartStatus screenPartStatus = ScreenPartStatus.UNSUPPORTED;
}
