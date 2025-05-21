import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/ui/dialogs/save/step_age.dart';
import 'package:l8fe/ui/dialogs/save/step_ask.dart';
import 'package:l8fe/ui/dialogs/save/step_doctor_selection.dart';
import 'package:l8fe/ui/dialogs/save/step_lmp.dart';
import 'package:l8fe/ui/dialogs/save/step_name.dart';
import 'package:l8fe/ui/dialogs/save/step_patient_id.dart';
import 'package:l8fe/ui/dialogs/save/step_save.dart';
import 'package:preferences/preferences.dart';
import 'package:stepper_a/stepper_a.dart';

import '../../models/association_model.dart';
import '../widgets/circle_icon_button.dart';

class SaveTestDialog extends StatefulWidget {
  final Null Function(Map<String,dynamic> map) onNewPressed;
  final VoidCallback onAnonymousPressed;
  const SaveTestDialog({Key? key,required this.onAnonymousPressed, required this.onNewPressed}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<SaveTestDialog> {
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
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: Container(
        //padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        height: 0.6.sh,
        width: 0.6.sw,
        //clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: StepperA(
            stepperSize:  Size(170.w, 150.h),
            //stepperSize: const Size(300, 95),
            borderShape: BorderShape.circle,
            borderType: BorderType.straight,
            stepperAxis: Axis.vertical,
            lineType: LineType.dotted,
            stepperBackgroundColor: Colors.transparent,
            stepperAController: controller,
            stepHeight: 40,
            stepWidth: 40,
            stepBorder: true,
            pageSwipe: false,
            formValidation: true,

            /*floatingPreviousButton: FloatingButton(
                buttonIconColor: Colors.white,
                backgroundColor:  Colors.blueAccent,
                position: Position(//
                    left: 10,
                    bottom: 10
                ),
                onTap: (int currentIndex) {

                }
            ),
            floatingForwardButton: FloatingButton(
                buttonIconColor: Colors.white,
                backgroundColor:  Colors.blueAccent,
                position: Position(
                    right: 10,
                    bottom: 20
                ),
                onTap: (int currentIndex) {

                },
              onComplete: (){
                widget.onNewPressed();
                debugPrint("Forward Button click complete step call back!");
              },
            ),*/
            /*previousButton: (int index) => StepperAButton(
              width: 40,
              height: 40,
              onTap: (int currentIndex) {
                debugPrint("Previous Button Current Index $currentIndex");
              },
              buttonWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),

            forwardButton: (index) => StepperAButton(
              onComplete: () {
                debugPrint("Forward Button click complete step call back!");
              },
              width: 40,
              // width: index == 0 ? MediaQuery.of(context).size.width-25 : MediaQuery.of(context).size.width-140,
              height: 40,
              onTap: (int currentIndex) {
                debugPrint("Forward Button Current Index $currentIndex");
              },
              boxDecoration: BoxDecoration(
                  color: index == 3 ? Colors.indigo : Colors.green,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              buttonWidget: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              // index == 3
              //     ? const Text('Complete',
              //         style: TextStyle(fontSize: 14, color: Colors.white))
              //     : const Text('Next',
              //         style:
              //             TextStyle(fontSize: 14, color: Colors.white)),
            ),*/
            /*customSteps: const [
              CustomSteps(stepsIcon: Icons.login, title: "LogIn"),
              CustomSteps(stepsIcon: Icons.home, title: "Home"),
              CustomSteps(stepsIcon: Icons.account_circle, title: "Account"),
              //  CustomSteps(image: Image.asset("assets/pic/pay.png", color: Colors.white), title: "Payment"),
            ],*/

            step: const StepA(
                currentStepColor: Colors.indigo,
                completeStepColor: Colors.teal,
                inactiveStepColor: Colors.black45,
                // loadingWidget: CircularProgressIndicator(color: Colors.green,),
                margin: EdgeInsets.all(5)),
            stepperBodyWidget: [
              // StepOne(controller: controller),
              StepAsk(controller: controller,mother:mother,close:widget.onAnonymousPressed),
              StepName(controller: controller,mother:mother,),
              if(PrefService.getBool("patientIdRequired")??false)
                StepPatientId(controller: controller,mother:mother),
              if(PrefService.getBool("selectDoctorName")??false)
                StepDoctorSelection(controller: controller,mother:mother),
              StepAge(controller: controller,mother:mother,),
              StepLMP(controller: controller,mother:mother,),
              StepSave(controller: controller,mother:mother, done: widget.onNewPressed),
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

