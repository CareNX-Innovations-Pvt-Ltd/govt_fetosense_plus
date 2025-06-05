import 'dart:async';
import 'package:action_slider/action_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:l8fe/ble/bluetooth_ctg_service.dart';
import 'package:l8fe/ble/bluetooth_spo2_service.dart';
import 'package:l8fe/ble/unified_service.dart';
import 'package:l8fe/bloc/session/session_cubit.dart';
import 'package:l8fe/services/firestore_database.dart';
import 'package:l8fe/ui/home/mother_home.dart';
import 'package:l8fe/ui/pdf/pdf_base_page.dart';
import 'package:l8fe/ui/test_view.dart';
import 'package:l8fe/ui/widgets/graphPainter.dart';
import 'package:collection/collection.dart';
import 'package:l8fe/utils/encryption_helper.dart';

import 'package:l8fe/utils/fhrPdfview.dart';
import 'package:l8fe/ui/pdf/fhrPdfview2.dart';
import 'package:l8fe/utils/test/interpretation.dart';
import 'package:pdf/pdf.dart';
//import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:preferences/preference_service.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/device_model.dart';
import '../models/mother_model.dart';
import '../models/test_model.dart';
import '../utils/intrepretations2.dart';
import 'dart:io' as io;

import '../utils/test/intrepretations2.dart';

enum PrintStatus {
  PRE_PROCESSING,
  GENERATING_FILE,
  GENERATING_PRINT,
  FILE_READY,
}

enum Action { PRINT, SHARE }

const directoryName = 'fetosense';

class DetailsView extends StatefulWidget {
  final CtgTest test;
  const DetailsView({super.key, required this.test, });

  @override
  State createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Mother? mom;
  final UnifiedBluetoothService _bluetoothService = UnifiedBluetoothService();
  int gridPreMin = 3;
  late int pointsOnDisplay;
  double mTouchStart = 0;
  int mOffset = 0;

  bool deviceFound = true;

  late String movements;

  late Device user;

  Interpretations2? interpretation;

  Interpretations2? interpretation2;

  bool isLoadingShare = false;

  bool isLoadingPrint = false;

  var pdfFile;
  late pw.Document pdfDoc;
  Action? action;
  PrintStatus printStatus = PrintStatus.PRE_PROCESSING;

  List<String>? paths;


  @override
  void initState() {
    gridPreMin = PrefService.getInt('gridPreMin') ?? 3;
    pointsOnDisplay = ((22/gridPreMin)*60).toInt() ;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    user = context.read<SessionCubit>().currentUser.value!;
    super.initState();
    if(widget.test.bpmEntries.isNotEmpty && widget.test.bpmEntries.length>180) {
      interpretation = Interpretations2.withData(
          widget.test.bpmEntries, widget.test.gAge ?? 0,
          test: widget.test);
      // Assuming you have:
// List<int> fhrData = [...]; // Your FHR samples
// int gestationalAge = 34;

// Perform the interpretation
      InterpretationResult result = Interpretations.interpret(widget.test.bpmEntries, widget.test.gAge??37);

// Check if the calculation was successful
      if (result.isSkipped) {
        print("CTG Interpretation skipped due to insufficient data or error.");
      } else {
        // Access the results
        print("Basal Heart Rate: ${result.basalHeartRate} BPM");
        print("Accelerations: ${result.nAccelerations}");
        print("Decelerations: ${result.nDecelerations}");
        print("STV (BPM): ${result.shortTermVariationBpm.toStringAsFixed(2)}");
        print("LTV (BPM): ${result.longTermVariation}");
        print("Fisher Score: ${result.fisherScore}");
        print("Fisher Details: ${result.fisherScoreDetails}");
        print("Noise Segments: ${result.noiseList.length}");
        // You can now update your CtgTest object if needed:
        // test?.fisherScore = result.fisherScore;
        // test?.autoInterpretations = { ... map result fields ... };
        // etc.
      }
    }
    if(widget.test.bpmEntries2.isNotEmpty && widget.test.bpmEntries2.length>180){
      interpretation2 = Interpretations2.withData(
          widget.test.bpmEntries2, widget.test.gAge ?? 0);
    }
    getMom();

    //_startTimer();
    //int _movements = test.movementEntries.length + test.autoFetalMovement.length;
    //movements = _movements < 10 ? "0$_movements" : '$_movements';
  }


  getMom()async {
    //debugPrint("getMom ==== ${mom?.toJson().toString()}");
    //debugPrint("btDevice null ==== ${widget.btDevice==null}");

    //if(widget.btDevice==null) return;
    debugPrint("getMom ==== ${mom?.toJson().toString()}");
    mom = await FirestoreDatabase(uid: context.read<SessionCubit>().currentUser.value!.uid).getMotherDetails(id:widget.test.motherId??"");
    debugPrint("getMom ==== ${mom?.toJson().toString()}");
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            width: 1.sw,
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 8.w,
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_back,
                          size: 32, color: Colors.teal),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: IconButton(
                          iconSize: 35,
                          icon: const Icon( Icons.manage_accounts_rounded),
                          onPressed: mom==null?null:() {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => MotherHome(motherId: mom!.documentId,mother: mom!.toJson(),)));
                          },
                        ),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${widget.test.motherName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.sp,
                                    color: Colors.white)),
                            Text(
                              DateFormat('dd MMM yy - hh:mm a')
                                  .format(widget.test.createdOn),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.sp,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )

                    ),
                    SizedBox(
                      width: 16.w,
                    ),
                    IconButton(
                      iconSize: 35,
                      icon: Icon(gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
                      onPressed: () => setState(() {
                        gridPreMin = gridPreMin == 1 ? 3 : 1;
                        pointsOnDisplay = ((24/gridPreMin)*60).toInt();
                      }),
                    ),
                    !isLoadingShare
                        ? IconButton(
                            iconSize: 35,
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              if (!isLoadingPrint) {
                                setState(() {
                                  isLoadingShare = true;
                                  action = Action.SHARE;
                                });
                                _print();
                              }
                            },
                          )
                        : IconButton(
                            iconSize: 35,
                            icon: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            onPressed: () {},
                          ),
                    !isLoadingPrint
                        ? IconButton(
                            iconSize: 35,
                            icon: const Icon(Icons.print),
                            onPressed: () {
                              if (!isLoadingShare) {
                                setState(() {
                                  isLoadingPrint = true;
                                  action = Action.PRINT;
                                });
                                _print();
                              }
                            },
                          )
                        : IconButton(
                            iconSize: 35,
                            icon: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            onPressed: () {},
                          ),
                   /* IconButton(
                      iconSize: 35,
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),*/
                  ],
                ),
                if(mom!=null && _bluetoothService.isConnectedNotifier.value && widget.test.bpmEntries2.isNotEmpty)
                Center(
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> TestView(mom: mom,)));
                    },
                    child: Container(
                      width: 0.125.sw,
                      height: 62.h,
                      padding: EdgeInsets.symmetric(vertical:8.w),
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(60.w),
                        color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
                      ),
                      alignment: Alignment.center,
                      child:
                      AutoSizeText(
                        "New test",
                        style: Theme.of(context).textTheme.bodyLarge,),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                    onHorizontalDragStart: (DragStartDetails start) =>
                        _onDragStart(context, start),
                    onHorizontalDragUpdate: (DragUpdateDetails update) =>
                        _handleHorizontalDragUpdate(context, update),
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        //width: MediaQuery.of(context).size.width* 0.7 ,
                        height: 0.85.sh,
                        child: CustomPaint(
                          key: Key("${widget.test.bpmEntries.length}"),
                          painter:
                              GraphPainter(widget.test, mOffset, gridPreMin,interpretations: interpretation),
                        ))),
              ),
              Container(
                width: 0.25.sw,
                height: 0.85.sh,
                decoration: const BoxDecoration(
                  border:
                      Border(left: BorderSide(width: 2, color: Colors.black)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                        height: 0.25.sh,
                        width: 0.24.sw,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                              BorderSide(width: 0.5, color: Colors.grey)),
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.w),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    AutoSizeText.rich(
                                      TextSpan(text: "", children: [
                                        const TextSpan(
                                          text: "DURATION",
                                        ),
                                        const TextSpan(text: "\nMOVEMENTS"),
                                        const TextSpan(text: "\nBLOOD PRESSURE"),
                                        const TextSpan(text: "\nPULSE"),
                                        TextSpan(
                                            text: "\nSHORT TERM VARI  ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color:
                                                Colors.white.withOpacity(0),
                                                fontWeight: FontWeight.w500)),
                                      ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    AutoSizeText.rich(
                                      TextSpan(text: "", children: [
                                        TextSpan(
                                          text:
                                          ": ${(widget.test.bpmEntries.length ~/ 60)} m",
                                        ),
                                        TextSpan(
                                          text:
                                          "\n: ${(widget.test.movementEntries.length)}/${(widget.test.autoFetalMovement.length)}",
                                        ),
                                        TextSpan(
                                          text:
                                          "\n: ${(widget.test.lastBp?["systolic"]??"---")}/${(widget.test.lastBp?["diastolic"]??"---")}",
                                        ),
                                        TextSpan(
                                          text:
                                          "\n: ${(widget.test.lastBp?["pulse"]??"---")}",
                                        ),
                                        const TextSpan(
                                          text: "\n ",
                                        ),
                                      ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ])),
                    Container(
                        height: 0.30.sh,
                        width: 0.24.sw,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 0.5, color: Colors.grey)),
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.w),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    AutoSizeText.rich(
                                      const TextSpan(
                                          text: "BASAL HR",
                                          children: [
                                            TextSpan(
                                              text: "\nACCELERATION",
                                            ),
                                            TextSpan(
                                              text: "\nDECELERATION",
                                            ),
                                            TextSpan(
                                              text: "\nSHORT TERM VARI  ",
                                            ),
                                            TextSpan(
                                              text: "\nLONG TERM VARI ",
                                            ),
                                          ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    AutoSizeText.rich(
                                      TextSpan(
                                          text:
                                              ": ${(interpretation?.basalHeartRate ?? "--")}",
                                          children: [
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation?.getnAccelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation?.getnDecelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation?.getShortTermVariationBpmStr() ?? "--")}/${(interpretation?.getShortTermVariationMilliStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation?.getLongTermVariationStr() ?? "--")}",
                                            ),
                                          ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                alignment: Alignment.center,
                                child: Text(
                                  "FHR 1",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white54,
                                    fontSize: 22.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ])),
                    Container(
                        height: 0.30.sh,
                        width: 0.24.sw,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 0.5, color: Colors.grey)),
                        ),
                        child:

                        (widget.test.bpmEntries2.isNotEmpty && widget.test.bpmEntries2.average>10)?
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.w),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    AutoSizeText.rich(
                                      const TextSpan(
                                          text: "BASAL HR",
                                          children: [
                                            TextSpan(
                                              text: "\nACCELERATION",
                                            ),
                                            TextSpan(
                                              text: "\nDECELERATION",
                                            ),
                                            TextSpan(
                                              text: "\nSHORT TERM VARI  ",
                                            ),
                                            TextSpan(
                                              text: "\nLONG TERM VARI ",
                                            ),
                                          ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    AutoSizeText.rich(
                                      TextSpan(
                                          text:
                                              ": ${(interpretation2?.basalHeartRate ?? "--")}",
                                          children: [
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation2?.getnAccelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation2?.getnDecelerationsStr() ?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation2?.getShortTermVariationBpmStr() ?? "--")}/${(interpretation2?.getShortTermVariationMilliStr()?? "--")}",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(interpretation2?.getLongTermVariationStr()?? "--")}",
                                            ),
                                          ]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                alignment: Alignment.center,
                                child: Text(
                                  "FHR 2",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white54,
                                    fontSize: 22.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]): (mom!=null && _bluetoothService.isConnectedNotifier.value) ?
                              Center(
                                child: InkWell(
                                  onTap: (){
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> TestView(mom: mom,)));
                                  },
                                  child: Container(
                                    width: 0.125.sw,
                                    height: 62.h,
                                    padding: EdgeInsets.symmetric(vertical:8.w),
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(60.w),
                                      color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
                                    ),
                                    alignment: Alignment.center,
                                    child:
                                    AutoSizeText(
                                      "New test",
                                      style: Theme.of(context).textTheme.bodyLarge,),
                                  ),
                                ),
                              ):SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  int _calculateMaxScrollOffset() {
    // Calculate the maximum scrollable distance based on data size and visible points
    //const visiblePoints = pointsOnDisplay; // Adjust as needed
    return  widget.test.bpmEntries.length - pointsOnDisplay;
  }


  void _handleHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) {
    setState(() {
      mOffset = (mOffset - details.delta.dx).clamp(0, _calculateMaxScrollOffset()).toInt();
    });
  }

  _onDragStart(BuildContext context, DragStartDetails start) {
    print(start.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    mOffset = trap(mOffset + (newChange / (gridPreMin * 24)).truncate());
    setState(() {
    });
    debugPrint("trap ${mOffset.toString()}, $newChange, ");
  }
  _onDragEnd(context, DragEndDetails end){
    debugPrint("end --- ${end.toString()}");

  }



  /*_onDragStart(BuildContext context, DragStartDetails start) {
    print(start.globalPosition.toString());
    RenderObject? getBox = context.findRenderObject();
    mTouchStart = getBox!.globalToLocal(start.globalPosition).dx;

    double touchStartX = details.globalPosition.dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject();
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      this.mOffset =
          trap(this.mOffset + (newChange / (gridPreMin * 5)).truncate());
    });
    print(this.mOffset.toString());
  }*/

  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if(pos>(widget.test.bpmEntries.length - pointsOnDisplay)){
      return pos = widget.test.bpmEntries.length - pointsOnDisplay;
    } else if (pos > widget.test.bpmEntries.length) {
      pos = widget.test.bpmEntries.length - 10;
    }

    return pos;
  }

  @override
  void dispose() {
    //subscriptions?.map((e) => e?.cancel());
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    debugPrint('didChangeDependencies');
    super.didChangeDependencies();
  }

  Future<void> _print() async {
    switch (printStatus) {
      case PrintStatus.PRE_PROCESSING:
        pdfDoc = await _generatePdf(PdfPageFormat.a4.landscape, widget.test);

        if (action == Action.PRINT) {
          await Printing.layoutPdf(
              format: PdfPageFormat.a4.landscape,
              onLayout: (PdfPageFormat format) async => pdfDoc.save());
          setState(() {
            isLoadingPrint = false;
          });
        } else {
          await Printing.sharePdf(
              bytes: await pdfDoc.save(), filename: 'NSTtest.pdf');
          setState(() {
            isLoadingShare = false;
          });

          //Navigator.of(context).pop();
        }

        break;
      case PrintStatus.GENERATING_FILE:
        break;
      case PrintStatus.GENERATING_PRINT:
        // TODO: Handle this case.
        pdfDoc.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) => <pw.Widget>[pw.Text("hello")]));
        setState(() {
          printStatus = PrintStatus.FILE_READY;
        });
        break;
      case PrintStatus.FILE_READY:
        // TODO: Handle this case.

        break;
    }
    setState(() {
      printStatus = PrintStatus.PRE_PROCESSING;
    });
  }


  Future<pw.Document> _generatePdf(PdfPageFormat format, CtgTest test) async {
    // final font = await PdfGoogleFonts.robotoLight();
    final pdf = pw.Document();
    int index = 1;
    Interpretations2 interpretations = (test.autoInterpretations??{}).isNotEmpty ? Interpretations2.fromMap(test):Interpretations2.withData(test.bpmEntries, test.gAge??32);
    Interpretations2? interpretations2 = test.bpmEntries2.isNotEmpty? Interpretations2.withData(test.bpmEntries2, test.gAge??32):null;
    FhrPdfView2 fhrPdfView = FhrPdfView2(test.lengthOfTest,);
    final paths = await fhrPdfView.getNSTGraph(test, interpretations);
    for (int i = 0; i<paths!.length; i++) {
      final mImage = pw.MemoryImage(io.File(paths[i]).readAsBytesSync());
      pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: pw.EdgeInsets.zero,
            build: (context) {
              return PfdBasePage(data: test,interpretation: interpretations,interpretation2: interpretations2, index: index+i, total: paths.length, body: pw.Image(mImage));
            },
          ));// Page
    }
    return pdf;
  }

}
