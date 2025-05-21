import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stepper_a/stepper_a.dart';

class StepSave extends StatefulWidget {
  final StepperAController controller;
  final void Function(Map<String,dynamic> map) done;
  final Map<String, dynamic> mother;

  const StepSave({Key? key, required this.controller, required  this.done, required this.mother}) : super(key: key);

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepSave> {

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
              "Save Test",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: AutoSizeText(
                'Click save to upload the test to the server. Once saved this test can be accessed to any of the fetosense apps for your organizations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    widget.controller.back(onTap: (int currentIndex) {  });
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

                    child: const Text("Back",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
                SizedBox(width: 24.w,),
                InkWell(
                  onTap: (){
                    // widget.controller.next(onTap: (int currentIndex) {  });
                      widget.done(widget.mother);
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

                    child: const Text("Save",style: TextStyle(fontSize: 18,color: Colors.white),),
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
}