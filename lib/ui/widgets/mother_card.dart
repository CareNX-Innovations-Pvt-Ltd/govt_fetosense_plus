import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/utils/date_format_utils.dart';

class MotherCard extends StatelessWidget {
  final dynamic motherDetails;
  final bool selected;
  final int index;
  void Function(int index) onClick;

  MotherCard(
      {super.key,
      required this.motherDetails,
      required this.selected,
      required this.onClick,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
        color: selected
            ? Theme.of(context).colorScheme.onTertiary
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(3.0),
          width: 42.w,
          height: 42.w,
          decoration: const BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  (motherDetails["lmp"] as DateTime).getGestAge().toString(),
                  //getGestAge().toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  "weeks",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 8.sp),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          motherDetails['fullName'] ?? motherDetails['name'],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
            ),
            child: motherDetails['edd'] != null
                ? Text(
                    (motherDetails["edd"] is DateTime)
                        ? "EDD - ${(motherDetails['edd'] as DateTime).format('dd MMM yyyy')}"
                        : ' EDD - ${DateFormat('dd MMM yyyy').format(
                            DateTime.parse(
                              motherDetails['edd'],
                            ),
                          )}',
                    style: const TextStyle(color: Colors.grey),
                  )
                : motherDetails['lmp'] != null
                    ? Text(
                        (motherDetails["lmp"] is DateTime)
                            ? "LMP - ${motherDetails['lmp'].format('dd MMM yyyy')}"
                            : ' LMP - ${DateFormat('dd MMM yyyy').format(
                                DateTime.parse(
                                  motherDetails['lmp'],
                                ),
                              )}',
                        style: const TextStyle(color: Colors.grey),
                      )
                    : const Text("")),
        //trailing: motherDetails['type'] == "BabyBeat" ? Image.asset("assets/bbc_icon.png", width: 20,) : Image.asset("images/ic_logo_good.png", width: 25,),
        onTap: () {
          onClick(index);
        },
      ),
    );
  }
}
