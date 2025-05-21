package com.carenx.fetosense.plus.bp.model;


import android.util.Log;

import com.carenx.fetosense.plus.bp.Constants;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.Model.OmronPeripheral;

import java.util.Map;

public class PairingDeviceData {

    public static OmronPeripheral changePeripheralObject(Map<String, String> configInfo) {
        Log.i("changePeripheralObject",configInfo.get(Constants.deviceInfoKeys.KEY_LOCAL_NAME));
        Log.i("changePeripheralObject",configInfo.get(Constants.deviceInfoKeys.KEY_UUID));

        return new OmronPeripheral(configInfo.get(Constants.deviceInfoKeys.KEY_LOCAL_NAME), configInfo.get(Constants.deviceInfoKeys.KEY_UUID));
    }
}
