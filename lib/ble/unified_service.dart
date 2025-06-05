import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:l8fe/ble/base_bluetooth_service.dart';

import 'package:l8fe/ble/bluetooth_service_helper.dart';
import 'package:l8fe/utils/fhr_data.dart';

import 'bluetooth_ctg_service.dart';

class UnifiedBluetoothService implements BaseBluetoothService {
  static final UnifiedBluetoothService _instance =
      UnifiedBluetoothService._internal();

  factory UnifiedBluetoothService() => _instance;

  UnifiedBluetoothService._internal();

  BaseBluetoothService? _activeService;
  StreamSubscription<FhrData?>? _dataSubscription;

  // Add ValueNotifier to track the currently connected device
  ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  bool _isBLEDevice(String deviceName) {
    final upper = deviceName.toUpperCase();
    return upper.contains("L8") || upper.contains("L8T32B");
  }


  BluetoothCharacteristic? get readChar {
    if (_activeService is BluetoothCTGService) {
      return (_activeService as BluetoothCTGService).readChar;
    }
    return null;
  }

  BluetoothCharacteristic? get writeChar {
    if (_activeService is BluetoothCTGService) {
      return (_activeService as BluetoothCTGService).writeChar;
    }
    return null;
  }


  @override
  Future<void> connect(dynamic device) async {
    if (_isBLEDevice(device.deviceName)) {
      _activeService = BluetoothCTGService.instance;
      _activeService?.connect(device);
    } else {
      BluetoothSerialService bluetoothService = BluetoothSerialService();
      List<serial.BluetoothDevice> devices = await bluetoothService
          .getPairedDevices();
      print("Paired devices: ${devices.length}");
      if (devices.isNotEmpty) {
        final matched = devices.firstWhere(
              (d) => d.name?.toLowerCase().contains('efm') ?? false,
          orElse: () =>
          throw Exception("Matching serial device with 'eFM' not found"),
        );
        device = matched;
      }
      _activeService = BluetoothSerialService();
      await _activeService?.connect(device);
      _dataSubscription = _activeService?.dataStream.listen(
            (data) {
              isConnectedNotifier.value = true;
        },
        onError: (error) {
          print("Error in data stream: $error");
          isConnectedNotifier.value = false;
        },
        onDone: () {
          print("Data stream closed");
          isConnectedNotifier.value = false;
        },
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await _activeService?.disconnect();
    _dataSubscription?.cancel();
    _dataSubscription = null;
    isConnectedNotifier.value = false;
  }

  @override
  Stream<FhrData?> get dataStream =>
      _activeService?.dataStream ?? const Stream.empty();
}
