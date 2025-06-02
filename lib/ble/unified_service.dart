import 'package:flutter/material.dart';
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

  // Add ValueNotifier to track the currently connected device
  final ValueNotifier<dynamic> connectedDeviceNotifier = ValueNotifier(false);

  bool _isBLEDevice(String deviceName) {
    final upper = deviceName.toUpperCase();
    return upper.contains("L8") || upper.contains("L8T32B");
  }

  @override
  Future<void> connect(dynamic device) async {
    // Set the correct service based on device name
    if (_isBLEDevice(device.deviceName)) {
      _activeService = BluetoothCTGService.instance;
    } else {
      _activeService = BluetoothSerialService();
    }

    // Connect using the chosen service
    await _activeService?.connect(device);

    // Update the notifier
    connectedDeviceNotifier.value = true;
  }

  @override
  Future<void> disconnect() async {
    await _activeService?.disconnect();

    // Clear the notifier
    connectedDeviceNotifier.value = false;
  }

  @override
  Stream<FhrData?> get dataStream =>
      _activeService?.dataStream ?? const Stream.empty();
}
