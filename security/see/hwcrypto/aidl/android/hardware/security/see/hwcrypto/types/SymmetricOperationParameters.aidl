/*
 * Copyright 2024 The Android Open Source Project
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
package android.hardware.security.see.hwcrypto.types;

import android.hardware.security.see.hwcrypto.IOpaqueKey;
import android.hardware.security.see.hwcrypto.types.SymmetricCryptoParameters;
import android.hardware.security.see.hwcrypto.types.SymmetricOperation;

/*
 * Parameters needed to perform a non-authenticated symmetric cryptographic operation.
 */
@VintfStability
parcelable SymmetricOperationParameters {
    /*
     * Key to be used on the operation.
     */
    IOpaqueKey key;

    /*
     * Encryption or Decryption.
     */
    SymmetricOperation direction;

    /*
     * Parameters that specify the desired non-authenticated symmetric cryptographic operation.
     */
    SymmetricCryptoParameters parameters;
}
