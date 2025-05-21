
import 'dart:typed_data';

import 'package:l8fe/utils/bluetooth_data.dart';

class FhrData
{
  int fhr1 = 0;
  int fhr2 = 0;
  int mhr = 0;
  int dia = 0;
  int sys = 0;
  int pulse = 0;
  int spo2 = 0;
  double pi = 0;
  int toco = 0;
  int afm = 0;
  int fhrSignal = 0;
  int afmFlag = 0;
  int fmFlag = 0;
  int tocoFlag = 0;
  int docFlag = 0;
  int devicePower = 0;
  int isHaveFhr1 = 0;
  int isHaveFhr2 = 0;
  int isHaveToco = 0;
  int isHaveAfm = 0;

  FhrData();
  FhrData.fromRaw(List<int> data){
    fhr1 = (data[4] & 0xFF);
    fhr2 = (data[5] & 0xFF);
    toco = data[6];
    afm = data[7];
    fhrSignal = (data[8] & 0x3);
    fmFlag = (((data[8] & 0x10) != 0x0) ? 1 : 0);
    afmFlag = (((data[8] & 0x8) != 0x0) ? 1 : 0);
    devicePower = (data[9] & 0xF);
    isHaveFhr1 = (((data[9] & 0x10) != 0x0) ? 1 : 0);
    isHaveFhr2 = (((data[9] & 0x20) != 0x0) ? 1 : 0);
    isHaveToco = (((data[8] & 0x40) != 0x0) ? 1 : 0);
    isHaveAfm = (((data[9] & 0x80) != 0x0) ? 1 : 0);
    docFlag = data[10];
  }
  FhrData.fromData(BluetoothData data){
    fhr1 = (data.mValue[4] & 0xFF);
    fhr2 = (data.mValue[5] & 0xFF);
    toco = data.mValue[6];
    afm = data.mValue[7];
    fhrSignal = (data.mValue[8] & 0x3);
    fmFlag = (((data.mValue[8] & 0x10) != 0x0) ? 1 : 0);
    afmFlag = (((data.mValue[8] & 0x8) != 0x0) ? 1 : 0);
    devicePower = (data.mValue[9] & 0xF);
    isHaveFhr1 = (((data.mValue[9] & 0x10) != 0x0) ? 1 : 0);
    isHaveFhr2 = (((data.mValue[9] & 0x20) != 0x0) ? 1 : 0);
    isHaveToco = (((data.mValue[8] & 0x40) != 0x0) ? 1 : 0);
    isHaveAfm = (((data.mValue[9] & 0x80) != 0x0) ? 1 : 0);
    docFlag = data.mValue[10];
  }


  String toPrint(){
    return  "FHR1: $fhr1 FHR2: $fhr2 TOCO: $toco fm: $fmFlag amf: $afmFlag docFlag: $docFlag isHaveFhr1: $isHaveFhr1 isHaveFhr2:$isHaveFhr2 isHaveToco:$isHaveToco isHaveAfm: $isHaveAfm";
  }
}
