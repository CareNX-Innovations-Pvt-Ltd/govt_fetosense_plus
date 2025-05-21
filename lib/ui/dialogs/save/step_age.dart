import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stepper_a/stepper_a.dart';

class StepAge extends StatefulWidget {
  final StepperAController controller;
  final Map<String, dynamic> mother;

  const StepAge({super.key, required this.controller, required this.mother});

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepAge> {

  late int _currentAgeIntValue;// = widget.mother["age"]??24;
  @override
  void initState() {
    _currentAgeIntValue = widget.mother["age"]??24;
    super.initState();
  }

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
             Text(
              "Select mother's Age",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 36.sp,fontWeight: FontWeight.w100),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: NumberPicker(
                value: _currentAgeIntValue,
                minValue: 1,
                maxValue: 100,
                itemCount: 3,
                step: 1,
                axis: Axis.horizontal,
                onChanged: (value) {
                  widget.mother["age"] = value;
                  setState(() => _currentAgeIntValue = value);
                },
                selectedTextStyle: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(
                  fontSize: 36.sp,
                  color: Colors.white,
                ),
                textStyle: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(
                  color: const Color(0xff575D7D),
                  fontSize: 26.sp,
                ),
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
                    widget.mother["age"] = _currentAgeIntValue;
                    widget.controller.next(onTap: (int currentIndex) {  });
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
}