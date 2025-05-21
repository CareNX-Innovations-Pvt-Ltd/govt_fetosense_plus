
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/ui/details_view.dart';
import 'package:l8fe/ui/pdf/pdf_base_page.dart';
import 'package:l8fe/ui/widgets/graphPainter.dart';
import 'package:l8fe/ui/widgets/graph_painter_tile.dart';
import 'package:l8fe/ui/pdf/fhrPdfview2.dart';
import 'package:l8fe/utils/intrepretations2.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io' as io;


class AllTestCard extends StatelessWidget {
  final CtgTest testDetails;
  Interpretations2? interpretation;
  Interpretations2? interpretation2;
  EdgeInsets? margin;
  String? _time;
  double? width;
  String? _movements;

  bool showName;

  AllTestCard({super.key, required this.testDetails,this.margin,this.showName=true,this.width=null,}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);
    // if (testDetails.lengthOfTest > 180 && testDetails.lengthOfTest < 3600)
    //   interpretation =
    //       Interpretations2.withData(testDetails.bpmEntries, testDetails.gAge);
    // else
    //   interpretation = Interpretations2();

    int movements = testDetails.movementEntries.length + testDetails.autoFetalMovement.length;
    _movements = movements < 10 ? "0$movements" : '$movements';

    int time = (testDetails.lengthOfTest / 60).truncate();
    if (time < 10) {
      _time = "0$time";
    } else {
      _time = "$time";
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("-----------Test Id test ----------- ${testDetails.id}");
    //interpretation = Interpretations2.fromMap(testDetails);

    interpretation = (testDetails.autoInterpretations??{}).isNotEmpty ? Interpretations2.fromMap(testDetails):Interpretations2.withData(testDetails.bpmEntries, testDetails.gAge??32);

    return InkWell(
      onTap: ()=> Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  DetailsView(
                    test: testDetails,
                  ))),
      child: Container(
        width: width?? 0.32.sw,
        margin: margin,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(14.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onTertiary,
                  borderRadius: BorderRadius.circular(14.h),
                ),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                            width: width??0.32.sw ,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.0),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                boxShadow:  const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 16.0,
                                    offset: Offset(8.0, 8.0),
                                  ),
                                ]
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: CustomPaint(
                                key: Key("${testDetails.bpmEntries.length}"),
                                painter: GraphPainterTile(testDetails, 0, 1,interpretations: interpretation),
                              ),
                            )),
                        Positioned(
                          right: 8.w,
                          top: 8.h,
                          child: AutoSizeText.rich(TextSpan(text:
                            "$_time", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white54),
                                children: [
                                  TextSpan(text: "\nmin",style:  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54))
                                ]
                            ),
                              textAlign: TextAlign.center,
                            ),)
                      ],
                    ),
                    Expanded(
                        child: Container(
                          width: width??0.32.sw,
                          alignment: Alignment.center,
                          child:AutoSizeText(
                              " ${interpretation?.basalHeartRate ?? '--'} Basal HR | ${(testDetails.movementEntries.length + testDetails.autoFetalMovement.length) > 0 ? _movements : '--'} Movements",
                              style: Theme.of(context).textTheme.labelSmall
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),


            Container(
              padding: margin??EdgeInsets.all(8.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(showName)
                      AutoSizeText(
                        "${testDetails.motherName}",
                        style: TextStyle(
                          fontSize: 22.sp,
                        ),
                        minFontSize: 10,
                      ),
                      AutoSizeText.rich(TextSpan(text:
                      DateFormat('dd MMM').format(testDetails.createdOn),
                          children: [
                            TextSpan(text:"${showName?"\n":" "}${DateFormat('hh:mm a').format(testDetails.createdOn)}",style:  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54))
                          ]
                      ),style:  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54)),

                    ],
                  ),


                ],
              ),
            )

          ],
        ),
      ),
    );
  }

}

class PreviewView extends StatelessWidget{
  final CtgTest test;
  const PreviewView({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      actions: const [],
      initialPageFormat:  PdfPageFormat.a4.landscape,
      build: (format) => _generatePdf(format, test),
    );
  }


  Future<Uint8List> _generatePdf(PdfPageFormat format, CtgTest test) async {
    // final font = await PdfGoogleFonts.robotoLight();
    final pdf = pw.Document();
    int index = 1;

    /*pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return PfdBasePage(data: data, index: index, total: 1, body: pw.Container());
        },
      ),
    );*/

    Interpretations2 interpretations = test.autoInterpretations!=null ? Interpretations2.fromMap(test):Interpretations2.withData(test.bpmEntries, test.gAge??32);
    Interpretations2? interpretations2 = test.bpmEntries2.isNotEmpty? Interpretations2.withData(test.bpmEntries2, test.gAge??32):null;
    FhrPdfView2 fhrPdfView = FhrPdfView2(test.lengthOfTest,);
    final paths = await fhrPdfView.getNSTGraph(test, interpretations2);
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

    //index++;

    return pdf.save();
  }
}
