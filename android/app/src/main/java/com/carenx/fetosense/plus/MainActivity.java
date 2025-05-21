package com.carenx.fetosense.plus;

import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;

import com.carenx.fetosense.plus.bp.BPMonitorHelper;
import com.carenx.fetosense.plus.bp.BPMonitorListener;
import com.carenx.fetosense.plus.bp.BPScanActivity;
import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.LibraryManager.OmronPeripheralManager;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements BPMonitorListener {
    private BPMonitorHelper bpMonitorHelper;
    private EventChannel.EventSink eventSink ;
    private String inputPartnerKey = "C4981517-E124-4159-A412-362C45381750";

    //keshav
    public static String LOCALNAMEKEY = "BLESmart_00000480DFFDDFA4CF0E";//todo this need to fill from the firebase
    public static String UUIDKEY = "DF:FD:DF:A4:CF:0E";//todo this need to fill from the firebase*/
    SharedPreferences preferences;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        preferences = getSharedPreferences("preferences", MODE_PRIVATE);

        GeneratedPluginRegistrant.registerWith(flutterEngine); // add this line
        initChannel(flutterEngine);
        super.configureFlutterEngine(flutterEngine);
    }

    private void initChannel(FlutterEngine flutterEngine) {
        OmronPeripheralManager.sharedManager(this).setAPIKey(inputPartnerKey, null);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.carenx.app/callback")
                .setMethodCallHandler((methodCall, result) -> {
                    if ("sendToBackground".equals(methodCall.method)) {
                        moveTaskToBack(true);
                        result.success(true);
                    }else if("startBpBle".equals(methodCall.method)){
                        initBPMonitor();
                    }else if("startBpBleTransfer".equals(methodCall.method)){
                        bpMonitorHelper.transferUsersDataWithPeripheral(true);
                    }else if("startBpBleScan".equals(methodCall.method)){
                        final Intent toScan = new Intent(MainActivity.this, BPScanActivity.class);
                        startActivityForResult(toScan,10292);
                        //bpMonitorHelper.transferUsersDataWithPeripheral(true);
                    }
                });


        // Event Channel
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.carenx.app/bpEvent")
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                        // Send an initial event if needed
                        Log.i("EventChannel","onListen");
                        if (eventSink != null) {
                            Map<String, Object> eventData = new HashMap<>();
                            eventData.put("type", 1);
                            eventData.put("status", "Event Channel Initialized");
                            eventSink.success(eventData);
                        }
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;
                    }
                });
    }

    void initBPMonitor() {
        Log.i("EventChannel","initBPMonitor");
        String localNameKey = preferences.getString("localNameKey","localNameKey");
        String uuidKey = preferences.getString("uuidKey","uuidKey");

        Log.i("initBPMonitor",localNameKey + uuidKey);
        if(bpMonitorHelper!=null)return;
        bpMonitorHelper = new BPMonitorHelper(getActivity(), this,localNameKey,uuidKey);
        //bpMonitorHelper.transferUsersDataWithPeripheral(true);
    }

    @Override
    public void onDestroy() {
        if (bpMonitorHelper != null) {
            bpMonitorHelper.onDestroy();
        }

        super.onDestroy();
    }

    @Override
    public void onError(String detailInfo, String messageInfo) {
        Log.i("EventChannel","onError");

        if(eventSink==null)return;
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 100);
        eventData.put("status", messageInfo);
        eventSink.success(eventData);
    }

    @Override
    public void onUpdateStatus(String status) {
        Log.i("EventChannel","onUpdateStatus");

        if(eventSink==null)return;
        // Creating the map data to send
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 100);
        eventData.put("status", status);
        if (status == "Connected") {
            bpMonitorHelper.transferUsersDataWithPeripheral(true);
        }
        eventSink.success(eventData);

    }

    @Override
    public void onResetResult() {
        Log.i("EventChannel","onResetResult");

        if(eventSink==null)return;
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 100);
        eventData.put("status", "0");
        eventSink.success(eventData);

    }

    @Override
    public void noRecordTransferred(String no_new_readings_transferred) {
        Log.i("EventChannel","noRecordTransferred");

        if(eventSink==null)return;
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 500);
        eventData.put("status", "0");
        eventSink.success(eventData);
    }

    @Override
    public void onDataReceived(Calendar calendar, String systolicKey, String diastolicKey, String pulseKey) {
        Log.i("EventChannel","onDataReceived");

        if(eventSink==null)return;
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 200);
        eventData.put("diastolicKey", diastolicKey);
        eventData.put("systolicKey", systolicKey);
        eventData.put("pulseKey", pulseKey);
        eventData.put("timeKey", calendar.getTimeInMillis());
        eventSink.success(eventData);
    }

    @Override
    public void onDeviceInfo(String deviceLocalName, String deviceUUID) {
        Log.i("EventChannel","onDeviceInfo");

        if(eventSink==null)return;
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("type", 400);
        eventData.put("info", deviceLocalName+" "+deviceUUID);
        eventSink.success(eventData);
    }
}
