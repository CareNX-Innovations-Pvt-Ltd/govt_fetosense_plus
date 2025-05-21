import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:l8fe/bloc/auth/email/email_auth_state.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/bloc/session/session_state.dart';

class EmailAuthCubit extends Cubit<EmailAuthState> {
  EmailAuthCubit({required this.sessionCubit})
      : super(const InitialEmailAuthState());

  final auth = FirebaseAuth.instance;
  final SessionCubit sessionCubit;

  Future<void> signInWithEmail(String email, String password) async {
    emit(InProgressEmailAuthState(email: email, password: password));
    try {
      if (sessionCubit.state is Authenticated) {
        //Handle already logged in user
        debugPrint(
            'EmailAuthCubit.dart|signInWithEmail User found. Attempting linking...');
        final credential =
            EmailAuthProvider.credential(email: email, password: password);
        await auth.currentUser?.linkWithCredential(credential);
      } else {
        //Handle new login user
        debugPrint(
            'EmailAuthCubit.dart|signInWithEmail No user currently logged in.');
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      await sessionCubit.showSession();
      emit(const SuccessEmailAuthState());
    } on FirebaseAuthException catch (e) {
      emit(FailureEmailAuthState(
        email: email,
        password: password,
        errorMessage: e.message ?? 'Unknown Error Occurred.',
      ));
      debugPrint(
        'EmailAuthCubit.dart|signInWithEmail FirebaseAuthError: ${e.code}\n${e.message}',
      );
    } catch (e) {
      emit(FailureEmailAuthState(
        email: email,
        password: password,
        errorMessage: e.toString(),
      ));
      debugPrint('EmailAuthCubit.dart|signInWithEmail UnknownError: $e');
    }
  }

  Future<void> sendPasswordResetLink({required String email}) async {
    try {
      emit(ForgotPassSendOtpAuthState(email: email));
      await auth.sendPasswordResetEmail(email: email);
      emit(const ForgotPassSuccessAuthState());
    } on FirebaseAuthException catch (e) {
      emit(ForgotPassFailureAuthState(
        email: email,
        errorMessage: e.message ?? 'Unknown Error Occurred.',
      ));
      debugPrint(
        'EmailAuthCubit.dart|sendOtp FirebaseAuthError: ${e.code}\n${e.message}',
      );
    } catch (e) {
      emit(ForgotPassFailureAuthState(
        email: email,
        errorMessage: e.toString(),
      ));
      debugPrint('EmailAuthCubit.dart|sendOtp UnknownError: $e');
    }
  }
}
