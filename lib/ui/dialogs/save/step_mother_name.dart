import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepper_a/stepper_a.dart';

class StepMotherName extends StatefulWidget {
  final VoidCallback skip;
  final StepperAController controller;
  final Map<String, dynamic> mother;
  const StepMotherName({super.key, required this.controller, required this.mother,required this.skip});

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepMotherName> {
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
              "Enter mother's name",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 36.sp,fontWeight: FontWeight.w100),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: TextFormField(
                onChanged: (c) {
                  setState(() {});
                },
                obscureText: false,
                initialValue: widget.mother["name"],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mother name is required';
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
                },
                keyboardType: TextInputType.name,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration:  InputDecoration(
                    contentPadding: EdgeInsets.only(left:26.w),
                  labelStyle: Theme.of(context).textTheme.labelLarge,
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
                    widget.skip();
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

                    child:  Text("Skip",style: Theme.of(context).textTheme.bodyLarge,),
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

                    child:  Text("Next",style: Theme.of(context).textTheme.bodyLarge,),
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