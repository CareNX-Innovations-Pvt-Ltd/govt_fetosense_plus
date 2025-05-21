import 'package:equatable/equatable.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/my_user.dart';

import '../../models/user_model.dart';

abstract class SessionState extends Equatable {}

class UnkownSessionState extends SessionState {
  @override
  List<Object> get props => [];
}

class Unauthenticated extends SessionState {
  @override
  List<Object> get props => [];
}

class Authenticated extends SessionState {
  final Device user;

  /// So session is refreshed when the oId is changed for the clinic app in [SessionCubit.showSession]
  final String? oId;

  Authenticated({required this.user, this.oId});

  @override
  List<Object> get props => [user.uid, oId.toString()];
}
