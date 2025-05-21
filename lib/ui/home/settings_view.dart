import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:preferences/preferences.dart';


class SettingsView extends StatefulWidget  {
  //final Organization? organization;

  const SettingsView(
      {super.key,});


  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsView> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late UserModel user;
  @override
  void initState() {
    user = context.read<SessionCubit>().currentUser.value!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
        Text(
          "Device Settings",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
          Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: PreferencePage([
                  PreferenceTitle('General'),
                  Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child:  Text(
                        "The settings apply for account configuration",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54),
                      )),

                  SwitchPreference(
                    'Pre save mother',
                    'preSaveMother',
                    defaultVal: true,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'You can change when to save mother details. (i.e Before/After test)',
                  ),

                  SwitchPreference(
                    'Patient/Case ID',
                    'patientIdRequired',
                    defaultVal: false,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'Turn the setting on if you require paitent/case id added in mother registration. ',
                  ),

                  SwitchPreference(
                    'Ask to select doctor',
                    'selectDoctorName',
                    defaultVal: false,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'Ask to select doctor of the mother in registration form.',
                  ),

                  PreferenceTitle('Test'),
                  Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child:  Text(
                        "The settings apply Live NST tests",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54),
                      )),

                  DropdownPreference(
                    'Default test time',
                    'testTime',
                    defaultVal: 0,
                    displayValues: const [
                      'NA',
                      '20 min',
                      '30 min',
                      '60 min',
                    ],
                    values: const [0,20,30,60],
                    desc: 'This time once set will auto finish test in the selected time.',
                  ),

                  SwitchPreference(
                    'Signal loss Alarm',
                    'signalLossAlarm',
                    defaultVal: false,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'Shows signal loss alarm on screen with sound',
                  ),

                  SwitchPreference(
                    'Auto Movement Marking',
                    'autoMovementMarking',
                    defaultVal: true,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'Turn on if you need auto movement marking.',
                  ),

                  SwitchPreference(
                    'Live Auto Interpretations',
                    'liveInterpretations',
                    defaultVal: true,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    desc: 'Interpretations will be printed if on',
                  ),

                   DropdownPreference(
                    'Default Live scale',
                    'liveGridPreMin',
                    defaultVal: 3,
                    displayValues: const [
                      '1 cm/min',
                      '3 cm/min',
                    ],
                    values: const [1, 3],
                  ),
                  PreferenceHider([
                    SwitchPreference(
                      'Highlight Live patterns',
                      'liveHighlight',
                      defaultVal: true,
                      switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                      desc: 'Identified patterns such as accelerations decelerations will be highlighted on the print. We recommend to use color printer for this feature',
                    ),
                  ], '!liveInterpretations'),

                  PreferenceTitle('Printing'),
                  Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child:  Text(
                        "The settings apply only to NST tests less than 60 min.",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54),
                      )),
                  DropdownPreference(
                    'Default print scale',
                    'scale',
                    defaultVal: 1,
                    displayValues: const [
                      '1 cm/min',
                      '3 cm/min',
                    ],
                    values: const [1, 3],
                  ),
                  SwitchPreference(
                    'Color Print',
                    'colorPrint',
                    defaultVal: true,
                    desc: 'Turn this on if you need a color print.',
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SwitchPreference(
                    'Doctor\'s Comment',
                    'comments',
                    defaultVal: false,
                    desc: 'This option will print comments by doctor',
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SwitchPreference(
                    'Auto Interpretations',
                    'interpretations',
                    defaultVal: true,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    /*onEnable: () {
                                PrefService.setBool('highlight', true);
                              },
                              onDisable: () {
                                PrefService.setBool('highlight', false);
                              },*/
                    desc: 'Interpretations will be printed if on',
                  ),
                  (PrefService.getBool('isAndroidTv')??false)
                      ? DropdownPreference(
                    'Default Live scale',
                    'gridPreMin',
                    defaultVal: 1,
                    displayValues: const [
                      '1 cm/min',
                      '3 cm/min',
                    ],
                    values: const [1, 3],
                  )
                      : Container(),
                  PreferenceHider([
                    SwitchPreference(
                      'Highlight patterns',
                      'highlight',
                      defaultVal: true,
                      switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                      desc:
                      'Identified patterns such as accelerations decelerations will be highlighted on the print. We recommend to use color printer for this feature',
                    ),
                  ], '!interpretations'), // Use ! to get reversed boolean values
                  PreferenceTitle('FHR 2'),
                  Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child:  Text(
                        "The settings apply only FHR 2 data.",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54),
                      )),
                  SwitchPreference(
                    'Twin Mode',
                    'hasFhr2',
                    defaultVal: true,
                    switchActiveColor: Theme.of(context).colorScheme.onPrimary,
                    onChange: () {
                      setState(() {});
                    },
                    /*onEnable: () {
                                PrefService.setBool('highlight', true);
                              },
                              onDisable: () {
                                PrefService.setBool('highlight', false);
                              },*/
                    desc: 'Turn this on for twin mode.',
                  ),
                  PreferenceHider(
                    [DropdownPreference(
                      'Bpm Offset',
                      'fhr2Offset',
                      defaultVal: 0,
                      displayValues: const [
                        '-20 bpm',
                        '-10 bpm',
                        '0 bpm',
                        '10 bpm',
                        '20 bpm',
                      ],
                      values: const [-20,-10,0,10,20],
                      desc: 'This shifts the entire FHR 2 bpm on the display and print by selected bpm.',
                    ),],"!hasFhr2"
                  ),
                ]),
              )),
          /*Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: PreferencePage([
                   // Use ! to get reversed boolean values
                  ]),
                ))*/
      ]),
    );
  }
}