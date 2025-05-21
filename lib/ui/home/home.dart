import 'dart:async';

import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/ble/bluetooth_spo2_service.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/constants/app_constant.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/ui/dialogs/save_mother_dailog.dart';
import 'package:l8fe/ui/home/device_list.dart';
import 'package:l8fe/ui/home/home_view.dart';
import 'package:l8fe/ui/home/organization_home.dart';
import 'package:l8fe/ui/home/recent_mothers_view.dart';
import 'package:l8fe/ui/home/recent_test_view.dart';
import 'package:l8fe/ui/home/settings_view.dart';
import 'package:l8fe/ui/test_view.dart';
import 'package:l8fe/ui/widgets/circle_icon_button.dart';
import 'package:l8fe/utils/bluetooth_data.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:l8fe/utils/fhr_command_maker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tab_container/tab_container.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/firestore_database.dart';
import '../../utils/fhr_data.dart';
//const String DEVICE_NAME = "L8T32B2019120011";
//const String DEVICE_NAME =  "L8T32B2021010004";

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();

}
class HomeState extends State<Home>
    with SingleTickerProviderStateMixin{
  String query = "*";
  final FocusNode _focus = FocusNode();
  final searchController = TextEditingController();
  final ActionSliderController _actionController = ActionSliderController();
  late final TabController _tabContainerController;
  final PageController _pageController = PageController();
  bool deviceFound = false;
  bool deviceSpO2Found = false;
  late SharedPreferences prefs;
  Timer? _timer;

  //StreamSubscription<ConnectionStateUpdate>? changeSub;
  //String? btDevice2;
  //String? btDeviceSPo2;

  BluetoothData? bluetoothData;
  BluetoothCharacteristic? writeChar;
  BluetoothCharacteristic? readChar;


  BluetoothCharacteristic? readCharSpO2;

  int tCount = 0;

  late StreamSubscription<List<ScanResult>> scanSubscription;

  BluetoothDevice? btDevice;
  BluetoothDevice? btDeviceSPo2;

  //late Stopwatch stopwatch;

  int _pageIndex = 0;

  late final Device user;

  late final List<Widget> tabChildren;

  @override
  void initState() {
    super.initState();
    //listenToChange();
    WakelockPlus.enable();
    prefs = context.read<SharedPreferences>();
    _tabContainerController = TabController(vsync: this, length: 5);
    //setBt();
    _tabContainerController.addListener(() {
      if(_tabContainerController.index == 0){
        debugPrint("start setNotifyValue true");
        //if(deviceFound) readChar?.setNotifyValue(true);
      }else{
        debugPrint("stop setNotifyValue false ${_tabContainerController.index}");
        //if(deviceFound) readChar?.setNotifyValue(false);
      }
      _pageIndex = _tabContainerController.index;
      _pageController.jumpToPage(_pageIndex);
      //FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_PROMPT);
      if(mounted){
        setState(() {

        });
      }
    });
    user = context.read<SessionCubit>().currentUser.value!;

    tabChildren = getChildren();
    initBt();
    BluetoothCTGService.instance.startBle(user);

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BluetoothSPo2Service.instance.deviceReady.notifyListeners();
    BluetoothCTGService.instance.deviceReady.notifyListeners();

  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    //dataListener?.cancel();
    //dataListenerSpO2?.cancel();
    _timer?.cancel();
    //scanSubscription.cancel();
    //_focus.dispose();
  }

  @override
  void deactivate() {
    debugPrint('deactivate');
    super.deactivate();
  }

  @override
  void activate() {
    debugPrint('activate');
    super.activate();
  }

  /*void listenToChange(BluetoothConnectionState state) {
    debugPrint("-------BluetoothConnectionState : ${state.name}-----");
      switch (state) {
        case BluetoothConnectionState.connected:
          debugPrint("-------BluetoothConnectionState.connected-----");
          deviceFound = true;
          btDevice?.requestMtu(100);
          //discoverServices();
          FlutterBluePlus.stopScan();
          Future.delayed(const Duration(seconds: 2),() {
            if (mounted) {
              setState(() {});
            }
          });
          debugPrint("-------BluetoothConnectionState.connected-----");
          break;
        case BluetoothConnectionState.disconnected:
          deviceFound = false;
          btDevice = null;
          if(mounted) {
            setState(() {});
          }
          break;
        case BluetoothConnectionState.connecting:
          break;
        case BluetoothConnectionState.disconnecting:
          break;
      }
  }

  void listenToChangeSpO2(BluetoothConnectionState state) {
    debugPrint("-------BluetoothConnectionState SPo2: ${state.name}-----");
    switch (state) {
      case BluetoothConnectionState.connected:
        debugPrint("-------BluetoothConnectionState.connected-----");
        deviceSpO2Found = true;
        //btDeviceSPo2?.requestMtu(100);
        //discoverServicesSpO2();
        Future.delayed(const Duration(seconds: 2),() {
          if (mounted) {
            setState(() {});
          }
        });
        debugPrint("-------BluetoothConnectionState.connected-----");
        break;
      case BluetoothConnectionState.disconnected:
        deviceSpO2Found = false;
        btDeviceSPo2 = null;
        if(mounted) {
          setState(() {});
        }
        break;
      case BluetoothConnectionState.connecting:
        break;
      case BluetoothConnectionState.disconnecting:
        break;
    }
  }*/

  ///Start the timer.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500), (Timer timer) {
      //updateValuesFromBT();
      /*if(bluetoothData!=null) {
        fhrData = FhrData.fromRaw(bluetoothData!);
      }*/

    },
    );
  }

  /*Future<void> setBt() async {
    //final scannerState = context.read<BleScannerState>();
    *//*final scanner = context.read<BleScanner>();
    final connector = context.read<BleDeviceConnector>();
    final scannerState = context.read<BleScannerState>();*//*
    //FlutterReactiveBle ble =  context.read<FlutterReactiveBle>();
    bool found = false;
    final devices = FlutterBluePlus.connectedDevices;
    if (devices.isNotEmpty) {
      for (BluetoothDevice bt in devices) {
        debugPrint("-------BluetoothDevice in connectedDevices ${bt.platformName}-----");
        if (bt.platformName.toUpperCase().contains(user.deviceName) || (bt.platformName.toUpperCase().contains("L8T32B") && user.testAccount)) {
          debugPrint("-------${user.deviceName} in connectedDevices BluetoothDevice-----");
          //btDevice2 = bt.remoteId.str;
          found = true;
          deviceFound = true;
          btDevice = bt;
          bt.connectionState.listen((event) =>listenToChange(event));
          discoverServices();
          //if(btDeviceSPo2!=null) {
            FlutterBluePlus.stopScan();
          //}
          //FlutterBluePlus.cancelWhenScanComplete(scanSubscription);

        }
        *//*if (bt.platformName.toUpperCase().contains("SP001") || (bt.platformName.toUpperCase().contains("SP001") && user.testAccount)) {
          debugPrint("-------SP001 in connectedDevices BluetoothDevice-----");
          //btDeviceSPo2 = bt.remoteId.str;
          deviceSpO2Found = true;
          btDeviceSPo2 = bt;
          bt.connectionState.listen((event) =>listenToChangeSpO2(event));
          discoverServicesSpO2();
          if(btDevice!=null) {
            FlutterBluePlus.stopScan();
          }
        }*//*
      }
    }

    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning
    // Use: `scanResults` if you want live scan results *or* the results from a previous scan
    scanSubscription = FlutterBluePlus.onScanResults.listen((devices) {
      if (devices.isNotEmpty) {
        ScanResult r = devices.last; // the most recently found device
        //print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        if (devices.isNotEmpty) {
          for (ScanResult bt in devices) {
            debugPrint("-------BluetoothDevice in onScanResults ${bt.device.platformName}-----");
            if (bt.device.platformName.toUpperCase().contains(user.deviceName) || (bt.device.platformName.toUpperCase().contains("L8T32B") && user.testAccount)) {
              debugPrint("-------${user.deviceName} in onScanResults BluetoothDevice-----");
              //btDevice2 = bt.device.remoteId.str;
              btDevice = bt.device;
              //connector.connect(bt.device.id.toString());
              bt.device.connectionState.listen((event) => listenToChange(event));
              bt.device.connect(autoConnect: true,mtu: null);
              if(btDeviceSPo2!=null)FlutterBluePlus.stopScan();
              found = true;
              deviceFound = true;
              //FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
              //discoverServices();
            }

            *//*if (bt.device.platformName.toUpperCase().contains("SP001") || (bt.device.platformName.toUpperCase().contains("SP001") && user.testAccount)) {
              debugPrint("-------SP001 in onScanResults BluetoothDevice-----");
              //btDeviceSPo2 = bt.remoteId.str;
              btDeviceSPo2 = bt.device;
              bt.device.connectionState.listen((event) =>listenToChangeSpO2(event));
              bt.device.connect(autoConnect: true,mtu: null);
              deviceSpO2Found = true;
              //discoverServicesSpO2();

            }*//*
          }
        }
      }
    },
      onError: (e) => debugPrint(e),
    );

    if (!found) {
      FlutterBluePlus.startScan();
    }
    if (mounted) {
      setState(() {});
    }
  }*/

  initBt(){
    BluetoothCTGService.instance.deviceReady.addListener(() async {
      deviceFound = BluetoothCTGService.instance.deviceReady.value;
      if (BluetoothCTGService.instance.deviceReady.value) {
        btDevice = BluetoothCTGService.instance.device;
        readChar = BluetoothCTGService.instance.readChar;
        writeChar = BluetoothCTGService.instance.writeChar;
      }
      if(mounted) setState(() {});
    });

    BluetoothSPo2Service.instance.deviceReady.addListener(() async {
      deviceSpO2Found = BluetoothSPo2Service.instance.deviceReady.value;
      if (BluetoothSPo2Service.instance.deviceReady.value) {
        btDeviceSPo2 = BluetoothSPo2Service.instance.device;
        //btDeviceSPo2?.connectionState.listen((event) => listenToChangeSpO2);
        readCharSpO2 = BluetoothSPo2Service.instance.pulseOximeterChar;
        await readCharSpO2?.setNotifyValue(true);
        //dataListenerSpO2?.cancel();
        //dataListenerSpO2 = readCharSpO2?.onValueReceived.listen((event) => getSpO2Data(event.toList()));
      }
      if(mounted ) setState(() {});
    });
  }

  /*Future<void> reSetBt(ctg)async {
    if(ctg) {
      deviceFound = BluetoothCTGService.instance.deviceReady.value;
      if (BluetoothCTGService.instance.deviceReady.value) {
        btDevice = BluetoothCTGService.instance.device;
        //btDevice?.connectionState.listen((event) => listenToChange);
        readChar = BluetoothCTGService.instance.readChar;
        writeChar = BluetoothCTGService.instance.writeChar;
        await readChar?.setNotifyValue(true);
        //dataListener?.cancel();
        //dataListener = readChar?.onValueReceived.listen((event) => getFHRData(event.toList()));
        //
        BluetoothSPo2Service.instance.startBle();
      }
    }else {
      deviceSpO2Found = BluetoothSPo2Service.instance.deviceReady.value;
      if (BluetoothSPo2Service.instance.deviceReady.value) {
        btDeviceSPo2 = BluetoothSPo2Service.instance.device;
        //btDeviceSPo2?.connectionState.listen((event) => listenToChangeSpO2);
        readCharSpO2 = BluetoothSPo2Service.instance.pulseOximeterChar;
        await readCharSpO2?.setNotifyValue(true);
        //dataListenerSpO2?.cancel();
        //dataListenerSpO2 = readCharSpO2?.onValueReceived.listen((event) => getSpO2Data(event.toList()));
      }
    }
    if(mounted) setState(() {});
  }*/

  /*Future<void> discoverServices() async {
    debugPrint("------------discoverServices  readCharacteristics ------");

    // Reads all services
    List<BluetoothService>? services = await btDevice?.discoverServices();
    for (BluetoothService service in services??[]) {
      debugPrint("------------discoverServices service ${service.serviceUuid.toString()} ------ $readService");
      if(service.serviceUuid.toString() == readService){
        // Reads all characteristics
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics??[]) {
          debugPrint("------------discoverServices characteristic ${characteristic.uuid.toString()} ------ $readCharacteristics");

          if(characteristic.uuid.toString() == readCharacteristics){
            debugPrint("------------ readCharacteristics ------");
            readChar = characteristic;
            //dataListener?.cancel();
            //stopwatch.start();
            //dataListener = readChar?.onValueReceived.listen((event)=>getFHRData(event.toList()));
            // cleanup: cancel subscription when disconnected
            //btDevice?.cancelWhenDisconnected(dataListener!);
            // subscribe
            // Note: If a characteristic supports both **notifications** and **indications**,
            // it will default to **notifications**. This matches how CoreBluetooth works on iOS.
            await readChar?.setNotifyValue(true);

          }else if(characteristic.uuid.toString() == writeCharacteristics){
            debugPrint("------------ writeCharacteristics ------");
            writeChar = characteristic;
            writeChar?.write(FhrCommandMaker.monitor(255));
            //writeChar?.write(FhrCommandMaker.monitor(0));
          }
        }
      }
    }
    if(mounted) {
      setState(() {});
    }
  }*/




  /*charListener(event) async {
      //debugPrint("byte size ------------ ${stopwatch.elapsed.inSeconds} --- ${event.length} -- ${event.toString()} ------");

      //lock.synchronized(() {
      //debugPrint("serial read $event");
      *//*final newEvent = event.toList();
          if(previousEvent!=null) {
            newEvent.addAll(previousEvent!);
          }*//*
      get11bytes(event.toList());
      //previousEvent = event;
      //dataBuffer.addDataList(event, 0, event.length);
      //updateValuesFromBT();
      //});

  }*/

  /*get11bytes(List<int> event){
    FhrData? fhr;
    bool afm= false;
    bool fm = false;
    for (int i = 0; i < (event.length - 10); i++) {
      if (85 == event[i] && 170 == event[i + 1]) {
        //debugPrint("-- $i --");
        if (87 == event[i + 2] && 10 == event[i + 3]) {
          *//*data = BluetoothData();
            data.dataType = DataType.TYPE_FHR;
            data.mValue.setRange(0, BluetoothData.BUFFER_SIZE, event, i);
            debugPrint("-- ${data.mValue.toString()} --");
            break;*//*
          final list = event.sublist(i,BluetoothData.BUFFER_SIZE);
          //debugPrint("test ${list[0]}, $list");
          fhr =FhrData.fromRaw(event.sublist(i,BluetoothData.BUFFER_SIZE));
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
    fhrData = fhr;
    if (tCount %  4 == 0) {
      //writeChar?.write(FhrCommandMaker.monitor(0));
      debugPrint("------ write complete -- ${FhrCommandMaker.monitor(0)}");
    }
    tCount++;
    if(mounted){
      setState(() {

      });
    }
    *//*if(previousEvent==null) {
    }
    else{
      final List<int> newEvent = previousEvent!.toList();
      newEvent.addAll(event);
      for (int i = 0; i < (newEvent.length / 2); i++) {
        if (85 == newEvent[i] && 170 == newEvent[i + 1]) {
          //debugPrint("-- $i --");
          if (87 == newEvent[i + 2] && 10 == newEvent[i + 3]) {
            data = BluetoothData();
            data.dataType = DataType.TYPE_FHR;
            data.mValue.setRange(0, BluetoothData.BUFFER_SIZE, newEvent, i);
            final fhr =FhrData.fromRaw(data);
            debugPrint("-- ${data.mValue.toString()} --");
            if(fhr.fmFlag !=1 || fhr.afmFlag !=1){
              break;
            }
            i+=10;
          }
        }
      }
    }
    if(data!=null){
      bluetoothData = data;

    }
    previousEvent = event;*//*
  }*/

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
        statusBarColor: Colors.transparent, // status bar color
        statusBarIconBrightness: Brightness.light,// status bar icons' color
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child:  Container(
              height: 1.sh,
              constraints: BoxConstraints(
                minHeight: 1.sh,
              ),
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 0.15.sh,
                    padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: "splash_icon",
                          child: SizedBox(
                              height: 0.08.sh,
                              width: 0.4.sw,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const OrganizationHome()));
                                    },
                                    child: SvgPicture.asset(
                                      'assets/icons/feto_icon.svg',
                                      height:  0.08.sh,fit: BoxFit.fitHeight,alignment: Alignment.centerLeft,
                                      width: 40.h,
                                    ),
                                  ),
                                  //Image.asset("assets/icons/feto_icon.png",height: 0.08.sh,fit: BoxFit.fitHeight,alignment: Alignment.centerLeft,),
                                  SizedBox(width: 8.w,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        user.name,
                                        style:  TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.sp,
                                            color: Colors.white),
                                      ),
                                      AutoSizeText(
                                          user.deviceName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12.sp,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                        Row(
                          children: [
                           // Center(child: IconButton(onPressed: (){}, icon: const Icon(FontAwesomeIcons.bell,color: Colors.white,size: 32,))),
                            SizedBox(width: 10.w,),
                            RichText(text: const TextSpan( text: "Support Number",children: [
                              TextSpan(text: "\n9326775598",
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                              style: TextStyle(
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Container(
                      //color: Theme.of(context).colorScheme.primaryContainer,

                      height: 0.78.sh,
                      //margin: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.w),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          TabContainer(
                            key: const Key("TabContainerHome"),
                            childPadding: EdgeInsets.zero,
                            tabExtent : 75.w,
                            tabsEnd: 0.4,
                            tabBorderRadius: BorderRadius.all(Radius.circular(15.w)),
                            tabEdge: TabEdge.bottom,
                            curve: Curves.easeIn,
                            controller: _tabContainerController,
                            transitionBuilder: (child, animation) {
                              animation = CurvedAnimation(
                                  curve: Curves.easeIn, parent: animation);
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(0.2, 0.0),
                                  end: const Offset(0.0, 0.0),
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            colors:  <Color>[
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer,
                            ],
                            tabs: [
                              const CircleIconButton(icon: Icons.home),
                              CircleIconButton(
                                icon: deviceFound?Icons.bluetooth_connected_outlined:Icons.bluetooth_disabled_outlined,
                                isSelected:deviceFound,
                              ),
                              const CircleIconButton(icon: Icons.people),
                              const CircleIconButton(icon: Icons.search),
                              const CircleIconButton(
                                icon: Icons.settings,
                              ),

                            ],
                            //isStringTabs: false,
                            children:  [

                              SizedBox(height: 0.65.sh,width:0.95.sw,),
                              SizedBox(height: 0.6.sh,width:0.9.sw,),
                              SizedBox(height: 0.6.sh,width:0.9.sw,),
                              SizedBox(height: 0.6.sh,width:0.9.sw,),
                              SizedBox(height: 0.6.sh,width:0.9.sw,),
                            ],
                          ),
                          Container(
                            clipBehavior: Clip.hardEdge,
                            margin: EdgeInsets.only(bottom: 0.125.sh),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.w),topRight: Radius.circular(15.w)),
                                color: Theme.of(context).colorScheme.primaryContainer
                            ),
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: _onPageViewChange,
                              clipBehavior: Clip.none,
                              children: tabChildren,
                            ),
                          ),
                          if(_pageIndex == 0 && deviceFound)
                          Positioned(
                            //alignment: Alignment.bottomRight,
                            bottom: 4.h,
                            right: 24.w,
                            child:
                            Container(
                              width: 0.25.sw,
                              //padding: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                              margin: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(30.w)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Theme.of(context).colorScheme.onPrimary,
                                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                                    ])
                              ),
                              child: MaterialButton(
                                //color:   Color(0xFF139DCB) ,
                                height: 80.h,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.w))
                                ),
                                highlightColor: Colors.white.withOpacity(0.5),
                                splashColor: Colors.white.withOpacity(0.5),
                                visualDensity: VisualDensity.compact,

                                child: AutoSizeText(
                                  "Start New Test",
                                  style: Theme.of(context).textTheme.titleLarge,//?.copyWith(fontSize: 36.sp),),
                              ),
                                onPressed: ()async {
                                  _timer?.cancel();
                                  //changeSub?.cancel();
                                  //dataListener?.cancel();
                                  //dataListenerSpO2?.cancel();
                                  writeChar?.write(FhrCommandMaker.tocoReset(0));
                                  writeChar?.write(FhrCommandMaker.fhrVolume(7,0));
                                  writeChar?.write(FhrCommandMaker.monitor(0));
                                  if(PrefService.getBool('preSaveMother') ?? false){
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) =>
                                            SaveMotherDialog(
                                                onNewPressed: (map) async {
                                                  Navigator.of(ctx).pop();
                                                  debugPrint("doctorName:  ${map["doctorName"]}");
                                                  Mother mom = Mother.fromUser(user.toJson(),map);
                                                  FirestoreDatabase(uid: user.documentId).saveNewMother(mom.toJson());
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (_)=> TestView(mom: mom)));
                                                  writeChar?.write(FhrCommandMaker.monitor(255));
                                                  //reSetBt(true);
                                                },
                                                onSkipPressed: () async{
                                                  Navigator.of(ctx).pop();
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const TestView()));
                                                  writeChar?.write(FhrCommandMaker.monitor(255));
                                                  //reSetBt(true);
                                                })
                                    );
                                  }else{
                                    await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const TestView()));
                                    writeChar?.write(FhrCommandMaker.monitor(255));
                                    //reSetBt(true);
                                  }
                                },

                                /*ActionSlider.standard(
                                height: 80.h,
                                action: (controller) async {
                                  _timer?.cancel();
                                  //changeSub?.cancel();
                                  //dataListener?.cancel();
                                  //dataListenerSpO2?.cancel();
                                  writeChar?.write(FhrCommandMaker.tocoReset(0));
                                  writeChar?.write(FhrCommandMaker.fhrVolume(7,0));
                                  writeChar?.write(FhrCommandMaker.monitor(0));
                                  if(PrefService.getBool('preSaveMother') ?? false){
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) =>
                                            SaveMotherDialog(
                                                onNewPressed: (map) async {
                                                  Navigator.of(ctx).pop();
                                                  Mother mom = Mother.fromUser(user.toJson(),map);
                                                  FirestoreDatabase(uid: user.documentId).saveNewMother(mom.toJson());
                                                  await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> TestView(mom: mom)));
                                                  writeChar?.write(FhrCommandMaker.monitor(255));
                                                  //reSetBt(true);
                                                },
                                                onSkipPressed: () async{
                                                  Navigator.of(ctx).pop();
                                                  await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const TestView()));
                                                  writeChar?.write(FhrCommandMaker.monitor(255));
                                                  //reSetBt(true);
                                                })
                                    );
                                  }else{
                                    await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const TestView()));
                                    writeChar?.write(FhrCommandMaker.monitor(255));
                                    //reSetBt(true);
                                  }
                                },
                                controller: _actionController,

                                successIcon: CircleIconButton(
                                  icon: FontAwesomeIcons.play,
                                  isSelected: false,
                                  margin: EdgeInsets.zero,
                                  showShadows: false,
                                  size: 66.h,
                                ),
                                icon:  CircleIconButton(
                                  icon: FontAwesomeIcons.play,
                                  isSelected: false,
                                  margin: EdgeInsets.zero,
                                  showShadows: false,
                                  size: 66.h,
                                ),

                                backgroundColor: const Color.fromRGBO(53, 54, 62, 1) ,
                                child:  Text('Slide to START test"',style: Theme.of(context).textTheme.labelLarge,),
                              )*/
                            ),
                          )),
                          if(_pageIndex == 4)
                          Align(
                          alignment: Alignment.bottomRight,
                          child:
                          Container(
                            width: 0.25.sw,
                            padding: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                            child: ActionSlider.standard(
                            direction:  TextDirection.rtl,
                            action: (controller) async {
                              HapticFeedback.vibrate();
                              context.read<SessionCubit>().signOut();
                              setState(() {
                              });
                            },
                            controller: _actionController,
                            successIcon: const CircleIconButton(
                              icon: FontAwesomeIcons.play,
                              isSelected: false,
                              margin: EdgeInsets.zero,
                              showShadows: false,
                              size: 55,
                            ),
                            icon: const CircleIconButton(
                              icon: Icons.logout_outlined,
                              isSelected: false,
                              margin: EdgeInsets.zero,
                              showShadows: false,
                              size: 55,
                            ),

                            backgroundColor: const Color.fromRGBO(53, 54, 62, 1) ,
                            child:  Text('Slide to SignOut',style: Theme.of(context).textTheme.labelLarge,),
                          ),
                        ),
                      ),

                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  Padding(
                    padding:  EdgeInsets.only(left: 32.w,bottom: 4.h),
                    child: RichText(text: TextSpan( text: "App version : ",children: const [
                      TextSpan(text: AppConstants.version)
                    ],
                      style:  TextStyle(
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.white24,
                      ),
                    ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              )

        )),

      ),
    );
  }

  List<Widget> getChildren() {
    return [
      const HomeView(),
      DeviceListScreen(pageController:_pageController),
      const RecentMothersView(key: Key("RecentMothersView"),),
      const RecentTestsView(key: Key("RecentTestsView"),),
      const SettingsView()
    ];
  }


  void _onPageViewChange(int value) {
    _pageIndex = value;
    setState(() {

    });
  }
}

