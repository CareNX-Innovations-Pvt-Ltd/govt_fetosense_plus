package com.carenx.fetosense.plus.bp;

import java.util.Calendar;

/**
 * interface for parameters changed.
 */
public interface BPMonitorListener {

    void onError(String detailInfo, String messageInfo);

    void onUpdateStatus(String status);

    void onResetResult();


    void noRecordTransferred(String no_new_readings_transferred);

    void onDataReceived(Calendar calendar, String systolicKey, String diastolicKey, String pulseKey);
    void onDeviceInfo(String deviceLocalName,String deviceUUID);
}