import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepper_a/stepper_a.dart';

class StepAsk extends StatefulWidget {
  final StepperAController controller;
  final VoidCallback close;
  final Map<String, dynamic> mother;
  const StepAsk({Key? key, required this.controller,  required this.close, required this.mother}) : super(key: key);

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepAsk> {
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
              "Save Test?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: AutoSizeText(
                'If you wish to save please press YES to enter patient information. You could also save this as an anonymous test by pressing NO.',
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
                    width: 80.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: Colors.teal),
                        //color: Colors.green
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("No",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
                 SizedBox(width: 24.w,),
                InkWell(
                  onTap: (){
                    widget.controller.next(onTap: (int currentIndex) {  });
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

                    child: const Text("Yes",style: TextStyle(fontSize: 18,color: Colors.white),),
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