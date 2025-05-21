import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/association_model.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:stepper_a/stepper_a.dart';

class StepDoctorSelection extends StatefulWidget {
  final StepperAController controller;
  final Map<String, dynamic> mother;
  const StepDoctorSelection({super.key, required this.controller, required this.mother});

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepDoctorSelection> {
  late final Device _device;
  late final List<Map<String, dynamic>> doctors;
  var _dropDownValue;


  @override
  void initState() {
    _device = context.read<SessionCubit>().currentUser.value!;
    doctors = _device.associations.values.map((e) => Map<String,dynamic>.from(e)).toList();
    if(doctors.where((element) => element["name"]==widget.mother["doctorName"]).isNotEmpty) {
      _dropDownValue = doctors.firstWhere((element) => element["name"] ==
          widget.mother["doctorName"], orElse: () => {});
    }
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
              "Select the doctor",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 36.sp,fontWeight: FontWeight.w100),
            ),
            const Spacer(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: DropdownButtonFormField<Map<String,dynamic>>(
                hint: Text("Select Doctor",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium),
                items: doctors.map((entry) {
                  return DropdownMenuItem<Map<String,dynamic>>(
                    value: entry,
                    child: Text(entry["name"],
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium),
                  );
                }).toList(),

                selectedItemBuilder: (context){
                  return doctors.map<Widget>((Map item) {
                    return Text(item["name"],
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium);
                  }).toList();
                },
                value: _dropDownValue,
                isExpanded: true,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
                onChanged: (value) {
                  setState(() {
                    _dropDownValue = value!;
                  });
                },
                validator: (value) => value ==
                    null
                    ? "Select a doctor"
                    : null,
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

                    child:  Text("Back",style: Theme.of(context).textTheme.bodyLarge,),
                  ),
                ),
                SizedBox(width: 24.w,),
                InkWell(
                  onTap: (){
                    widget.mother["doctorId"]=_dropDownValue["id"];
                    widget.mother["doctorName"]=_dropDownValue["name"];
                    widget.mother["associations"][_dropDownValue["id"]] = _dropDownValue;
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