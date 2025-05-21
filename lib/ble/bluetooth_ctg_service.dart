import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:l8fe/ble/bluetooth_spo2_service.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/utils/bluetooth_data.dart';
import 'package:l8fe/utils/fhr_data.dart';
import 'package:preferences/preference_service.dart';

class BluetoothCTGService {
  late BluetoothDevice device;
  late List<BluetoothService> services;
  bool foundCtgService = false;
  late BluetoothService ctgService;
  BluetoothCharacteristic? readChar;
  late BluetoothCharacteristic writeChar;
  bool serviceAvailable = false;
  StreamSubscription<List<int>>? dataListener;

  ValueNotifier<bool> ctgDeviceFound = ValueNotifier(false);
  ValueNotifier<bool> deviceReady = ValueNotifier(false);
  final StreamController<FhrData?> _streamController = StreamController.broadcast();
  late Stream<FhrData?> _broadcastStream;

  FhrData? fhrData;

  static  DateTime? lastBpDataTime;

  static Map<String,dynamic>? lastBpValue;

  BluetoothCTGService._();

  static final BluetoothCTGService _instance =
  BluetoothCTGService._();
  static BluetoothCTGService get instance => _instance;

  Future<BluetoothCTGService> startBlueToothService(Device user) async {
    serviceAvailable = true;// await FlutterBluePlus.adapterState.first;
    if (serviceAvailable) {
      await startBle(user);
      return this;
    } else {
      return this;
    }
  }

  Future<BluetoothCTGService> startBle(Device user) async {
    listenToNativeEvents();

    if(deviceReady.value) return this;
    _broadcastStream = _streamController.stream.asBroadcastStream();

    int countdown = 60;
    final devices = FlutterBluePlus.connectedDevices;
    for (BluetoothDevice bt in devices) {
      debugPrint('BluetoothDevice = ${bt.advName}');
      if (bt.platformName.toUpperCase().contains(user.deviceName) || (bt.platformName.toUpperCase().contains("L8T32B") && (user.testAccount || kDebugMode))) {
        device = bt;
        //await device.connect(); //await Future.delayed(Duration(seconds: 1));
        device.connectionState.listen((event) => listenToChange(event));
        ctgDeviceFound.value = true;
        await discoverServicesBle();
      }
    }
    if(ctgDeviceFound.value) {
      while (!deviceReady.value && countdown > 0) {
        await Future.delayed(const Duration(seconds: 1));
        countdown--;
        debugPrint('countdown = $countdown');
      }
      return this;
    }

    if(!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(/*timeout: const Duration(seconds: 100)*/);
    }

    FlutterBluePlus.scanResults.listen((results) async {
      // Wait for list to build
      await Future.delayed(const Duration(seconds: 1));
      for (ScanResult r in results) {
        debugPrint('BluetoothDevice = ${r.device.advName} testAccount :${user.testAccount} ${user.documentId}');
        if (r.device.platformName.toUpperCase().contains(user.deviceName) || (r.device.platformName.toUpperCase().contains("EFM60")||(r.device.platformName.toUpperCase().contains("L8T32B") )&& (user.testAccount || kDebugMode)) ) {
          device = r.device;
          await device.connect(autoConnect: true,mtu: null);
          await Future.delayed(const Duration(seconds: 1));
          ctgDeviceFound.value = true;
          await discoverServicesBle();
          device.connectionState.listen((event) => listenToChange(event));
          FlutterBluePlus.stopScan();
          debugPrint('BluetoothDevice = ${r.device.advName}');

        }
      }
    });

    //int countdown = 100;
    while (!deviceReady.value && countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      countdown--;
      debugPrint('countdown = $countdown');
    }
    return this;
  }

  bool checkUUID(Guid uuid, String serviceCode) {
    String uuidAsString = uuid.toString();
    return (uuidAsString.contains(serviceCode)) ? true : false;
  }

  Future<void> discoverServicesBle() async {
    try{
      if (ctgDeviceFound.value) {
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
        if (checkUUID(element.uuid, '0001') && !foundCtgService) {
          foundCtgService = true;
          ctgService = element;
          discoverReadWriteCharacteristicProperty(ctgService);
        }
      }
    }
    deviceReady.value = true;
  }

  Future<void> listenToChange(BluetoothConnectionState state) async {
    debugPrint("------- CTG BluetoothConnectionState test : ${state.name}-----");
    switch (state) {
      case BluetoothConnectionState.connected:
        debugPrint("------- CTG BluetoothConnectionState.connected-----");
        ctgDeviceFound.value = true;
        await discoverServicesBle();
        device.requestMtu(100);
        readChar?.setNotifyValue(true);
        deviceReady.notifyListeners();
        BluetoothSPo2Service.instance.startBle();
        debugPrint("------- CTG BluetoothConnectionState.connected-----");
        break;
      case BluetoothConnectionState.disconnected:
        debugPrint("------- CTG BluetoothConnectionState test in disconnected : ${state.name}-----");
        deviceReady.value = false;
        ctgDeviceFound.value = false;
        deviceReady.notifyListeners();
        break;
      case BluetoothConnectionState.connecting:
        break;
      case BluetoothConnectionState.disconnecting:
        break;
    }
  }

  void discoverReadWriteCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    for (var element in lc) {
      if (checkUUID(element.uuid, '0003')) {
        readChar = element;
        //pulseRateChar = element;
      }else if (checkUUID(element.uuid, '0002')) {
        writeChar = element;
        //pulseRateChar = element;
      }
    }
    readChar?.setNotifyValue(true);
    dataListener?.cancel();
    dataListener = readChar?.onValueReceived.listen((event)async {
      //=>debugPrint("data: ${event.toList()}"
      fhrData = await parseFHRData(event);
      _streamController.add(fhrData);
    });
  }

  void discoverWriteCharacteristicProperty(BluetoothService service) {
    List<BluetoothCharacteristic> lc = service.characteristics;
    for (var element in lc) {
      if (checkUUID(element.uuid, '2a37')) {
        writeChar = element;
      }
    }
  }

  Future<FhrData?> parseFHRData(List<int> event) async{
    //debugPrint("------ read complete at ${stopwatch.elapsed.inSeconds} -----${event.length}--");
    debugPrint("------ read  ${event.toList()}--");
    final fhr = await compute(get11bytes1, event);
    if(!(PrefService.getBool("hasFhr2")??true)) {//singleton mode remove fhr2
      fhr?.fhr2 = 0;
    }
    fhr?.mhr = BluetoothSPo2Service.instance.getSPo2Data()[1];
    fhr?.spo2 = BluetoothSPo2Service.instance.getSPo2Data()[0];
    fhr?.pi = BluetoothSPo2Service.instance.getSPo2Data()[2];
    if(lastBpDataTime!=null && DateTime.now().difference(lastBpDataTime!).inMinutes<10){
      fhr?.dia = int.tryParse(lastBpValue?["diastolicKey"].toString()??"0")??0;
      fhr?.sys = int.tryParse(lastBpValue?["systolicKey"].toString()??"0")??0;
      fhr?.pulse = int.tryParse(lastBpValue?["pulseKey"].toString()??"0")??0;
    }
    //fhrData = fhr;
    return fhr;
  }

  Stream<FhrData?> streamData() {
    return _broadcastStream.asBroadcastStream();
  }

  void endBle() {
    device.disconnect();
  }
  void fetchBpData(){
    const methodChannel = MethodChannel('com.carenx.app/callback');
    methodChannel.invokeMethod("startBpBleTransfer");
  }

  void listenToNativeEvents() {
    debugPrint('listenToNativeEvents');

    const methodChannel = MethodChannel('com.carenx.app/callback');
    methodChannel.invokeMethod("startBpBle");

    const eventChannel = EventChannel('com.carenx.app/bpEvent');

    eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        print('Status: ${event.toString()}');
        if(event["diastolicKey"]!=null){
          print('Status: receiveBroadcastStream ${event.toString()}');

          lastBpDataTime = DateTime.fromMillisecondsSinceEpoch(event["timeKey"]);
          debugPrint("fromMillisecondsSinceEpoch $lastBpDataTime");
          lastBpValue = Map<String,dynamic>.from(event);
          if(lastBpDataTime!=null && DateTime.now().difference(lastBpDataTime!).inMinutes<10){
            fhrData?.dia = int.tryParse(lastBpValue?["diastolicKey"].toString()??"0")??0;
            fhrData?.sys = int.tryParse(lastBpValue?["systolicKey"].toString()??"0")??0;
            fhrData?.pulse = int.tryParse(lastBpValue?["pulseKey"].toString()??"0")??0;
          }
          _streamController.add(fhrData);
        }
      }
    }, onError: (error) {
      print('Error receiving event: $error');
    });
  }
}

FhrData? get11bytes1(List<int> event) {
  FhrData? fhr;
  bool afm= false;
  bool fm = false;
  for (int i = 0; i < (1+event.length - BluetoothData.BUFFER_SIZE); i++) {
    if (85 == event[i] && 170 == event[i + 1]) {
      //debugPrint("-- $i --");
      if (87 == event[i + 2] && 10 == event[i + 3]) {
        final list = event.sublist(i,i+BluetoothData.BUFFER_SIZE);
        //debugPrint("test ${list[0]}, $list");
        fhr =FhrData.fromRaw(list);
        //debugPrint("-- ${fhr.toPrint()} --");
        if(fhr.fmFlag ==1 ){
          fm = true;
          debugPrint("-- found marker --");
        }
        if(fhr.afmFlag ==1 ){
          afm = true;
          debugPrint("-- found auto marker --");
        }
        i+=10;
      }
    }
  }
  fhr?.afmFlag = afm?1:0;
  fhr?.fmFlag = fm?1:0;
  return fhr;
}