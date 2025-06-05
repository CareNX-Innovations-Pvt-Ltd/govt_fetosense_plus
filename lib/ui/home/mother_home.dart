
import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/services/firestore_database.dart';
import 'package:l8fe/ui/test_view.dart';
import 'package:l8fe/ui/widgets/all_test_card.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ble/bluetooth_ctg_service.dart';
import '../../ble/unified_service.dart';


class MotherHome extends StatefulWidget {
  final String motherId;
  final Map<String,dynamic>? mother;
  const MotherHome({super.key,required this.motherId,this.mother});

  @override
  State<StatefulWidget> createState() => HomeState();

}
class HomeState extends State<MotherHome>{
  late SharedPreferences prefs;
  final UnifiedBluetoothService _bluetoothService = UnifiedBluetoothService();

  late final Device user;
  Mother? mom;
  @override
  void initState() {
    super.initState();
    getMom();
    prefs = context.read<SharedPreferences>();
    user = context.read<SessionCubit>().currentUser.value!;
  }

  @override
  void dispose() {
    super.dispose();
  }



  getMom()async {
    mom = (await FirestoreDatabase(uid: context.read<SessionCubit>().currentUser.value!.uid).getMotherDetails(id:widget.motherId??""))!;
    debugPrint("getMom ==== ${mom?.toJson().toString()}");
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              Container(
                width: 1.sw,
                decoration: const BoxDecoration(
                  border:
                  Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 8.w,
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_back,
                          size: 32, color: Colors.teal),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Mother Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.sp,
                                  color: Colors.white),),
                          subtitle: Text(mom?.organizationName??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 14.sp,
                                color: Colors.white),),
                        )
                    ),
                    SizedBox(
                      width: 16.w,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 0.3.sw,
                    height: 0.85.sh,
                    decoration:  const BoxDecoration(
                      border:
                       Border(left: BorderSide(width: 2, color: Colors.black)),

                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                            width: 0.3.sw,
                            padding: EdgeInsets.only(left: 16.w,top: 16.h),
                            decoration: const  BoxDecoration(
                              border:  Border(
                                  bottom:
                                  BorderSide(width: 0.5, color: Colors.grey)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  AutoSizeText( mom?.name??widget.motherId,
                                    style: Theme.of(context).textTheme.bodyLarge,),
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                            const TextSpan(text: "AGE"),
                                            const TextSpan(text: "\nLMP",),
                                            const TextSpan(text: "\nEDD"),
                                            const TextSpan(text: "\nG. Age"),

                                            TextSpan(
                                                text: "\nSHORT TERM   ",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color:
                                                    Colors.white.withOpacity(0),
                                                    fontWeight: FontWeight.w500)),
                                          ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.white.withOpacity(0.6),
                                              fontWeight: FontWeight.w700),
                                        ),
                                        if(mom!=null)
                                        AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                            TextSpan(
                                              text: " ${mom!.age} years",
                                            ),
                                             TextSpan(
                                              text: "\n ${DateFormat('dd MMM yyyy').format(mom!.lmp)}",
                                            ),
                                            TextSpan(
                                              text: "\n ${DateFormat('dd MMM yyyy').format(mom!.edd)}",
                                            ),
                                            TextSpan(
                                              text: "\n ${mom!.lmp.getGestAge()} weeks",
                                            ),
                                            const TextSpan(
                                              text: "\n ",
                                            )
                                          ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),

                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 0.85.sh,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      padding: EdgeInsets.only(right: 16.w,bottom: 16.h),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            child: StreamBuilder(
                                stream: FirestoreDatabase(uid: context.read<SessionCubit>().currentUser.value!.documentId).allMotherTestsStream(widget.motherId),
                                builder: (context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
                                  if (snapshot.hasData) {
                                    final tests = snapshot.data!
                                        .map((doc) {
                                      debugPrint("autoInterpretations mother : ${doc['autoInterpretations']}");
                                      return CtgTest.fromMap(doc, doc["documentId"]);})
                                        .toList();

                                    return tests.isEmpty
                                        ? const Center(
                                        child: Text('No test yet',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.grey,
                                                fontSize: 20)))
                                        : GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, // Number of columns
                                        crossAxisSpacing: 10.0, // Space between columns
                                        mainAxisSpacing: 10.0, // Space between rows
                                        childAspectRatio: 1.2, // Adjust as needed for card aspect ratio
                                      ),
                                      itemCount: tests.length,
                                      shrinkWrap: true,
                                      //physics: NeverScrollableScrollPhysics(), // Prevents GridView from scrolling inside a parent scrollable widget
                                      itemBuilder: (context, index) {
                                        return AllTestCard(testDetails: tests[index],showName: false,);
                                      },
                                    );

                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.black),
                                        ));
                                  }
                                }),
                          ),
                          if(mom!=null && _bluetoothService.isConnectedNotifier.value)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: (){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> TestView(mom: mom,)));
                                },
                                child: Container(
                                  width: 0.125.sw,
                                  height: 62.h,
                                  padding: EdgeInsets.symmetric(vertical:8.w),
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(60.w),
                                    color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
                                  ),
                                  alignment: Alignment.center,
                                  child:
                                  AutoSizeText(
                                    "New test",
                                    style: Theme.of(context).textTheme.bodyLarge,),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

}

