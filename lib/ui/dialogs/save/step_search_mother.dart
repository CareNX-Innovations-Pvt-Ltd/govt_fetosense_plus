import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/ui/home/mother_home.dart';
import 'package:stepper_a/stepper_a.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:http/http.dart' as http;

class StepSearchMother extends StatefulWidget {
  final VoidCallback skip;
  final StepperAController controller;
  final Map<String, dynamic> mother;
  const StepSearchMother({Key? key, required this.controller, required this.mother,required this.skip}) : super(key: key);

  @override
  State createState() => _StepState();
}

class _StepState extends State<StepSearchMother> {
  late Device user;

  String? _motherId;


  @override
  void initState() {
    user = context.read<SessionCubit>().currentUser.value!;
    super.initState();
  }

  TextEditingController searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              "Search mother's Name",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child:
              TextFieldSearch(
                controller: searchController,
                label: "search",
                getSelectedValue: (c) {
                  setState(() {});
                  debugPrint("getSelectedValue ${c.value.toString()}");
                  _motherId = c.value["documentId"];
                },
                minStringLength: 2,
                  future: () {
                    return fetchMother(searchController.text);
                  },

                autoClear: false,
                /*obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jon Doe';
                  }
                  return null;
                },
                onSaved: (value){
                  widget.mother["name"] = value;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value){
                  widget.mother["name"] = value;
                  widget.controller.next(onTap: (v){});
                },
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },*/
                decoration:  InputDecoration(
                    contentPadding: EdgeInsets.only(left:26.w),
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.white54,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    labelText: "Search Mother Name"),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    widget.controller.next(onTap: (int currentIndex) {  });
                  },
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(

                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(color: Colors.teal),
                      //color: Colors.green
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("New Mother",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
                SizedBox(width: 24.w,),

                InkWell(
                  onTap: _motherId==null?null:(){
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MotherHome(motherId: _motherId!,mother: null,)));
                    //widget.controller.next(onTap: (int currentIndex) {  });
                  },
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: Colors.teal),
                        color: Colors.teal
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("Next",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.w,),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchMother(String query) async {
    debugPrint("fetchMother");
    try {
      if(query.trim().length > 2){
        final body = json.encode( {
          "searchDocumentId": user.documentId,
          "orgDocumentId": user.organizationId ?? "NANANANANNANA",
          "searchString": query,
          "apiKey": "ay7px0rjojzbtz0ym0"
        });
        final response = await http.post(Uri.parse('https://backend.carenx.com:3006/api/search/searchMother'), headers: {
          "Content-Type": "application/json"
        }, body:body);
        debugPrint("response body $body");
        if (response.statusCode == 200) {
          debugPrint(response.body.toString());
          final mothers = json.decode(response.body)["data"]
              .map((doc) {
            final map = TestItem(label:"${doc["fullName"] } Gest. Age ${getGestAge(doc)}",value: doc);
            return map;
          }).toList();
          debugPrint(mothers.toString());
          return mothers;
        } else {
          throw Exception('Failed to load post');
        }
      }else{
        return [];

      }
    } catch (error) {
      debugPrint(error.toString());
      //return [];
      throw error;
    }
  }

  int getGestAge(motherDetails) {

    if(motherDetails['edd'] != null){
      double age = (280 - (
          (DateTime.parse(motherDetails['edd']).millisecondsSinceEpoch -new DateTime.now().millisecondsSinceEpoch)
              /(1000*60*60*24)))/
          7;
      return age.floor();
    }else{
      return 0;
    }

  }
}

class TestItem {
  final String label;
  dynamic value;

  TestItem({required this.label, this.value});

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(label: json['label'], value: json['value']);
  }
}