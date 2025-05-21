import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BpScanView extends StatefulWidget {
  const BpScanView({super.key});

  @override
  State<BpScanView> createState() => _BpScanViewState();
}

class _BpScanViewState extends State<BpScanView> {
  static const platform = MethodChannel('com.carenx.fetosense.plus/bp');

  List<dynamic> _scannedDevices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  String _connectionStatus = "Disconnected";
  String _deviceInfo = "";

  @override
  void initState() {
    super.initState();
    _startOmronPeripheralManager();
  }

  Future<void> _startOmronPeripheralManager() async {
    try {
      await platform.invokeMethod('startOmronPeripheralManager');
      _startScan(); // Start scanning after manager is initialized
    } on PlatformException catch (e) {
      debugPrint("Error starting manager: '${e.message}'.");
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scannedDevices.clear(); // Clear previous scan results
    });

    try {
      final List<dynamic> devices = await platform.invokeMethod('startScan');
      setState(() {
        _scannedDevices = devices;
        _isScanning = false;
      });
    } on PlatformException catch (e) {
      debugPrint("Error scanning: '${e.message}'.");
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      await platform.invokeMethod('stopScan');
      setState(() {
        _isScanning = false;
      });
    } on PlatformException catch (e) {
      debugPrint("Error stopping scan: '${e.message}'.");
    }
  }

  Future<void> _connectDevice(String deviceIdentifier) async {
    setState(() {
      _isConnected = true;
      _connectionStatus = "Connecting...";
    });
    try {
      await platform.invokeMethod('connectDevice', {"identifier": deviceIdentifier});
      setState(() {
        _isConnected = true;
        _connectionStatus = "Connected";
        _deviceInfo = "Connected to: $deviceIdentifier"; // Or fetch more info
      });
    } on PlatformException catch (e) {
      debugPrint("Error connecting: '${e.message}'.");
      setState(() {
        _isConnected = false;
        _connectionStatus = "Connection Failed";
      });
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      await platform.invokeMethod('disconnectDevice');
      setState(() {
        _isConnected = false;
        _connectionStatus = "Disconnected";
        _deviceInfo = "";
      });
    } on PlatformException catch (e) {
      debugPrint("Error disconnecting: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BP Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connection Status: $_connectionStatus',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _deviceInfo,
              style: const TextStyle(fontSize: 14),
            ),
            const Text(
              'Scanned Devices:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scannedDevices.length,
                itemBuilder: (context, index) {
                  final device = _scannedDevices[index];
                  return ListTile(
                    title: Text(device['name'] ?? "Unknown Device"), // Display device name
                    subtitle: Text(device['identifier'] ?? "No Identifier"),
                    onTap: () => _connectDevice(device['identifier']),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
            ),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : null,
              child: const Text('Stop Scan'),
            ),
            ElevatedButton(
              onPressed: _isConnected ? _disconnectDevice : null,
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}