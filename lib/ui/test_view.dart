import 'dart:async';
import 'package:action_slider/action_slider.dart';
import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/enums/hatch_mark_alignment_enum.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/handler_animation.dart';
import 'package:another_xlider/models/hatch_mark.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:another_xlider/widgets/sized_box.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep_plus/flutter_beep_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/ble/bluetooth_spo2_service.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/constants/my_color_scheme.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/ui/details_view.dart';
import 'package:l8fe/ui/widgets/circle_icon_button.dart';
import 'package:l8fe/ui/widgets/graphPainter.dart';
import 'package:collection/collection.dart';
import 'package:l8fe/utils/bluetooth_data.dart';
import 'package:l8fe/utils/fhr_byte_data_buffer.dart';
import 'package:l8fe/utils/fhr_command_maker.dart';
import 'package:l8fe/utils/fhr_data.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/device_model.dart';
import '../models/test_model.dart';
import '../services/firestore_database.dart';
import '../utils/intrepretations2.dart';
import 'dialogs/save_dailog.dart';
import 'dialogs/save_test_dailog.dart';
import 'widgets/blink_widget.dart';

class TestView extends StatefulWidget {
  final Mother? mom;
  const TestView({super.key, this.mom,});

  @override
  State createState() => _DetailsViewState();
}

class _DetailsViewState extends State<TestView>
    with TickerProviderStateMixin {


  BluetoothCharacteristic? readChar;
  BluetoothCharacteristic? readCharSpO2;
  BluetoothCharacteristic? writeChar;
  BluetoothDevice? btDevice;
  BluetoothDevice? btDeviceSPo2;

  late AnimationController _animationController;
  late AnimationController _animationControllerFHR1;
  late AnimationController _animationControllerFHR2;

  late CtgTest test;
  late Mother? testMom;

  int gridPreMin = 3;
  double mTouchStart = 0;
  int mOffset = 0;

  bool dragOn = false;
  bool deviceFound = true;

  late String movements;
  Timer? _timer;

  bool showAlarmTime = false;

  FhrData? fhrData;

  BluetoothData? bluetoothData;

  double _volume = 7;

  int _volumePath = 0;
  int _fhrPath = 0;

  bool testStarted = false;

  late Device user;
  late Stopwatch stopwatch;

  Interpretations2? interpretations;
  Interpretations2? interpretations2;

  bool blink = false;
  bool noData1 = false;
  bool noData2 = false;
  bool alarm1 = false;
  bool alarm2 = false;

  bool auto = true;
  bool autoMovementMarking = true;

  int testTime = 0;

  bool deviceSpO2Found = false;

  bool signalLossAlarm = true;
  late int pointsOnDisplay;

  bool _isFetchingBp = false;

  var _isTocoReseting = false;


  final _flutterBeepPlus = FlutterBeepPlus();

  @override
  void initState() {
    testMom = widget.mom;
    _fhrPath = ((PrefService.getBool("hasFhr2")??true))?_fhrPath:1;
    user = context.read<SessionCubit>().currentUser.value!;
    if(testMom!=null) {
      test = CtgTest.withMother(testMom!);
    }else {
      test = CtgTest.withDevice(user);
    }
    WakelockPlus.enable();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _animationControllerFHR1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _animationControllerFHR2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    //_animationController.repeat(reverse: true);
    super.initState();
    stopwatch = Stopwatch();
    signalLossAlarm = PrefService.getBool('signalLossAlarm') ?? true;
    debugPrint("signalLossAlarm : $signalLossAlarm");
    //startTest();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
    //_startTimer();
    //int _movements = test.movementEntries.length + test.autoFetalMovement.length;
    //movements = _movements < 10 ? "0$_movements" : '$_movements';
    reSetBt(true);
    reSetBt(false);

    BluetoothCTGService.instance.deviceReady.addListener(() async {
      reSetBt(true);
    });

    BluetoothSPo2Service.instance.deviceReady.addListener(() async {
      reSetBt(false);
    });

  }

  Future<void> reSetBt(ctg)async {
    if(ctg) {
      deviceFound = BluetoothCTGService.instance.deviceReady.value;
      if (BluetoothCTGService.instance.deviceReady.value) {
        btDevice = BluetoothCTGService.instance.device;
        //btDevice?.connectionState.listen((event) => listenToChange);
        readChar = BluetoothCTGService.instance.readChar;
        writeChar = BluetoothCTGService.instance.writeChar;
        //await readChar?.setNotifyValue(true);
        //dataListener?.cancel();
        //dataListener = readChar?.onValueReceived.listen((event) =>getFHRData(event.toList()));
        // BluetoothSPo2Service.instance.startBle();
      }
    }
    else {
      deviceSpO2Found = BluetoothSPo2Service.instance.deviceReady.value;
      if (BluetoothSPo2Service.instance.deviceReady.value) {
        btDeviceSPo2 = BluetoothSPo2Service.instance.device;
        //btDeviceSPo2?.connectionState.listen((event) => listenToChangeSpO2);
        readCharSpO2 = BluetoothSPo2Service.instance.pulseOximeterChar;
        //await readCharSpO2?.setNotifyValue(true);
        //dataListenerSpO2?.cancel();
        //dataListenerSpO2 = readCharSpO2?.onValueReceived.listen((event) =>getSpO2Data(event.toList()));
        //deviceSpO2Found = true;

      }
    }
    if(mounted)setState(() {});
  }

  @override
  void didChangeDependencies() {
    debugPrint('didChangeDependencies');
    initialize();
    super.didChangeDependencies();
    BluetoothSPo2Service.instance.deviceReady.notifyListeners();
    BluetoothCTGService.instance.deviceReady.notifyListeners();
  }

  void startTest() {
    debugPrint("startTest === ${testMom?.toJson().toString()??""}");
    if(testMom!=null) {
      test = CtgTest.withMother(testMom!);
    }else {
      test = CtgTest.withDevice(user);
    }
    testStarted = true;
    stopwatch.reset();
    stopwatch.start();
    _startTimer();
  }

  void stopTest() {
    testStarted = false;
    blink = false;
    alarm2 = false;
    alarm1 = false;
    stopwatch.stop();
    _timer?.cancel();
    if(_animationController.isAnimating){
      _animationController.reset();
    }
    if(_animationControllerFHR1.isAnimating){
      _animationControllerFHR1.reset();
    }
    if(_animationControllerFHR2.isAnimating){
      _animationControllerFHR2.reset();
    }
    if((test.bpmEntries.length>60 && test.bpmEntries.average>0) || (test.bpmEntries2.length>60 && test.bpmEntries2.average>60)) {
      if(testMom==null) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) =>
                SaveTestDialog(
                    onNewPressed: (map) {
                      Navigator.of(ctx).pop();
                      Mother mom = Mother.fromUser(user.toJson(),map);
                      testMom = mom;
                      setState(() {});
                      uploadTestAndMother(mom);
                    },
                    onAnonymousPressed: () {
                      Navigator.of(ctx).pop();
                      test.motherId = "Anonymous";
                      test.motherName = "Anonymous";
                      test.gAge = 37;
                      uploadTest(live: false);
                    })
        );
      }else{
        uploadTest(live: false);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) =>
                SaveDialog(
                    onClosePressed: () {
                      Navigator.of(ctx).pop();
                    },
                    onPrintPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_)=> DetailsView(test: test,)));
                    })
        );
      }
    }
    else{
      debugPrint("-----------Delete test ----------- ${testMom?.documentId}");

      if( testMom !=null){
        debugPrint("-----------Delete test ----------- ${test.documentId}");
        FirestoreDatabase(uid: user.documentId)
            .deleteNewTest(test.documentId);
      }
    }
  }
  ///Start the timer.
  void _startTimer() {
    _timer?.cancel();
    if(deviceFound) {
      _timer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (Timer timer) {
          if( deviceFound && fhrData!=null && testStarted){
            debugPrint("length ------ ${test.bpmEntries.length} , ${test.bpmEntries2.length} ");
            if(test.lengthOfTest>10 ){
              final avg1 = test.bpmEntries.sublist(test.bpmEntries.length-9).average;
              final avg2 = test.bpmEntries2.sublist(test.bpmEntries2.length-9).average;
              noData1 = (avg1  == 0 && avg2 ==0) && signalLossAlarm;
              if(test.lengthOfTest<180) {
                alarm1 = (test.bpmEntries.last > 160 ||
                    test.bpmEntries.last < 120) && avg1>0;
                debugPrint(
                    "alarm ------ $alarm1 $noData1 ${test.bpmEntries.average >
                        10} ");
              }
            }
            if(test.bpmEntries2.length>10 ){
              final avg2 = test.bpmEntries2.sublist(test.bpmEntries2.length-9).average;
              noData2 = avg2==0 && _volumePath==1 && signalLossAlarm;
              if(test.bpmEntries2.length < 180) {
                alarm2 = (test.bpmEntries2.last > 160 ||
                    test.bpmEntries2.last < 120) &&
                    avg2 > 0;
              }
              debugPrint("alarm 2------ $alarm2  $noData2 ${test.bpmEntries2.average>10}");
            }

            test.bpmEntries.add(fhrData!.fhr1);
            test.bpmEntries2.add(fhrData!.fhr2);
            test.mhrEntries.add(fhrData!.mhr);
            test.spo2Entries.add(fhrData!.spo2);
            test.tocoEntries.add(fhrData!.toco);
            test.lengthOfTest = test.bpmEntries.length;
            if((fhrData?.sys??0)!=0) {
              test.lastBp = {"systolic":fhrData!.sys,"diastolic":fhrData!.dia,"pulse":fhrData!.pulse};
            }
            if(fhrData!.fmFlag ==1) {
              test.movementEntries.add(test.bpmEntries.length);
            }
            if(fhrData!.afmFlag==1 && autoMovementMarking) {
              test.autoFetalMovement.add(test.bpmEntries.length);
            }

            if (timer.tick % 4 == 0) {
              //writeChar?.write(FhrCommandMaker.monitor(0));
              //debugPrint("------ write complete -- ${FhrCommandMaker.monitor(0)}");
            }

            if(_animationController.isAnimating){
              //_animationController.stop();
              _animationController.reset();
            }
            blink = false;
          }
          else if(testStarted){
            blink = true;
            test.bpmEntries.add(-1);
            test.bpmEntries2.add(-1);
            test.mhrEntries.add(-1);
            test.spo2Entries.add(-1);
            test.tocoEntries.add(-1);
            test.lengthOfTest = test.bpmEntries.length;
            //_flutterBeepPlus.beep(true);
            _flutterBeepPlus.playSysSound(AndroidSoundID.TONE_PROP_BEEP2);
            if(!_animationController.isAnimating){
              _animationController.repeat(reverse: false);
            }
          }

          if(alarm1 || noData1 ){
            _flutterBeepPlus.playSysSound(AndroidSoundID.TONE_PROP_BEEP);
            if(!_animationControllerFHR1.isAnimating){
              _animationControllerFHR1.repeat(reverse: false);
            }
          }else{
            if(_animationControllerFHR1.isAnimating) {
              _animationControllerFHR1.reset();
            }
          }
          if( alarm2 || noData2 ){
            _flutterBeepPlus.playSysSound(AndroidSoundID.TONE_PROP_BEEP);
            if(!_animationControllerFHR2.isAnimating){
              _animationControllerFHR2.repeat(reverse: false);
            }
          }else{
            if(_animationControllerFHR2.isAnimating) {
              _animationControllerFHR2.reset();
            }
          }

          if(test.bpmEntries.isNotEmpty && test.bpmEntries.average > 10 && test.lengthOfTest > 180 && timer.tick % 20 == 0){
            interpretations = Interpretations2.withData(test.bpmEntries, 37);
            if(interpretations!.basalHeartRate>160 || interpretations!.basalHeartRate<120){
              alarm1 = true;
              _flutterBeepPlus.playSysSound(AndroidSoundID.TONE_PROP_BEEP);

            }else{
              alarm1 = false;
            }
          }
          if(test.bpmEntries2.average > 10 && test.bpmEntries2 .length> 180 && timer.tick % 20 == 0){
            interpretations2 = Interpretations2.withData(test.bpmEntries2, 37);
            if(interpretations2!.basalHeartRate>160 || interpretations2!.basalHeartRate<120){
              alarm2 = true;
              _flutterBeepPlus.playSysSound(AndroidSoundID.TONE_PROP_BEEP);
            }else{
              alarm2 = false;
            }
          }

          if(test.lengthOfTest>30 && test.lengthOfTest%30 ==0 && test.motherId!=null){
            uploadTest(live: true);
          }
          if(testTime!=0 && test.lengthOfTest == (testTime*60)){
            stopTest();
          }
          if(mounted) {
            setState(() {});
          }
      },
    );
    }
    if(test.motherId!=null && testStarted) {
      uploadTest(live: true);
    }
  }

  void initialize(){
    auto = PrefService.getBool('liveInterpretations') ?? true;
    autoMovementMarking = PrefService.getBool('autoMovementMarking') ?? true;
    gridPreMin = PrefService.getInt('liveGridPreMin') ?? 3;
    pointsOnDisplay = ((22/gridPreMin)*60).toInt() ;
    testTime = PrefService.getInt('testTime') ?? 0;
    //highlight = PrefService.getBool('highlight') ?? false;
    if (test.lengthOfTest > 3600) {
      auto = false;
      //highlight = false;
      gridPreMin = 1;
    }
    //dataListener?.cancel();
    /*dataListener = readChar?.onValueReceived.listen((event) {
      //debugPrint("------------ ${event.toString()} ------");
        //debugPrint("${event.toList()}");
        //dataBuffer.addDataList(event, 0, event.length);
      getFHRData(event);
    });
    dataListenerSpO2?.cancel();
    dataListenerSpO2 = readCharSpO2?.onValueReceived.listen((event) {
      //debugPrint("------------ ${event.toString()} ------");
      //debugPrint("${event.toList()}");
      //dataBuffer.addDataList(event, 0, event.length);
      getSpO2Data(event);
    });
    readChar?.setNotifyValue(true);
    readCharSpO2?.setNotifyValue(true)*/
  }


  uploadTestAndMother(Mother mother){
    test.motherName = mother.name;
    test.gAge = ((mother.lmp)
        .difference(DateTime.now())
        .inDays ~/ 7).abs();
    final interpreter = Interpretations2
        .withData(
        test.bpmEntries, test.gAge!,
        test: test);
    //test.patientId

    //optimize data saved
    if(test.bpmEntries2.average<=0){
      test.bpmEntries2 =[];
    }
    if(test.tocoEntries.average<=0){
      test.tocoEntries =[];
    }
    test.baseLineEntries =[];
    //saveNewTest
    FirestoreDatabase(uid: user.documentId)
        .saveNewTestAndMother(
        test.toJson(), mother.toJson()).then((value) => test.motherId = value);
  }
  uploadTest({bool live = false}) async {

    if(!live) {
      if (test.bpmEntries.average <= 0) {
        test.bpmEntries = [];
      }
      if (test.bpmEntries2.average <= 0 ) {
        test.bpmEntries2 = [];
      }
      if (test.tocoEntries.average <= 0) {
        test.tocoEntries = [];
      }
      if (test.mhrEntries.average <= 0) {
        test.mhrEntries = [];
      }
      if (test.spo2Entries.average <= 0) {
        test.spo2Entries = [];
      }
    }
    test.baseLineEntries =[];
    test.live = live;
    /*if(test.bpmEntries.isNotEmpty) {
      final interpreter = Interpretations2
          .withData(
          test.bpmEntries, test.gAge!,
          test: test);
    }*/
    if(test.documentId== null){
      test.documentId = const Uuid().v4();
      test.id = test.documentId;
    }
    FirestoreDatabase(uid: user.documentId)
        .saveNewTest(test.toJson(),testId:test.documentId);
    debugPrint("-----------Test Id test live----------- ${test.documentId}");

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !testStarted,
      /*onPopInvoked: (pop){
        if(testStarted ) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Test is in progress...",),
          backgroundColor:   Color.fromRGBO(53, 54, 62, 1),
          showCloseIcon: true,
        ));
        } else {
          Navigator.pop(context);
        }},*/
      child: Scaffold(
        body: SafeArea(
            child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 8.w,),
                      IconButton(
                        iconSize: 32,
                        icon:
                        const Icon(Icons.arrow_back, size: 32, color: Colors.teal),
                        onPressed: () => testStarted? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Test is in progress...",),
                          backgroundColor:   Color.fromRGBO(53, 54, 62, 1),
                          showCloseIcon: true,
                        )): Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testMom?.name ?? "Anonymous",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14.sp,
                                  color: Colors.white)),
                              Text(
                                DateFormat('dd MMM yy - hh:mm a').format(test.createdOn),
                                style:  TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.sp,
                                    color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 0.2.sw,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30.w)),
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: testStarted ?[
                                  Colors.red,
                                  Colors.red.withOpacity(0.7),
                                  ]:[
                                    Theme.of(context).colorScheme.onPrimary,
                                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                                  ]
                                  )
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
                            testStarted?"Stop Test":"Start Test",
                            style: Theme.of(context).textTheme.titleLarge,//?.copyWith(fontSize: 36.sp),),
                          ),
                          onPressed: ()async {
                            HapticFeedback.vibrate();
                            if(testStarted) {
                              stopTest();
                            }else{
                              startTest();
                            }
                            setState(() {
                            });
                          },
                        )
                        /*ActionSlider.standard(
                          direction: testStarted? TextDirection.rtl: TextDirection.ltr,
                          action: (controller) async {
                            HapticFeedback.vibrate();
                            if(testStarted) {
                              stopTest();
                            }else{
                              startTest();
                            }
                            setState(() {
                            });
                          },
                          controller: _actionController,
                          successIcon:  const CircleIconButton(
                            icon: FontAwesomeIcons.play,
                            isSelected: false,
                            margin: EdgeInsets.zero,
                            showShadows: false,
                            size: 55,
                          ),
                          icon: CircleIconButton(
                            icon: testStarted?FontAwesomeIcons.stop:FontAwesomeIcons.play,
                            isSelected: testStarted?true:false,
                            margin: EdgeInsets.zero,
                            showShadows: false,
                            size: 55,
                          ),

                          backgroundColor: const Color.fromRGBO(53, 54, 62, 1) ,
                          child:  Text('Slide to ${testStarted? "STOP test":"START test" }',style: Theme.of(context).textTheme.labelLarge,),
                        ),*/
                      ),
                      /*Container(
                          padding: const EdgeInsets.all(3.0),
                          margin:  EdgeInsets.all(8.h),
                          width: 0.1.sh,
                          height: 0.1.sh,
                          decoration:  BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(80.h)),
                          ),
                          child: Center(
                              child: IconButton(
                                icon:  Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                  size: 34.h,
                                ),
                                onPressed: () async {

                                },
                              ))),*/
                      SizedBox(width: 16.w,)

                    ],

                  ),

                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleIconButton(
                          icon: Icons.add,
                          num: AutoSizeText.rich(
                            TextSpan(
                              text: _fhrPath==0?"All":"US$_fhrPath",
                              children: [
                                TextSpan(text: "\nFHR",style: Theme.of(context).textTheme.labelSmall)
                              ],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          isSelected:false,
                          margin: EdgeInsets.zero,
                          size: 54.w,
                          onTap: (){
                            if(!(PrefService.getBool("hasFhr2")??true))return;
                            _fhrPath = _fhrPath==2?0:_fhrPath+1;
                            if(_fhrPath!=0){
                              _volumePath = _fhrPath-1;
                               writeChar?.write(
                                FhrCommandMaker.fhrVolume(
                                _volume.toInt(), _volumePath)
                               );
                            }
                            setState(() {});
                          },
                        ),
                        SizedBox(width:4.w),
                        Center(child:BlinkingWidget.create(Container(
                              width: 0.25.sw,
                              height: 62.w,
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(100.w),
                                color: (blink )? Colors.red:  const Color.fromRGBO(53, 54, 62, 1) ,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleIconButton(
                                    icon: deviceFound?Icons.bluetooth_connected_outlined:Icons.bluetooth_disabled_outlined,
                                    isSelected:deviceFound,
                                    margin: EdgeInsets.zero,
                                    size: 54.w,
                                  ),
                                  Container(
                                    width: 0.125.sw,
                                    height: 72.h,
                                    padding: EdgeInsets.symmetric(vertical:16.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(60.w),
                                      color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
                                    ),
                                    alignment: Alignment.center,
                                    child:
                                    AutoSizeText(
                                      "${stopwatch.elapsed.inHours.toString().padLeft(2,"0")}:${stopwatch.elapsed.inMinutes.remainder(60).toString().padLeft(2,"0")}:${(stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2,"0"))}",
                                      style: Theme.of(context).textTheme.bodyLarge,),
                                  ),
                                  PullDownButton(
                                    itemBuilder: (context) =>[0,20,30,60].map((time) => PullDownMenuItem.selectable(
                                      onTap: () {
                                        PrefService.setInt("testTime", time);
                                        testTime = time;
                                        setState(() {});
                                      },
                                      selected: testTime==time,
                                      title: time==0?'NA':"$time min",
                                    )).toList(),

                                    buttonBuilder: (context, showMenu) => CircleIconButton(
                                      num: AutoSizeText.rich(
                                        TextSpan(
                                          text: "${testTime==0?"--":testTime}",
                                          children: [
                                            TextSpan(text: "\nmin",style: Theme.of(context).textTheme.labelSmall)
                                          ],
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      onTap: showMenu,
                                      icon: Icons.add,
                                      isSelected:deviceFound,
                                      margin: EdgeInsets.zero,
                                      size: 54.w,
                                    ),
                                  ),

                                ],
                              ),
                            ), _animationController),),
                        SizedBox(width:4.w),
                        CircleIconButton(
                          icon: gridPreMin==1?Icons.zoom_in:Icons.zoom_out,
                          isSelected:false,
                          margin: EdgeInsets.zero,
                          size: 54.w,
                          onTap: (){
                            gridPreMin = gridPreMin==1?3:1;
                            pointsOnDisplay = ((22/gridPreMin)*60).toInt() ;

                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            StreamBuilder<FhrData?>(
              stream: BluetoothCTGService.instance.streamData(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  fhrData = snapshot.data;
                }
                return Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                              onHorizontalDragStart: (DragStartDetails start) =>
                                  _onDragStart(context, start),
                              onHorizontalDragUpdate: (DragUpdateDetails update) =>
                                  _handleHorizontalDragUpdate(context, update),
                              onHorizontalDragEnd: (DragEndDetails end)=> _onDragEnd(context,end),
                              child: Container(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  //width: MediaQuery.of(context).size.width* 0.7 ,
                                  height: 0.85.sh,
                                  child: CustomPaint(
                                    key: Key("${test.bpmEntries.length}"),
                                    painter: GraphPainter(test, dragOn?mOffset:test.lengthOfTest, gridPreMin,displayFhr: _fhrPath,interpretations: interpretations),
                                  ))),
                        ),
                        Container(
                          width: 0.225.sw,
                          height: 0.85.sh,
                          padding: EdgeInsets.only(top: 8.h,bottom: 1),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            border: Border(left: BorderSide(width: 2, color: Colors.black)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              BlinkingWidget.create(
                                 Container(
                                    height: (PrefService.getBool("hasFhr2")??true)?0.21.sh:0.31.sh,
                                    decoration: BoxDecoration(
                                      border: const Border(
                                          bottom:
                                          BorderSide(width: 0.5, color: Colors.grey)),
                                      color: (alarm1 || noData1 )? Colors.red:Colors.transparent
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: AutoSizeText(
                                                      '${(fhrData?.fhr1 ?? 0)==0? "---" : (fhrData?.fhr1 ?? "---")}',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 120.sp,
                                                          color: AppColors.us1,
                                                          fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                                 Container(
                                                    height: 0.25.sh,
                                                    width: 0.1.sh,
                                                    child: Visibility(
                                                      visible: _volumePath == 0,
                                                      child: FlutterSlider(
                                                      values: [_volume],
                                                      axis: Axis.vertical,
                                                      disabled: _volumePath == 1,
                                                      max: 7,
                                                      min: 1,
                                                      rtl: true,
                                                      handlerHeight: 40,
                                                      handlerWidth: 32,
                                                      tooltip: FlutterSliderTooltip(
                                                          disabled: true),
                                                      handler: FlutterSliderHandler(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                            color: Colors.transparent),
                                                        child: Container(
                                                            margin: EdgeInsets.all(5.w),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius.circular(15),
                                                              border: Border.all(
                                                                  color: Colors.white,
                                                                  width: 1),
                                                              gradient: const RadialGradient(
                                                                colors: [
                                                                  Color.fromRGBO(
                                                                      128, 128, 138, 1),
                                                                  Color.fromRGBO(
                                                                      53, 54, 62, 1),
                                                                ],
                                                                center: Alignment(1, 1),
                                                                focal:
                                                                Alignment(-0.75, -0.75),
                                                                focalRadius: 1.0,
                                                              ),
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  color: Colors.white54,
                                                                  blurRadius: 8.0,
                                                                  offset: Offset(2.0, 2.0),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                                  Icons.menu,
                                                                  size: 12,
                                                                  color: Theme.of(context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                ))),
                                                      ),
                                                      trackBar: FlutterSliderTrackBar(
                                                        //activeTrackBarHeight: 8,
                                                        //inactiveTrackBarHeight: 4,
                                                        inactiveTrackBar: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .colorScheme.secondary.withOpacity(0.5),
                                                          border: Border.all(
                                                              width: 2,
                                                              color: Theme.of(context)
                                                                  .colorScheme.secondary.withOpacity(0.5)),
                                                        ),
                                                        activeTrackBar: const BoxDecoration(
                                                          gradient: RadialGradient(
                                                            colors: [
                                                              Color.fromRGBO(
                                                                  128, 128, 138, 1),
                                                              Color.fromRGBO(53, 54, 62, 1),
                                                            ],
                                                            center: Alignment.bottomCenter,
                                                            focal: Alignment.topCenter,
                                                            focalRadius: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      handlerAnimation:
                                                      const FlutterSliderHandlerAnimation(
                                                          curve: Curves.elasticOut,
                                                          reverseCurve: Curves.bounceIn,
                                                          duration:
                                                          Duration(milliseconds: 500),
                                                          scale: 1.2),
                                                      onDragStarted: (handlerIndex,
                                                          lowerValue, upperValue) {
                                                        HapticFeedback.heavyImpact();
                                                      },
                                                      onDragging: (handlerIndex, lowerValue,
                                                          upperValue) {
                                                        _volume = lowerValue;
                                                        //_upperValue = upperValue;*/
                                                        setState(() {});
                                                      },
                                                      onDragCompleted: (handlerIndex,
                                                          lowerValue, upperValue) async {
                                                        HapticFeedback.heavyImpact();
                                                        _volume = lowerValue;
                                                        await writeChar?.write(
                                                            FhrCommandMaker.fhrVolume(
                                                                _volume.toInt(), _volumePath)
                                                            );
                                                        debugPrint("------ write complete fhrVolume -- ${FhrCommandMaker.fhrVolume(_volume.toInt(), _volumePath)}");
                                                      },
                                                      hatchMark: FlutterSliderHatchMark(
                                                        displayLines: true,
                                                        linesDistanceFromTrackBar: 0,
                                                        /*labelBox: FlutterSliderSizedBox(
                                                                    width: 40,
                                                                    height: 20,
                                                                    foregroundDecoration: BoxDecoration(color: Color.fromARGB(39, 54, 165, 244)),
                                                                    transform: Matrix4.translationValues(0, 30, 0),
                                                                  ),*/
                                                        linesAlignment:
                                                        FlutterSliderHatchMarkAlignment
                                                            .left,
                                                        density: 0.3,
                                                        smallLine:
                                                        const FlutterSliderSizedBox(
                                                          width: 1,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                              color: Colors.transparent),
                                                        ),
                                                        bigLine: FlutterSliderSizedBox(
                                                          width: 1,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            padding: EdgeInsets.symmetric(vertical: 4.h),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "  FHR 1",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.us1,
                                                      fontSize: 22.sp,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 0.1.sh,
                                                  child: IconButton(
                                                    iconSize: 24.w,
                                                    //backgroundColor: Colors.transparent,
                                                    //margin: EdgeInsets.all(2.h),
                                                    icon: Icon(_volumePath == 1
                                                        ? FontAwesomeIcons.volumeXmark
                                                        : _volume < 4
                                                        ? FontAwesomeIcons.volumeLow
                                                        : FontAwesomeIcons.volumeHigh),
                                                    onPressed: () async {
                                                      if (_volumePath == 1) {
                                                        HapticFeedback.mediumImpact();
                                                        _volumePath = 0;
                                                        await writeChar?.write(
                                                            FhrCommandMaker.fhrVolume(
                                                                _volume.toInt(),
                                                                _volumePath)
                                                            );
                                                        debugPrint("------ write complete fhrVolume -- ${FhrCommandMaker.fhrVolume(_volume.toInt(), _volumePath)}");
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ])),
                                _animationControllerFHR1
                              ),
                              if(PrefService.getBool("hasFhr2")??true)
                              BlinkingWidget.create(
                                  Container(
                                    height: (PrefService.getBool("hasFhr2")??true)?0.21.sh:0.31.sh,
                                    decoration: BoxDecoration(
                                        border: const Border(
                                            bottom:
                                            BorderSide(width: 0.5, color: Colors.grey)),
                                        color: (alarm2 || noData2)? Colors.red:Colors.transparent
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: AutoSizeText(
                                                      '${(fhrData?.fhr2 ?? 0)==0? "---" : (fhrData?.fhr2 ?? "---")}',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 120.sp,
                                                          color: AppColors.us2,
                                                          fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                                 Container(
                                                    height: 0.25.sh,
                                                    width: 0.1.sh,
                                                    child: Visibility(
                                                      visible: _volumePath == 1,
                                                      child: FlutterSlider(
                                                      values: [_volume],
                                                      axis: Axis.vertical,
                                                      disabled: _volumePath == 0,
                                                      max: 7,
                                                      min: 1,
                                                      rtl: true,
                                                      handlerHeight: 40,
                                                      handlerWidth: 32,
                                                      tooltip: FlutterSliderTooltip(
                                                          disabled: true),
                                                      handler: FlutterSliderHandler(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                            color: Colors.transparent),
                                                        child: Container(
                                                            margin: EdgeInsets.all(5.w),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius.circular(15),
                                                              border: Border.all(
                                                                  color: Colors.white,
                                                                  width: 1),
                                                              gradient: const RadialGradient(
                                                                colors: [
                                                                  Color.fromRGBO(
                                                                      128, 128, 138, 1),
                                                                  Color.fromRGBO(
                                                                      53, 54, 62, 1),
                                                                ],
                                                                center: Alignment(1, 1),
                                                                focal:
                                                                Alignment(-0.75, -0.75),
                                                                focalRadius: 1.0,
                                                              ),
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  color: Colors.black38,
                                                                  blurRadius: 8.0,
                                                                  offset: Offset(2.0, 2.0),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                                  Icons.menu,
                                                                  size: 12,
                                                                  color: Theme.of(context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                ))),
                                                      ),
                                                      trackBar: FlutterSliderTrackBar(
                                                        //activeTrackBarHeight: 8,
                                                        //inactiveTrackBarHeight: 4,
                                                        inactiveTrackBar: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .colorScheme.secondary.withOpacity(0.5),
                                                          border: Border.all(
                                                              width: 2,
                                                              color: Theme.of(context)
                                                                  .colorScheme.secondary.withOpacity(0.5)),
                                                        ),
                                                        activeTrackBar: const BoxDecoration(
                                                          gradient: RadialGradient(
                                                            colors: [
                                                              Color.fromRGBO(
                                                                  128, 128, 138, 1),
                                                              Color.fromRGBO(53, 54, 62, 1),
                                                            ],
                                                            center: Alignment.bottomCenter,
                                                            focal: Alignment.topCenter,
                                                            focalRadius: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      handlerAnimation:
                                                      const FlutterSliderHandlerAnimation(
                                                          curve: Curves.elasticOut,
                                                          reverseCurve: Curves.bounceIn,
                                                          duration:
                                                          Duration(milliseconds: 500),
                                                          scale: 1.2),
                                                      onDragStarted: (handlerIndex,
                                                          lowerValue, upperValue) {
                                                        HapticFeedback.lightImpact();
                                                      },
                                                      onDragging: (handlerIndex, lowerValue,
                                                          upperValue) {
                                                        _volume = lowerValue;
                                                        //_upperValue = upperValue;*/
                                                        setState(() {});
                                                      },
                                                      onDragCompleted: (handlerIndex,
                                                          lowerValue, upperValue) async {
                                                        HapticFeedback.lightImpact();
                                                        _volume = lowerValue;
                                                        await writeChar?.write(
                                                            FhrCommandMaker.fhrVolume(
                                                                _volume.toInt(), _volumePath)
                                                            );
                                                        debugPrint("------ write complete fhrVolume -- ${FhrCommandMaker.fhrVolume(_volume.toInt(), _volumePath)}");
                                                      },
                                                      hatchMark: FlutterSliderHatchMark(
                                                        displayLines: true,
                                                        linesDistanceFromTrackBar: 0,
                                                        /*labelBox: FlutterSliderSizedBox(
                                                                    width: 40,
                                                                    height: 20,
                                                                    foregroundDecoration: BoxDecoration(color: Color.fromARGB(39, 54, 165, 244)),
                                                                    transform: Matrix4.translationValues(0, 30, 0),
                                                                  ),*/
                                                        linesAlignment:
                                                        FlutterSliderHatchMarkAlignment
                                                            .left,
                                                        density: 0.3,
                                                        smallLine:
                                                        const FlutterSliderSizedBox(
                                                          width: 1,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                              color: Colors.transparent),
                                                        ),
                                                        bigLine: FlutterSliderSizedBox(
                                                          width: 1,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            padding: EdgeInsets.symmetric(vertical: 4.h),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "  FHR 2",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.us2,
                                                      fontSize: 22.sp,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 0.1.sh,
                                                  child: IconButton(
                                                    iconSize: 24.w,
                                                    //backgroundColor: Colors.transparent,
                                                    //margin: EdgeInsets.all(2.h),
                                                    icon: Icon(_volumePath == 0
                                                        ? FontAwesomeIcons.volumeXmark
                                                        : _volume < 4
                                                        ? FontAwesomeIcons.volumeLow
                                                        : FontAwesomeIcons.volumeHigh),
                                                    onPressed: () async {
                                                      if (_volumePath == 0) {
                                                        HapticFeedback.mediumImpact();
                                                        _volumePath = 1;
                                                        await writeChar?.write(
                                                            FhrCommandMaker.fhrVolume(
                                                                _volume.toInt(),
                                                                _volumePath)
                                                            );
                                                        debugPrint("------ write complete fhrVolume -- ${FhrCommandMaker.fhrVolume(_volume.toInt(), _volumePath)}");
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ])),
                                  _animationControllerFHR2),
                              Container(
                                  height: (PrefService.getBool("hasFhr2")??true)?0.21.sh:0.3.sh,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                        BorderSide(width: 0.5, color: Colors.grey)),
                                  ),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: AutoSizeText(
                                                    '${fhrData?.toco ?? "---"}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 120.sp,
                                                        color: AppColors.uc,
                                                        fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 0.25.sh,
                                                width: 0.1.sh,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText.rich(TextSpan(text:
                                                      '${test.movementEntries.length}',
                                                          //'${fhrData?.sys ?? "---"}',
                                                          children: [
                                                            TextSpan(text: "\nmanual",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w400,
                                                                  color: Colors.white54,
                                                                  fontSize: 12.sp,
                                                                ))
                                                          ]
                                                      ),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.white,
                                                          fontSize: 28.sp,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: AutoSizeText.rich(TextSpan(text:
                                                      '${test.autoFetalMovement.length}',
                                                          //'${fhrData?.dia ?? "---"}',
                                                          children: [
                                                            TextSpan(text: "\nauto",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w400,
                                                                  color: Colors.white54,
                                                                  fontSize: 12.sp,
                                                                ))
                                                          ]
                                                      ),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.white,
                                                          fontSize: 28.sp,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer,
                                          padding: EdgeInsets.symmetric(vertical: 4.h),
                                          alignment: Alignment.center,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "  Toco",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.uc,
                                                    fontSize: 22.sp,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 0.1.sh,
                                                child:RiveAnimatedIcon(
                                                  key: Key(_isTocoReseting.toString()),
                                                  riveIcon: RiveIcon.reload,
                                                  width: 42.w,
                                                  height: 42.w,
                                                  strokeWidth: 8,
                                                  splashColor: Colors.white54,
                                                  loopAnimation: _isTocoReseting,
                                                  onTap: () {
                                                    debugPrint('tapped toco');
                                                    _isTocoReseting = true;
                                                    HapticFeedback.heavyImpact();
                                                    writeChar?.write(FhrCommandMaker.tocoReset(0));
                                                    Future.delayed(
                                                        const Duration(seconds: 3),()=>
                                                        setState(() {_isTocoReseting = false;
                                                        }));
                                                    setState(() {});
                                                  },
                                                  onHover: (value) {
                                                    debugPrint('value is $value');
                                                  },
                                                  color: Colors.white,
                                                ),
                                               /* CircleIconButton(
                                                  size: 34.w,
                                                  backgroundColor: Colors.transparent,
                                                  margin: EdgeInsets.all(2.h),
                                                  icon: _isTocoReseting?Icons.timer_3_rounded:FontAwesomeIcons.arrowsRotate,
                                                  onTap: () async {
                                                    _isTocoReseting = true;
                                                    setState(() {});
                                                    HapticFeedback.heavyImpact();
                                                    writeChar?.write(FhrCommandMaker.tocoReset(0)
                                                          );
                                                    Future.delayed(
                                                        const Duration(seconds: 5),()=>
                                                        setState(() {_isTocoReseting = false;
                                                    }));
                                                      debugPrint(
                                                          "------ write complete tocoReset -- ${FhrCommandMaker.tocoReset(0)}");
                                                      setState(() {});
                                                  },
                                                ),*/
                                              ),
                                            ],
                                          ),
                                        ),
                                      ])),
                              Container(
                                  height: 0.1.sh,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                        BorderSide(width: 0.5, color: Colors.grey)),
                                  ),
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    padding: EdgeInsets.symmetric(vertical: 4.h),
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.sys ?? 0)==0? "---" : (fhrData?.sys ?? "---")}',
                                              //'${fhrData?.sys ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nSys",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.dia ?? 0)==0? "---" : (fhrData?.dia ?? "---")}',
                                              //'${fhrData?.dia ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nDia",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.pulse ?? 0)==0? "---" : (fhrData?.pulse ?? "---")}',
                                              //'${fhrData?.pulse ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nPulse",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 0.1.sh,
                                          child: CircleIconButton(
                                            icon: _isFetchingBp?Icons.timer_3_rounded:Icons.refresh,
                                            isSelected:deviceSpO2Found,
                                            margin: EdgeInsets.all(2.h),
                                            size: 38.w,
                                            onTap: (){
                                              fetchBp();
                                            },
                                          ),
                                          /*CircleIconButton(
                                            size: 34.w,
                                            backgroundColor: Colors.transparent,
                                            margin: EdgeInsets.all(2.h),
                                            icon: FontAwesomeIcons.bluetooth,
                                            onTap: () async {
                                              setState(() {});
                                            },
                                          ),*/
                                        ),

                                      ],
                                    ),
                                  )),
                              Container(
                                  height: 0.1.sh,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                        BorderSide(width: 0.5, color: Colors.grey)),
                                  ),
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    padding: EdgeInsets.symmetric(vertical: 4.h),
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.mhr ?? 0)==0? "---" : (fhrData?.mhr ?? "---")}',
                                              // '${fhrData?.mhr ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nMHR",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.spo2 ?? 0)==0? "---" : (fhrData?.spo2 ?? "---")}',
                                              //'${fhrData?.mhr ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nSpO2",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText.rich(TextSpan(text:
                                          '${(fhrData?.pi ?? 0)==0? "---" : (fhrData?.pi.toStringAsFixed(1) ?? "---")}',
                                              //'${fhrData?.pi ?? "---"}',
                                              children: [
                                                TextSpan(text: "\nPI%",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 12.sp,
                                                    ))
                                              ]
                                          ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 28.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 0.1.sh,
                                          child: CircleIconButton(
                                            icon: deviceSpO2Found?Icons.bluetooth_connected_outlined:Icons.bluetooth_disabled_outlined,
                                            isSelected:deviceSpO2Found,
                                            margin: EdgeInsets.all(2.h),
                                            size: 38.w,
                                            onTap: ()=> BluetoothSPo2Service.instance.startBle(),
                                          ),
                                          /*CircleIconButton(
                                            size: 34.w,
                                            backgroundColor: Colors.transparent,
                                            margin: EdgeInsets.all(2.h),
                                            icon: FontAwesomeIcons.bluetooth,
                                            onTap: () async {
                                              setState(() {});
                                            },
                                          ),*/
                                        ),

                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Visibility(
                        visible:dragOn,
                        child: Padding(
                          padding:  EdgeInsets.only(left:64.w,bottom: 32.h),
                          child: CircleIconButton(
                            icon: Icons.format_indent_increase_sharp,
                            isSelected:false,
                            margin: EdgeInsets.zero,
                            size: 54.w,
                            onTap: (){
                              dragOn = false;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    )

                  ],
                );
              }
            ),
          ],
        )),
      ),
    );
  }

  void fetchBp(){
    _isFetchingBp = true;
    setState(() {});
    Future.delayed(
        const Duration(seconds: 5),()=>setState(() {
      _isFetchingBp = false;
    }));
    const methodChannel = MethodChannel('com.carenx.app/callback');
    methodChannel.invokeMethod("startBpBleTransfer");
  }

  int _calculateMaxScrollOffset() {
    // Calculate the maximum scrollable distance based on data size and visible points
    //const visiblePoints = pointsOnDisplay; // Adjust as needed
    return  test.bpmEntries.length - pointsOnDisplay;
  }

  void _handleHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) {
    setState(() {
      mOffset = (mOffset - details.delta.dx).clamp(0, _calculateMaxScrollOffset()).toInt();
    });
  }

  _onDragEnd(BuildContext context, DragEndDetails start) {
    dragOn = test.bpmEntries.length>pointsOnDisplay;

    //dragOn = test.bpmEntries.length>(mOffset+pointsOnDisplay);
    setState(() {
    });
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }
  _onDragStart(BuildContext context, DragStartDetails start) {
    print(start.globalPosition.toString());
    //RenderBox getBox = context.findRenderObject() as RenderBox;
    //mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    dragOn = true;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > test.bpmEntries.length) {
      pos = test.bpmEntries.length - 10;
    }

    return pos;
  }
/*
  void listenToChange(BluetoothConnectionState state) {
    debugPrint("-------BluetoothConnectionState test : ${state.name}-----");
    switch (state) {
      case BluetoothConnectionState.connected:
        debugPrint("-------BluetoothConnectionState.connected-----");
        deviceFound = true;
        btDevice?.requestMtu(100);

        //discoverServices();
        Future.delayed(const Duration(seconds: 1),() {
          if (mounted) {
            setState(() {});
          }
        });
        debugPrint("-------BluetoothConnectionState.connected-----");
        break;
      case BluetoothConnectionState.disconnected:
        debugPrint("-------BluetoothConnectionState test in disconnected : ${state.name}-----");
        deviceFound = false;
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
    debugPrint("-------BluetoothConnectionState spo2 : ${state.name}-----");
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


  /*List<StreamSubscription<List<int>>?>? subscriptions;
  List<Service> btServices2 = [];
  List<Characteristic> btCharacteristics2 = [];*/

  /*String readService = "6e400001-b5a3-f393-e0a9-e50e24dcca91";
  String readCharacteristics = "6e400003-b5a3-f393-e0a9-e50e24dcca93";
  String writeCharacteristics = "6e400002-b5a3-f393-e0a9-e50e24dcca92";*/

  /*_updateValuesFromBT() async {
    try {
      final data = await dataBuffer.getBag();
      if(data !=null) {
        //debugPrint("-------Data read ${data?.mValue.toList()} -----");
        bluetoothData = data ?? bluetoothData;
        fhrData = FhrData.fromRaw(bluetoothData!);
      }
    } catch (ex) {
      debugPrint("update method ${ex.toString()}");
      if (mounted) {
        setState(() {});
      }
    }
  }*/

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }



  FhrByteDataBuffer dataBuffer = FhrByteDataBuffer();

}

