import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/app_navigator.dart';
import 'package:l8fe/constants/app_themes.dart';
import 'package:l8fe/firebase_options.dart';
import 'package:l8fe/services/firebase_auth.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bloc/session/session_cubit.dart';
import 'bloc/session/session_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await PrefService.init(prefix: 'pref_');
  PrefService.setDefaultValues({'user_description': 'This is my description!'});
  SharedPreferences preferences = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  if (Platform.isAndroid) {
    await FlutterBluePlus.turnOn();
  }

  runApp(MultiProvider(
    providers: [
      Provider<SharedPreferences>(create: (_) => preferences),
      StreamProvider<BluetoothAdapterState>(
        create: (_) => FlutterBluePlus.adapterState,
        initialData: FlutterBluePlus.adapterStateNow,
      )
    ],
    child: MyApp(),
  ));

}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final SessionCubit _sessionCubit = SessionCubit(authRepo: FirebaseAuthRepo());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1024, 768),
      minTextAdapt: true,
      splitScreenMode: false,
      child: ChangeNotifierProvider<SessionCubit>.value(
          value: _sessionCubit,
          child: BlocBuilder<SessionCubit, SessionState>(
            buildWhen: (previous, current) {
              return true;
            },
            builder: (_, state) {
              return  MaterialApp(
                navigatorObservers: [
                  FirebaseAnalyticsObserver(
                    analytics: analytics,
                  ),
                ],
                debugShowCheckedModeBanner: false,
                title: "L8Fe",
                initialRoute: '/',
                theme: AppThemes.newBrightTheme,
                darkTheme: AppThemes.newDarkTheme,
                themeMode: ThemeMode.dark,
                home: AppNavigator(),
              );
            },
          ),
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
