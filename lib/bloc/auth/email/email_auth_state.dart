// ignore_for_file: annotate_overrides, overridden_fields

import 'package:equatable/equatable.dart';

enum EmailAuthStatus {
  initial,
  inProgress,
  success,
  failure,
  // forgotPassOtpSent,
  // forgotPassVerifyOtp,
}

class EmailAuthState extends Equatable {
  final String? email;
  final String? password;
  final EmailAuthStatus? authStatus;
  final String? failureMessage;

  const EmailAuthState({
    this.email,
    this.password,
    this.authStatus,
    this.failureMessage,
  });

  @override
  List get props => [email, password, authStatus, failureMessage];
}

class InitialEmailAuthState extends EmailAuthState {
  const InitialEmailAuthState();
}

class InProgressEmailAuthState extends EmailAuthState {
  final String email, password;
  const InProgressEmailAuthState({required this.email, required this.password});
}

class SuccessEmailAuthState extends EmailAuthState {
  // final String email, password;
  // const SuccessEmailAuthState({required this.email, required this.password});
  const SuccessEmailAuthState();
}

class FailureEmailAuthState extends EmailAuthState {
  final String email, password, errorMessage;
  const FailureEmailAuthState({
    required this.email,
    required this.password,
    required this.errorMessage,
  });
}

class ForgotPassSendOtpAuthState extends EmailAuthState {
  final String email;
  const ForgotPassSendOtpAuthState({required this.email});
}

class ForgotPassSuccessAuthState extends EmailAuthState {
  const ForgotPassSuccessAuthState();
}

class ForgotPassFailureAuthState extends EmailAuthState {
  final String email, errorMessage;
  const ForgotPassFailureAuthState(
      {required this.email, required this.errorMessage});
}
