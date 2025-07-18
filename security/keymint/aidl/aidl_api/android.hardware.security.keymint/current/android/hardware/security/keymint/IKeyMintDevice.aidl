/*
 * Copyright (C) 2020 The Android Open Source Project
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
///////////////////////////////////////////////////////////////////////////////
// THIS FILE IS IMMUTABLE. DO NOT EDIT IN ANY CASE.                          //
///////////////////////////////////////////////////////////////////////////////

// This file is a snapshot of an AIDL file. Do not edit it manually. There are
// two cases:
// 1). this is a frozen version file - do not edit this in any case.
// 2). this is a 'current' file. If you make a backwards compatible change to
//     the interface (from the latest frozen version), the build system will
//     prompt you to update this file with `m <name>-update-api`.
//
// You must not make a backward incompatible change to any AIDL file built
// with the aidl_interface module type with versions property set. The module
// type is used to build AIDL files in a way that they can be used across
// independently updatable components of the system. If a device is shipped
// with such a backward incompatible change, it has a high risk of breaking
// later when a module using the interface is updated, e.g., Mainline modules.

package android.hardware.security.keymint;
/* @hide */
@SensitiveData @VintfStability
interface IKeyMintDevice {
  android.hardware.security.keymint.KeyMintHardwareInfo getHardwareInfo();
  void addRngEntropy(in byte[] data);
  android.hardware.security.keymint.KeyCreationResult generateKey(in android.hardware.security.keymint.KeyParameter[] keyParams, in @nullable android.hardware.security.keymint.AttestationKey attestationKey);
  android.hardware.security.keymint.KeyCreationResult importKey(in android.hardware.security.keymint.KeyParameter[] keyParams, in android.hardware.security.keymint.KeyFormat keyFormat, in byte[] keyData, in @nullable android.hardware.security.keymint.AttestationKey attestationKey);
  android.hardware.security.keymint.KeyCreationResult importWrappedKey(in byte[] wrappedKeyData, in byte[] wrappingKeyBlob, in byte[] maskingKey, in android.hardware.security.keymint.KeyParameter[] unwrappingParams, in long passwordSid, in long biometricSid);
  byte[] upgradeKey(in byte[] keyBlobToUpgrade, in android.hardware.security.keymint.KeyParameter[] upgradeParams);
  void deleteKey(in byte[] keyBlob);
  void deleteAllKeys();
  void destroyAttestationIds();
  android.hardware.security.keymint.BeginResult begin(in android.hardware.security.keymint.KeyPurpose purpose, in byte[] keyBlob, in android.hardware.security.keymint.KeyParameter[] params, in @nullable android.hardware.security.keymint.HardwareAuthToken authToken);
  void deviceLocked(in boolean passwordOnly, in @nullable android.hardware.security.secureclock.TimeStampToken timestampToken);
  void earlyBootEnded();
  byte[] convertStorageKeyToEphemeral(in byte[] storageKeyBlob);
  android.hardware.security.keymint.KeyCharacteristics[] getKeyCharacteristics(in byte[] keyBlob, in byte[] appId, in byte[] appData);
  byte[16] getRootOfTrustChallenge();
  byte[] getRootOfTrust(in byte[16] challenge);
  void sendRootOfTrust(in byte[] rootOfTrust);
  void setAdditionalAttestationInfo(in android.hardware.security.keymint.KeyParameter[] info);
  const int AUTH_TOKEN_MAC_LENGTH = 32;
}
