import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepper_a/stepper_a.dart';

class StepLMP extends StatefulWidget {
  final StepperAController controller;
  final Map<String, dynamic> mother;
  final void Function(Map<String,dynamic> map)? done;
  const StepLMP({super.key, required this.controller, required this.mother, this.done});

  @override
  State createState() => _StepTwoState();
}

class _StepTwoState extends State<StepLMP> {

  late DateTime _selectedDate;
  List<DateTime?> _singleDatePickerValueWithDefaultValue = [
    DateTime.now(),
  ];

  late CalendarDatePicker2Config _cConfig;

  @override
  void initState() {
    _selectedDate = widget.mother["lmp"]?? DateTime(DateTime.now().year,DateTime.now().month-2,DateTime.now().day);
    _singleDatePickerValueWithDefaultValue = [
      _selectedDate,
    ];
    calenderInit();
    super.initState();
  }

  calenderInit(){
    _cConfig = CalendarDatePicker2Config(
      selectedDayHighlightColor: Colors.teal,
      selectedMonthTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
      selectedYearTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
      selectedDayTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
      weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      firstDayOfWeek: 1,
      controlsHeight: 50,
      dayMaxWidth: 25,
      animateToDisplayedMonthDate: true,
      centerAlignModePicker: true,
      useAbbrLabelForMonthModePicker: true,
      modePickersGap: 0,
      firstDate: DateTime(DateTime.now().year-1,DateTime.now().month,DateTime.now().day) ,
      lastDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "Select mother's LMP",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 36.sp,fontWeight: FontWeight.w100),
            ),
            const Spacer(),
              CalendarDatePicker2(
                config: _cConfig,
                value: _singleDatePickerValueWithDefaultValue,
                onValueChanged: (dates) => setState(
                        () {
                          _singleDatePickerValueWithDefaultValue = dates;
                          setState(() {
                            _selectedDate = dates.first;
                          });
                          debugPrint("----onChange ---$_selectedDate-------");
                          widget.mother["lmp"] = _selectedDate;
                          widget.mother["edd"] = _selectedDate.add(const Duration(days: 280));
                        }),
              ),
            /*Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: DatePickerWidget(
                looping: true, // default is not looping
                firstDate:DateTime(DateTime.now().year-1,DateTime.now().month,DateTime.now().day) ,
                lastDate:DateTime.now(),
                initialDate: _selectedDate,// DateTime(1994),
                dateFormat:
                // "MM-dd(E)",
                "dd/MMMM/yyyy",
                locale: DatePicker.localeFromString('en'),
                onChange: (DateTime newDate, _) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                  debugPrint("----onChange ---$_selectedDate-------");
                  widget.mother["lmp"] = newDate;
                  widget.mother["edd"] = newDate.add(const Duration(days: 280));
                },
                onConfirm: (DateTime newDate, _) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                  debugPrint("--- onConfirm ----$_selectedDate-------");

                },
                pickerTheme: const DateTimePickerTheme(
                  backgroundColor: Colors.transparent,
                  itemTextStyle:
                  TextStyle(color: Colors.white, fontSize: 19),
                  dividerColor: Colors.white,
                ),
              ),
            ),*/
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    widget.controller.back(onTap: (int currentIndex) {  });
                  },
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(

                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(color: Colors.teal),
                      //color: Colors.green
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: Text(widget.done==null?"Back":"Back",style: const TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
                SizedBox(width: 24.w,),
                InkWell(
                  onTap: (){
                    // widget.controller.next(onTap: (int currentIndex) {  });
                    widget.mother["lmp"] = _selectedDate;
                    widget.mother["edd"] = _selectedDate.add(const Duration(days: 280));
                    if(widget.done!=null){
                      widget.done!(widget.mother);
                    }else {
                      widget.controller.next(onTap: (int currentIndex) {});
                    }
                                    },
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(color: Colors.teal),
                        color: Colors.teal
                    ),
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 8.h),

                    child: const Text("Next",style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.w,),
          ],
        ),
      ),
    );
  }
}