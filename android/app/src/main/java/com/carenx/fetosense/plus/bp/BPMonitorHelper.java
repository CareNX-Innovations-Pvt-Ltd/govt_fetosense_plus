package com.carenx.fetosense.plus.bp;

import static android.content.Context.RECEIVER_NOT_EXPORTED;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Handler;
import android.util.Log;


import com.carenx.fetosense.plus.bp.BPMonitorListener;
import com.carenx.fetosense.plus.bp.model.PairingDeviceData;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.DeviceConfiguration.OmronPeripheralManagerConfig;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.Interface.OmronPeripheralManagerConnectStateListener;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.Interface.OmronPeripheralManagerDataTransferListener;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.LibraryManager.OmronPeripheralManager;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.Model.OmronErrorInfo;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.Model.OmronPeripheral;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.OmronUtility.OmronConstants;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BPMonitorHelper {
    String TAG = "Vital => BPMonitorHelper";

    private String OMRON_PARTNER_KEY = "C4981517-E124-4159-A412-362C45381750";

/*
    //mp
    public static String LocalNameKey = "BLESmart_00000480EF66214013B0";//todo this need to fill from the firebase
    public static String uuidKey = "EF:66:21:40:13:B0";//todo this need to fill from the firebase
*/

/*
    //keshav
    public static String LocalNameKey = "BLESmart_00000480DFFDDFA4CF0E";//todo this need to fill from the firebase
    public static String uuidKey = "DF:FD:DF:A4:CF:0E";//todo this need to fill from the firebase*/


    //public static String LocalNameKey = "";//todo this need to fill from the firebase
    //public static String uuidKey = "";//todo this need to fill from the firebase

    protected Activity activity;
    protected BPMonitorListener bpMonitorListener;
    private Map<String, String> device = new HashMap<>();

    private OmronPeripheral mSelectedPeripheral;
    private List<Integer> selectedUsers = new ArrayList<>();

    private final Integer connectStatus_Idle = 0;
    private final Integer connectStatus_Scanning = 1;
    private final Integer connectStatus_Connecting = 2;
    private Integer connectStatus = connectStatus_Idle;
    private boolean isReceiverRegistered = false;

    private static final String STR_CONNECTING = "Connecting...";

    private Handler handler;
    private Runnable periodicTask;
    private final long timerDelay = 1000 * 30;//30seconds

    public BPMonitorHelper(Activity activity, BPMonitorListener bpMonitorListener,String localNameKey,String uuidKey) {
        Log.i("BPMonitorListener",localNameKey + uuidKey);

        OmronPeripheralManager.sharedManager(activity).setAPIKey(OMRON_PARTNER_KEY, null);
        this.activity = activity;
        this.bpMonitorListener = bpMonitorListener;
        setDeviceConfig(localNameKey,uuidKey);

        String user = device.get(Constants.deviceInfoKeys.KEY_SELECTED_USER);
        if (user != null) {
            selectedUsers.add(Integer.parseInt(user));
        }
        mSelectedPeripheral = PairingDeviceData.changePeripheralObject(device);
        if(bpMonitorListener != null){
            bpMonitorListener.onDeviceInfo(mSelectedPeripheral.getLocalName(),mSelectedPeripheral.getUuid());
        }
        //startTimer();
    }

    private void setDeviceConfig(String localNameKey, String uuidKey) {

        device.put("LocalNameKey", localNameKey);
        device.put("uuidKey", uuidKey);
        device.put("category", "0");
        device.put("selectedUserKey", "1");
    }

    // Data transfer with multiple users
    public void transferUsersDataWithPeripheral(final boolean isHistoricDataRead) {
        startOmronPeripheralManager(isHistoricDataRead);
        Log.i("EventChannel","transferUsersDataWithPeripheral");

        // Set State Change Listener
        setStateChanges();
        connectStatus = connectStatus_Scanning;
        OmronPeripheralManager.sharedManager(activity.getApplicationContext()).startDataTransferFromPeripheral(mSelectedPeripheral, selectedUsers, true, new OmronPeripheralManagerDataTransferListener() {
            @Override
            public void onDataTransferCompleted(OmronPeripheral peripheral, final OmronErrorInfo resultInfo) {
                if (resultInfo.isSuccess() && peripheral != null) {
                    mSelectedPeripheral = peripheral; // Saving for Transfer Function
                    OmronPeripheralManager.sharedManager(activity.getApplicationContext()).endDataTransferFromPeripheral((peripheral1, resultInfo2) -> {
                        if (resultInfo2.isSuccess() && peripheral1 != null) {
                            ArrayList<HashMap<String, Object>> vitalDataList = null;
                            HashMap<String, Object> vitalData = (HashMap<String, Object>) peripheral1.getVitalData();
                            if (vitalData != null) {
                                vitalDataList = (ArrayList<HashMap<String, Object>>) vitalData.get(OmronConstants.OMRONVitalDataBloodPressureKey);
                            }
                            showVitalDataResult(vitalDataList);
                        }
                    });
                } else {
                    bpMonitorListener.onError(resultInfo.getDetailInfo(), resultInfo.getMessageInfo());
                    Log.d(TAG,"onError info :: " + resultInfo.getDetailInfo() + " :: message :: " + resultInfo.getMessageInfo());
                }
            }

        });
    }

    private void startOmronPeripheralManager(boolean isHistoricDataRead) {

        OmronPeripheralManagerConfig peripheralConfig = OmronPeripheralManager.sharedManager(activity.getApplicationContext()).getConfiguration();
        Log.d(TAG, "Library Identifier : " + peripheralConfig.getLibraryIdentifier());

        // Filter device to scan and connect (optional)
        if (device != null && device.get(OmronConstants.OMRONBLEConfigDevice.GroupID) != null && device.get(OmronConstants.OMRONBLEConfigDevice.GroupIncludedGroupID) != null) {
            // Add item
            List<HashMap<String, String>> filterDevices = new ArrayList<>();
            filterDevices.add((HashMap<String, String>) device);
            peripheralConfig.deviceFilters = filterDevices;
        }

        ArrayList<HashMap> deviceSettings = new ArrayList<>();

        // Personal device settings (optional)
        deviceSettings = (ArrayList<HashMap>) getPersonalSettings(deviceSettings);

        // Scan settings (optional)
        deviceSettings = (ArrayList<HashMap>) getScanSettings(deviceSettings);

        peripheralConfig.deviceSettings = deviceSettings;
        // Set Scan timeout interval (optional)
        peripheralConfig.timeoutInterval = Constants.CONNECTION_TIMEOUT;
        // Set User Hash Id (mandatory)
        peripheralConfig.userHashId = "<email_address_of_user>"; // Set logged in user email
        // Disclaimer: Read definition before usage
        peripheralConfig.enableAllDataRead = isHistoricDataRead;
        // Set configuration for OmronPeripheralManager
        OmronPeripheralManager.sharedManager(activity.getApplicationContext()).setConfiguration(peripheralConfig);

        //Initialize the connection process.
        OmronPeripheralManager.sharedManager(activity.getApplicationContext()).startManager();

        // Notification Listener for BLE State Change
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(mMessageReceiver,
                    new IntentFilter(OmronConstants.OMRONBLEBluetoothStateNotification), RECEIVER_NOT_EXPORTED);
        } else {
            activity.registerReceiver(mMessageReceiver,
                    new IntentFilter(OmronConstants.OMRONBLEBluetoothStateNotification));
        }
        //Track instances of BroadcastReceiver.
        isReceiverRegistered = true;
    }

    private final BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            // Get extra data included in the Intent
            int status = intent.getIntExtra(OmronConstants.OMRONBLEBluetoothStateKey, 0);
            if (status == OmronConstants.OMRONBLEBluetoothState.OMRONBLEBluetoothStateUnknown) {
                Log.d(TAG, "Bluetooth is in unknown state");
            } else if (status == OmronConstants.OMRONBLEBluetoothState.OMRONBLEBluetoothStateOff) {
                Log.d(TAG, "Bluetooth is currently powered off");
            } else if (status == OmronConstants.OMRONBLEBluetoothState.OMRONBLEBluetoothStateOn) {
                Log.d(TAG, "Bluetooth is currently powered on");
            }
        }
    };

    private List<HashMap> getPersonalSettings(List<HashMap> deviceSettings) {
        HashMap<String, Object> bloodPressurePersonalSettings = new HashMap<>();
        HashMap<String, Object> settings = new HashMap<>();
        settings.put(OmronConstants.OMRONDevicePersonalSettings.BloodPressureKey, bloodPressurePersonalSettings);
        //settings.put(OmronConstants.OMRONDevicePersonalSettings.UserDateOfBirthKey, personalData.getBirthdayNum());
        HashMap<String, HashMap> _personalSettings = new HashMap<>();
        _personalSettings.put(OmronConstants.OMRONDevicePersonalSettingsKey, settings);

        // Personal settings for device
        deviceSettings.add(_personalSettings);
        return deviceSettings;
    }

    private List<HashMap> getScanSettings(List<HashMap> deviceSettings) {

        // Scan Settings
        HashMap<String, Object> ScanModeSettings = new HashMap<>();
        HashMap<String, HashMap> ScanSettings = new HashMap<>();
        ScanModeSettings.put(OmronConstants.OMRONDeviceScanSettings.ModeKey, OmronConstants.OMRONDeviceScanSettingsMode.MismatchSequence);
        ScanSettings.put(OmronConstants.OMRONDeviceScanSettingsKey, ScanModeSettings);

        deviceSettings.add(ScanSettings);

        return deviceSettings;
    }

    private void setStateChanges() {
        // Listen to Device state changes using OmronPeripheralManager
        OmronPeripheralManager.sharedManager(activity.getApplicationContext()).onConnectStateChange(new OmronPeripheralManagerConnectStateListener() {

            @Override
            public void onConnectStateChange(final int state) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        String status = "-";
                        if (state == OmronConstants.OMRONBLEConnectionState.CONNECTING) {
                            connectStatus = connectStatus_Connecting;
                            status = STR_CONNECTING;
                        } else if (state == OmronConstants.OMRONBLEConnectionState.CONNECTED) {
                            status = "Connected";
                        } else if (state == OmronConstants.OMRONBLEConnectionState.DISCONNECTING) {
                            connectStatus = connectStatus_Idle;
                            status = "Disconnecting...";
                        } else if (state == OmronConstants.OMRONBLEConnectionState.DISCONNECTED) {
                            status = "Disconnected";
                            //enableDisableButton(true);
                        }
                        Log.d(TAG, "onUpdateStatus status :: " + status);
                        bpMonitorListener.onUpdateStatus(status);
                    }});

            }
        });
    }


    private void showVitalDataResult(final List<HashMap<String, Object>> vitalData) {

        //bpMonitorListener.onResetResult();
        Log.d(TAG,"onResetResult "+vitalData.toString());
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (vitalData.size() == 0) {
                    bpMonitorListener.noRecordTransferred("No New readings transferred");
                    Log.d(TAG, "noRecordTransferred no data");
                } else {
                    HashMap<String, Object> vitalDataItem = vitalData.get(vitalData.size() - 1);

                    Calendar calendar = Calendar.getInstance();
                    calendar.setTimeInMillis((Long) vitalDataItem.get(OmronConstants.OMRONVitalData.StartDateKey));
                    String systolicKey = getValue(vitalDataItem, OmronConstants.OMRONVitalData.SystolicKey, "");
                    String diastolicKey = getValue(vitalDataItem, OmronConstants.OMRONVitalData.DiastolicKey, "");
                    String pulseKey = getValue(vitalDataItem, OmronConstants.OMRONVitalData.PulseKey, "");

                    bpMonitorListener.onDataReceived(calendar, systolicKey, diastolicKey, pulseKey);
                    Log.d(TAG, "onDataReceived calendar :: " + calendar + " :: systolicKey :: " + systolicKey + " :: diastolicKey :: " + diastolicKey + " :: pulseKey :: " + pulseKey);
                }
            }});

    }

    private String getValue(Map<String, Object> dataList, String key, String addText) {
        Object objectData = dataList.get(key);
        if (objectData != null) {
            return objectData + addText;
        }
        return "";
    }

    /*private void startTimer() {
        handler = new Handler();
        periodicTask = new Runnable() {
            @Override
            public void run() {
                Log.d("startTimer", "startTimer :: startTimer :: startTimer");
                transferUsersDataWithPeripheral(false);
                Log.d("startTimer", "startTimer");

                // Re-schedule the task to run again after 1 minute
                handler.postDelayed(this, timerDelay);
            }
        };

        // Schedule the task to run the first time after a short delay
        handler.postDelayed(periodicTask, 3000);
    }*/

    public void onDestroy() {
        if (isReceiverRegistered) {
            activity.unregisterReceiver(mMessageReceiver);
        }

        if (handler != null && periodicTask != null) {
            handler.removeCallbacks(periodicTask);
        }
    }
}
