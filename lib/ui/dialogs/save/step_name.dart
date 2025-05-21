import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepper_a/stepper_a.dart';

class StepName extends StatefulWidget {
  final StepperAController controller;
  final Map<String, dynamic> mother;
  const StepName({super.key, required this.controller, required this.mother});

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepName> {
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
              "Enter mother's Name",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: TextFormField(
                onChanged: (c) {
                  setState(() {});
                },
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jon Doe';
                  }
                  return null;
                },
                initialValue: widget.mother["name"],
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
                },
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
                    labelText: "Mother Name"),
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