import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:l8fe/bloc/session/session_state.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/my_user.dart';
import 'package:l8fe/services/firebase_auth.dart';

import '../../models/user_model.dart';

class SessionCubit extends Cubit<SessionState> with ChangeNotifier {
  SessionCubit({required this.authRepo}) : super(UnkownSessionState()) {
    attemptAutoLogin();
  }

  final FirebaseAuthRepo authRepo;
  final ValueNotifier<Device?> currentUser = ValueNotifier(null);
  bool collapsedNeodocs = false;

  Future<void> attemptAutoLogin() async {
    try {
      await showSession();
    } on Exception {
      emit(Unauthenticated());
    }
  }

  Future<void> showSession({String? oId}) async {
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      currentUser.value = user;
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
      throw Exception('User not logged in');
    }
  }

  Future<void> signOut() async {
    await authRepo.signOut();
    currentUser.value = null;
    emit(Unauthenticated());
  }
}
