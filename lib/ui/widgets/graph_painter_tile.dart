import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preferences/preference_service.dart';

import '../../constants/my_color_scheme.dart';
import '../../models/marker_indices.dart';
import '../../models/test_model.dart';
import '../../utils/intrepretations2.dart';

class GraphPainterTile extends CustomPainter {

  late double paddingTop;

  late double paddingBottom;

  late double paddingRight;

  late int timeScaleFactor;

  // late double xTocoOrigin;

  // late double yTocoOrigin;

  late double xOrigin;

  late double yOrigin;

  late double yAxisLength;

  late double xAxisLength;

  late double xDivLength;

  late int xDiv;

  late double yDivLength;

  // late double yTocoEnd;

  // late double yTocoDiv;

  late int pointsPerDiv;

  late int pointsPerPage;

  late double mIncrement;

  late double yDiv;

  late Paint graphGridMainLines;

  late Paint graphGridSubLines;

  late Paint graphGridLines;

  late Paint graphOutlines;

  late Paint graphSafeZone;
  late Paint graphUnSafeZone;
  late Paint graphNoiseZone;

  int gridPerMin = 3;
  int mOffset = 0;

  bool mTouchMode = false;

  late Paint graphBpmLine;
  late Paint graphBpmLine2;
  late Paint graphBpmLine3;
  late Paint graphBpmLine4;

  late Paint graphBaseLine;
  int scaleOrigin = 40;

  late double mTouchStart = 0;

  late int mTouchInitialStartIndex = 0;
  Interpretations2? interpretations;

  bool auto = true;

  bool highlight = true;

  int fhr2Offset = 0;

  GraphPainterTile(this.test, this.mOffset, this.gridPerMin, {this.interpretations});

  late double screenHeight;
  late double screenWidth;
  late double pixelsPerOneCM;
  late double pixelsPerOneMM;

  late double leftOffsetStart;
  late double topOffsetEnd;
  late double drawingWidth;
  late double drawingHeight;
  CtgTest test;

  @override
  void paint(Canvas canvas, Size size) {
    screenHeight = size.height;
    screenWidth = size.width;

    pixelsPerOneCM = screenHeight / 10;
    pixelsPerOneMM = pixelsPerOneCM / 10;

    leftOffsetStart = size.width * 0.07;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.93;
    drawingHeight = topOffsetEnd;

    graphGridMainLines =  Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = pixelsPerOneMM * 0.25;
    graphGridLines =  Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = pixelsPerOneMM * 0.20;
    graphGridSubLines =  Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = pixelsPerOneMM * 0.10;
    graphOutlines =  Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = pixelsPerOneMM * .40;
    graphSafeZone =  Paint()
      ..color = const Color.fromARGB(34, 123, 250, 66)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphUnSafeZone =  Paint()
      ..color = const Color.fromARGB(90, 250, 30, 0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphNoiseZone =  Paint()
      ..color = const Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine =  Paint()
      ..color = AppColors.us1 ////const Color.fromRGBO(38, 164, 36, 1.0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine2 =  Paint()
      ..color = AppColors.us2 //const Color.fromRGBO(12, 227, 16, 1.0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine3 =  Paint()
      ..color = const Color.fromRGBO(197, 11, 95, 1.0)
      ..strokeWidth = pixelsPerOneMM * .20;
    graphBpmLine4 =  Paint()
      ..color = AppColors.uc //const Color.fromRGBO(150, 163, 243, 1.0)
      ..strokeWidth = pixelsPerOneMM * .50;
    graphBaseLine =  Paint()
      ..color = const Color.fromRGBO(180, 187, 180, 1.0)
      ..strokeWidth = pixelsPerOneMM * .20;

    init(size);

    drawGraph(canvas);
  }

  @override
  bool shouldRepaint(GraphPainterTile oldDelegate) {
    if (oldDelegate.mOffset != mOffset) {
      return true;
    } else
      return false;
  }

  void init(Size size) {

    var paddingLeft = 0;//pixelsPerOneMM;

    paddingTop = 0;//pixelsPerOneMM;
    paddingBottom = 0;//pixelsPerOneMM;
    paddingRight = 0;//pixelsPerOneMM;

    timeScaleFactor = gridPerMin == 1 ? 6 : 2;

    // xTocoOrigin = paddingLeft;
    // yTocoOrigin = screenHeight - (paddingBottom);

    xOrigin = 0;// paddingLeft * 1.5;
    yOrigin = screenHeight - (paddingBottom);

    yAxisLength = yOrigin - paddingTop;
    xAxisLength = screenWidth - paddingLeft - paddingRight;

    xDivLength = pixelsPerOneCM;
    xDiv = ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM).truncate();

    //yOrigin =  xDivLength * 6; // x= 2y

    yDivLength = xDivLength / 2;
    yDiv = (yOrigin - paddingTop) / pixelsPerOneCM * 2;

    //yOrigin =  yDivLength * 12;

    // yTocoEnd = yOrigin + xDivLength;
    // yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM * 2;

    pointsPerDiv = (timeScaleFactor * 10);
    pointsPerPage = (pointsPerDiv * xDiv + (pointsPerDiv / 2)).truncate();

    mIncrement = (pixelsPerOneMM / timeScaleFactor);
    //nstTouchMove(offset);
    mOffset = trap(mOffset);
  }

  drawGraph(Canvas canvas) {
    auto = PrefService.getBool('liveInterpretations') ?? true;
    highlight = PrefService.getBool('liveHighlight') ?? false;
    fhr2Offset = PrefService.getInt('fhr2Offset') ?? 0;

    if (test.lengthOfTest > 3600) {
      auto = false;
      highlight = false;
      gridPerMin = 1;
    }

    drawXAxis(canvas);
    drawYAxis(canvas);

    // drawTocoXAxis(canvas);
    // drawTocoYAxis(canvas);

    //drawBPMLine(canvas, /*interpretations.baselineBpmList*/, graphBaseLine);
    drawBPMLine(canvas, test.bpmEntries, graphBpmLine);
    //drawBPMLine(canvas, [150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142], graphBpmLine);
    drawBPMLine(canvas, test.bpmEntries2, graphBpmLine2,bpmOffset: fhr2Offset);
    drawBPMLine(canvas, test.mhrEntries, graphBpmLine3);
    drawMovements(canvas);
    drawAutoMovements(canvas);
    // drawTocoLine(canvas,test.tocoEntries,graphBpmLine);
    // drawTocoLine(canvas,test.spo2Entries,graphBpmLine4);


    // canvas.drawLine(
    //      Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneCM ),
    //      Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneMM * 3),
    //     graphOutlines);

  }

  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder =  ui.ParagraphBuilder(
         ui.ParagraphStyle(fontSize: 12.sp, textAlign: TextAlign.right))
      ..pushStyle( ui.TextStyle(color: Colors.white54))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout( ui.ParagraphConstraints(width: 24.w));
    return paragraph;
  }

  // bool printMin = true;
  void drawXAxis(Canvas canvas) {
    //SafeZone
    int interval = 10;
    int ymin = 50;
    int safeZoneMax = 160;
    Rect safeZoneRect = Rect.fromLTRB(
        xOrigin,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin + xAxisLength,
        yOrigin - yDivLength * 8); //50
    canvas.drawRect(safeZoneRect, graphSafeZone);
    //safe zone end

    canvas.drawLine( Offset(xOrigin + ((xDivLength / 2)), paddingTop),
         Offset(xOrigin + ((xDivLength / 2)), yOrigin), graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine( Offset(xOrigin + (xDivLength * i), paddingTop),
           Offset(xOrigin + (xDivLength * i), yOrigin), graphGridLines);

      canvas.drawLine(
           Offset(
              xOrigin + (xDivLength * i) + ((xDivLength / 2)), paddingTop),
           Offset(xOrigin + (xDivLength * i) + ((xDivLength / 2)), yOrigin),
          graphGridSubLines);
      int offset = (mOffset / pointsPerDiv).truncate();
      if ((i + offset) % gridPerMin == 0) {
        // if (gridPerMin == 1 && printMin) {
        //   canvas.drawParagraph(
        //       getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
        //        Offset(xOrigin + (xDivLength * i) - pixelsPerOneMM * 5,
        //           pixelsPerOneCM * 0.2));
        // } else if (gridPerMin == 3) {
        /*canvas.drawParagraph(
            getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
             Offset(xOrigin + (xDivLength * i) - pixelsPerOneMM * 5,
                pixelsPerOneCM * 0.2));*/
        // }
        // printMin = !printMin;
        /*canvas.drawLine(
             Offset(xOrigin + (xDivLength * i), paddingTop),
             Offset(xOrigin + (xDivLength * i), yOrigin),
            graphGridMainLines);*/
      }
    }
  }

  void drawYAxis(Canvas canvas) {
    //y-axis outlines
   /* canvas.drawLine( Offset(xOrigin, yOrigin),
         Offset(screenWidth - paddingRight, yOrigin), graphOutlines);
    canvas.drawLine( Offset(xOrigin, paddingTop),
         Offset(screenWidth - paddingRight, paddingTop), graphOutlines);*/

    int interval = 10;
    int ymin = 50;

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
             Offset(xOrigin, yOrigin - (yDivLength * i)),
             Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        /*canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).truncate().toString()),
             Offset(pixelsPerOneMM * 2,
                yOrigin - (yDivLength * i + (pixelsPerOneMM * 3))));*/

        canvas.drawLine(
             Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
             Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
             Offset(xOrigin, yOrigin - (yDivLength * i)),
             Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);

        canvas.drawLine(
             Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
             Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }


  void drawBPMLine(Canvas canvas, List<int> list, Paint lineStyle, {int bpmOffset = 0}) {
    if (list == null || list.length <= 0) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    for (; i < list.length - 1 && i < (mOffset + pointsPerPage); i++) {
      startData = stopData;
      stopData = list[i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenX(i);
      stopY = getYValueFromBPM(list[i]+bpmOffset); // getScreenY(stopData);

      if (i < 1) continue;
      if (startData == 0 ||
          stopData == 0 ||
          startData > 210 ||
          stopData > 210 ||
          (startData - stopData).abs() > 30) {
        continue;
      }

      // a. If the value is 0, it is not drawn
      // b. If the results of the two values before and after are different by more than 30, they are not connected.

      canvas.drawLine(
           Offset(startX, startY),  Offset(stopX, stopY), lineStyle);
    }
  }

  void drawMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int> movementList = test.movementEntries;
    if (movementList == null || movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
             Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2),
             Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 4)),
            graphOutlines);
        canvas.drawLine(
             Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2),
             Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM,
                yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 2)),
            graphOutlines);
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  void drawAutoMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int> movementList = test.autoFetalMovement;
    if (movementList == null || movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
             Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM),
             Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneMM * 3),
            graphOutlines);
        canvas.drawLine(
             Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM),
             Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM +
                    pixelsPerOneMM,
                yOrigin - pixelsPerOneMM * 7),
            graphOutlines);
        canvas.drawLine(
             Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM * 7),
             Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM +
                    pixelsPerOneMM,
                yOrigin - pixelsPerOneMM * 5),
            graphOutlines);

      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }


  double getScreenX(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }

  double getScreenXToco(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }

  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yOrigin - (adjustedBPM * pixelsPerOneMM);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }


  int trap(int pos) {
    if (pos < 0) return 0;
    int max = test.bpmEntries.length + pointsPerDiv - pointsPerPage;
    if (max < 0) max = 0;

    if (pos > max) pos = max;

    if (pos != 0) pos = pos - (pos % pointsPerDiv);

    print("$pos   $pointsPerPage   $pointsPerDiv");

    return pos;
  }
}
