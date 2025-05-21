import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:l8fe/bloc/auth/email/email_auth_cubit.dart';
import 'package:l8fe/bloc/auth/email/email_auth_state.dart';
import 'package:l8fe/ui/widgets/auth/auth_text_field.dart';
import 'package:l8fe/utils/definitions.dart';

class PasswordLogin extends StatefulWidget {
  const PasswordLogin({super.key});

  @override
  State<PasswordLogin> createState() => _PasswordLoginState();
}

class _PasswordLoginState extends State<PasswordLogin> {
  final validationNotifier = ValueNotifier(false);
  bool emailValidated = false;
  bool passValidated = false;
  String email = '';
  String password = '';
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    validationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Row(
          children: [
            Hero(
              tag: "splash_icon",
              child: Container(
                width: 0.35.sw,
                color: Theme.of(context).colorScheme.secondary,
                child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/ic_logo_big.svg',fit: BoxFit.fitHeight,alignment: Alignment.centerLeft,
                    ),
                    //Image.asset("assets/images/ic_fetosense.png",height: 0.4.sh,width: 0.25.sw,fit: BoxFit.fitWidth,)
                ),
              ),
            ),
            Expanded(child: emailPasswordForm()),

          ],
        )
    );
    //child: Image.asset("assets/images/ic_fetosense.png",height: 0.4.sh,width: 0.25.sw,fit: BoxFit.fitWidth,)
  }

  Widget emailPasswordForm() {
    validationNotifier.value = false;
    emailValidated = false;
    passValidated = false;
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 500.w,
            minHeight: 720.h,
          ),
          child: IntrinsicHeight(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                width: 500.w,
                height: 720.h,
                constraints: BoxConstraints(
                    minHeight: 720.h
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                /*decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const RadialGradient(
                    colors: [
                      Color.fromRGBO(128, 128, 138, 1),
                      Color.fromRGBO(53, 54, 62, 1),
                    ],
                    center: Alignment(1, 1),
                    focal: Alignment(-0.75, -0.75),
                    focalRadius: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16.0,
                      offset: Offset(8.0, 8.0),
                    ),
                  ],
                ),*/
                child: BlocBuilder<EmailAuthCubit, EmailAuthState>(
                  builder: (_, state) {

                    return Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 2),
                            AutoSizeText(
                              'Sign in',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(flex: 3),
                            AutoSizeText(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            const Spacer(),
                            Form(
                              key: emailFormKey,
                              child: AuthTextField(
                                label: 'abc@example.com',
                                onChanged: (id) {
                                  emailFormKey.currentState?.validate();
                                },
                                validator: (value) {
                                  String? s;
                                  if (Regex.email.hasMatch(value ?? '')) {
                                    emailValidated = true;
                                  } else {
                                    emailValidated = false;
                                    s = 'Enter a valid email';
                                  }
                                  validationNotifier.value = emailValidated & passValidated;
                                  return s;
                                },
                                onSaved: (id) {
                                  email = id ?? '';
                                },
                              ),
                            ),
                            const Spacer(),
                            AutoSizeText(
                              'Password',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            const Spacer(),
                            Form(
                              key: passwordFormKey,
                              child: AuthTextField(
                                label: '**********',
                                obscureText: true,
                                onChanged: (password) {
                                  passwordFormKey.currentState?.validate();
                                },
                                action: TextInputAction.done,
                                validator: (pass) {
                                  String? s;
                                  if (Regex.password.hasMatch(pass ?? '')) {
                                    passValidated = true;
                                  } else {
                                    passValidated = false;
                                    s = 'Password should be atleast six characters';
                                  }
                                  validationNotifier.value = emailValidated & passValidated;
                                  return s;
                                },
                                onSaved: (pass) {
                                  password = pass ?? '';
                                },
                              ),
                            ),
                            const Spacer(flex: 2),
                            /*Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  //todo: forgot pass
                                },
                                child: AutoSizeText(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: const Color(0xFFFF5858),
                                  ),
                                ),
                              ),
                            ),*/
                            const Spacer(),
                            BlocBuilder<EmailAuthCubit, EmailAuthState>(
                              builder: (_, state) {
                                if (state is FailureEmailAuthState) {
                                  return AutoSizeText(
                                    state.errorMessage,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: const Color(0xFFFF5858),
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                            const Spacer(flex: 2),
                            Center(
                              child: ValueListenableBuilder(
                                valueListenable: validationNotifier,
                                builder: (_, validated, child) {
                                  return ActionSlider.standard(

                                    action: (controller) async {
                                      controller.loading(); //starts loading animation
                                      emailFormKey.currentState!.save();
                                      passwordFormKey.currentState!.save();
                                      if (email.isNotEmpty) {
                                        await context.read<EmailAuthCubit>()
                                            .signInWithEmail(email, password);
                                      }
                                      controller.reset();
                                    },

                                    backgroundColor: const Color.fromRGBO(53, 54, 62, 1) ,
                                    child:  Text('Slide to sign in',style: Theme.of(context).textTheme.labelMedium,),
                                  );
                                },
                              ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                        if (state is InProgressEmailAuthState)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.transparent,),
                          )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
