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
@Backing(type="int") @VintfStability
enum ErrorCode {
  OK = 0,
  ROOT_OF_TRUST_ALREADY_SET = (-1) /* -1 */,
  UNSUPPORTED_PURPOSE = (-2) /* -2 */,
  INCOMPATIBLE_PURPOSE = (-3) /* -3 */,
  UNSUPPORTED_ALGORITHM = (-4) /* -4 */,
  INCOMPATIBLE_ALGORITHM = (-5) /* -5 */,
  UNSUPPORTED_KEY_SIZE = (-6) /* -6 */,
  UNSUPPORTED_BLOCK_MODE = (-7) /* -7 */,
  INCOMPATIBLE_BLOCK_MODE = (-8) /* -8 */,
  UNSUPPORTED_MAC_LENGTH = (-9) /* -9 */,
  UNSUPPORTED_PADDING_MODE = (-10) /* -10 */,
  INCOMPATIBLE_PADDING_MODE = (-11) /* -11 */,
  UNSUPPORTED_DIGEST = (-12) /* -12 */,
  INCOMPATIBLE_DIGEST = (-13) /* -13 */,
  INVALID_EXPIRATION_TIME = (-14) /* -14 */,
  INVALID_USER_ID = (-15) /* -15 */,
  INVALID_AUTHORIZATION_TIMEOUT = (-16) /* -16 */,
  UNSUPPORTED_KEY_FORMAT = (-17) /* -17 */,
  INCOMPATIBLE_KEY_FORMAT = (-18) /* -18 */,
  UNSUPPORTED_KEY_ENCRYPTION_ALGORITHM = (-19) /* -19 */,
  UNSUPPORTED_KEY_VERIFICATION_ALGORITHM = (-20) /* -20 */,
  INVALID_INPUT_LENGTH = (-21) /* -21 */,
  KEY_EXPORT_OPTIONS_INVALID = (-22) /* -22 */,
  DELEGATION_NOT_ALLOWED = (-23) /* -23 */,
  KEY_NOT_YET_VALID = (-24) /* -24 */,
  KEY_EXPIRED = (-25) /* -25 */,
  KEY_USER_NOT_AUTHENTICATED = (-26) /* -26 */,
  OUTPUT_PARAMETER_NULL = (-27) /* -27 */,
  INVALID_OPERATION_HANDLE = (-28) /* -28 */,
  INSUFFICIENT_BUFFER_SPACE = (-29) /* -29 */,
  VERIFICATION_FAILED = (-30) /* -30 */,
  TOO_MANY_OPERATIONS = (-31) /* -31 */,
  UNEXPECTED_NULL_POINTER = (-32) /* -32 */,
  INVALID_KEY_BLOB = (-33) /* -33 */,
  IMPORTED_KEY_NOT_ENCRYPTED = (-34) /* -34 */,
  IMPORTED_KEY_DECRYPTION_FAILED = (-35) /* -35 */,
  IMPORTED_KEY_NOT_SIGNED = (-36) /* -36 */,
  IMPORTED_KEY_VERIFICATION_FAILED = (-37) /* -37 */,
  INVALID_ARGUMENT = (-38) /* -38 */,
  UNSUPPORTED_TAG = (-39) /* -39 */,
  INVALID_TAG = (-40) /* -40 */,
  MEMORY_ALLOCATION_FAILED = (-41) /* -41 */,
  IMPORT_PARAMETER_MISMATCH = (-44) /* -44 */,
  SECURE_HW_ACCESS_DENIED = (-45) /* -45 */,
  OPERATION_CANCELLED = (-46) /* -46 */,
  CONCURRENT_ACCESS_CONFLICT = (-47) /* -47 */,
  SECURE_HW_BUSY = (-48) /* -48 */,
  SECURE_HW_COMMUNICATION_FAILED = (-49) /* -49 */,
  UNSUPPORTED_EC_FIELD = (-50) /* -50 */,
  MISSING_NONCE = (-51) /* -51 */,
  INVALID_NONCE = (-52) /* -52 */,
  MISSING_MAC_LENGTH = (-53) /* -53 */,
  KEY_RATE_LIMIT_EXCEEDED = (-54) /* -54 */,
  CALLER_NONCE_PROHIBITED = (-55) /* -55 */,
  KEY_MAX_OPS_EXCEEDED = (-56) /* -56 */,
  INVALID_MAC_LENGTH = (-57) /* -57 */,
  MISSING_MIN_MAC_LENGTH = (-58) /* -58 */,
  UNSUPPORTED_MIN_MAC_LENGTH = (-59) /* -59 */,
  UNSUPPORTED_KDF = (-60) /* -60 */,
  UNSUPPORTED_EC_CURVE = (-61) /* -61 */,
  KEY_REQUIRES_UPGRADE = (-62) /* -62 */,
  ATTESTATION_CHALLENGE_MISSING = (-63) /* -63 */,
  KEYMINT_NOT_CONFIGURED = (-64) /* -64 */,
  ATTESTATION_APPLICATION_ID_MISSING = (-65) /* -65 */,
  CANNOT_ATTEST_IDS = (-66) /* -66 */,
  ROLLBACK_RESISTANCE_UNAVAILABLE = (-67) /* -67 */,
  HARDWARE_TYPE_UNAVAILABLE = (-68) /* -68 */,
  PROOF_OF_PRESENCE_REQUIRED = (-69) /* -69 */,
  CONCURRENT_PROOF_OF_PRESENCE_REQUESTED = (-70) /* -70 */,
  NO_USER_CONFIRMATION = (-71) /* -71 */,
  DEVICE_LOCKED = (-72) /* -72 */,
  EARLY_BOOT_ENDED = (-73) /* -73 */,
  ATTESTATION_KEYS_NOT_PROVISIONED = (-74) /* -74 */,
  ATTESTATION_IDS_NOT_PROVISIONED = (-75) /* -75 */,
  INVALID_OPERATION = (-76) /* -76 */,
  STORAGE_KEY_UNSUPPORTED = (-77) /* -77 */,
  INCOMPATIBLE_MGF_DIGEST = (-78) /* -78 */,
  UNSUPPORTED_MGF_DIGEST = (-79) /* -79 */,
  MISSING_NOT_BEFORE = (-80) /* -80 */,
  MISSING_NOT_AFTER = (-81) /* -81 */,
  MISSING_ISSUER_SUBJECT = (-82) /* -82 */,
  INVALID_ISSUER_SUBJECT = (-83) /* -83 */,
  BOOT_LEVEL_EXCEEDED = (-84) /* -84 */,
  HARDWARE_NOT_YET_AVAILABLE = (-85) /* -85 */,
  MODULE_HASH_ALREADY_SET = (-86) /* -86 */,
  UNIMPLEMENTED = (-100) /* -100 */,
  VERSION_MISMATCH = (-101) /* -101 */,
  UNKNOWN_ERROR = (-1000) /* -1000 */,
}
