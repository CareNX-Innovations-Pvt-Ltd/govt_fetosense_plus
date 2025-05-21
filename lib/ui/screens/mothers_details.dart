
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'mother_test_list_view.dart';

class MotherDetails extends StatelessWidget {
  final dynamic mother;

  const MotherDetails({super.key, required this.mother});
  @override
  // TODO: implement screenName
  String get screenName => "MotherDeatilsScreen";

  int getGestAge() {
    // double age = ((new DateTime.now().millisecondsSinceEpoch -
    //             mother.getLmp().millisecondsSinceEpoch) /
    //         1000 /
    //         60 /
    //         60 /
    //         24) /
    //     7;
    // return age.floor();

    if(mother['edd'] != null){
      double age = (280 - (
          (DateTime.parse(mother['edd']).millisecondsSinceEpoch -new DateTime.now().millisecondsSinceEpoch)
              /(1000*60*60*24)))/
          7;
      return age.floor();
    }else{
      return 0;
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.teal)),
        ),
        child: ListTile(
          leading: IconButton(
            iconSize: 35,
            icon: Icon(Icons.arrow_back, size: 30, color: Colors.teal),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "${mother['fullName']}",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          subtitle: Text(
            "LMP - ${DateFormat('dd MMM yyyy').format(DateTime.parse(mother['edd']))}",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
          ),
          trailing: Container(
              padding: const EdgeInsets.all(3.0),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    getGestAge().toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 36.sp,
                    ),
                  ),
                  Text(
                    "weeks",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 22.sp,
                    ),
                  ),
                ],
              ))),
        ),
      ),
      Expanded(child:  MotherTestListView(mother: mother))
    ])));
  }
}

/*  Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                       Text(
                            mother.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                              fontSize: FontUtil().setSp(44),
                            ),
                          ),
                    ]),
              ), //name
              Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("AGE"),
                          Text(
                            mother.age.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                fontStyle: FontStyle.italic),
                          ),
                          Text("years")
                        ],
                      ),
                      Column(
                        children: [
                          Text("G Age"),
                          Text(
                            getGestAge().toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                fontStyle: FontStyle.italic),
                          ),
                          Text("weeks")
                        ],
                      ),
                      Column(
                        children: [
                          Text("EDD"),
                          Text(
                            mother.getEdd().day.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(getMonthName(mother.getEdd().month))
                        ],
                      )
                    ]),
              ), //details
*/
