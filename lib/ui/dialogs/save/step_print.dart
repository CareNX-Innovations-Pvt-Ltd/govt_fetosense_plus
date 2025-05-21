import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepper_a/stepper_a.dart';

class StepPrintAsk extends StatefulWidget {
  final StepperAController controller;
  final void Function() close;
  final void Function() print;

  const StepPrintAsk({Key? key, required this.controller,  required this.close, required this.print}) : super(key: key);

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepPrintAsk> {
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
              "Test Saved Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: AutoSizeText(
                'If you wish to view, print or share the report please press the View button. You could also do this any time from recent tests section.',
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
                  onTap: widget.close,/* (){
                    widget.controller.back(onTap: (int currentIndex) {  });
                  },*/
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(
                    width: 120.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: Colors.teal),
                        //color: Colors.green
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("New Test",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
                 SizedBox(width: 24.w,),
                InkWell(
                  onTap: (){
                    widget.print();
                  },
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(
                    width: 80.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: Colors.teal),
                        color: Colors.teal
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("View",style: TextStyle(fontSize: 18,color: Colors.white),),
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