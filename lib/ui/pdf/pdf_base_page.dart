import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:l8fe/models/test_model.dart';
import 'package:l8fe/utils/date_format_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:preferences/preferences.dart';
import 'package:collection/collection.dart';

import '../../constants/svg_strings.dart';
import '../../utils/intrepretations2.dart';

/// A class representing a base page for a PDF document.
class PfdBasePage extends pw.StatelessWidget {
  final pw.Widget body;
  final CtgTest data;
  final Interpretations2? interpretation;
  final Interpretations2? interpretation2;
  final int index;
  final int total;

  /// Creates a new instance of [PfdBasePage].
  ///
  /// [index] is the current page index.
  /// [total] is the total number of pages.
  /// [data] contains the test data.
  /// [interpretation] is the first interpretation data.
  /// [interpretation2] is the second interpretation data.
  /// [body] is the main content of the page.
  PfdBasePage({
    required this.index,
    required this.total,
    required this.data,
    required this.interpretation,
    required this.interpretation2,
    required this.body,
  });

  @override
  pw.Widget build(dynamic context) {
    final doctorsComment = splitTextIntoLines(data.interpretationExtraComments??"",2, 8 * PdfPageFormat.cm, 4);

    return pw.Column(
      children: [
        Header(data: data),
        pw.Flexible(child:pw.Row(
            children: [
              //pw.Transform.scale(scale: 1.05,child: body),
              body,
              pw.Container(
                width: 8 * PdfPageFormat.cm,
                margin: const pw.EdgeInsets.only(left: PdfPageFormat.mm),
                padding: const pw.EdgeInsets.symmetric(horizontal:PdfPageFormat.mm * 5 ),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      left: pw.BorderSide(width: 1.0, color: PdfColors.grey)),
                ),
                alignment: pw.Alignment.topLeft,
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: PdfPageFormat.mm * 4),
                      pw.Row(
                        children: [
                          pw.RichText(text:
                          pw.TextSpan(
                            text: "DURATION",
                            children:   [
                              const pw.TextSpan(
                                text: "\nMOVEMENTS",
                              ),
                              const pw.TextSpan(
                                text: "\nBP",
                              ),
                              const pw.TextSpan(
                                text: "\nPULSE",
                              ),
                              pw.TextSpan(
                                  text: "\nSHORT TERM VARI  ",
                                  style: pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.white,
                                      lineSpacing: PdfPageFormat.mm *1,
                                      fontWeight: pw.FontWeight.bold)
                              ),

                            ],
                            style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey,
                                lineSpacing: PdfPageFormat.mm *1,
                                fontWeight: pw.FontWeight.bold),
                          ),
                            textAlign: pw.TextAlign.left,

                          ),
                          pw.RichText(text:
                          pw.TextSpan(
                            text:
                            ": ${data.lengthOfTest~/60} Minutes ",
                            children: [
                              pw.TextSpan(
                                text:
                                "\n: ${(data.movementEntries.length)} manual / ${(data.autoFetalMovement.length)} auto",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(data.lastBp?["systolic"]??"---")}/${(data.lastBp?["diastolic"]??"---")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(data.lastBp?["pulse"]??"---")}",
                              ),
                              pw.TextSpan(
                                  text: "\nSHORT   ",
                                  style: pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.white,
                                      lineSpacing: PdfPageFormat.mm *1,
                                      fontWeight: pw.FontWeight.bold)
                              )

                            ],

                            style: pw.TextStyle(
                                fontSize: 8,
                                lineSpacing: PdfPageFormat.mm *1,
                                fontWeight: pw.FontWeight.bold),),
                            textAlign: pw.TextAlign.left,
                            /*
                        style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold),*/
                          ),
                        ],
                      ),
                      pw.Text("FHR1",
                          style: pw.TextStyle(
                              color: PdfColors.teal,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0),
                          textAlign: pw.TextAlign.left
                      ),
                      pw.Row(
                        children: [
                          pw.RichText(text:
                          pw.TextSpan(
                            text: "BASAL HR",
                            children: const [
                              pw.TextSpan(
                                text: "\nACCELERATION",
                              ),
                              pw.TextSpan(
                                text: "\nDECELERATION",
                              ),
                              pw.TextSpan(
                                text: "\nFISHER SCORE",
                              ),
                              pw.TextSpan(
                                text: "\nSHORT TERM VARI  ",
                              ),
                              pw.TextSpan(
                                text: "\nLONG TERM VARI ",
                              ),
                            ],
                            style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey,
                                lineSpacing: PdfPageFormat.mm *1,
                                fontWeight: pw.FontWeight.bold),
                          ),
                            textAlign: pw.TextAlign.left,

                          ),
                          pw.RichText(text:
                          pw.TextSpan(
                            text:
                            ": ${(interpretation?.basalHeartRate ?? "--")} bpm",
                            children: [
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation?.getnAccelerationsStr() ?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation?.getnDecelerationsStr() ?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation?.fisherScore)}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation?.getShortTermVariationBpmStr() ?? "--")} bpm /${(interpretation?.getShortTermVariationMilliStr()?? "--")} milli",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation?.getLongTermVariationStr()?? "--")} bpm",
                              ),
                            ],

                            style: pw.TextStyle(
                                fontSize: 8,
                                lineSpacing: PdfPageFormat.mm *1,
                                fontWeight: pw.FontWeight.bold),),
                            textAlign: pw.TextAlign.left,
                            /*
                        style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold),*/
                          ),
                        ],
                      ),
                      pw.SizedBox(height: PdfPageFormat.mm * 4),

                      pw.Text("FHR2",
                          style: pw.TextStyle(
                              color: (data.bpmEntries2.isNotEmpty && data.bpmEntries2.average>10)?PdfColors.teal:PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0),
                          textAlign: pw.TextAlign.left
                      ),
                      pw.Row(
                        children: [
                          pw.RichText(text:
                          pw.TextSpan(
                            text: "BASAL HR",
                            children: const [
                              pw.TextSpan(
                                text: "\nACCELERATION",
                              ),
                              pw.TextSpan(
                                text: "\nDECELERATION",
                              ),
                              pw.TextSpan(
                                text: "\nFISHER SCORE",
                              ),
                              pw.TextSpan(
                                text: "\nSHORT TERM VARI ",
                              ),
                              pw.TextSpan(
                                text: "\nLONG TERM VARI ",
                              ),
                            ],
                            style: pw.TextStyle(
                                fontSize: 8,
                                color: (data.bpmEntries2.isNotEmpty && data.bpmEntries2.average>10)?PdfColors.grey:PdfColors.white,
                                lineSpacing: PdfPageFormat.mm * 1,
                                fontWeight: pw.FontWeight.bold),
                          ),
                            textAlign: pw.TextAlign.left,

                          ),
                          pw.RichText(text:
                          pw.TextSpan(
                            text:
                            ": ${(interpretation2?.basalHeartRate ?? "--")}",
                            children: [
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation2?.getnAccelerationsStr() ?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation2?.getnDecelerationsStr() ?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation2?.fisherScore ?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation2?.getShortTermVariationBpmStr() ?? "--")}/${(interpretation2?.getShortTermVariationMilliStr()?? "--")}",
                              ),
                              pw.TextSpan(
                                text:
                                "\n: ${(interpretation2?.getLongTermVariationStr()?? "--")}",
                              ),
                            ],

                            style: pw.TextStyle(
                                fontSize: 8,
                                color: (data.bpmEntries2.isNotEmpty && data.bpmEntries2.average>10)?PdfColors.black:PdfColors.white,
                                lineSpacing: PdfPageFormat.mm * 1,
                                fontWeight: pw.FontWeight.bold),),
                            textAlign: pw.TextAlign.left,
                            /*
                        style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold),*/
                          ),
                        ],
                      ),
                      pw.SizedBox(height: PdfPageFormat.mm * 4),
                      //if(data.interpretationType.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Doctor's note: ${data.interpretationType.toUpperCase()}",
                              style: pw.TextStyle(
                                  color: PdfColors.teal,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1.0),
                              textAlign: pw.TextAlign.left
                          ),
                          ...List.generate(2, (index) {
                            return pw.Container(
                              width: PdfPageFormat.cm * 8,
                              height: PdfPageFormat.cm * 0.6, // Space between lines
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.grey, width: 1),
                                ),
                              ),
                              child: pw.Align(
                                alignment: pw.Alignment.bottomLeft,
                                child: pw.Text(
                                  doctorsComment[index],
                                  style: pw.TextStyle(
                                      color: PdfColors.teal,
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.normal,
                                      letterSpacing: 1),
                                  textAlign: pw.TextAlign.left,
                                ),
                              ),
                            );
                          })
                        ],
                      ),

                      pw.SizedBox(height: PdfPageFormat.mm * 6),
                      pw.TableHelper.fromTextArray(
                        border: pw.TableBorder.all(color: PdfColors.grey), // Adds border to the entire table
                        headerStyle:  pw.TextStyle( fontSize: 4,fontWeight: pw.FontWeight.bold),
                        headerAlignment: pw.Alignment.centerLeft,// Custom font for headers
                        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                        cellStyle: const pw.TextStyle(fontSize: 4),   // Custom font for cells
                        columnWidths: {
                          0: const pw.FixedColumnWidth(60), // Parameter
                          1: const pw.FixedColumnWidth(100), // Normal NST
                          2: const pw.FixedColumnWidth(100), // Atypical NST
                          3: const pw.FixedColumnWidth(100), // Abnormal Tracing
                        },
                        headers: const [
                          'Parameter',
                          'Normal NST\n("Reactive")',
                          'Atypical NST\n("Non-reactive")',
                          'Abnormal Tracing\n("Non-reassuring")',
                        ],
                        data: [
                          ['Baseline', '110-160 bpm', '100-110 bpm\nTachy > 160 bpm (>30 min)\nRising', 'Brady < 100 bpm\nTachy > 160 bpm (>30 min) Erratic'],
                          ['Variability', '6-25 bpm (mod)\n<= 5 (abs/min) < 40 min', '<= 5 (abs/min) 40-80 min', '<= 5 bpm >= 80 min\n>= 25 bpm >= 10 min Sinusoidal'],
                          ['Accelerations (Term)', '>= 2 accelerations >= 15 bpm, 15 sec in < 40 min', '>= 2 accelerations >= 15 bpm, 15 sec in 40-80 min', '>= 2 accelerations >= 15 bpm, 15 sec in > 80 min'],
                          //['Accelerations (Preterm < 32w)', '>= 2 accelerations >= 10 bpm, 10 sec in < 40 min', '>= 2 accelerations ≥ 10 bpm, 10 sec in 40-80 min', '<= 2 accelerations >= 10 bpm, 10 sec in > 80 min'],
                          ['Decelerations', 'None/occ var < 30 sec', 'Var decelerations 30-60 sec', 'Variable Decelerations > 60 sec Late Decelerations'],
                          ['ACTION', 'Further assess (opt) based on total clinical picture', 'Further assess (req)', 'URGENT ACTION REQ\nAssess & investigate (U/S or BPP). Possible delivery.'],
                        ],
                      ),
                      //pw.Image(pw.MemoryImage(chart),width: PdfPageFormat.cm * 7),
                      //buildNstTable()
                    ]
                ),

              ),
            ]
        ),fit: pw.FlexFit.tight),
        Footer(page: index, total: total),
      ],
    );
  }
  pw.Widget buildNstTable() {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey),
      headerStyle:  pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerAlignment: pw.Alignment.center,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      cellStyle: const pw.TextStyle(fontSize: 6),
      /*columnWidths: {
        0: const pw.FixedColumnWidth(60), // Parameter
        1: const pw.FixedColumnWidth(100), // Normal NST
        2: const pw.FixedColumnWidth(100), // Atypical NST
        3: const pw.FixedColumnWidth(100), // Abnormal Tracing
      },*/
      headers: const [
        'Parameter',
        'Normal NST\n(Previously "Reactive")',
        'Atypical NST\n(Previously "Non-reactive")',
        'Abnormal Tracing\n(Previously "Non-reassuring")',
      ],
      data: [
        [
          'Baseline',
          '110 - 160 bpm',
          '100-110 bpm\n> 160 bpm (Tachycardia) for > 30 min.\nRising baseline',
          'Bradycardia < 100 bpm\nTachycardia > 160 bpm for > 30 min.\nErratic baseline',
        ],
        [
          'Variability',
          '6-25 bpm (moderate)\n≤ 5 (absent or minimal) for < 40 min.',
          '≤ 5 (absent or minimal) for 40-80 min.',
          '≤ 5 bpm for ≥ 80 min.\n≥ 25 bpm for ≥ 10 min.\nSinusoidal',
        ],
        [
          'Accelerations\nTerm Fetus',
          '≥ 2 accelerations with acme of ≥ 15 bpm, lasting 15 sec. in < 40 min. of testing',
          '≥ 2 accelerations with acme of ≥ 15 bpm, lasting 15 sec. in 40 - 80 min.',
          '≥ 2 accelerations with acme of ≥ 15 bpm, lasting 15 sec. in > 80 min.',
        ],
        [
          'Accelerations\nPreterm Fetus (< 32 weeks)',
          '≥ 2 accelerations of ≥ 10 bpm, lasting 10 sec. in < 40 min. of testing',
          '≤ 2 accelerations of ≥ 10 bpm, lasting 10 sec. in 40-80 min.',
          '≤ 2 accelerations of ≥ 10 bpm, lasting 10 sec. in > 80 min.',
        ],
        [
          'Decelerations',
          'None or occasional variable < 30 sec.',
          'Variable decelerations 30-60 sec. duration',
          'Variable deceleration(s) > 60 sec. duration\nLate deceleration(s)',
        ],
        [
          'ACTION',
          'FURTHER ASSESSMENT OPTIONAL\nbased on total clinical picture',
          'FURTHER ASSESSMENT REQUIRED',
          'URGENT ACTION REQUIRED\nAn overall assessment of the situation and further investigation with U/S or BPP is required. Some situations will require delivery.',
        ],
      ],
    );
  }
}

/// A class representing the header of a PDF page.
class Header extends pw.StatelessWidget {
  /// [data] contains the test data.
  final CtgTest data;
  Header({required this.data});

  late int timeScaleFactor;
  late int scale;

  @override
  pw.Widget build(dynamic context) {
    scale = PrefService.getInt('scale') ?? 1;
    timeScaleFactor = scale == 3 ? 2 : 6;
    return pw.Container(
      //margin: const pw.EdgeInsets.only(top: 2 * PdfPageFormat.mm),
        padding: const pw.EdgeInsets.symmetric(horizontal: 3 * PdfPageFormat.mm,vertical: 3 * PdfPageFormat.mm),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(width: 1.0, color: PdfColors.grey)),
        ),
        child: pw.Row(
            children: [
              pw.Container(
                width: PdfPageFormat.cm * 3,
                margin: const pw.EdgeInsets.only(right: 3 * PdfPageFormat.mm,left: PdfPageFormat.mm *2),
                child: pw.FittedBox(
                    child: pw.Flexible(
                        child: pw.SvgImage(
                          svg: SvgStrings.fetosense_icon,
                          fit: pw.BoxFit.contain,
                        ))),//.asset("assets/images/ic_fetosense.png")
              ),

              pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    HeaderData(title: "Hospital Name", content: data.organizationName??""),
                    HeaderData(
                        title: "Doctor Name",
                        content:"${data.doctorName}"),

                    HeaderData(title: "Patient ID", content: data.patientId??""),
                    HeaderData(title: ". ", content: " "),
                  ]),
              pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    HeaderData(title: "NAME", content: data.motherName??""),
                    HeaderData(
                        title: "AGE",
                        content:"${data.age} Years"),
                    HeaderData(
                        title: "GEST AGE",
                        content:"${data.gAge} Weeks"),
                    HeaderData(title: "DURATION", content: "${data.lengthOfTest~/60} Minutes" ??""),
                  ]),
              pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    HeaderData(title: "DATE", content: data.createdOn.format()),
                    HeaderData(title: "TIME", content:data.createdOn.format('hh:mm a')),
                    HeaderData(title: "X-Axis", content: "${timeScaleFactor * 10} SEC/DIV"),
                    HeaderData(title: "Y-Axis", content: "20 BPM/DIV"),
                  ])
            ]
        )
    );
  }
}

/// A class representing the footer of a PDF page.
class Footer extends pw.StatelessWidget {
  /// [page] is the current page number.
  /// [total] is the total number of pages.
  int page;
  int total;
  Footer({required this.page, this.total = 18});
  @override
  pw.Widget build(dynamic context) {
    return pw.Container(
        padding:
        const pw.EdgeInsets.symmetric(horizontal: 8 * PdfPageFormat.mm),
        decoration: const pw.BoxDecoration(
          border:
          pw.Border(top: pw.BorderSide(width: 1.0, color: PdfColors.grey)),
        ),
        height: 2 * PdfPageFormat.cm,
        child:
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(
            width: 24 * PdfPageFormat.cm,
            padding:
            const pw.EdgeInsets.symmetric(vertical: PdfPageFormat.mm * 4),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text("Disclaimer : NST auto interpretation does not provide medical advice it is intended for informational purposes only. It is not a substitute for professional medical advice, diagnosis or treatment.",
                style: pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                    letterSpacing: 1.0),
                textAlign: pw.TextAlign.left
            ),
          ),
          pw.Flexible(
              child: pw.Container(
                  child: pw.Center(
                      child: pw.Text("$page of $total",
                          style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.normal),
                          textAlign: pw.TextAlign.center)))),

        ]));
  }

  /// A helper method to create a bullet view with the given text and color.
  pw.Widget bulletView(String text, {String? color}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1 * PdfPageFormat.mm),
        child: pw.Row(
          children: [
            /*pw.SvgImage(
              svg:
                  SvgStrings.icDot.replaceAll("#dot_color", color ?? "#030104"),
              fit: pw.BoxFit.contain,
              height: 2.5 * PdfPageFormat.mm,
            ),*/
            pw.SizedBox(width: 2 * PdfPageFormat.mm),
            pw.Text(text,
                style: pw.TextStyle(
                    color: const PdfColor.fromInt(0xff0059A5),
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 8,
                    height: 6 * PdfPageFormat.mm,
                    letterSpacing: 1.1)),
          ],
        ));
  }
}

/// A class representing a header data item.
class HeaderData extends pw.StatelessWidget {
  final String title;
  final String content;

  /// [title] is the title of the header data.
  /// [content] is the content of the header data.
  HeaderData({required this.title, required this.content});

  @override
  pw.Widget build(dynamic context) {
    return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: PdfPageFormat.mm ),
        child:pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 3 * PdfPageFormat.cm,
                child: pw.Text(title,
                    style: pw.TextStyle(
                        color: PdfColors.teal,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.normal,
                        letterSpacing: 1.0),
                    textAlign: pw.TextAlign.left
                ),
              ),

              pw.Container(
                  width: 5 * PdfPageFormat.cm,
                  child:pw.Text(content,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.normal),
                      textAlign: pw.TextAlign.left
                  ))
            ]));
  }
}

List<String> splitTextIntoLines(String text, int maxLines, double maxWidthPerLine, double charWidth) {
  List<String> words = text.split(' '); // Split text into words
  List<String> lines = [];
  String currentLine = "";
  double currentWidth = 0;

  for (String word in words) {
    double wordWidth = word.length * charWidth; // Approximate width of the word

    // Check if adding the word exceeds the max width of the line
    if ((currentWidth + wordWidth) > maxWidthPerLine) {
      // Save the current line and start a new one
      lines.add(currentLine.trim());
      currentLine = word;
      currentWidth = wordWidth;

      // Stop if we have reached the max number of lines
      if (lines.length >= maxLines) {
        break;
      }
    } else {
      // Add word to the current line
      currentLine += (currentLine.isEmpty ? "" : " ") + word;
      currentWidth += wordWidth;
    }
  }

  // Add the last line if it’s not empty
  if (currentLine.isNotEmpty && lines.length < maxLines) {
    lines.add(currentLine.trim());
  }
  for(int i= lines.length-1;i<maxLines;i++){
    lines.add("");
  }

  return lines;
}
