
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/ui/widgets/text_with_icon.dart';
import 'package:l8fe/utils/intrepretations2.dart';

class TestCard extends StatelessWidget {
  final CtgTest testDetails;
  late Interpretations2 interpretation;
  String? time;
  String? movements;
  TestCard({super.key, required this.testDetails}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);
    if (testDetails.lengthOfTest! > 180 && testDetails.lengthOfTest! < 3600) {
      interpretation =
          Interpretations2.withData(testDetails.bpmEntries, testDetails.gAge!);
    } else {
      interpretation = Interpretations2();
    }

    int _movements = testDetails.movementEntries!.length + testDetails.autoFetalMovement.length;
    movements = _movements < 10 ? "0$_movements" : '$_movements';

    int _time = (testDetails.lengthOfTest! / 60).truncate();
    if (_time < 10) {
      time = "0$_time";
    } else {
      time = "$_time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                  height: 40,
                                  //margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.5, color: Colors.grey)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      TextWithIcon(
                                          icon: Icons.favorite,
                                          text:
                                              '${interpretation.getBasalHeartRateStr()}'),
                                      Text(
                                        "Basal HR",
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  )),
                              Container(
                                  height: 40,
                                  //margin: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.5, color: Colors.grey)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      TextWithIcon(
                                          icon: Icons.arrow_upward,
                                          text:
                                              ' ${testDetails
                                                  .movementEntries != null &&
                                                  (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'}'),
                                      Text(
                                        "Movements",
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(

                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 0.5, color: Colors.grey)),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "${interpretation.getnAccelerationsStr()}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      30.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "ACCELERATION",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black87,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ]),
                                    )),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 0.5, color: Colors.grey)),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "${interpretation.getnDecelerationsStr()}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      30.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "DECELERATION",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black87,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ]),
                                    )),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 0.5, color: Colors.grey)),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "${interpretation.getShortTermVariationBpmStr()}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      30.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "SHORT TERM VARI",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black87,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ]),
                                    )),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 2),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 0.5, color: Colors.grey)),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              interpretation.getLongTermVariationStr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      30.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "LONG TERM VARI",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black87,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ]),
                                    )),
                              ],
                            )),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        testDetails.live!
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Live\nnow",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )))
                            : Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${DateFormat('dd\nMMM').format(testDetails.createdOn!)}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 30.sp,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ))),
                        Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(3.0),
                            margin: const EdgeInsets.only(top: 10, bottom: 5),
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 30.sp,
                                  ),
                                ),
                                Text(
                                  "min",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ))),
                      ],
                    ))
              ],
            )),
        onTap: () {
          //todo:
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetailsView(
                        test: this.testDetails,
                      )));*/
        });
  }
/*  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all( 3.0),

          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ' $time',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: FontUtil().setSp(26),
                    ),
                  ),
                  Text(
                    "min",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: FontUtil().setSp(12),
                    ),
                  ),
                ],
              ))),
      title: Text(
        'Basal HR - ${interpretation.getBasalHeartRate()==0?'--':interpretation.getBasalHeartRate()} bpm | Movements - ${testDetails.movementEntries != null && testDetails.movementEntries.length>0? testDetails.movementEntries.length : '--'} ',
        style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black87
        ),
      ),
      subtitle: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: Text(
            'STV - ${interpretation.getShortTermVariationBpmStr()} bpm | LTV - ${interpretation.getLongTermVariationStr()} bpm',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey),
          )),
      trailing: testDetails.isLive()? Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: SizedBox(
              width: 40,
              height: 40,
              child :Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Center(child: Text("Live\nnow", textAlign: TextAlign.center, style: TextStyle( fontSize: 10,color: Colors.white,fontWeight: FontWeight.w500),),),
              ))): Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: SizedBox(
              width: 40,
              height: 40,
              child :Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Center(child: Text("${DateFormat('dd\nMMM').format(testDetails.createdOn)}", textAlign: TextAlign.center,  style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.w500),),),
              ))),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsView(
                  test: this.testDetails,
                  interpretations: interpretation,
                )));
      },
    );
    */ /*return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsView(
                      test: this.testDetails,
                      interpretations: interpretation,
                    )));
      },
      child: Padding(
        padding: EdgeInsets.all(FontUtil().setSp(24)),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors
                            .grey))),
            child: Column(
              children: <Widget>[
                */ /* */ /*Hero(
                  tag: motherDetails.documentId,
                  child: Image.asset(
                  'assets/ic_feton_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height *
                        0.35,
                  ),
                ),*/ /* */ /*

                Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Text("${testDetails.motherName} - ${DateFormat('dd MMM yyyy').format(testDetails.createdOn)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey
                            ))
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(0,8,0,8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Icon(Icons.favorite),
                      Text(
                        ' ${interpretation.getBasalHeartRate()} Basal HR',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize : FontUtil().setSp(20)),

                          //'${testDetails.averageFHR} Basal HR ',
                      ),
                      new ImageIcon(new AssetImage("assets/Line.png")),
                      new Icon(Icons.arrow_upward),
                      Text(
                        ' ${testDetails.movementEntries != null ? testDetails.movementEntries.length : 0} Movements',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize : FontUtil().setSp(20)),
                      ),
                      new ImageIcon(new AssetImage("assets/Line.png")),
                      new Icon(Icons.access_time),
                      Text(
                        ' ${(testDetails.lengthOfTest / 60).truncate()} min',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize : FontUtil().setSp(20)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );*/ /*
  }*/
  /* @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsView(
                      test: this.testDetails,
                      interpretations: interpretation,
                    )));
      },
      child: Padding(
        padding: EdgeInsets.all(FontUtil().setSp(24)),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors
                            .grey))),
            child: Column(
              children: <Widget>[
                */ /*Hero(
                  tag: motherDetails.documentId,
                  child: Image.asset(
                  'assets/ic_feton_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height *
                        0.35,
                  ),
                ),*/ /*

                Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Text(DateFormat('dd MMM yyyy - hh:mm a').format(testDetails.createdOn),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey
                            ))
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(0,8,0,8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Icon(Icons.favorite),
                      Text(
                        ' ${interpretation.getBasalHeartRate()} Basal HR',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize : FontUtil().setSp(20)),

                          //'${testDetails.averageFHR} Basal HR ',
                      ),
                      new ImageIcon(new AssetImage("assets/Line.png")),
                      new Icon(Icons.arrow_upward),
                      Text(
                        ' ${testDetails.movementEntries != null ? testDetails.movementEntries.length : 0} Movements',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize : FontUtil().setSp(20)),
                      ),
                      new ImageIcon(new AssetImage("assets/Line.png")),
                      new Icon(Icons.access_time),
                      Text(
                        ' ${(testDetails.lengthOfTest / 60).truncate()} min',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize : FontUtil().setSp(20)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }*/

  /*ListTile makeListTile(Test test) => ListTile(
    contentPadding:
    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    leading: Container(
      padding: EdgeInsets.only(right: 12.0),
      decoration: new BoxDecoration(
          border: new Border(
              right: new BorderSide(width: 1.0, color: Colors.white24))),
      child: Icon(Icons.favorite, color: Colors.black),
    ),
    title: Text(
      test.motherName,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),


    subtitle: Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(test.level,
                  style: TextStyle(color: Colors.white))),
        )
      ],
    ),
    trailing:
    Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
    onTap: () {

      //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
    },
  );*/
}
