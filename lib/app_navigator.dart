import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:l8fe/ui/ble/ble_status_screen.dart';
import 'package:l8fe/ui/home/home.dart';
import 'package:l8fe/ui/home_view.dart';
import 'package:provider/provider.dart';

import 'bloc/auth/email/email_auth_cubit.dart';
import 'bloc/session/session_cubit.dart';
import 'bloc/session/session_state.dart';
import 'ui/auth/password_login.dart';
import 'ui/widgets/loading_view.dart';

class AppNavigator extends StatelessWidget {
  AppNavigator({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();

  MethodChannel platformChannel =
  const MethodChannel("com.neodocs.app/callback");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return WillPopScope(
          onWillPop: () async {
            if (Platform.isAndroid) {
              if (_navigatorKey.currentState!.canPop()) {
                return !await _navigatorKey.currentState!.maybePop();
              } else {
                platformChannel.invokeMethod("sendToBackground");
                return Future.value(false);
              }
            } else {
              return !await _navigatorKey.currentState!.maybePop();
            }
          },
          //async => !await _navigatorKey.currentState!.maybePop(),
          child: Navigator(
            key: _navigatorKey,
            observers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
            ],
            pages: [
              // Show loading screen
              if (state is UnkownSessionState)
                const MaterialPage(child: LoadingView()),
              // Show auth flow
              if (state is Unauthenticated)
                MaterialPage(
                  child: BlocProvider(
                    create: (context) => EmailAuthCubit(
                        sessionCubit: context.read<SessionCubit>()),
                    child: const PasswordLogin(),
                  ),
                ),

              // Show session flow
              if (state is Authenticated)
                MaterialPage(
                    child: Builder(
                        builder: (context) => Consumer<BluetoothAdapterState?>(
                          builder: (_, status, __) {
                            if (status == BluetoothAdapterState.on) {
                              return  const Home();
                            } else {
                              return BleStatusScreen(
                                  status: status ?? BluetoothAdapterState.unknown);
                            }
                          },
                        )),
                    name: "home")
            ],
            onPopPage: (route, result) => route.didPop(result),
          ));
    });
  }
}
