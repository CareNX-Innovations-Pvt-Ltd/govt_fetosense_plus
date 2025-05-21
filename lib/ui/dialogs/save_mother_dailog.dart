import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/association_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/ui/dialogs/save/step_age.dart';
import 'package:l8fe/ui/dialogs/save/step_ask.dart';
import 'package:l8fe/ui/dialogs/save/step_doctor_selection.dart';
import 'package:l8fe/ui/dialogs/save/step_lmp.dart';
import 'package:l8fe/ui/dialogs/save/step_mother_name.dart';
import 'package:l8fe/ui/dialogs/save/step_name.dart';
import 'package:l8fe/ui/dialogs/save/step_patient_id.dart';
import 'package:l8fe/ui/dialogs/save/step_save.dart';
import 'package:l8fe/ui/dialogs/save/step_search_mother.dart';
import 'package:preferences/preference_service.dart';
import 'package:stepper_a/stepper_a.dart';

import '../widgets/circle_icon_button.dart';

class SaveMotherDialog extends StatefulWidget {
  final void Function(Map<String,dynamic> map) onNewPressed;
  final VoidCallback onSkipPressed;
  const SaveMotherDialog({Key? key,required this.onSkipPressed, required this.onNewPressed}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<SaveMotherDialog> {
  late AnimationController animationController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PageController pageController;
  final StepperAController controller = StepperAController();

  Map<String,dynamic> mother = {};
  int pageNo = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    final device = context.read<SessionCubit>().currentUser.value!;
    mother["documentId"] = FirebaseFirestore.instance.collection("tests").doc().id;
    mother["associations"] = {device.documentId:Association.fromUser(device).toJson()};
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 10,
      shadowColor: Colors.white54,
      surfaceTintColor: Colors.grey.withOpacity(0.5),

      clipBehavior: Clip.hardEdge,
      child: Container(
        //padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        height: 0.6.sh,
        width: 0.6.sw,
        constraints: BoxConstraints(
          maxHeight: 0.6.sh
        ),
        /*decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(3, 1),
              blurRadius: 5,
              spreadRadius: 0,
            ),
            BoxShadow(color: Theme.of(context).colorScheme.primaryContainer)
          ],
          borderRadius: BorderRadius.circular(15),
        ),*/
        //clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Stack(
            children: [
              StepperA(
                stepperSize:  Size(170.w, 150.h),
                //stepperSize: const Size(300, 95),
                borderShape: BorderShape.circle,
                borderType: BorderType.straight,
                stepperAxis: Axis.vertical,
                lineType: LineType.dotted,
                stepperBackgroundColor: Colors.transparent,
                stepperAController: controller,
                stepHeight: 50.h,
                stepWidth: 50.h,
                dashPattern: const [4,10],
                stepBorder: true,
                pageSwipe: false,
                formValidation: true,

                step: const StepA(
                    currentStepColor: Colors.indigo,
                    completeStepColor: Colors.teal,
                    inactiveStepColor: Colors.black45,
                    // loadingWidget: CircularProgressIndicator(color: Colors.green,),
                    margin: EdgeInsets.all(5)),
                stepperBodyWidget: [
                  // StepOne(controller: controller),
                  //StepSearchMother(controller: controller,mother:mother,skip: widget.onSkipPressed,),
                  StepMotherName(controller: controller,mother:mother,skip: widget.onSkipPressed,),
                  if(PrefService.getBool("patientIdRequired")??false)
                  StepPatientId(controller: controller,mother:mother),
                  if(PrefService.getBool("selectDoctorName")??false)
                    StepDoctorSelection(controller: controller,mother:mother),
                  StepAge(controller: controller,mother:mother,),
                  StepLMP(controller: controller,mother:mother,done: widget.onNewPressed),
                ],
              ),
              Positioned(
                top: 16.h,
                  right: 16.h,
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30.w,
                        color: Colors.white,
                      )
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop(BuildContext context) async {
    if (pageNo != 1) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      return false;
    }
    return true;
  }


}

