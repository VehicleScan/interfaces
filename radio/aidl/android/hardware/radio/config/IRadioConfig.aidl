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
 *
 *
 * This interface is used by telephony and telecom to talk to cellular radio for the purpose of
 * radio configuration, and it is not associated with any specific modem or slot.
 * All the functions have minimum one parameter:
 * serial: which corresponds to the serial number of the request. Serial numbers must only be
 * memorized for the duration of a method call. If clients provide colliding serials (including
 * passing the same serial to different methods), multiple responses (one for each method call) must
 * still be served.
 */

package android.hardware.radio.config;

import android.hardware.radio.config.IRadioConfigIndication;
import android.hardware.radio.config.IRadioConfigResponse;
import android.hardware.radio.config.SimType;
import android.hardware.radio.config.SlotPortMapping;

/** @hide */
@VintfStability
oneway interface IRadioConfig {
    /**
     * Gets the available Radio Hal capabilities on the current device.
     *
     * This is called once per device boot up.
     *
     * @param serial Serial number of request
     *
     * Response callback is
     * IRadioConfigResponse.getHalDeviceCapabilitiesResponse()
     *
     * This is available when android.hardware.telephony is defined.
     */
    void getHalDeviceCapabilities(in int serial);

    /**
     * Get the number of live modems (i.e modems that are
     * enabled and actively working as part of a working telephony stack)
     *
     * Note: in order to get the overall number of modems available on the phone,
     * refer to getPhoneCapability API
     *
     * @param serial Serial number of request.
     *
     * Response callback is IRadioConfigResponse.getNumOfLiveModemsResponse() which
     * will return <byte>.
     *
     * This is available when android.hardware.telephony is defined.
     */
    void getNumOfLiveModems(in int serial);

    /**
     * Request current phone capability.
     *
     * @param serial Serial number of request.
     *
     * Response callback is IRadioResponse.getPhoneCapabilityResponse() which
     * will return <PhoneCapability>.
     *
     * This is available when android.hardware.telephony is defined.
     */
    void getPhoneCapability(in int serial);

    /**
     * Get SIM Slot status.
     *
     * Request provides the slot status of all active and inactive SIM slots and whether card is
     * present in the slots or not.
     *
     * @param serial Serial number of request.
     *
     * Response callback is IRadioConfigResponse.getSimSlotsStatusResponse()
     *
     * This is available when android.hardware.telephony.subscription is defined.
     */
    void getSimSlotsStatus(in int serial);

    /**
     * Set modems configurations by specifying the number of live modems (i.e modems that are
     * enabled and actively working as part of a working telephony stack).
     *
     * Example: this interface can be used to switch to single/multi sim mode by specifying
     * the number of live modems as 1, 2, etc
     *
     * Note: by setting the number of live modems in this API, that number of modems will
     * subsequently get enabled/disabled
     *
     * @param serial serial number of request.
     * @param modemsConfig byte object including the number of live modems
     *
     * Response callback is IRadioResponse.setNumOfLiveModemsResponse()
     *
     * This is available when android.hardware.telephony is defined.
     */
    void setNumOfLiveModems(in int serial, in byte numOfLiveModems);

    /**
     * Set preferred data modem Id.
     * In a multi-SIM device, notify the modem layer which logical modem will be used primarily
     * for data. It helps the modem with resource optimization and decisions of what data
     * connections should be satisfied.
     *
     * @param serial Serial number of request.
     * @param modemId the logical modem ID which should match one of the modem IDs returned
     * from getPhoneCapability().
     *
     * Response callback is IRadioConfigResponse.setPreferredDataModemResponse()
     *
     * This is available when android.hardware.telephony.data is defined.
     */
    void setPreferredDataModem(in int serial, in byte modemId);

    /**
     * Set response functions for radio config requests & radio config indications.
     *
     * @param radioConfigResponse Object containing radio config response functions
     * @param radioConfigIndication Object containing radio config indications
     *
     * This is available when android.hardware.telephony is defined.
     */
    void setResponseFunctions(in IRadioConfigResponse radioConfigResponse,
            in IRadioConfigIndication radioConfigIndication);

    /**
     * Set SIM Slot mapping.
     *
     * Maps the logical slots to the SlotPortMapping, which consists of both physical slot id and
     * port id. Logical slot is the slot that is seen by the modem. Physical slot is the actual
     * physical slot. PortId is the id (enumerated value) for the associated port available on the
     * SIM. Each physical slot can have multiple ports, which enables multi-enabled profile(MEP). If
     * eUICC physical slot supports 2 ports, then the portId is numbered 0,1 and if eUICC2 supports
     * 4 ports then the portID is numbered 0,1,2,3. Each portId is unique within a UICC physical
     * slot but not necessarily unique across UICC’s. SEP(Single enabled profile) eUICC and
     * non-eUICC will only have portId 0.
     *
     * Logical slots that are already mapped to the requested SlotPortMapping are not impacted.
     *
     * Example: There is 1 logical slot, 2 physical slots, MEP is not supported and each physical
     * slot has one port:
     * The only logical slot (index 0) can be mapped to the first physical slot (value 0),
     * port(index 0), or second physical slot(value 1), port (index 0), while the other physical
     * slot remains unmapped and inactive.
     * slotMap[0] = SlotPortMapping{0 //physical slot//, 0 //port//}
     * slotMap[0] = SlotPortMapping{1 //physical slot//, 0 //port//}
     *
     * Example: There are 2 logical slots, 2 physical slots, MEP is supported and there are 2 ports
     * available:
     * Each logical slot must be mapped to a port (physical slot and port combination). The first
     * logical slot (index 0) can be mapped to the physical slot 1 and the second logical slot can
     * be mapped to either port from physical slot 2.
     *
     * slotMap[0] = SlotPortMapping{0, 0} and slotMap[1] = SlotPortMapping{1, 0} or
     * slotMap[0] = SlotPortMapping{0, 0} and slotMap[1] = SlotPortMapping{1, 1}
     *
     * or the other way around, the second logical slot(index 1) can be mapped to physical slot 1
     * and the first logical slot can be mapped to either port from physical slot 2.
     *
     * slotMap[1] = SlotPortMapping{0, 0} and slotMap[0] = SlotPortMapping{1, 0} or
     * slotMap[1] = SlotPortMapping{0, 0} and slotMap[0] = SlotPortMapping{1, 1}
     *
     * another possible mapping is each logical slot maps to each port of physical slot 2 and there
     * is no active logical modem mapped to physical slot 1.
     *
     * slotMap[0] = SlotPortMapping{1, 0} and slotMap[1] = SlotPortMapping{1, 1} or
     * slotMap[0] = SlotPortMapping{1, 1} and slotMap[1] = SlotPortMapping{1, 0}
     *
     * @param serial Serial number of request
     * @param slotMap Logical to physical slot and port mapping.
     *        The index maps to the logical slot, and the value to the physical slot and port id. In
     *        the case of a multi-slot device, provide all the slot mappings when sending a request.
     *
     *        Example: SlotPortMapping(physical slot, port id)
     *        index 0 is the first logical_slot number of logical slots is equal to number of Radio
     *        instances and number of physical slots is equal to size of slotStatus in
     *        getSimSlotsStatusResponse
     *
     * Response callback is IRadioConfigResponse.setSimSlotsMappingResponse()
     *
     * This is available when android.hardware.telephony.subscription is defined.
     */
    void setSimSlotsMapping(in int serial, in SlotPortMapping[] slotMap);

    /**
     * Get the set of logical slots where simultaneous cellular calling is currently possible. This
     * does not include simultaneous calling availability over other non-cellular transports, such
     * as IWLAN.
     *
     * Get the set of slots that currently support simultaneous cellular calling. When a new
     * cellular call is placed/received, if another slot is active and handing a call, both the
     * active slot and proposed slot must be in this list in order to support simultaneous cellular
     * calling for both of those slots.
     *
     * @param serial Serial number of request
     *
     * This is available when android.hardware.telephony is defined.
     */
    void getSimultaneousCallingSupport(in int serial);

    /**
     * Get the sim type information.
     *
     * Response provides the current active sim type and supported sim types associated with each
     * active physical slot ids.
     *
     * @param serial Serial number of request.
     *
     * Response callback is IRadioConfigResponse.getSimTypeInfoResponse()
     *
     * This is available when android.hardware.telephony.subscription is defined.
     */
    void getSimTypeInfo(in int serial);

    /**
     * Set the sim type associated with the physical slot id and activate if the sim type is
     * currently inactive.
     *
     * Example: There are 2 active physical slot ids and 3 physical sims(2 pSIM and 1 eSIM). First
     * physical slot id is always linked pSIM and 2nd physical slot id supports either pSIM/eSIM one
     * at a time. In order to activate eSIM on 2nd physical slot id, caller should pass
     * corresponding sim type.
     *
     * simTypes[0] = pSIM
     * simTypes[1] = eSIM
     *
     * @param serial Serial number of request.
     * @param simTypes SimType to be activated on each logical slot
     *
     * Response callback is IRadioConfigResponse.setSimTypeResponse()
     *
     * This is available when android.hardware.telephony.subscription is defined.
     */
    void setSimType(in int serial, in SimType[] simTypes);
}
