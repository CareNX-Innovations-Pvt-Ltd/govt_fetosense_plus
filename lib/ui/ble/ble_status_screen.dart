import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleStatusScreen extends StatelessWidget {
  const BleStatusScreen({required this.status, super.key});

  final BluetoothAdapterState status;

  String determineText(BluetoothAdapterState status) {
    switch (status) {
      case BluetoothAdapterState.unavailable:
        return "This device does not support Bluetooth";
      case BluetoothAdapterState.unauthorized:
        permissions();
        return "Authorize the Pulmonator app to use Bluetooth and location";
      case BluetoothAdapterState.off:
        return "Bluetooth is powered off on your device turn it on";
      case BluetoothAdapterState.unknown:
        return "Please Wait...";
      case BluetoothAdapterState.on:
        return "Bluetooth is up and running";
      default:
        return "Waiting to fetch Bluetooth status $status";
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(determineText(status),
          style: const TextStyle(
        fontFamily: 'Barlow',
        fontWeight: FontWeight.w400,
        fontSize: 24,
        color: Colors.white54,
      )),
    ),
  );

  void permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.location,
    ].request();
  }
}
