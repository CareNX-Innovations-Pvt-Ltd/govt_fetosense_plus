import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSPo2Service {
  late BluetoothDevice device;
  //bool pulseOximeterFound = false;
  late List<BluetoothService> services;
  late BluetoothService pulseOximeterService;
  bool foundPulseOximeterService = false;
  late BluetoothService pulseRateService;
  bool foundPulseRateService = false;
  late BluetoothCharacteristic pulseOximeterChar;
  //late BluetoothCharacteristic pulseRateChar;
  //bool deviceReady = false;
  bool serviceAvailable = false;
  StreamSubscription<List<int>>? dataListener;

  ValueNotifier<bool> pulseOximeterFound = ValueNotifier(false);
  ValueNotifier<bool> deviceReady = ValueNotifier(false);

  final StreamController<List<int>> _streamController = StreamController.broadcast();
  late Stream<List<int>> _broadcastStream;

  List<int> spo2Data = [];

  int _heartRate = 0;

  int _SpO2 = 0;
  double _pi = 0;

  BluetoothSPo2Service._();

  static final BluetoothSPo2Service _instance =
  BluetoothSPo2Service._();
  static BluetoothSPo2Service get instance => _instance;

  Future<BluetoothSPo2Service> startBlueToothService() async {
    serviceAvailable = true;// await FlutterBluePlus.adapterState.first;
    if (serviceAvailable) {
      await startBle();
      return this;
    } else {
      return this;
    }
  }

  Future<BluetoothSPo2Service> startBle() async {

    if(deviceReady.value){
      deviceReady.notifyListeners();
      return this;
    }
    _broadcastStream = _streamController.stream.asBroadcastStream();

    int countdown = 100;
    final devices = FlutterBluePlus.connectedDevices;
    for (BluetoothDevice d in devices) {
      debugPrint('BluetoothDevice = ${d.advName}');
      if (d.advName.toLowerCase().contains("sp001")) {
        device = d;
        //await device.connect();
        await Future.delayed(const Duration(seconds: 1));
        await discoverServicesBle();
        device.connectionState.listen((event) => listenToChange(event));
        pulseOximeterFound.value = true;
      }
    }
    if(pulseOximeterFound.value) {
      while (!deviceReady.value && countdown > 0) {
        await Future.delayed(const Duration(seconds: 1));
        countdown--;
        debugPrint('countdown = $countdown');
      }
      return this;
    }

    if(!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 100));
    }

    FlutterBluePlus.scanResults.listen((results) async {
      // Wait for list to build
      await Future.delayed(const Duration(seconds: 1));
      for (ScanResult r in results) {
        if (r.device.advName.toLowerCase().contains("sp001")) {
          device = r.device;
          await device.connect(autoConnect: true,mtu: null);
          await Future.delayed(const Duration(seconds: 1));
          pulseOximeterFound.value = true;
          device.connectionState.listen((event) => listenToChange(event));
          await discoverServicesBle();
          FlutterBluePlus.stopScan();
        }
      }
    });

    //int countdown = 100;
    while (!deviceReady.value && countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      countdown--;
      debugPrint('countdown = $countdown');
    }
    FlutterBluePlus.stopScan();
    return this;
  }

  bool checkUUID(Guid uuid, String serviceCode) {
    String uuidAsString = uuid.toString();
    return (uuidAsString.contains(serviceCode)) ? true : false;
  }

  Future<void> discoverServicesBle() async {
    try {
      if (pulseOximeterFound.value) {
        services = await device.discoverServices();
        await discoverCharacteristic();
      }
    }catch(ex){
      debugPrint(ex.toString());
    }
  }

  Future<void> discoverCharacteristic() async {
    if (services.isNotEmpty) {
      for (var element in services) {
        if (checkUUID(element.uuid, 'efe0') && !foundPulseOximeterService) {
          pulseOximeterService = element;
          foundPulseOximeterService = true;
          pulseRateService = element;
          foundPulseRateService = true;
          discoverPulseOximeterCharacteristicProperty(pulseOximeterService);
        }
       /* if (checkUUID(element.uuid, '180d') && !foundPulseRateService) {
          pulseRateService = element;
          foundPulseRateService = true;
          discoverPulseRateCharacteristicProperty(pulseRateService);
        }*/
      }
    }
    deviceReady.value = true;
  }

  void discoverPulseOximeterCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    for (var element in lc) {
      if (checkUUID(element.uuid, 'efe3')) {
        pulseOximeterChar = element;
        //pulseRateChar = element;
      }
    }
    pulseOximeterChar.setNotifyValue(true);
    dataListener?.cancel();
    dataListener= pulseOximeterChar.onValueReceived.listen((event){
      //=>debugPrint("data: ${event.toList()}"
      spo2Data = event;
      parseSpO2Data(event);
      _streamController.add(spo2Data);
    });
  }


  void listenToChange(BluetoothConnectionState state) {
    debugPrint("------- Sp02 BluetoothConnectionState test : ${state.name}-----");
    switch (state) {
      case BluetoothConnectionState.connected:
        debugPrint("------- Sp02 BluetoothConnectionState.connected-----");
        pulseOximeterFound.value = true;
        discoverServicesBle();
        device.requestMtu(100);
        deviceReady.notifyListeners();
        debugPrint("------- Sp02 BluetoothConnectionState.connected-----");
        break;
      case BluetoothConnectionState.disconnected:
        debugPrint("------- Sp02 BluetoothConnectionState test in disconnected : ${state.name}-----");
        _SpO2 = 0;
        _heartRate = 0;
        deviceReady.value = false;
        deviceReady.notifyListeners();
        pulseOximeterFound.value = false;
        break;
      case BluetoothConnectionState.connecting:
        break;
      case BluetoothConnectionState.disconnecting:
        break;
    }
  }
  /*void discoverPulseRateCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    lc.forEach((element) {
      if (checkUUID(element.uuid, '2a37')) {
        pulseRateChar = element;
      }
    });
  }*/

  List<dynamic> getSPo2Data() {
    debugPrint("getSPo2Data : $_SpO2, $_heartRate");
   return[_SpO2,_heartRate,_pi];
  }

  Stream<List<int>> streamSPo2Data() {
    return _broadcastStream.asBroadcastStream();
  }

  parseSpO2Data(List<int> event) async{
    if (event.isNotEmpty){
      int firstIndex = event[0];
      if (firstIndex == 18) {//spo2
        int spo2 = event[12]; // Spo2 value is at index 12
        double pi = event[14] / 10.0; // Spo2 value is at index 12
        //print("onCharacteristicChanged :: spo2 :: " + spo2 + " :: pi :: "+ pi);
        _pi = pi;
        _SpO2 = spo2;
      } else if (firstIndex == 10) {//pulse rate
        int pulseRate = event[12]; // pulse value is at index 12
        //print("onCharacteristicChanged :: pulseRate :: " + pulseRate);
        _heartRate = pulseRate;
        //dataChangeListener.pulseRate(pulseRate);
      }
      //_SpO2 = event[1].toDouble();
    }
  }

  void endBle() {
    device.disconnect();
  }
}
