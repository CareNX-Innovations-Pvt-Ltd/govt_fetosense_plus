
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:l8fe/utils/bluetooth_data.dart';
import 'package:synchronized/synchronized.dart';

class FhrByteDataBuffer
{
  static const int BUFFER_LENGTH = 1024;//4096;
  Uint8List buffer = Uint8List(BUFFER_LENGTH);
  int inIndex = 0;
  int outIndex = 0;
  int count = 0;
  var lock = Lock();

  FhrByteDataBuffer();

  Future<BluetoothData?> getBag() async {
    return lock.synchronized(() {
      BluetoothData? data;
      //debugPrint("--data length --- $inIndex --- $outIndex -- $count ");
      while(count > BluetoothData.BUFFER_SIZE && data==null) {
        if (count > BluetoothData.BUFFER_SIZE) {
          if (85 == testBuffer(outIndex) && 170 == testBuffer(outIndex + 1)) {
            final int offLen = BUFFER_LENGTH - outIndex;
            debugPrint("-- $offLen --- $count -- $inIndex -- $outIndex --");
            if (87 == testBuffer(outIndex + 2) &&
                10 == testBuffer(outIndex + 3)) {
              data = BluetoothData();
              data.dataType = DataType.TYPE_FHR;
              if (offLen >= BluetoothData.BUFFER_SIZE) {
                data.mValue.setRange(
                    0, BluetoothData.BUFFER_SIZE, buffer, outIndex);
                //System.arraycopy(buffer, outIndex, data.mValue, 0, 10);
                outIndex += BluetoothData.BUFFER_SIZE;
                outIndex %= BUFFER_LENGTH;
              }
              else {
                data.mValue.setRange(0, offLen, buffer, outIndex);
                //System.arraycopy(buffer, outIndex, data.mValue, 0, offLen);
                outIndex += offLen;
                outIndex %= BUFFER_LENGTH;
                data.mValue.setRange(
                    offLen, BluetoothData.BUFFER_SIZE - offLen, buffer, outIndex);
                //System.arraycopy(buffer, outIndex, data.mValue, offLen, 10 - offLen);
                outIndex += BluetoothData.BUFFER_SIZE - offLen;
                outIndex %= BUFFER_LENGTH;
              }
              count -= BluetoothData.BUFFER_SIZE;
            }
            else {
              outIndex += 2;
              outIndex %= BUFFER_LENGTH;
              count -= 2;
            }
          }
          else {
            --count;
            ++outIndex;
            if (outIndex >= BUFFER_LENGTH) {
              outIndex %= BUFFER_LENGTH;
            }
          }
        }
      }
      debugPrint("-------Data read ${data?.mValue.toList()} ----- $inIndex --- $outIndex -- $count ");
      return data;
    });
  }

  int testBuffer(int index) {
    index %= BUFFER_LENGTH;
    return buffer[index];
  }

  void addData(final int data) {
    buffer[inIndex] = data;
    ++inIndex;
    if (inIndex >= BUFFER_LENGTH) {
      inIndex = 0;
    }
    if (count <= BUFFER_LENGTH) {
      ++count;
    }
    else {
      ++outIndex;
      if (outIndex >= BUFFER_LENGTH) {
        outIndex = 0;
      }
    }
  }

  void addDataList(final List<int> data, final int startIndex, final int endIndex) async{
    return lock.synchronized(() {
      for (int len = (endIndex - startIndex), i = 0; i < len; ++i) {
        buffer[inIndex] = data[startIndex + i];
        ++inIndex;
        if (inIndex >= BUFFER_LENGTH) {
          inIndex = 0;
        }
        ++count;
        if (count <= BUFFER_LENGTH) {
          ++count;
        } else {
          ++outIndex;
          if (outIndex >= BUFFER_LENGTH) {
            outIndex = 0;
          }
        }
      }
      debugPrint("serial read $data ----$count, $inIndex, $outIndex");
    });
  }

  void clean() {
    inIndex = 0;
    outIndex = 0;
    count = 0;
  }

  Future<bool> canRead() {
    return lock.synchronized(() {
      return count > BluetoothData.BUFFER_SIZE;
    });
  }

}
