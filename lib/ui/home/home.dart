import 'dart:async';

import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/ble/bluetooth_spo2_service.dart';
import 'package:l8fe/ble/unified_service.dart';
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
import 'package:l8fe/utils/fhr_command_maker.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tab_container/tab_container.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/firestore_database.dart';

//const String DEVICE_NAME = "L8T32B2019120011";
//const String DEVICE_NAME =  "L8T32B2021010004";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String query = "*";
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
    WakelockPlus.enable();
    prefs = context.read<SharedPreferences>();
    _tabContainerController = TabController(vsync: this, length: 5);
    _tabContainerController.addListener(() {
      if (_tabContainerController.index == 0) {
        debugPrint("start setNotifyValue true");
      } else {
        debugPrint(
            "stop setNotifyValue false ${_tabContainerController.index}");
      }
      _pageIndex = _tabContainerController.index;
      _pageController.jumpToPage(_pageIndex);
      if (mounted) {
        setState(() {});
      }
    });
    user = context.read<SessionCubit>().currentUser.value!;

    tabChildren = getChildren();
    // initBt();
    // BluetoothCTGService.instance.startBle(user);
    UnifiedBluetoothService().connect(user);

    UnifiedBluetoothService().connectedDeviceNotifier.addListener(() {
      if (mounted) {
          deviceFound = UnifiedBluetoothService().connectedDeviceNotifier.value;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BluetoothSPo2Service.instance.deviceReady.notifyListeners();
    // BluetoothCTGService.instance.deviceReady.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _timer?.cancel();
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

  // initBt() {
  //   BluetoothCTGService.instance.deviceReady.addListener(() async {
  //     deviceFound = BluetoothCTGService.instance.deviceReady.value;
  //     if (BluetoothCTGService.instance.deviceReady.value) {
  //       btDevice = BluetoothCTGService.instance.device;
  //       readChar = BluetoothCTGService.instance.readChar;
  //       writeChar = BluetoothCTGService.instance.writeChar;
  //     }
  //     if (mounted) setState(() {});
  //   });
  //
  //   BluetoothSPo2Service.instance.deviceReady.addListener(() async {
  //     deviceSpO2Found = BluetoothSPo2Service.instance.deviceReady.value;
  //     if (BluetoothSPo2Service.instance.deviceReady.value) {
  //       btDeviceSPo2 = BluetoothSPo2Service.instance.device;
  //       readCharSpO2 = BluetoothSPo2Service.instance.pulseOximeterChar;
  //       await readCharSpO2?.setNotifyValue(true);
  //     }
  //     if (mounted) setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
            statusBarColor: Colors.transparent, // status bar color
            statusBarIconBrightness:
                Brightness.light, // status bar icons' color
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarDividerColor:
                Theme.of(context).scaffoldBackgroundColor,
          ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            height: 1.sh,
            constraints: BoxConstraints(
              minHeight: 1.sh,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 0.15.sh,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
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
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OrganizationHome(),
                                      ),
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/feto_icon.svg',
                                    height: 0.08.sh,
                                    fit: BoxFit.fitHeight,
                                    alignment: Alignment.centerLeft,
                                    width: 40.h,
                                  ),
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      user.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18.sp,
                                          color: Colors.white),
                                    ),
                                    AutoSizeText(user.deviceName,
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
                          SizedBox(
                            width: 10.w,
                          ),
                          RichText(
                            text: const TextSpan(
                              text: "Support Number",
                              children: [
                                TextSpan(
                                  text: "\n9326775598",
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
                          tabExtent: 75.w,
                          tabsEnd: 0.4,
                          tabBorderRadius:
                              BorderRadius.all(Radius.circular(15.w)),
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
                          colors: <Color>[
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                          tabs: [
                            const CircleIconButton(icon: Icons.home),
                            CircleIconButton(
                              icon: deviceFound
                                  ? Icons.bluetooth_connected_outlined
                                  : Icons.bluetooth_disabled_outlined,
                              isSelected: deviceFound,
                            ),
                            const CircleIconButton(icon: Icons.people),
                            const CircleIconButton(icon: Icons.search),
                            const CircleIconButton(
                              icon: Icons.settings,
                            ),
                          ],
                          //isStringTabs: false,
                          children: [
                            SizedBox(
                              height: 0.65.sh,
                              width: 0.95.sw,
                            ),
                            SizedBox(
                              height: 0.6.sh,
                              width: 0.9.sw,
                            ),
                            SizedBox(
                              height: 0.6.sh,
                              width: 0.9.sw,
                            ),
                            SizedBox(
                              height: 0.6.sh,
                              width: 0.9.sw,
                            ),
                            SizedBox(
                              height: 0.6.sh,
                              width: 0.9.sw,
                            ),
                          ],
                        ),
                        Container(
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.only(bottom: 0.125.sh),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.w),
                                  topRight: Radius.circular(15.w)),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          child: PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _pageController,
                            onPageChanged: _onPageViewChange,
                            clipBehavior: Clip.none,
                            children: tabChildren,
                          ),
                        ),
                        if (_pageIndex == 0 && deviceFound)
                          Positioned(
                            //alignment: Alignment.bottomRight,
                            bottom: 4.h,
                            right: 24.w,
                            child: Container(
                              width: 0.25.sw,
                              //padding: EdgeInsets.symmetric(vertical:8.w,horizontal: 16),
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.w, horizontal: 16),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.w)),
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Theme.of(context).colorScheme.onPrimary,
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withOpacity(0.7),
                                      ])),
                              child: MaterialButton(
                                //color:   Color(0xFF139DCB) ,
                                height: 80.h,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(30.w))),
                                highlightColor: Colors.white.withOpacity(0.5),
                                splashColor: Colors.white.withOpacity(0.5),
                                visualDensity: VisualDensity.compact,

                                child: AutoSizeText(
                                  "Start New Test",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge, //?.copyWith(fontSize: 36.sp),),
                                ),
                                onPressed: () async {
                                  _timer?.cancel();
                                  //changeSub?.cancel();
                                  //dataListener?.cancel();
                                  //dataListenerSpO2?.cancel();
                                  writeChar
                                      ?.write(FhrCommandMaker.tocoReset(0));
                                  writeChar
                                      ?.write(FhrCommandMaker.fhrVolume(7, 0));
                                  writeChar?.write(FhrCommandMaker.monitor(0));
                                  if (PrefService.getBool('preSaveMother') ??
                                      false) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => SaveMotherDialog(
                                        onNewPressed: (map) async {
                                          Navigator.of(ctx).pop();
                                          debugPrint(
                                              "doctorName:  ${map["doctorName"]}");
                                          Mother mom = Mother.fromUser(
                                              user.toJson(), map);
                                          FirestoreDatabase(
                                                  uid: user.documentId)
                                              .saveNewMother(mom.toJson());
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      TestView(mom: mom)));
                                          writeChar?.write(
                                              FhrCommandMaker.monitor(255));
                                          //reSetBt(true);
                                        },
                                        onSkipPressed: () async {
                                          Navigator.of(ctx).pop();
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const TestView()));
                                          writeChar?.write(
                                              FhrCommandMaker.monitor(255));
                                          //reSetBt(true);
                                        },
                                      ),
                                    );
                                  } else {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const TestView(),
                                      ),
                                    );
                                    writeChar?.write(
                                      FhrCommandMaker.monitor(255),
                                    );
                                    //reSetBt(true);
                                  }
                                },
                              ),
                            ),
                          ),
                        if (_pageIndex == 4)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 0.25.sw,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.w, horizontal: 16),
                              child: ActionSlider.standard(
                                direction: TextDirection.rtl,
                                action: (controller) async {
                                  HapticFeedback.vibrate();
                                  context.read<SessionCubit>().signOut();
                                  setState(() {});
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
                                backgroundColor:
                                    const Color.fromRGBO(53, 54, 62, 1),
                                child: Text(
                                  'Slide to SignOut',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(left: 32.w, bottom: 4.h),
                  child: RichText(
                    text: TextSpan(
                      text: "App version : ",
                      children: const [TextSpan(text: AppConstants.version)],
                      style: TextStyle(
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
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getChildren() {
    return [
      const HomeView(),
      DeviceListScreen(pageController: _pageController),
      const RecentMothersView(
        key: Key("RecentMothersView"),
      ),
      const RecentTestsView(
        key: Key("RecentTestsView"),
      ),
      const SettingsView()
    ];
  }

  void _onPageViewChange(int value) {
    _pageIndex = value;
    setState(() {});
  }
}
