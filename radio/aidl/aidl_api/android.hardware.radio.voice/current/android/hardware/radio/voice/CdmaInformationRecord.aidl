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

package android.hardware.radio.voice;
/* @hide */
@JavaDerive(toString=true) @SuppressWarnings(value={"redundant-name"}) @VintfStability
parcelable CdmaInformationRecord {
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  int name;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaDisplayInfoRecord[] display;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaNumberInfoRecord[] number;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaSignalInfoRecord[] signal;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaRedirectingNumberInfoRecord[] redir;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaLineControlInfoRecord[] lineCtrl;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaT53ClirInfoRecord[] clir;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  android.hardware.radio.voice.CdmaT53AudioControlInfoRecord[] audioCtrl;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int CDMA_MAX_NUMBER_OF_INFO_RECS = 10;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_DISPLAY = 0;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_CALLED_PARTY_NUMBER = 1;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_CALLING_PARTY_NUMBER = 2;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_CONNECTED_NUMBER = 3;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_SIGNAL = 4;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_REDIRECTING_NUMBER = 5;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_LINE_CONTROL = 6;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_EXTENDED_DISPLAY = 7;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_T53_CLIR = 8;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_T53_RELEASE = 9;
  /**
   * @deprecated Legacy CDMA is unsupported.
   */
  const int NAME_T53_AUDIO_CONTROL = 10;
}
