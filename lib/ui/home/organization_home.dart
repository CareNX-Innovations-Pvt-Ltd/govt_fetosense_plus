
import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/my_user.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:l8fe/services/firestore_database.dart';
import 'package:l8fe/ui/test_view.dart';
import 'package:l8fe/ui/widgets/all_test_card.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ble/bluetooth_ctg_service.dart';


class OrganizationHome extends StatefulWidget {
  const OrganizationHome({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();

}
class HomeState extends State<OrganizationHome>{
  late SharedPreferences prefs;

  late final Device user;
  UserModel? org;
  @override
  void initState() {
    super.initState();
    prefs = context.read<SharedPreferences>();
    user = context.read<SessionCubit>().currentUser.value!;
    getOrg();
  }

  @override
  void dispose() {
    super.dispose();
  }



  getOrg()async {
    org = (await FirestoreDatabase(uid:user.uid).getOrgDetails(id:user.organizationId??""))!;
    debugPrint("getorg ==== ${org?.toJson().toString()}");
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
                          title: Text("Org Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.sp,
                                  color: Colors.white),),
                          subtitle: Text(org?.name??"",
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
                                  AutoSizeText( org?.name??"",
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
                                        if(org!=null)
                                        AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                            TextSpan(
                                              text: " ${org!.uid} years",
                                            ),
                                             TextSpan(
                                              text: "\n ${DateFormat('dd MMM yyyy').format(org!.createdOn)}",
                                            ),
                                            TextSpan(
                                              text: "\n ${DateFormat('dd MMM yyyy').format(org!.createdOn)}",
                                            ),
                                            TextSpan(
                                              text: "\n ${org!.createdOn} weeks",
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

                ],
              ),
            ],
          )),
    );
  }

}

