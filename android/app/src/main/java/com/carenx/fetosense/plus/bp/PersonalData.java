package com.carenx.fetosense.plus.bp;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.database.Cursor;

import com.omronhealthcare.OmronConnectivityLibrary.OmronLibrary.OmronUtility.OmronConstants;

public class PersonalData {
    private boolean isDataExists = false;
    private int genderValue;
    private int unitValue;
    private String Height;
    private String Weight;
    private String Birthday;
    private int day;
    private int month;
    private int year;
    private String Stride;
    private ContentResolver contentResolver;

    public PersonalData(ContentResolver contentResolver){
        this.contentResolver = contentResolver;
    }
    public boolean isDataExists(){return isDataExists;}
    public int getUnitValue(){
        return unitValue;
    }
    public void setUnitValue(int value){
        unitValue = value;
    }
    public int getGenderValue(){
        return genderValue;
    }
    public void setGenderValue(int value){
        genderValue = value;
    }

    public String getHeight(){
        return Height;
    }
    public void setHeight(String value){
        Height = value;
    }

    public String getWeight(){
        return Weight;
    }
    public void setWeight(String value){
        Weight = value;
    }

    public String getStride(){
        return Stride;
    }
    public void setStride(String value){
        Stride = value;
    }

    public String getBirthday(){
        return Birthday;
    }
    public String getBirthdayNum(){
        String[] dateParts = Birthday.split("/");
        return dateParts[0] + dateParts[1] + dateParts[2];
    }
    public int getDay(){ return day; }
    public int getMonth(){ return month; }
    public int getYear(){ return year; }
    public void setBirthday(String value){
        String[] dateParts = value.split("/");
        year = Integer.parseInt(dateParts[0]);
        month = Integer.parseInt(dateParts[1]);
        day = Integer.parseInt(dateParts[2]);
        Birthday = value;
    }
    public void loadPersonalData() {
        String _setHeight = "170";
        String _setWeight = "70";
        String _setStride = "80";
        String _setBirthday = "2000/01/01";
        int _setGenderValue = OmronConstants.OMRONDevicePersonalSettingsUserGenderType.Female;
        int _setUnitValue = OmronConstants.OMRONDeviceWeightUnit.Kg;
        isDataExists = false;
        setHeight(_setHeight);
        setWeight(_setWeight);
        setStride(_setStride);
        setBirthday(_setBirthday);
        setGenderValue(_setGenderValue);
        setUnitValue(_setUnitValue);
    }
}
