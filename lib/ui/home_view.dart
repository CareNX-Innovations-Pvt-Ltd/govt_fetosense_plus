// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
//
// import 'package:action_slider/action_slider.dart';
// import 'package:another_xlider/another_xlider.dart';
// import 'package:another_xlider/enums/hatch_mark_alignment_enum.dart';
// import 'package:another_xlider/models/handler.dart';
// import 'package:another_xlider/models/handler_animation.dart';
// import 'package:another_xlider/models/hatch_mark.dart';
// import 'package:another_xlider/models/hatch_mark_label.dart';
// import 'package:another_xlider/models/tooltip/tooltip.dart';
// import 'package:another_xlider/models/trackbar.dart';
// import 'package:another_xlider/widgets/sized_box.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// //import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:l8fe/ble/ble_device_connector.dart';
// import 'package:l8fe/models/user_model.dart';
// import 'package:l8fe/services/firestore_database.dart';
// import 'package:l8fe/ui/details_view.dart';
// import 'package:l8fe/ui/dialogs/save_dailog.dart';
// import 'package:l8fe/ui/dialogs/search_dailog.dart';
// import 'package:l8fe/ui/test_view.dart';
// import 'package:l8fe/ui/widgets/circle_icon_button.dart';
// import 'package:l8fe/utils/bluetooth_data.dart';
// import 'package:l8fe/utils/date_format_utils.dart';
// import 'package:l8fe/utils/fhr_byte_data_buffer.dart';
// import 'package:l8fe/utils/fhr_command_maker.dart';
// import 'package:l8fe/utils/fhr_data.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:synchronized/synchronized.dart';
//
// import '../ble/ble_device_interactor.dart';
// import '../ble/ble_scanner.dart';
//
// const String DEVICE_NAME = "L8T32B2019120011";
// //const String DEVICE_NAME =  "L8T32B2021010004";
// class HomeView2 extends StatefulWidget {
//   final UserModel user;
//   const HomeView2({super.key, required  this.user});
//
//   @override
//   State<HomeView2> createState() => _ViewState();
// }
//
// class _ViewState extends State<HomeView2> {
//
//
//
//   final ActionSliderController _actionController = ActionSliderController();
//
//   bool _locked = false;
//
//   bool deviceFound = false;
//
//   String? btDevice2;
//
//   int? _btFreq;
//   int? _btIntensity;
//   int? _btTime;
//   int? _btAlarmTime;
//   int? _btState;
//
//   var showControls = false;
//   var showBleList = false;
//
//   late SharedPreferences prefs;
//
//   //late int defaultTime;
//
//   //late int defaultAlarmTime;
//
//   bool isAlarmEnabled = false;
//
//   Timer? _timer;
//
//   StreamSubscription<ConnectionStateUpdate>? changeSub;
//
//   bool showAlarmTime = false;
//
//   FhrData? fhrData;
//
//   double _volume = 2;
//
//   int _volumePath = 0;
//
//   BluetoothData? bluetoothData;
//   Characteristic? writeChar;
//   Characteristic? readChar;
//   StreamSubscription<List<int>>? dataListener;
//
//   //List<StreamSubscription<List<int>>?>? subscriptions;
//   List<Service> btServices2 = [];
//   List<Characteristic> btCharacteristics2 = [];
//
//   String readService = "6e400001-b5a3-f393-e0a9-e50e24dcca91";
//   String readCharacteristics = "6e400003-b5a3-f393-e0a9-e50e24dcca93";
//   String writeCharacteristics = "6e400002-b5a3-f393-e0a9-e50e24dcca92";
//
//
//   @override
//   void initState() {
//     super.initState();
//     listenToChange();
//     prefs = context.read<SharedPreferences>();
//     setBt();
//     //_startTimer();
//   }
//   void listenToChange() {
//     final connector = context.read<BleDeviceConnector>();
//     changeSub = connector.state.listen((ConnectionStateUpdate update) {
//       debugPrint("-------ConnectionStateUpdate in ${update.connectionState.name}-----");
//       if (update.deviceId == btDevice2) {
//         switch (update.connectionState) {
//           case DeviceConnectionState.connecting:
//             break;
//           case DeviceConnectionState.connected:
//             deviceFound = true;
//             discoverServices();
//             break;
//           case DeviceConnectionState.disconnecting:
//             deviceFound = false;
//             break;
//           case DeviceConnectionState.disconnected:
//             btCharacteristics2 = [];
//             btServices2 = [];
//             deviceFound = false;
//             btDevice2 = null;
//             break;
//         }
//       }
//     }, cancelOnError: true);
//   }
//
//   ///Start the timer.
//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(
//       const Duration(milliseconds: 500), (Timer timer) {
//       //updateValuesFromBT();
//       if(bluetoothData!=null) {
//         fhrData = FhrData.fromRaw(bluetoothData!);
//       }
//       if (btDevice2!=null) {
//         if (timer.tick %  8 == 0) {
//             writeChar?.write(FhrCommandMaker.monitor(0), withResponse: false);
//             debugPrint(
//                 "------ write complete -- ${FhrCommandMaker.monitor(0)}");
//           }
//         if(timer.tick % 1 == 0 && mounted){
//           setState(() {
//
//           });
//         }
//       }
//     },
//     );
//   }
//
//
//   Future<void> setBt() async {
//     //final scannerState = context.read<BleScannerState>();
//     final scanner = context.read<BleScanner>();
//     final connector = context.read<BleDeviceConnector>();
//     //FlutterReactiveBle ble =  context.read<FlutterReactiveBle>();
//     bool found = false;
//
//     final devices = await FlutterBluePlus.instance.connectedDevices;
//     if (devices.isNotEmpty) {
//       for (BluetoothDevice bt in devices) {
//         debugPrint("-------BluetoothDevice in ${bt.name}-----");
//         if (bt.name.toUpperCase().contains(DEVICE_NAME)) {
//           debugPrint("-------$DEVICE_NAME in BluetoothDevice-----");
//           btDevice2 = bt.id.toString();
//           connector.connect(bt.id.toString());
//           found = true;
//           deviceFound = true;
//           btDevice2 = bt.id.toString();
//           discoverServices();
//           if (mounted) {
//             setState(() {});
//           }
//         }
//       }
//     }
//     debugPrint("-------scanIsInProgress in  $found-----");
//     if (!found) {
//       //if (!(scannerState.scanIsInProgress)) {
//       debugPrint("-------scanIsInProgress in -----");
//       scanner.startScan([]); //[Uuid.parse(_uuidController.text)]
//     }
//
//   }
//
//   Future<void> discoverServices() async {
//     final bleDeviceInteractor = context.read<BleDeviceInteractor>();
//     final result = await bleDeviceInteractor.discoverServices(btDevice2!);
//     setState(() {
//       btServices2 = result;
//     });
//     for (Service service in btServices2) {
//       debugPrint("service--------------${service.id} : ${btServices2.length} ");
//
//       if (service.id.toString() == readService) {
//         debugPrint("-------------char--------------");
//
//         btCharacteristics2 = service.characteristics.map((Characteristic c) {
//           debugPrint("char--------------${c.id.toString()}");
//           return c;
//         }).toList();
//       }
//       if(btCharacteristics2.isNotEmpty) {
//         discoverCharacteristics();
//         _startTimer();
//       }
//     }
//   }
//
//
//   FhrByteDataBuffer dataBuffer = FhrByteDataBuffer();
//   var lock = Lock();
//   void discoverCharacteristics() {
//     debugPrint("---char--------------}");
//     for (var char in btCharacteristics2) {
//       debugPrint("---char--------------${char.id.toString()}");
//       if (char.id.toString() == readCharacteristics) {
//         debugPrint("------------ readCharacteristics ------");
//         readChar = char;
//         dataListener?.cancel();
//         dataListener = readChar?.subscribe().listen((event) {
//           //debugPrint("------------ ${event.toString()} ------");
//
//           //lock.synchronized(() {
//             //debugPrint("serial read $event");
//             get11bytes(event);
//             //dataBuffer.addDataList(event, 0, event.length);
//             //updateValuesFromBT();
//           //});
//         });
//       }
//       if (char.id.toString() == writeCharacteristics) {
//         writeChar = char;
//       }
//     }
//   }
//
//   get11bytes(List<int> event){
//     BluetoothData? data;
//     for (int i=0; i<(event.length/2); i++) {
//       if (85 == event[i] && 170 == event[i + 1]) {
//         debugPrint("-- $i --");
//         if (87 == event[i + 2] && 10 == event[i + 3]) {
//           data = BluetoothData();
//           data.dataType = DataType.TYPE_FHR;
//           data.mValue.setRange(0, BluetoothData.BUFFER_SIZE, event, i);
//         }
//       }
//     }
//     if(data!=null){
//       bluetoothData = data;
//     }
//   }
//
//   _updateValuesFromBT() async {
//     try {
//       //if (dataBuffer.canRead()) {
//         final data = await dataBuffer.getBag();
//         if(data !=null) {
//           //debugPrint("-------Data read ${data?.mValue.toList()} -----");
//           bluetoothData = data ?? bluetoothData;
//           fhrData = FhrData.fromRaw(bluetoothData!);
//         }
//         /*debugPrint("------${dataBuffer
//             .getBag()
//             ?.mValue
//             .toList()}");*/
//       /*} else {
//         //debugPrint("-------Data low -----");
//       }*/
//     } catch (ex) {
//       debugPrint("update method ${ex.toString()}");
//       if (mounted) {
//         setState(() {});
//       }
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
//         statusBarColor: Colors.transparent, // status bar color
//         statusBarIconBrightness: Brightness.light,// status bar icons' color
//         systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
//         systemNavigationBarDividerColor: Theme.of(context).scaffoldBackgroundColor,
//       ),
//       child: Scaffold(
//           backgroundColor: Theme.of(context).primaryColorDark,
//           resizeToAvoidBottomInset: false,
//           body: SafeArea(
//             child:  Container(
//               height: 1.sh,
//               constraints: BoxConstraints(
//                 minHeight: 1.sh,
//               ),
//               child: Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
//                   builder: (_, bleScanner, bleScannerState, bleConnector, __) {
//                     if(deviceFound){
//                       bleScanner.stopScan();
//                     }
//                     if(btDevice2==null) {
//                       debugPrint("-------Consumer3 in 1 -----");
//                       debugPrint("-------Consumer3 in  scanIsInProgress : ${bleScannerState?.discoveredDevices.length} -----");
//                       if(!(bleScannerState?.scanIsInProgress??false)) {
//                         bleScanner.startScan([]);
//                         //todo: start scan
//                       }
//                       bleScannerState?.discoveredDevices.forEach((bt) {
//                         debugPrint("-------DiscoveredDevice in ${bt.name.toUpperCase()} -----");
//                         if (bt.name.toUpperCase().contains(DEVICE_NAME)) {
//                           debugPrint("-------$DEVICE_NAME in DiscoveredDevice-----");
//                           btDevice2 = bt.id.toString();
//                           bleConnector.connect(bt.id);
//                           bleScanner.stopScan();
//                         }
//                       });
//                     }
//                   return Column(
//                     children: [
//                       Container(
//                         height: 0.15.sh,
//                         padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 32.w),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Hero(
//                               tag: "splash_icon",
//                               child: SizedBox(
//                                   height: 0.08.sh,
//                                   width: 0.4.sw,
//                                   child: Row(
//                                     children: [
//                                       SvgPicture.asset(
//                                         'assets/icons/feto_icon.svg',
//                                         height:  0.08.sh,fit: BoxFit.fitHeight,alignment: Alignment.centerLeft,
//                                         width: 40.h,
//                                       ),
//                                       //Image.asset("assets/icons/feto_icon.png",height: 0.08.sh,fit: BoxFit.fitHeight,alignment: Alignment.centerLeft,),
//                                       SizedBox(width: 8.w,),
//                                       Column(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             widget.user.name,
//                                             style:  TextStyle(
//                                                 fontWeight: FontWeight.w500,
//                                                 fontSize: 18.sp,
//                                                 color: Colors.white),
//                                           ),
//                                           Text(
//                                               "${/*test.motherName ?? */"Demo Mode"}",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.w300,
//                                                   fontSize: 14.sp,
//                                                   color: Colors.white)),
//                                         ],
//                                       ),
//                                     ],
//                                   )),
//                             ),
//                             Row(
//                               children: [
//                                 Center(child: IconButton(onPressed: (){}, icon: const Icon(FontAwesomeIcons.bell,color: Colors.white,size: 32,))),
//                                 SizedBox(width: 10.w,),
//                                 RichText(text: TextSpan( text: "${DateTime.now().format("hh:mm")} ",children: [
//                                   TextSpan(text: DateTime.now().format("a"),
//                                     style: const TextStyle(
//                                       fontFamily: 'Barlow',
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 24,
//                                       color: Colors.white54,
//                                     ),),
//                                   TextSpan(text: "\n${DateTime.now().format("EEE, MMMM dd, yyyy")}",
//                                     style: const TextStyle(
//                                       fontFamily: 'Barlow',
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 16,
//                                       color: Colors.white54,
//                                     ),
//                                   ),
//                                 ],
//                                   style: const TextStyle(
//                                     fontFamily: 'Barlow',
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 24,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 32.w),
//                         child: Container(
//                           height: 0.8.sh,
//                           //margin: EdgeInsets.symmetric(vertical: 16.h),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15.w),
//                               color: Theme.of(context).colorScheme.primaryContainer
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               const Spacer(),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 //mainAxisSize: MainAxisSize.max,
//                                 children: <Widget>[
//                                   SizedBox(
//                                       height: 0.4.sh,
//                                       width: 0.3.sw,
//                                       child: Column(
//                                           //mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             Expanded(
//                                               child: Container(
//                                                 alignment: Alignment.center,
//                                                 child: AutoSizeText(
//                                                   '${(fhrData?.fhr1 ?? 0)==0? "---" : (fhrData?.fhr1 ?? "---")}',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontSize: 120.sp,
//                                                       color: Colors.white,
//                                                       fontWeight: FontWeight.w700),
//                                                 ),
//                                               ),
//                                             ),
//                                             Column(
//                                               children: [
//                                                 Text(
//                                                   "  FHR 1",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.white54,
//                                                     fontSize: 22.sp,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                                 // Padding(
//                                                 //   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                                                 //   child: Row(
//                                                 //     children: [
//                                                 //       SizedBox(
//                                                 //         width: 60.w,
//                                                 //         child: CircleIconButton(
//                                                 //           size: 48.w,
//                                                 //           margin: EdgeInsets.all(2.h),
//                                                 //           icon: _volumePath == 1
//                                                 //               ? FontAwesomeIcons.volumeXmark
//                                                 //               : _volume < 4
//                                                 //               ? FontAwesomeIcons.volumeLow
//                                                 //               : FontAwesomeIcons.volumeHigh,
//                                                 //           onTap: () async {
//                                                 //             if (_volumePath == 1) {
//                                                 //               HapticFeedback.mediumImpact();
//                                                 //               _volumePath = 0;
//                                                 //               await writeChar?.write(
//                                                 //                   FhrCommandMaker.fhrVolume(
//                                                 //                       _volume.toInt(),
//                                                 //                       _volumePath),
//                                                 //                   withResponse: false);
//                                                 //               setState(() {});
//                                                 //             }
//                                                 //           },
//                                                 //         ),
//                                                 //       ),
//                                                 //       Expanded(
//                                                 //         child: Container(
//                                                 //           height: 92.h,
//                                                 //           child: Visibility(
//                                                 //             visible: _volumePath == 0,
//                                                 //             child: FlutterSlider(
//                                                 //               values: [_volume],
//                                                 //               axis: Axis.horizontal,
//                                                 //               disabled: _volumePath == 1,
//                                                 //               max: 7,
//                                                 //               min: 1,
//                                                 //               rtl: false,
//                                                 //               handlerHeight: 34,
//                                                 //               handlerWidth: 22,
//                                                 //               tooltip: FlutterSliderTooltip(
//                                                 //                   disabled: true),
//                                                 //               handler: FlutterSliderHandler(
//                                                 //                 decoration: BoxDecoration(
//                                                 //                     borderRadius:
//                                                 //                     BorderRadius.circular(10),
//                                                 //                     color: Colors.transparent),
//                                                 //                 child: Container(
//                                                 //                     margin: EdgeInsets.all(5.w),
//                                                 //                     decoration: BoxDecoration(
//                                                 //                       borderRadius:
//                                                 //                       BorderRadius.circular(15),
//                                                 //                       border: Border.all(
//                                                 //                           color: Colors.white,
//                                                 //                           width: 1),
//                                                 //                       gradient: const RadialGradient(
//                                                 //                         colors: [
//                                                 //                           Color.fromRGBO(
//                                                 //                               128, 128, 138, 1),
//                                                 //                           Color.fromRGBO(
//                                                 //                               53, 54, 62, 1),
//                                                 //                         ],
//                                                 //                         center: Alignment(1, 1),
//                                                 //                         focal:
//                                                 //                         Alignment(-0.75, -0.75),
//                                                 //                         focalRadius: 1.0,
//                                                 //                       ),
//                                                 //                       boxShadow: const [
//                                                 //                         BoxShadow(
//                                                 //                           color: Colors.black38,
//                                                 //                           blurRadius: 8.0,
//                                                 //                           offset: Offset(2.0, 2.0),
//                                                 //                         ),
//                                                 //                       ],
//                                                 //                     ),
//                                                 //                     child: Center(
//                                                 //                         child: Icon(
//                                                 //                           Icons.menu,
//                                                 //                           size: 12,
//                                                 //                           color: Theme.of(context)
//                                                 //                               .colorScheme
//                                                 //                               .secondary,
//                                                 //                         ))),
//                                                 //               ),
//                                                 //               trackBar: FlutterSliderTrackBar(
//                                                 //                 //activeTrackBarHeight: 8,
//                                                 //                 //inactiveTrackBarHeight: 4,
//                                                 //                 inactiveTrackBar: BoxDecoration(
//                                                 //                   color: Colors.white,
//                                                 //                   border: Border.all(
//                                                 //                       width: 4,
//                                                 //                       color: Theme.of(context)
//                                                 //                           .primaryColorDark),
//                                                 //                 ),
//                                                 //                 activeTrackBar: const BoxDecoration(
//                                                 //                   gradient: RadialGradient(
//                                                 //                     colors: [
//                                                 //                       Color.fromRGBO(53, 54, 62, 1),
//                                                 //                       Color.fromRGBO(
//                                                 //                           128, 128, 138, 1),
//                                                 //                     ],
//                                                 //                     center: Alignment.centerLeft,
//                                                 //                     focal: Alignment.centerRight,
//                                                 //                     focalRadius: 1.0,
//                                                 //                   ),
//                                                 //                 ),
//                                                 //               ),
//                                                 //               handlerAnimation:
//                                                 //               const FlutterSliderHandlerAnimation(
//                                                 //                   curve: Curves.elasticOut,
//                                                 //                   reverseCurve: Curves.bounceIn,
//                                                 //                   duration:
//                                                 //                   Duration(milliseconds: 500),
//                                                 //                   scale: 1.2),
//                                                 //               onDragStarted: (handlerIndex,
//                                                 //                   lowerValue, upperValue) {
//                                                 //                 HapticFeedback.lightImpact();
//                                                 //               },
//                                                 //               onDragging: (handlerIndex, lowerValue,
//                                                 //                   upperValue) {
//                                                 //                 _volume = lowerValue;
//                                                 //                 //_upperValue = upperValue;*/
//                                                 //                 setState(() {});
//                                                 //               },
//                                                 //               onDragCompleted: (handlerIndex,
//                                                 //                   lowerValue, upperValue) async {
//                                                 //                 HapticFeedback.lightImpact();
//                                                 //                 _volume = lowerValue;
//                                                 //                 await writeChar?.write(
//                                                 //                     FhrCommandMaker.fhrVolume(
//                                                 //                         _volume.toInt(), _volumePath),
//                                                 //                     withResponse: false);
//                                                 //               },
//                                                 //               hatchMark: FlutterSliderHatchMark(
//                                                 //                 displayLines: true,
//                                                 //                 linesDistanceFromTrackBar: 0,
//                                                 //                 /*labelBox: FlutterSliderSizedBox(
//                                                 //             width: 40,
//                                                 //             height: 20,
//                                                 //             foregroundDecoration: BoxDecoration(color: Color.fromARGB(39, 54, 165, 244)),
//                                                 //             transform: Matrix4.translationValues(0, 30, 0),
//                                                 //           ),*/
//                                                 //                 linesAlignment:
//                                                 //                 FlutterSliderHatchMarkAlignment
//                                                 //                     .left,
//                                                 //                 density: 0.3,
//                                                 //                 smallLine:
//                                                 //                 const FlutterSliderSizedBox(
//                                                 //                   width: 1,
//                                                 //                   height: 4,
//                                                 //                   decoration: BoxDecoration(
//                                                 //                       color: Colors.transparent),
//                                                 //                 ),
//                                                 //                 bigLine: FlutterSliderSizedBox(
//                                                 //                   width: 1,
//                                                 //                   height: 4,
//                                                 //                   decoration: BoxDecoration(
//                                                 //                       color: Theme.of(context)
//                                                 //                           .colorScheme
//                                                 //                           .secondary),
//                                                 //                 ),
//                                                 //               ),
//                                                 //             ),
//                                                 //           ),
//                                                 //         ),
//                                                 //       ),
//                                                 //     ],
//                                                 //   ),
//                                                 // ),
//                                               ],
//                                             ),
//                                           ])),
//                                   SizedBox(
//                                       height: 0.4.sh,
//                                       width: 0.3.sw,
//                                       child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             Expanded(
//                                               child: Container(
//                                                 alignment: Alignment.center,
//                                                 child: AutoSizeText(
//                                                   '${(fhrData?.fhr2 ?? 0)==0? "---" : (fhrData?.fhr2 ?? "---")}',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontSize: 120.sp,
//                                                       color: Colors.white,
//                                                       fontWeight: FontWeight.w700),
//                                                 ),
//                                               ),
//                                             ),
//                                             Column(
//                                               children: [
//                                                 Text(
//                                                   "  FHR 2",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.w400,
//                                                     color: Colors.white54,
//                                                     fontSize: 22.sp,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                                 // Padding(
//                                                 //   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                                                 //   child: Row(
//                                                 //     children: [
//                                                 //       SizedBox(
//                                                 //         width: 60.w,
//                                                 //         child: CircleIconButton(
//                                                 //           size: 48.w,
//                                                 //           margin: EdgeInsets.all(2.h),
//                                                 //           icon: _volumePath == 0
//                                                 //               ? FontAwesomeIcons.volumeXmark
//                                                 //               : _volume < 4
//                                                 //               ? FontAwesomeIcons.volumeLow
//                                                 //               : FontAwesomeIcons.volumeHigh,
//                                                 //           onTap: () async {
//                                                 //             if (_volumePath == 0) {
//                                                 //               HapticFeedback.mediumImpact();
//                                                 //               _volumePath = 1;
//                                                 //               await writeChar?.write(
//                                                 //                   FhrCommandMaker.fhrVolume(
//                                                 //                       _volume.toInt(),
//                                                 //                       _volumePath),
//                                                 //                   withResponse: false);
//                                                 //               setState(() {});
//                                                 //             }
//                                                 //           },
//                                                 //         ),
//                                                 //       ),
//                                                 //       Expanded(
//                                                 //         child: Container(
//                                                 //           height: 92.h,
//                                                 //           child: IgnorePointer(
//                                                 //             ignoring: _volumePath != 1,
//                                                 //             child: FlutterSlider(
//                                                 //               values: [(_volumePath != 1)?1:_volume],
//                                                 //               axis: Axis.horizontal,
//                                                 //               disabled: _volumePath == 0,
//                                                 //               max: 7,
//                                                 //               min: 1,
//                                                 //               rtl: false,
//                                                 //               handlerHeight: 34,
//                                                 //               handlerWidth: 22,
//                                                 //               tooltip: FlutterSliderTooltip(
//                                                 //                   disabled: true),
//                                                 //               handler: FlutterSliderHandler(
//                                                 //                 decoration: BoxDecoration(
//                                                 //                     borderRadius:
//                                                 //                     BorderRadius.circular(10),
//                                                 //                     color: Colors.transparent),
//                                                 //                 child: Container(
//                                                 //                     margin: EdgeInsets.all(5.w),
//                                                 //                     decoration: BoxDecoration(
//                                                 //                       borderRadius:
//                                                 //                       BorderRadius.circular(15),
//                                                 //                       border: Border.all(
//                                                 //                           color: Colors.white,
//                                                 //                           width: 1),
//                                                 //                       gradient: const RadialGradient(
//                                                 //                         colors: [
//                                                 //                           Color.fromRGBO(
//                                                 //                               128, 128, 138, 1),
//                                                 //                           Color.fromRGBO(
//                                                 //                               53, 54, 62, 1),
//                                                 //                         ],
//                                                 //                         center: Alignment(1, 1),
//                                                 //                         focal:
//                                                 //                         Alignment(-0.75, -0.75),
//                                                 //                         focalRadius: 1.0,
//                                                 //                       ),
//                                                 //                       boxShadow: const [
//                                                 //                         BoxShadow(
//                                                 //                           color: Colors.black38,
//                                                 //                           blurRadius: 8.0,
//                                                 //                           offset: Offset(2.0, 2.0),
//                                                 //                         ),
//                                                 //                       ],
//                                                 //                     ),
//                                                 //                     child: Center(
//                                                 //                         child: Icon(
//                                                 //                           Icons.menu,
//                                                 //                           size: 12,
//                                                 //                           color: Theme.of(context)
//                                                 //                               .colorScheme
//                                                 //                               .secondary,
//                                                 //                         ))),
//                                                 //               ),
//                                                 //               trackBar: FlutterSliderTrackBar(
//                                                 //                 //activeTrackBarHeight: 8,
//                                                 //                 //inactiveTrackBarHeight: 4,
//                                                 //                 inactiveTrackBar: BoxDecoration(
//                                                 //                   color: Colors.white,
//                                                 //                   border: Border.all(
//                                                 //                       width: 4,
//                                                 //                       color: Theme.of(context)
//                                                 //                           .primaryColorDark),
//                                                 //                 ),
//                                                 //                 activeTrackBar: const BoxDecoration(
//                                                 //                   gradient: RadialGradient(
//                                                 //                     colors: [
//                                                 //                       Color.fromRGBO(
//                                                 //                           128, 128, 138, 1),
//                                                 //                       Color.fromRGBO(53, 54, 62, 1),
//                                                 //                     ],
//                                                 //                     center: Alignment.centerLeft,
//                                                 //                     focal: Alignment.centerRight,
//                                                 //                     focalRadius: 1.0,
//                                                 //                   ),
//                                                 //                 ),
//                                                 //               ),
//                                                 //               handlerAnimation:
//                                                 //               const FlutterSliderHandlerAnimation(
//                                                 //                   curve: Curves.elasticOut,
//                                                 //                   reverseCurve: Curves.bounceIn,
//                                                 //                   duration:
//                                                 //                   Duration(milliseconds: 500),
//                                                 //                   scale: 1.2),
//                                                 //               onDragStarted: (handlerIndex,
//                                                 //                   lowerValue, upperValue) {
//                                                 //                 HapticFeedback.lightImpact();
//                                                 //               },
//                                                 //               onDragging: (handlerIndex, lowerValue,
//                                                 //                   upperValue) {
//                                                 //                 _volume = lowerValue;
//                                                 //                 //_upperValue = upperValue;*/
//                                                 //                 setState(() {});
//                                                 //               },
//                                                 //               onDragCompleted: (handlerIndex,
//                                                 //                   lowerValue, upperValue) async {
//                                                 //                 HapticFeedback.lightImpact();
//                                                 //                 _volume = lowerValue;
//                                                 //                 await writeChar?.write(
//                                                 //                     FhrCommandMaker.fhrVolume(
//                                                 //                         _volume.toInt(), _volumePath),
//                                                 //                     withResponse: false);
//                                                 //               },
//                                                 //               hatchMark: FlutterSliderHatchMark(
//                                                 //                 displayLines: true,
//                                                 //                 linesDistanceFromTrackBar: 0,
//                                                 //                 linesAlignment:
//                                                 //                 FlutterSliderHatchMarkAlignment
//                                                 //                     .left,
//                                                 //                 density: 0.3,
//                                                 //                 smallLine:
//                                                 //                 const FlutterSliderSizedBox(
//                                                 //                   width: 1,
//                                                 //                   height: 4,
//                                                 //                   decoration: BoxDecoration(
//                                                 //                       color: Colors.transparent),
//                                                 //                 ),
//                                                 //                 bigLine: FlutterSliderSizedBox(
//                                                 //                   width: 1,
//                                                 //                   height: 4,
//                                                 //                   decoration: BoxDecoration(
//                                                 //                       color: Theme.of(context)
//                                                 //                           .colorScheme
//                                                 //                           .secondary),
//                                                 //                 ),
//                                                 //               ),
//                                                 //             ),
//                                                 //           ),
//                                                 //         ),
//                                                 //       ),
//                                                 //     ],
//                                                 //   ),
//                                                 // ),
//                                               ],
//                                             ),
//                                           ])),
//                                   SizedBox(
//                                       height: 0.4.sh,
//                                       width: 0.3.sw,
//                                       child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             Expanded(
//                                               child: Container(
//                                                 alignment: Alignment.center,
//                                                 child: AutoSizeText(
//                                                   '${fhrData?.toco ?? "---"}',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontSize: 120.sp,
//                                                       color: Colors.white,
//                                                       fontWeight: FontWeight.w700),
//                                                 ),
//                                               ),
//                                             ),
//                                             Container(
//                                               padding: EdgeInsets.symmetric(vertical: 4.h),
//                                               alignment: Alignment.center,
//                                               child: Column(
//                                                 children: [
//                                                   Text(
//                                                     "  Toco",
//                                                     style: TextStyle(
//                                                       fontWeight: FontWeight.w400,
//                                                       color: Colors.white54,
//                                                       fontSize: 22.sp,
//                                                     ),
//                                                     textAlign: TextAlign.center,
//                                                   ),
//                                                   // Row(
//                                                   //   children: [
//                                                   //     SizedBox(
//                                                   //       width: 60.w,
//                                                   //       child: CircleIconButton(
//                                                   //         size: 48.w,
//                                                   //         margin: EdgeInsets.all(2.h),
//                                                   //         icon: FontAwesomeIcons.arrowsRotate,
//                                                   //         onTap: () async {
//                                                   //           HapticFeedback.heavyImpact();
//                                                   //           await writeChar?.write(FhrCommandMaker.tocoReset(0),
//                                                   //               withResponse: false);
//                                                   //           debugPrint(
//                                                   //               "------ write complete -- ${FhrCommandMaker.tocoReset(0)}");
//                                                   //           setState(() {});
//                                                   //         },
//                                                   //       ),
//                                                   //     ),
//                                                   //     Expanded(
//                                                   //       child: Container(
//                                                   //         height: 92.h,
//                                                   //       ),
//                                                   //     ),
//                                                   //   ],
//                                                   // ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ])),
//
//
//                                 ],
//                               ),
//                               const Spacer(),
//                               Container(
//                                 margin: EdgeInsets.symmetric(horizontal: 32.w,vertical: 8.h),
//                                 padding: EdgeInsets.symmetric(vertical: 16.h),
//                                 decoration: const BoxDecoration(
//                                     border: Border(top: BorderSide(color: Colors.grey,width: 1))
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     CircleIconButton(
//                                       icon: _locked? Icons.lock_open_outlined: Icons.lock_outline_rounded,
//                                       isSelected: _locked,
//                                       onTap: (){
//                                         _locked = !_locked;
//                                         setState(() {
//                                         });
//                                       },
//                                     ),
//                                     CircleIconButton(
//                                       icon: deviceFound?Icons.bluetooth_connected_outlined:Icons.bluetooth_disabled_outlined,
//                                       isSelected:deviceFound,
//                                       onLongTap: (){
//                                         setState(() {
//                                           showBleList = true;
//
//                                         });
//                                       },
//                                       onTap: _locked?null:(){
//                                         setState(() {
//                                           //setBt();
//                                           /*if(btDevice2==null) {
//                                             //setBt();
//                                             try {
//                                               FlutterBluePlus.instance
//                                                   .startScan(
//                                                   timeout: const Duration(
//                                                       seconds: 10));
//                                             } catch (ex) {
//                                               debugPrint(ex
//                                                   .toString());
//                                             }
//                                           }*/
//                                         });
//                                         //scanAndConnect();
//                                       },
//                                     ),
//                                     Stack(
//                                       clipBehavior: Clip.none,
//                                       children: [
//                                         CircleIconButton(
//                                           icon: isAlarmEnabled?Icons.notifications_active_outlined:Icons.notifications_off_outlined,
//                                           isSelected:isAlarmEnabled,
//                                           onTap: _locked?null:(){
//                                             setState(() {
//                                               isAlarmEnabled = !isAlarmEnabled;
//                                               prefs.setBool("isAlarmEnabled", isAlarmEnabled);
//                                             });
//                                             //scanAndConnect();
//                                           },
//                                           onLongTap: (){
//                                             setState(() {
//                                               showAlarmTime = true;
//                                             });
//                                           },
//                                         ),
//                                         if(isAlarmEnabled)
//                                           Positioned(
//                                             right: -4,
//                                             top: -10,
//                                             child: IgnorePointer(
//                                               child: SizedBox(
//                                                 width: 30.h,
//                                                 child: CircleAvatar(
//                                                   backgroundColor: Colors.white,
//                                                   child: Text(((_btAlarmTime??180)~/60).toString(),style: Theme.of(context).textTheme.labelSmall?.copyWith(color:Colors.black)),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                       ],
//                                     ),
//                                     //const Icon(Icons.settings,color: Colors.white,size: 40,),
//                                     //Text("Controls",style: Theme.of(context).textTheme?.labelMedium,),
//                                     CircleIconButton(
//                                       icon: Icons.settings,
//                                       onTap: /*_locked?null:*/(){
//                                         //showControls = true;
//                                         showDialog(
//                                             context: context,
//                                             barrierDismissible: false,
//                                             builder: (ctx) =>  SearchDialog(
//                                                 onNewPressed: ()=>Navigator.of(ctx).pop())
//                                         );
//                                         setState(() {
//                                         });
//                                         //scanAndConnect();
//                                       },
//                                     ),
//                                     SizedBox(
//                                       width: 0.25.sw,
//                                       child: IgnorePointer(
//                                         ignoring: _locked,
//                                         child: ActionSlider.standard(
//                                           action: (controller) async {
//                                             _timer?.cancel();
//                                             changeSub?.cancel();
//                                             dataListener?.cancel();
//
//                                             await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> TestView(readChar:readChar,writeChar:writeChar)));
//                                             setBt();
//                                           },
//                                           controller: _actionController,
//                                           successIcon: const CircleIconButton(
//                                             icon: FontAwesomeIcons.play,
//                                             isSelected: false,
//                                             margin: EdgeInsets.zero,
//                                             showShadows: false,
//                                             size: 55,
//                                           ),
//                                           icon: CircleIconButton(
//                                             icon: (_btState??1) ==1?FontAwesomeIcons.play:FontAwesomeIcons.stop,
//                                             isSelected: (_btState??1) ==1?false:true,
//                                             margin: EdgeInsets.zero,
//                                             showShadows: false,
//                                             size: 55,
//                                           ),
//
//                                           backgroundColor: const Color.fromRGBO(53, 54, 62, 1) ,
//                                           child:  Text('Slide to ${(_btState??1) ==1?"start" : "stop"}',style: Theme.of(context).textTheme.labelMedium,),
//                                         ),
//                                       ),
//                                     ),
//
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//               ),
//             ),
//           )
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     changeSub?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void didChangeDependencies() {
//     debugPrint('didChangeDependencies');
//     super.didChangeDependencies();
//   }
//
//   @override
//   void deactivate() {
//     debugPrint('deactivate');
//     super.deactivate();
//   }
//
//   @override
//   void activate() {
//     debugPrint('activate');
//     super.activate();
//   }
//
// }
//
//
