
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/constants/my_color_scheme.dart';
import 'package:l8fe/utils/fhr_data.dart';
import 'package:preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  bool isFetchingBp = false;

  late final SharedPreferences prefs;


  @override
  void initState() {
    prefs = context.read<SharedPreferences>();
    super.initState();
  }
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    FhrData? fhrData;
    return StreamBuilder<FhrData?>(
      stream: BluetoothCTGService.instance.streamData(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          fhrData = snapshot.data;
        }
        return Container(
          //margin: EdgeInsets.symmetric(horizontal: 8.w),
          child: Container(
            height: 0.6.sh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                        height: 0.4.sh,
                        width: (PrefService.getBool("hasFhr2")??true)?0.2.sw:0.3.sw,
                        child: Column(
                          //mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${(fhrData?.fhr1 ?? 0)==0? "---" : (fhrData?.fhr1 ?? "---")}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: (PrefService.getBool("hasFhr2")??true)?112.sp:156.sp,
                                        color: AppColors.us1,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Text(
                                "FHR 1",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.us1,
                                  fontSize: 22.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ])),
                    if(PrefService.getBool("hasFhr2")??true)
                    SizedBox(
                        height: 0.4.sh,
                        width: 0.2.sw,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${(fhrData?.fhr2 ?? 0)==0? "---" : (fhrData?.fhr2 ?? "---")}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 112.sp,
                                        color: AppColors.us2,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Text(
                                "FHR 2",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.us2,
                                  fontSize: 22.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ])),
                    SizedBox(
                        height: 0.4.sh,
                        width: (PrefService.getBool("hasFhr2")??true)?0.2.sw:0.3.sw,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${fhrData?.toco ?? "---"}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: (PrefService.getBool("hasFhr2")??true)?112.sp:156.sp,
                                        color: AppColors.uc,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Text(
                                "Toco",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.uc,
                                  fontSize: 22.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ])),
                    Container(
                      width: 0.3.sw,
                      padding: EdgeInsets.symmetric(vertical:18.w),
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(24.w),
                        color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Positioned(
                            right : 16.w,
                            top: -4.h,
                            child: IconButton(
                              iconSize: 32.w,
                              icon: isFetchingBp?CircularProgressIndicator(color: Colors.white,)
                              : Icon(Icons.refresh, size: 32, color: Colors.white),
                              onPressed: (){
                                isFetchingBp = true;
                                setState(() {});
                                Future.delayed(
                                    const Duration(seconds: 5),()=>setState(() {
                                  isFetchingBp = false;
                                }));
                                const methodChannel = MethodChannel('com.carenx.app/callback');
                                methodChannel.invokeMethod("startBpBleTransfer");
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                      height: 0.15.sh,
                                      width: 0.15.sw,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                  '${(fhrData?.spo2 ?? 0)==0? "---" : (fhrData?.spo2 ?? "---")}',

                                                  //'${fhrData?.spo2 ?? "---"}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 50.sp,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              alignment: Alignment.center,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "SpO2",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 16.sp,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ])),
                                  SizedBox(
                                      height: 0.15.sh,
                                      width: 0.15.sw,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                  '${(fhrData?.pi ?? 0)==0? "---" : (fhrData?.pi.toStringAsFixed(1) ?? "---")}',
                                                  //fhrData?.pi.toStringAsFixed(1) ?? "---",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 50.sp,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              alignment: Alignment.center,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "PI%",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 16.sp,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ])),
                                  SizedBox(
                                      height: 0.15.sh,
                                      width: 0.15.sw,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                  '${(fhrData?.mhr ?? 0)==0? "---" : (fhrData?.mhr ?? "---")}',
                                                  //'${fhrData?.mhr ?? "---"}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 50.sp,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              alignment: Alignment.center,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "MHR",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white54,
                                                      fontSize: 16.sp,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  // Row(
                                                  //   children: [
                                                  //     SizedBox(
                                                  //       width: 60.w,
                                                  //       child: CircleIconButton(
                                                  //         size: 48.w,
                                                  //         margin: EdgeInsets.all(2.h),
                                                  //         icon: FontAwesomeIcons.arrowsRotate,
                                                  //         onTap: () async {
                                                  //           HapticFeedback.heavyImpact();
                                                  //           await writeChar?.write(FhrCommandMaker.tocoReset(0),
                                                  //               withResponse: false);
                                                  //           debugPrint(
                                                  //               "------ write complete -- ${FhrCommandMaker.tocoReset(0)}");
                                                  //           setState(() {});
                                                  //         },
                                                  //       ),
                                                  //     ),
                                                  //     Expanded(
                                                  //       child: Container(
                                                  //         height: 92.h,
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ])),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right:16.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        height: 0.15.sh,
                                        width: 0.12.sw,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: AutoSizeText(
                                                    '${(fhrData?.sys ?? 0)==0? "---" : (fhrData?.sys ?? "---")}',
                                                    //'${fhrData?.sys ?? "---"}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 50.sp,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Systolic",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.white54,
                                                        fontSize: 16.sp,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ])),
                                    SizedBox(
                                        height: 0.15.sh,
                                        width: 0.12.sw,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: AutoSizeText(
                                                    '${(fhrData?.dia ?? 0)==0? "---" : (fhrData?.dia ?? "---")}',
                                                    //'${fhrData?.dia ?? "---"}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 50.sp,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Diastolic",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.white54,
                                                        fontSize: 16.sp,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ])),
                                    SizedBox(
                                        height: 0.15.sh,
                                        width: 0.12.sw,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: AutoSizeText(
                                                    '${(fhrData?.pulse ?? 0)==0? "---" : (fhrData?.pulse ?? "---")}',
                                                    //'${fhrData?.pulse ?? "---"}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 50.sp,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Pulse",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.white54,
                                                        fontSize: 16.sp,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     SizedBox(
                                                    //       width: 60.w,
                                                    //       child: CircleIconButton(
                                                    //         size: 48.w,
                                                    //         margin: EdgeInsets.all(2.h),
                                                    //         icon: FontAwesomeIcons.arrowsRotate,
                                                    //         onTap: () async {
                                                    //           HapticFeedback.heavyImpact();
                                                    //           await writeChar?.write(FhrCommandMaker.tocoReset(0),
                                                    //               withResponse: false);
                                                    //           debugPrint(
                                                    //               "------ write complete -- ${FhrCommandMaker.tocoReset(0)}");
                                                    //           setState(() {});
                                                    //         },
                                                    //       ),
                                                    //     ),
                                                    //     Expanded(
                                                    //       child: Container(
                                                    //         height: 92.h,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ])),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      }
    );
  }

}


