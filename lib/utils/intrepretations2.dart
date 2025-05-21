import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:l8fe/models/marker_indices.dart';
import 'package:l8fe/models/test_model.dart';

// --- Constants ---
const int _SIXTY_THOUSAND_MS = 60000;
const int _FACTOR = 4; // Samples per epoch
const int _NO_OF_SAMPLES_PER_MINUTE = 15; // Epochs per minute (60 sec / 4 sec/epoch)


class Interpretations2 {
  static const int SIXTY_THOUSAND_MS = 60000;
  static const int NO_OF_SAMPLES_PER_MINUTE = 15; // 16 datapoints (3.75 ms for 1 sample) per minute
  static final List highFHREpisodePercentiles = [
    //criteria for confirming high FHR episodes
    // gestAge, 3rd percentile, 10th percentile of healthy fetus
    [26, 11.75, 12.75],
    [27, 11.75, 12.75],
    [28, 11.5, 12.75],
    [29, 11.5, 13],
    [30, 11.5, 13],
    [31, 11.75, 13],
    [32, 11.75, 13.25],
    [33, 12, 13.25],
    [34, 12, 13.5],
    [35, 12.25, 14],
    [36, 12.5, 14.25],
    [37, 12.5, 14.5],
    [38, 12.75, 14.5],
    [39, 12.75, 14.75],
    [40, 12.5, 14.75],
    [41, 12.75, 14.75]
  ];

  static const int FACTOR = 4;
  late List<int> bpmList;
  late List<int> bpmListSmooth;
  late int gestAge;
  late List<MarkerIndices> accelerationsList;
  late List<MarkerIndices> decelerationsList;
  late List<MarkerIndices> noiseList;
  late List<int> baselineBpmList;
  late List<int> baselineEpochBpm;
  late List<int> millisecondsEpochBpm;
  //List<int>? millisecondsEpochBpmSmooth;
  late List<int> beatsInMilliseconds;
  late List<int> beatsInMillisecondsSmooth;
  late List<int> millisecondsEpoch;
  late List<int> millisecondsEpochSmooth;
  late List<int> baselineEpoch;
  late List<int> cleanMillisecondsEpoch;
  late List<int> cleanMillisecondsEpochBpm;
  late List<int> cleanBaselineEpoch;
  late List<int> cleanBaselineEpochBpm;
  late int nAccelerations;
  late int nDecelerations;


  int? correctionCount;
  late List<int> bpmCorrectedIndices;
  int basalHeartRate = 0;
  int longTermVariation = 0;

  double shortTermVariationBpm = 0;
  int shortTermVariationMilli = 0;

  bool isSkipped = false;

  int fisherScore= 0;

  Interpretations2() {
    gestAge = 26;
    basalHeartRate = 0;
    nAccelerations = 0;
    nDecelerations = 0;
    //this.signalLossPercent = 0.0;
    //this.lengthOfHighFHREpisodes = 0;
    //this.lengthOfLowFHREpisodes = 0;
    //this.highFHRVariationBpm = 0;
    //this.lowFHRVariationBpm = 0;
    shortTermVariationMilli = 0;
    shortTermVariationBpm = 0;
    longTermVariation = 0;
    //this.isBradycardia = false;
    //this.isTachycardia = false;
    noiseList = [];
    isSkipped = true;
  }

  Interpretations2.fromMap(CtgTest test){
    debugPrint(" autoInterpretations ${test.autoInterpretations?["decelerationsList"]??[]}");
    accelerationsList = (test.autoInterpretations?["accelerationsList"]??[]).map<MarkerIndices>((e) => MarkerIndices.fromData(e["from"], e["to"])).toList();
    decelerationsList = (test.autoInterpretations?["decelerationsList"]??[] ).map<MarkerIndices>((e) => MarkerIndices.fromData(e["from"], e["to"])).toList();
    noiseList = (test.autoInterpretations?["noiseList"]??[] ).map<MarkerIndices>((e) => MarkerIndices.fromData(e["from"], e["to"])).toList();
    fisherScore = test.fisherScore??0;
    basalHeartRate = int.tryParse(test.autoInterpretations?["basalHeartRate"]??"")??0;
    nAccelerations = int.tryParse(test.autoInterpretations?["nAccelerations"]??"")??0;
    nDecelerations = int.tryParse(test.autoInterpretations?["nDecelerations"]??"")??0;
    longTermVariation = int.tryParse(test.autoInterpretations?["longTermVariation"]??"")??0;
    shortTermVariationBpm = double.tryParse(test.autoInterpretations?["shortTermVariationBpm"]??"")??0;
    shortTermVariationMilli = int.tryParse(test.autoInterpretations?["shortTermVariationMilli"]??"")??0;
  }

  Interpretations2.withData(List<int> bpm, int gAge, {CtgTest? test}) {
    if(bpm.isEmpty){
      return;
    }
    debugPrint("Interpretations2 :: withData ${bpm.length} && age $gAge");
    gestAge = gAge > 41 ? 41 : gAge;
    bpmList = List.from(bpm); //[]..addAll(bpm);//bpm.clone();
    nAccelerations = 0;
    nDecelerations = 0;
    noiseList = [];

    bpmCorrectedIndices = _getNoiseAreas(List.from(bpm));
    _cleanBpmList();
    beatsInMilliseconds = _convertBpmToMilli(bpmList);
    millisecondsEpoch = _convertMilliToEpoch(beatsInMilliseconds);
    millisecondsEpochBpm = _calculateEpochBpm();

    bpmListSmooth = List.from(bpmList); //[]..addAll(bpmList);//(List<int>) bpmList.clone();
    _smoothBpm();
    beatsInMillisecondsSmooth = _convertBpmToMilli(bpmListSmooth);
    millisecondsEpochSmooth =
        _convertMilliToEpoch(beatsInMillisecondsSmooth);

    baselineEpoch = _calculateBaseLine(millisecondsEpochSmooth);

    baselineEpochBpm = _convertBaselineArrayToBpmEpoch(baselineEpoch);
    baselineBpmList = _convertBaselineArrayToBpmList(baselineEpoch);

    //re-correct bpm list noise to baseline
    if (correctionCount! > 0) {
      _removeNoiseMinutes();
      beatsInMilliseconds = _convertBpmToMilli(bpmList);
      millisecondsEpoch = _convertMilliToEpoch(beatsInMilliseconds);
      millisecondsEpochBpm = _calculateEpochBpm();
    }

    cleanMillisecondsEpoch = List.from(
        millisecondsEpoch); //[]..addAll(millisecondsEpoch);//millisecondsEpoch.clone();
    cleanMillisecondsEpochBpm = List.from(
        millisecondsEpochBpm); //[]..addAll(millisecondsEpochBpm);//millisecondsEpochBpm.clone();
    cleanBaselineEpoch = List.from(
        baselineEpoch); //[]..addAll(baselineEpoch);//baselineEpoch.clone();
    cleanBaselineEpochBpm = List.from(
        baselineEpochBpm); //[]..addAll(baselineEpochBpm);//baselineEpochBpm.clone();

    nAccelerations = _calculateAccelerations();
    nDecelerations = _calculateDecelerations();

    if (nDecelerations > 0) {
      // todo: remove them
      _removeDecelerationMinutes();
    }

    _calculateEpisodesOfLowAndHighVariation();
    basalHeartRate = _calculateBasalHeartRate(cleanBaselineEpochBpm);
    _calculateShortTermVariability();

    //fisherScore code
    List<int> tempBPMEntries = [];
    int minMaxDiff =0;
    if(accelerationsList.isNotEmpty) {
      if (bpmList.length >= (accelerationsList[0].getTo())! + 120) {
        try {
          for (int j = 0; j < bpmList.length; j++) {
            for (int? i = accelerationsList[j].getTo(); i! < (accelerationsList[j].getTo()! + 120); i++) {
              tempBPMEntries.add(bpmList[i]);
            }
          }
        }catch (ex){
          debugPrint("fisherScore error : ${ex.toString()}");
        }
    }else {
      for (int i = accelerationsList[0].getTo()!; i < bpmList.length; i++) {
        tempBPMEntries.add(bpmList[i]);
      }
    }

      // sorting List using collections.sort()
      //Collections.sort(tempBPMEntries);

      // getting the min value
      int min = tempBPMEntries[0];

      // getting max value
      int max = tempBPMEntries[tempBPMEntries.length - 1];

      //Log.e("LISTMINMAX", "List sorting - min : " + min + ", max : " + max);

       minMaxDiff = max - min;
    }

    if(basalHeartRate < 100 || basalHeartRate > 180){
      fisherScore = fisherScore + 0;
    }else if((basalHeartRate >= 100 && basalHeartRate <= 110) || (basalHeartRate > 160 && basalHeartRate <= 180)){
      fisherScore = fisherScore + 1;
    }else if((basalHeartRate > 110 && basalHeartRate <= 160)){
      fisherScore = fisherScore + 2;
    }


    if(minMaxDiff < 5){
      fisherScore = fisherScore + 0;
    }else if((minMaxDiff >= 5 && minMaxDiff <= 10) || minMaxDiff > 30){
      fisherScore = fisherScore + 1;
    }else if(minMaxDiff > 10 && minMaxDiff <= 30){
      fisherScore = fisherScore + 2;
    }


    if(nAccelerations > 0 && nAccelerations <= 4){
      fisherScore = fisherScore + 1;
    }else if(nAccelerations > 4){
      fisherScore = fisherScore + 2;
    }else if(nAccelerations <= 0){
      fisherScore = fisherScore + 0;
    }

    if(nDecelerations == 0){
      fisherScore = fisherScore + 2;
    }else if(nDecelerations == 1){
      fisherScore = fisherScore + 1;
    }else if(nDecelerations >= 2){
      fisherScore = fisherScore + 0;
    }

    int zero_crossings = 0;

    for(int i =0; i < baselineBpmList.length; i++){
      if(baselineBpmList[i] == bpmList[i]){
        zero_crossings = zero_crossings + 1;
      }
    }

    //Log.e("ZeroCrossings: " , String.valueOf(zero_crossings));
    if(zero_crossings < 2){
      fisherScore = fisherScore + 0;
    }else if(zero_crossings >= 2 && zero_crossings <= 6){
      fisherScore = fisherScore + 1;
    }else if(zero_crossings > 6){
      fisherScore = fisherScore + 2;
    }

    test?.fisherScore = fisherScore;
    test?.fisherScoreArray = {
      "score":fisherScore,
      "Acceleration":getnAccelerationsStr(),
      "Deceleration":getnDecelerationsStr(),
      "Bandwidth":minMaxDiff,
      "Zero-Crossing":zero_crossings,
      "BaseLine Frequency":getBasalHeartRateStr(),
    };

    test?.autoInterpretations = {
      "accelerationsList" : getAccelerationsList(),
      "decelerationsList" : getDecelerationsList(),
      "noiseList" : getNoiseAreaList(),
      "basalHeartRate" : getBasalHeartRateStr(),
      "nAccelerations" : getnAccelerationsStr(),
      "nDecelerations" : getnDecelerationsStr(),
      "longTermVariation" : getLongTermVariationStr(),
      "shortTermVariationBpm" : getShortTermVariationBpmStr(),
      "shortTermVariationMilli" : getShortTermVariationMilliStr(),
      "fisherScore":test.fisherScoreArray
    };
    test?.baseLineEntries  = getBaselineBpmList()??[];
    test?.averageFHR = getBasalHeartRate();

    debugPrint("Accelerations : $nAccelerations Decelerations : $nDecelerations Basal HR : $basalHeartRate STV : $shortTermVariationBpm LTV : $longTermVariation");
  }

  /*Map<String,dynamic> getFisherScore(){
    return {
      "score":fisherScore,
      "Acceleration":getnAccelerationsStr(),
      "Deceleration":getnDecelerationsStr(),
      "Bandwidth":minMaxDiff,
      "Zero-Crossing":zero_crossings,
      "BaseLine-Frequency":getBasalHeartRateStr(),
    };
  }*/

  List<int>? getBaselineBpmList() {
    return baselineBpmList;
  }

  List<Map<String, int>>? getAccelerationsList() {
    return accelerationsList.map((MarkerIndices e) =>e.toMap()).toList();
  }

  List<Map<String, int>>? getDecelerationsList() {
    return decelerationsList.map((MarkerIndices e) =>e.toMap()).toList();
  }

  List<Map<String, int>>? getNoiseAreaList() {
    return noiseList.map((MarkerIndices e) =>e.toMap()).toList();
  }

  int? getnAccelerations() {
    return nAccelerations;
  }

  int? getnDecelerations() {
    return nDecelerations;
  }

  String getnAccelerationsStr() {
    return isSkipped ? "--" : nAccelerations.toString().padLeft(2, '0');
  }

  String getnDecelerationsStr() {
    return isSkipped ? "--" : nDecelerations.toString().padLeft(2, '0');
  }

  int getBasalHeartRate() {
    return basalHeartRate;
  }

  int getLongTermVariation() {
    return longTermVariation;
  }

  double getShortTermVariationBpm() {
    return shortTermVariationBpm;
  }

  int getShortTermVariationMilli() {
    return shortTermVariationMilli;
  }

  String getBasalHeartRateStr() {
    if (isSkipped) {
      return "--";
    } else {
      return basalHeartRate == 0
          ? "--"
          : basalHeartRate
          .toString(); //basalHeartRate == 0?"--": basalHeartRate;
    }
  }

  String getLongTermVariationStr() {
    return longTermVariation == 0
        ? "--"
        : longTermVariation.toString().padLeft(2, '0');
  }

  String getShortTermVariationBpmStr() {
    return shortTermVariationBpm == 0
        ? "--"
        : shortTermVariationBpm.toStringAsFixed(1);
  }

  String getShortTermVariationMilliStr() {
    return shortTermVariationMilli == 0
        ? "--"
        : shortTermVariationMilli.toString();
  }

  void _cleanBpmList() {
    _removeTrailingZeros(bpmList);

    //reduce zeros and jumps
    for (int i = 0; i < bpmList.length; i++) {
      if (bpmList[i] == 0) {
        bpmList[i] = _getNextNonZeroBpm(i, bpmList);
      }
    }
    for (int i = 1; i < bpmList.length; i++) {
      int startData = bpmList[i - 1];
      int stopData = bpmList[i];
      if (startData < 60 ||
          stopData < 60 ||
          startData > 210 ||
          stopData > 210 ||
          (startData - stopData).abs() > 35) {
        bpmList[i] = _getWindowAvreage(bpmList, i, 60);
      }
    }
    /*int window = 4;
        for (int i = window; i < bpmList.length - window - 1; i++) {
            bpmList.set(i, getWindowAvreage(bpmList, i, window));
        }*/
  }

  List<int> _convertBpmToMilli(List<int> list) {
    int size = list.length;
    List<int> milliseconds = List.filled(size, 0, growable: false);
    for (int i = 0; i < size; i++) {
      milliseconds[i] = 0;
      if (list[i] != 0) {
        milliseconds[i] = (SIXTY_THOUSAND_MS / list[i]).truncate();
      } else {
        milliseconds[i] = 0;
      }
    }
    return milliseconds;
    //convertMilliToEpoch();
  }

  void _smoothBpm() {
    //bpmCorrectedIndices = new List<>();
    //correctionCount = 0;
    //reduce zeros and jumps
    for (int i = 1; i < bpmListSmooth.length; i++) {
      if (bpmListSmooth[i] == 0 && bpmListSmooth[i] == -1) {
        correctionCount = correctionCount! + 1;
        bpmListSmooth[i] = _getNextNonZeroBpm(i, bpmListSmooth);
      }
    }

    //Log.i("Correction count", correctionCount + "");
    for (int i = 1; i < bpmListSmooth.length; i++) {
      int startData = bpmListSmooth[i - 1];
      int stopData = bpmListSmooth[i];
      if (startData < 60 ||
          stopData < 60 ||
          startData > 210 ||
          stopData > 210 ||
          (startData - stopData).abs() > 35) {
        //correctionCount++;
        if (stopData - startData > 60) {
          bpmListSmooth[--i] = ((startData + stopData) / 2).truncate();
        } else {
          bpmListSmooth[i] = _getNextValidBpm(i, bpmListSmooth);
        }
        //bpmCorrectedIndices.add(i);
        //Log.i("Correction", i + "");
      }
    }

    //Log.i("Correction count", correctionCount + "");
    int window = FACTOR * 4;
    for (int i = window; i < bpmListSmooth.length - window - 1; i++) {
      bpmListSmooth[i] = _getWindowAvreage(bpmListSmooth, i, window);
    }

    double tiny = 0.33;
    int start = bpmListSmooth.length - 60;
    start = start < 0 ? 0 : start;
    for (int i = start; i < bpmListSmooth.length - 1; i++) {
      bpmListSmooth[i + 1] =
          (tiny * bpmListSmooth[i] + (1.0 - tiny) * bpmListSmooth[i + 1])
              .truncate();
    }
    /*window = (int) FACTOR * 2;
        for (int i = window; i < bpmListSmooth.length - window - 1; i++) {
            bpmListSmooth.set(i, getWindowAvreage(i, window));
        }*/
  }

  List<int> _getNoiseAreas(List<int> list) {
    //delete traling zeros
    _removeTrailingZeros(list);

    List<int> bpmCorrected = [];
    correctionCount = 0;
    //reduce zeros and jumps
    for (int i = 0; i < list.length; i++) {
      if (list[i] == 0) {
        correctionCount = correctionCount! + 1;
        list[i] = _getNextNonZeroBpm(i, list);
        bpmCorrected.add(i);
      }
    }

    //Log.i("Correction count", correctionCount + "");
    for (int i = 1; i < list.length; i++) {
      int startData = list[i - 1];
      int stopData = list[i];
      if (startData < 60 ||
          stopData < 60 ||
          startData > 210 ||
          stopData > 210 ||
          (startData - stopData).abs() > 35) {
        correctionCount = correctionCount! + 1;
        if (stopData - startData > 50 && startData > 60 && stopData > 110) {
          list[--i] = ((startData + stopData) / 2).truncate();
          continue;
        } else {
          list[i] = _getNextValidBpm(i, list);
        }
        if (!bpmCorrected.contains(i)) bpmCorrected.add(i);
        //Log.i("Correction", i + "");
      }
    }
    //Log.i("Correction count", correctionCount + "");

    bpmCorrected.sort();
    return bpmCorrected;
  }

  void _removeTrailingZeros(List<int> list) {
    bool zero = list[list.length - 1] == 0 ||
        list[list.length - 2] == 0 ||
        list[list.length - 3] == 0;
    while (zero) {
      list.removeLast();
      if (list.length > 60) {
        zero = list[list.length - 1] == 0 ||
            list[list.length - 2] == 0 ||
            list[list.length - 3] == 0;
      } else {
        break;
      }
    }
  }

  int _getNextNonZeroBpm(int index, List<int>? list) {
    int i = index;
    int value = 0;
    while ((value == 0 || value == -1) && i < list!.length - 1) {
      value = list[i++];
    }
    index = index == 0 ? 1 : index;

    return (value == 0 || value == -1) ? list![index - 1] : value;
  }

  int _getNextValidBpm(int index, List<int> list) {
    int i = index;
    int value = 0;
    int startData = list[i - 1];
    while (value == 0 && i < list.length) {
      int stopData = list[i++];
      if ((startData - stopData).abs() > 35) {
        value = 0;
      } else {
        value = stopData;
      }
    }
    return value;
  }

  int _getWindowAvreage(List<int> list, int index, int window) {
    int start = index - window;
    int stop = index + window;
    if (stop >= list.length - 1) stop = list.length - 2;
    if (start < 0) start = 0;

    int divisor = 0; //window * 2 + 1;
    int value = 0;
    for (int i = start; i <= stop; i++) {
      if (list[i] != 0 || (list[i] - list[i + 1]).abs() < 35) {
        value += list[i];
        divisor++;
      }
    }
    if (divisor != 0) {
      return (value / divisor).truncate();
    } else {
      return list[index];
    }
  }

  List<int> _convertMilliToEpoch(List<int> millisecondBeats) {
    int size = (millisecondBeats.length / FACTOR).truncate();
    List<int> epoch = List.filled(size, 0, growable: false);
    for (int i = 0; i < size; i++) {
      int milli = 0;
      for (int j = (i * FACTOR), k = 0;
      j < millisecondBeats.length && k < 4;
      j++, k++) {
        milli += millisecondBeats[j];
      }
      milli = (milli / 4).truncate();
      epoch[i] = milli;
    }

    return epoch;
  }

  List<int> _calculateEpochBpm() {
    List<int> millisecondsEpochBpm =
    List.filled(millisecondsEpoch.length, 0, growable: false);
    for (int i = 0; i < millisecondsEpoch.length; i++) {
      if (millisecondsEpoch[i] == 0) {
        millisecondsEpochBpm[i] = 0;
      } else {
        millisecondsEpochBpm[i] =
            (SIXTY_THOUSAND_MS / millisecondsEpoch[i]).truncate();
      }
    }
    return millisecondsEpochBpm;
  }

  List<int> _calculateBaseLine(List<int> millisecondsEpoch) {
    int size = millisecondsEpoch.length;
    List<int> baselineArray = List.filled(size, 0, growable: false);

    int buckets = 1001, modeIndex = 0;
    List<int> freq = List.filled(buckets, 0, growable: false);
    int? modeValue = 0,
        sumOfValues = 0,
        selectedPeak = 0; // 60-220 bpm = 1000-272 ms

    /** calculate frequency distribution of intervals**/
    for (int i = 0; i < buckets; i++) {
      freq[i] = 0;
    }

    for (int j = 0; j < millisecondsEpoch.length; j++) {
      int? epoch = millisecondsEpoch[j];
      //epoch = epoch==-1?0:epoch;
      if (epoch == 0 || epoch >= buckets) {
        freq[0] = freq[0] + 1;
        continue;
      }
      freq[epoch] = freq[epoch] + 1;
    }

    /** calculate peak frequency or mode **/
    for (int i = 1; i < buckets - 1; i++) {
      if (freq[i] > modeValue!) {
        modeValue = freq[i];
        modeIndex = i;
      }
    }

    int peak = 0;
    /** calculate limiting parameter **/
    for (int i = buckets - 1; i >= 5; i--) {
      if (sumOfValues! > (0.125 * (size - freq[0]))) {
        if (freq[i] >= freq[i - 5] &&
            freq[i] >= freq[i - 4] &&
            freq[i] >= freq[i - 3] &&
            freq[i] >= freq[i - 2] &&
            freq[i] >= freq[i - 1]) {
          if (freq[i] > 0.005 * (size - freq[0]) ||
              (modeIndex - i).abs() <= 30) {
            selectedPeak = i;
            peak = i;
            break;
          }
        }
      }
      sumOfValues += freq[i];
    }

    /*if the peak is selected; other- wise, the mode is used*/
    if (selectedPeak == 0) selectedPeak = modeIndex;

    /** apply band filter with the use of limiting value
     *  low-pass filter are then set to 60 milliseconds below and above the selected peak or mode
     * **/
    baselineArray[0] = millisecondsEpoch[0];
    for (int i = 0; i < size - 1; i++) {
      // change i from 1 to 0
      if (millisecondsEpoch[i] == 0) {
        baselineArray[i] =
        millisecondsEpoch[i]; //avgLastMin(baselineFHRDR, i - 1);;
      } else {
        if (millisecondsEpoch[i] >= (selectedPeak! + 100)) {
          baselineArray[i] =
          (selectedPeak + 100); // 60 is given in the literature
        }

        if (millisecondsEpoch[i] <= (selectedPeak - 100)) {
          baselineArray[i] = (selectedPeak - 100);
        } else {
          baselineArray[i] = millisecondsEpoch[i];
        }
      }
      //if (Double.isNaN(_baselineArray[i]))
      //_baselineArray[i] = _baselineArray[i - 1];
    }
    //_baselineArray[0] = _millisecondsEpoch[0];
    for (int i = 1; i < size - 1; i++) {
      if (baselineArray[i] == 0) {
        baselineArray[i] =
        baselineArray[i - 1]; //avgLastMin(baselineFHRDR, i - 1);;
      } else {
        if (baselineArray[i] >= (selectedPeak! - 50) &&
            baselineArray[i] <=
                (selectedPeak + 50)) {
          // 60 is given in the literature
          baselineArray[i] = baselineArray[i];
        } else {
          baselineArray[i] = baselineArray[i -
              1]; //avgLastMin(baselineFHRDR, i - 1); //interpolate over previous values
        }
      }
      //if (Double.isNaN(_baselineArray[i]))
      //_baselineArray[i] = _baselineArray[i - 1];
    }
    baselineArray[size - 1] =
    baselineArray[size - 2]; //avgLastMin(baselineFHRDR, size - 2);

    double aTiny = 0.75;
    for (int i = 0; i < baselineArray.length - 1; i++) {
      baselineArray[i + 1] =
          (aTiny * baselineArray[i + 1] + (1.0 - aTiny) * selectedPeak!)
              .toInt();
    }

    int window = 2;
    for (int i = window; i < baselineArray.length - window - 1; i++) {
      baselineArray[i] =
          _getBaselineWindowSmoothAverage(baselineArray, i, window);
    }

    int avgHR;

    avgHR = _calculateAvgHeartRate(baselineArray);

    // smoothing last min
    double tiny = 0.3;
    int start = baselineArray.length - window * 2;
    for (int i = 0; i < baselineArray.length - 1; i++) {
      baselineArray[i + 1] =
          (tiny * avgHR + (1.0 - tiny) * baselineArray[i + 1]).truncate();
    }

    start = 0;
    for (int i = start; i < (window * 2) - 1; i++) {
      baselineArray[i] =
          (tiny * avgHR + (1.0 - tiny) * baselineArray[i + 1]).truncate();
    }

    //int index = 1 * NO_OF_SAMPLES_PER_MINUTE;
    //window = index;

    avgHR = _calculateLowVariationAvg(baselineArray, avgHR);

    /*avgHR = calculateLowVariationAvg(_baselineArray,avgHR);
        Log.i("avgHR",avgHR+"");
        if(avgHR <=300 || avgHR > 700)
            avgHR = calculateBasalHeartRate(_baselineArray);
        Log.i("avgHR",avgHR+"");*/

    tiny = 0.25;
    for (int i = start; i < baselineArray.length - 1; i++) {
      baselineArray[i] =
          (tiny * avgHR + (1.0 - tiny) * baselineArray[i + 1]).truncate();
    }

    return baselineArray;
  }

  int _getBaselineWindowSmoothAverage(List<int> list, int index, int window) {
    int start = index - window;
    int stop = index + window;

    int divisor = window * 2 + 1;
    int value = 0;
    for (int i = start; i <= stop; i++) {
      if (list[i] == 0 || (list[i] - list[i + 1]).abs() > 30) {
        divisor--;
      } else {
        value += list[i];
      }
    }
    if (divisor != 0) {
      return (value / divisor).truncate();
    } else {
      return list[index];
    }
  }

  int _getBaselineWindowAverage(List<int> list, int index, int window) {
    int start = index - window;
    int stop = index + window;
    if (stop > list.length) stop = list.length;

    int divisor = 0;
    int value = 0;
    for (int i = start; i < stop - 1; i++) {
      if (list[i] != 0 || (list[i] - list[i + 1]).abs() < 40) {
        divisor++;
        value += list[i];
      }
    }
    if (divisor != 0) {
      return (value / divisor).truncate();
    } else {
      return list[index];
    }
  }

  /*convert epoch to bpm*/
  List<int> _convertBaselineArrayToBpmList(List<int?> baselineArray) {
    List<int> baselineBpmList = [];
    for (int i = 0; i < baselineArray.length - 1; i++) {
      for (int j = (i * FACTOR); j < ((i + 1) * FACTOR); j++) {
        if (baselineArray[i] == 0) {
          baselineBpmList.add(0);
        } else {
          baselineBpmList
              .add((SIXTY_THOUSAND_MS / baselineArray[i]!).truncate());
        }
      }
    }

    //smoothing the baseline for a cleaner look
    /*int window = 3;
        for (int i = window; i < _baselineBpmList.length - window - 1; i++) {
            _baselineBpmList.set(i, getWindowAvreage(_baselineBpmList, i, window));
        }*/

    return baselineBpmList;
  }

  /*convert epoch to bpm*/
  List<int> _convertBaselineArrayToBpmEpoch(List<int> baselineArray) {
    List<int> baselineBpmEpoch =
    List.filled(baselineArray.length, 0, growable: false);
    for (int i = 0; i < baselineArray.length; i++) {
      if (baselineArray[i] == 0) {
        baselineBpmEpoch[i] = 0;
      } else {
        baselineBpmEpoch[i] =
        ((SIXTY_THOUSAND_MS / baselineArray[i]).truncate());
      }
    }

    return baselineBpmEpoch;
  }

  void _removeNoiseMinutes() {
    List<MarkerIndices> groups = [];
    // create groups form corrected Indices

    int start = 1;
    while (start < bpmCorrectedIndices.length) {
      int margin = 7;
      MarkerIndices index = MarkerIndices();
      index.setFrom(bpmCorrectedIndices[start - 1]);
      index.setTo(start); // change from 0 to start varibale
      for (int i = start; i < bpmCorrectedIndices.length; i++) {
        if ((bpmCorrectedIndices[i] - bpmCorrectedIndices[i - 1]).abs() >=
            margin) {
          index.setTo(bpmCorrectedIndices[i - 1]);
          start = i + 1;
          break;
        } else {
          start++;
        }
      }

      // if (index.getTo() == 0)
      //   index.setTo(bpmCorrectedIndices[bpmCorrectedIndices.length - 1]); // change commented as CTG App

      groups.add(index);

      if (start == bpmCorrectedIndices.length - 1) break;
    }

    if (groups.isEmpty) {
      return;
    } else {
      for (int i = 0, j = 0; i < groups.length; i++) {
        int from = groups[i].getFrom()!;
        int to = groups[i].getTo()!;
        if (to < from || (to - from) < 30) {
          groups.removeAt(i);
          i--;
        }
      }
    }

    int minutes = (bpmList.length / 60).truncate();
    //List<int> noiseMinutes = new int[groups.length * 2];
    List<int> minuteRanges = [];

    //expanding the areas to minute
    for (int i = 0, j = 0; i < groups.length; i++) {
      int from = groups[i].getFrom()!;
      int to = groups[i].getTo()!;

      from = from - (from % 60);
      to = to - (to % 60);
      to = to + 60;

      groups[i].setFrom(from);
      groups[i].setTo(to);

      //converting index to min
      from = ((from + 1) / 60).truncate();
      to = ((to - 1) / 60).truncate();

      while (from <= to) {
        if (from < minutes) minuteRanges.add(from);
        from++;
      }
    }

    //identifying the minutes to clean

    //asigning baseline values to avoid interpretations

    for (int interval = 0; interval < minutes; interval++) {
      int start1 = interval * 60;
      int limit = ((1 + interval) * 60).truncate();
      if (limit >= baselineBpmList.length) limit = baselineBpmList.length - 1;
      if (minuteRanges.contains(interval)) {
        for (int i = start1; i < limit; i++) {
          bpmList[i] = baselineBpmList[i];
        }
      }
    }

    noiseList = groups;
  }
  /*void _removeNoiseMinutes() {
    if (bpmCorrectedIndices.isEmpty || baselineBpmList.isEmpty) return;

    List<MarkerIndices> noiseGroups = _groupConsecutiveIndices(bpmCorrectedIndices, 7); // Group noisy indices

    int samplesPerMinute = _FACTOR * _NO_OF_SAMPLES_PER_MINUTE; // e.g., 4 * 15 = 60
    int totalMinutes = (bpmList.length / samplesPerMinute).ceil();
    Set<int> minutesToClean = {}; // Use a Set for efficient checking

    // Expand noise groups to cover full minutes
    for (MarkerIndices group in noiseGroups) {
      int fromIndex = group.getFrom() ?? 0;
      int toIndex = group.getTo() ?? fromIndex;

      // Ensure 'to' is at least 'from' and the duration is somewhat significant
      if (toIndex < fromIndex || (toIndex - fromIndex) < samplesPerMinute ~/ 2) { // Skip very small noise segments
        continue;
      }

      int startMinute = (fromIndex / samplesPerMinute).floor();
      int endMinute = (toIndex / samplesPerMinute).floor();

      for (int min = startMinute; min <= endMinute; min++) {
        if (min < totalMinutes) {
          minutesToClean.add(min);
        }
      }

      // Add the group to the official noise list for reporting
      // Adjust indices to minute boundaries for clarity in reporting? Or keep raw? Keeping raw for now.
      noiseList.add(group);
    }


    // Apply baseline to the identified minutes
    for (int minute in minutesToClean) {
      int startSample = minute * samplesPerMinute;
      int endSample = min((minute + 1) * samplesPerMinute, bpmList.length);
      int baselineEndSample = min(endSample, baselineBpmList.length); // Ensure baseline index is valid

      for (int i = startSample; i < endSample; i++) {
        // Only replace if baseline data is available for that index
        if (i < baselineEndSample && baselineBpmList[i] > 0) {
          bpmList[i] = baselineBpmList[i];
        } else if (i > startSample) {
          // Fallback: use previous value if baseline is missing
          bpmList[i] = bpmList[i-1];
        } // Else: leave as is (might be start of trace without baseline yet)
      }
    }
    // Original code added groups to _noiseList within _removeNoiseMinutes, moved grouping logic here.
  }*/

  /// Groups consecutive indices where the gap is less than `maxGap`.
  List<MarkerIndices> _groupConsecutiveIndices(List<int> indices, int maxGap) {
    List<MarkerIndices> groups = [];
    if (indices.isEmpty) return groups;

    int groupStart = indices[0];
    int groupEnd = indices[0];

    for (int i = 1; i < indices.length; i++) {
      if (indices[i] - indices[i-1] < maxGap) {
        groupEnd = indices[i]; // Extend current group
      } else {
        // Finalize previous group
        groups.add(MarkerIndices.from(from: groupStart, to: groupEnd));
        // Start new group
        groupStart = indices[i];
        groupEnd = indices[i];
      }
    }
    // Add the last group
    groups.add(MarkerIndices.from(from: groupStart, to: groupEnd));

    return groups;
  }


  /// An acceleration is defined as an increase in FHR above the baseline
  /// that lasts for longer than 15 seconds and has a maximum excursion
  /// above the baseline of greater than 10 beats/min
  int _calculateAccelerations() {
    List<MarkerIndices> accelerations = [];
    int size = millisecondsEpoch.length;
    int counter1 = 0, counter2 = 0, n = 0;
    int maxExcursion = 0;
    bool isAcceleration = false;

    for (int i = 0; i < size; i++) {
      MarkerIndices acceleration = MarkerIndices();
      int difference = millisecondsEpochBpm[i] - baselineEpochBpm[i];

      /*if (difference <= 0) {
                if (isAcceleration && (maxExcursion> (gestAge<= 32?15:10))) {
                    acceleration = new MarkerIndices();
                    acceleration.setFrom((int) ((i - (gestAge <= 32 ? counter1 : counter2)) * FACTOR));
                    acceleration.setTo((int) ((i) * FACTOR));
                    accelerations.add(acceleration);
                    n++;//adding acc count
                }
                counter1 = 0;
                counter2 = 0;
                maxExcursion = 0;
                isAcceleration = false;
                continue;
            }*/

      if (gestAge < 32) {
        if (difference >= 1) {
          counter1++;

          if (maxExcursion < difference) maxExcursion = difference;

          /*if (counter1 > 3 && !isAcceleration) { // 10 seconds = 3 samples
                        // acceleration detected
                        isAcceleration = true;
                        //n++;
                    }*/
        } else {
          if (counter1 >= 3 && maxExcursion >= 9) {
            // change from counter1 > 3 to counter1 >= 3
            acceleration = MarkerIndices();
            acceleration.setFrom(((i - counter1) * FACTOR));
            acceleration.setTo(((i) * FACTOR));
            accelerations.add(acceleration);
            n++; //adding acc count
          }
          counter1 = 0;
          //isAcceleration = false;
          maxExcursion = 0;
        }
      } else {
        /** gestetional age >=32 weeks **/
        if (difference > 1) {
          counter2++;

          if (maxExcursion < difference) maxExcursion = difference;

          /*if (counter2 >= 4 && !isAcceleration) {// 15 seconds = 4 samples
                        isAcceleration = true;
                        //n++;
                    }*/
        } else if (gestAge >= 32) {
          // change from gestAge > 32 to gestAge >= 32
          if (maxExcursion >= 10) {
            //debugPrint("maxExcursion", counter2 + " - " + maxExcursion + " - " + ((i * 4) / 60));
          }

          if (counter2 >= 4 && maxExcursion >= 14) {
            // change counter2 > 4 to counter2 >= 4
            acceleration = MarkerIndices();
            acceleration.setFrom(((i - counter2) * FACTOR));
            acceleration.setTo(((i) * FACTOR));
            accelerations.add(acceleration);
            n++; //adding acc count
          }
          counter2 = 0;
          //isAcceleration = false;
          maxExcursion = 0;
        }
      }
    }
    accelerationsList = accelerations;
    return n;
  }

  bool isDeceleration = false;

  /**
   * A deceleration is defined as a decrease in FHR below the baseline that lasts for
   * lasts for longer than 30 seconds and has a maximum excursion below the baseline of greater than 20 beats/min or
   * lasts for longer than 60 seconds and has a maximum excursion below the baseline of greater than 10 beats/min
   */
/*
  int calculateDecelerations() {
    List<MarkerIndices> decelerations = [];
    int size = millisecondsEpoch.length;
    int counter1 = 0, counter2 = 0, n = 0;
    int maxExcursion = 0;

    print("Interpretations2 :: calculateDecelerations size - $size");
    */
  /** first criteria **//*

    for (int i = 0; i < size; i++) {
      MarkerIndices deceleration = new MarkerIndices();
      if (millisecondsEpochBpm[i] == 0) continue;
      int difference = baselineEpochBpm[i]! - millisecondsEpochBpm[i]!;


      //print("Interpretations2 :: loop :: $i difference:$difference");
      if (difference > 0) {
        counter1++;
        if (maxExcursion < difference) maxExcursion = difference;

        */
/*if (counter1 >= 15 && !isDeceleration) { // 60 seconds = 16 samples
                    isDeceleration = true;
                    //n++;
                }*//*

        if (counter1 >= 4 && !isDeceleration) {
          isDeceleration = true;
        }
      } else {
        if (maxExcursion >= 10)
        //Log.i("maxExcursion dec 1", counter1 + " - " + maxExcursion + " - " + ((i * 4) / 60));
        if (counter1 >= 14 && maxExcursion >= 10) {
          // change from couter1 >= 15 to couter >= 4
          deceleration = new MarkerIndices();
          deceleration.setFrom(((i - counter1) * FACTOR));
          deceleration.setTo(((i) * FACTOR));
          decelerations.add(deceleration);
          n++;
          print("Interpretations2 :: loop :: $i if");

        } else if (counter1 >= 3 && counter1 < 15 && maxExcursion >= 15) {
          deceleration = MarkerIndices()
            ..setFrom((i - counter1).toInt() * FACTOR)
            ..setTo((i).toInt() * FACTOR);
          decelerations.add(deceleration);
          n++;
          print("Interpretations2 :: loop :: $i else if");
        }
        counter1 = 0;
        isDeceleration = false;
        maxExcursion = 0;
      }
    }
    //isDeceleration = false;
    maxExcursion = 0;

    */
  /// second criteria
/*for (int i = 0; i < size; i++) {
      int difference = baselineEpochBpm[i]! - millisecondsEpochBpm[i]!;

      if (difference > 1) {
        counter2++;

        if (maxExcursion < difference) maxExcursion = difference;

        *//*
 */
/*if (counter2 > 8 && counter2 < 15 && !isDeceleration) {// 60 seconds = 16 samples
                    isDeceleration = true;
                    //n++;
                }*//*
 */
/*
      } else {
        if (maxExcursion >= 10)
        //Log.i("maxExcursion dec 2", counter2 + " - " + maxExcursion + " - " + ((i * 4) / 60));

        if (counter2 >= 2 && counter2 < 4 && maxExcursion >= 20) {  // change from counter2 >= 8 && counter2 < 15 to counter2 >= 2 && counter2 < 4
          MarkerIndices deceleration = new MarkerIndices();
          deceleration.setFrom(((i - counter2) * FACTOR));
          deceleration.setTo(((i) * FACTOR));
          decelerations.add(deceleration);
          n++;
        }
        counter2 = 0;
        //isDeceleration = false;
        maxExcursion = 0;
      }
    }*//*


    decelerationsList = decelerations;
    print("Interpretations2 :: decelerationsList - ${decelerationsList?.length}");
    print("Interpretations2 :: counter1 - $counter1");
    print("Interpretations2 :: n - $n");
    print("Interpretations2 :: isDeceleration - $isDeceleration");
    print("Interpretations2 :: maxExcursion - $maxExcursion");
    return n;
  }
*/

  int _calculateDecelerations() {
    List<MarkerIndices> decelerations = [];
    int size = millisecondsEpoch.length;
    int counter1 = 0, counter2 = 0, n = 0;
    int maxExcursion = 0;

    for (int i = 0; i < size; i++) {
      MarkerIndices deceleration = MarkerIndices();
      if (millisecondsEpochBpm[i] == 0) continue;
      int difference = baselineEpochBpm[i] - millisecondsEpochBpm[i];

      if (difference > 0) {
        counter1++;
        if (maxExcursion < difference) maxExcursion = difference;

        if (counter1 >= 4 && !isDeceleration) {
          isDeceleration = true;
        }
      } else {
        if (maxExcursion >= 10) {
          print("maxExcursion dec 1: $counter1 - $maxExcursion - ${(i * 4) / 60}");

          if (counter1 >= 14 && maxExcursion >= 10) {
            deceleration = MarkerIndices()
              ..from = ((i - counter1) * FACTOR).toInt()
              ..to = (i * FACTOR).toInt();
            decelerations.add(deceleration);
            n++;
          } else if (counter1 > 3 && counter1 < 15 && maxExcursion >= 15) {
            deceleration = MarkerIndices()
              ..from = ((i - counter1) * FACTOR).toInt()
              ..to = (i * FACTOR).toInt();
            decelerations.add(deceleration);
            n++;
          }
        }
        counter1 = 0;
        isDeceleration = false;
        maxExcursion = 0;
      }
    }
    maxExcursion = 0;

    decelerationsList = decelerations;
    return n;
  }
  void _removeDecelerationMinutes() {
    int minutes =
    (millisecondsEpoch.length / NO_OF_SAMPLES_PER_MINUTE).truncate();
    List<int> minuteRanges = [];

    //List<int> decelerationMinutes = new int[decelerationsList.length * 2];

    //expanding the areas to minute
    for (int i = 0; i < decelerationsList.length; i++) {
      int from = (decelerationsList[i].getFrom()! / FACTOR).truncate();
      int to = (decelerationsList[i].getTo()! / FACTOR).truncate();

      from = from - (from % NO_OF_SAMPLES_PER_MINUTE);
      to = to - (to % NO_OF_SAMPLES_PER_MINUTE);
      to = to + NO_OF_SAMPLES_PER_MINUTE;

      from = ((from + 1) / NO_OF_SAMPLES_PER_MINUTE).truncate();
      to = ((to - 1) / NO_OF_SAMPLES_PER_MINUTE).truncate();

      while (from <= to) {
        if (from < minutes) minuteRanges.add(from);
        from++;
      }
    }

    List<int> finalMinutesToRemove = [];
    for (int j = 0; j < minuteRanges.length; j++) {
      int i = minuteRanges[j];
      if (!finalMinutesToRemove.contains(i)) {
        finalMinutesToRemove.add(i);
      }
    }

    //identifying the miutes to remove
    /*List<int> min = new List<>();
        min.add(decelerationMinutes[0] / NO_OF_SAMPLES_PER_MINUTE);
        for (int i = 1; i < decelerationMinutes.length - 1; i++) {
            if (decelerationMinutes[i - 1] != decelerationMinutes[i]) {
                min.add(decelerationMinutes[i] / NO_OF_SAMPLES_PER_MINUTE);
            }
        }*/

    //removing the minutes with decelerations
    int newLength = (minutes * NO_OF_SAMPLES_PER_MINUTE) -
        (finalMinutesToRemove.length * NO_OF_SAMPLES_PER_MINUTE);
    cleanMillisecondsEpoch = List.filled(newLength, 0, growable: false);
    cleanMillisecondsEpochBpm =
    List.filled(newLength, 0, growable: false);
    cleanBaselineEpoch = List.filled(newLength, 0, growable: false);
    cleanBaselineEpochBpm = List.filled(newLength, 0, growable: false);

    int c = 0;
    for (int interval = 0; interval < minutes; interval++) {
      if (finalMinutesToRemove.contains(interval)) continue;
      int start = interval * NO_OF_SAMPLES_PER_MINUTE;
      int limit = start +
          NO_OF_SAMPLES_PER_MINUTE; //((1 + interval) * NO_OF_SAMPLES_PER_MINUTE) - 1;
      for (int i = start; i < limit; i++) {
        cleanMillisecondsEpoch[c] = millisecondsEpoch[i];
        cleanMillisecondsEpochBpm[c] = millisecondsEpochBpm[i];
        cleanBaselineEpoch[c] = baselineEpoch[i];
        cleanBaselineEpochBpm[c++] = baselineEpochBpm[i];
      }
    }
  }

  int _calculateLowVariationAvg(List<int?> list, int avgHR) {
    /*if(bpmList.length/correctionCount <2){
            //todo: remove
        }*/

    int minutes = (list.length / NO_OF_SAMPLES_PER_MINUTE).truncate();
    minutes *= 3;
    if (minutes == 0) return minutes;
    List<int?> minuteRanges = List.filled(minutes, null, growable: false);
    for (int interval = 0; interval < minutes; interval++) {
      int max = 0;
      int min = 0;
      int start = (interval * (NO_OF_SAMPLES_PER_MINUTE / 3)).truncate();
      int limit = ((1 + interval) * (NO_OF_SAMPLES_PER_MINUTE / 3)).truncate();
      for (int i = start; i < limit; i++) {
        int diff = avgHR - list[i]!;
        if (diff > 0) {
          if (max < diff) max = diff;
        } else {
          if (min > diff) min = diff;
        }
      }

      minuteRanges[interval] = (max).abs() + (min).abs();
    }

    int sum = 0;
    int count = 0;
    for (int i = 0; i < minuteRanges.length; i++) {
      if (minuteRanges[i]! < 30) {
        int start = (i * (NO_OF_SAMPLES_PER_MINUTE / 3)).truncate();
        int limit = (((1 + i) * (NO_OF_SAMPLES_PER_MINUTE / 3))).truncate();
        int divisor = 0;
        int value = 0;
        for (int j = start; j < limit - 1; j++) {
          if (list[i] != 0) {
            divisor++;
            value += list[i]!;
          }
        }
        if (divisor != 0) {
          value = (value / divisor).truncate();
          count++;
        }
        sum += value;
      }
    }
    if (!sum.isNaN && !count.isNaN) {
      sum = (sum / count).isNaN ? 0 : (sum / count).truncate();
    } else {
      sum = 0;
    }

    return sum;
  }

  int _calculateAvgHeartRate(List<int?> list) {
    // todo: consider low variations

    int sum = 0;
    double basalHeartRate;
    int errorCount = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i]! < 60) {
        errorCount++;
        continue;
      }
      sum += list[i]!;
      //Log.i("clean bpm",cleanBaselineEpochBpm[i]+"");
    }
    basalHeartRate = (sum / (list.length - errorCount));

    return basalHeartRate.isNaN || basalHeartRate.isInfinite
        ? 0
        : basalHeartRate.truncate();
  }

  int _calculateBasalHeartRate(List<int?> list) {
    // todo: consider low variations

    int sum = 0;
    int basalHeartRate = 0;
    int errorCount = 0;
    try {
      for (int i = 0; i < list.length; i++) {
        if (list[i]! < 60) {
          errorCount++;
          continue;
        }
        sum += list[i]!;
        //Log.i("clean bpm",cleanBaselineEpochBpm[i]+"");
      }
      basalHeartRate = (sum / (list.length - errorCount)).truncate();

      // rounding of to nearest multiple of 5
      if (basalHeartRate % 5 >= 3) {
        basalHeartRate = basalHeartRate - (basalHeartRate % 5);
        basalHeartRate += 5;
      } else {
        basalHeartRate = basalHeartRate - (basalHeartRate % 5);
      }
      // rounding off ends
    } catch (ex, trace) {
      print(ex.toString());
    }
    return basalHeartRate;
  }

  void _calculateShortTermVariability() {
    if (cleanMillisecondsEpoch == null || cleanMillisecondsEpoch.isEmpty) {
      return;
    }
    int avgMilli = 0;
    double avgBpm = 0;

    for (int i = 1; i < cleanMillisecondsEpoch.length - 1; i++) {
      avgBpm +=
          (cleanMillisecondsEpochBpm[i - 1]! - cleanMillisecondsEpochBpm[i]!)
              .abs();
      avgMilli +=
          (cleanMillisecondsEpoch[i - 1] - cleanMillisecondsEpoch[i]).abs();
    }

    shortTermVariationBpm = avgBpm / cleanMillisecondsEpoch.length;
    shortTermVariationMilli =
        (avgMilli / cleanMillisecondsEpoch.length).truncate();
  }

  void _calculateEpisodesOfLowAndHighVariation() {
    /*if(bpmList.length/correctionCount <2){
            //todo: remove
        }*/

    try {
      int minutes =
      (cleanBaselineEpoch.length / NO_OF_SAMPLES_PER_MINUTE).truncate();
      if (minutes == 0) return;
      List<int?> minuteRanges = List.filled(minutes, null, growable: false);
      for (int interval = 0; interval < minutes; interval++) {
        int max = 0;
        int min = 0;
        int start = interval * NO_OF_SAMPLES_PER_MINUTE;
        int limit = ((1 + interval) * NO_OF_SAMPLES_PER_MINUTE).truncate();
        for (int i = start; i < limit; i++) {
          if (cleanMillisecondsEpochBpm[i]! < cleanBaselineEpochBpm[i]! - 30 ||
              cleanMillisecondsEpochBpm[i]! > 210) continue;

          int diff = cleanMillisecondsEpochBpm[i]! - cleanBaselineEpochBpm[i]!;
          if (diff > 0) {
            if (max < diff) max = diff;
          } else {
            if (min > diff) min = diff;
          }
        }

        minuteRanges[interval] = (max).abs() + (min).abs();
      }

      int errorCount = 0;
      for (int i = 0; i < minutes; i++) {
        if (minuteRanges[i] == 0) errorCount++;
        longTermVariation += minuteRanges[i]!;
      }
      longTermVariation =
          (longTermVariation / (minutes - errorCount)).truncate();

      double meanMinuteRange = 0,
          sum = 0,
          meanLowEpisodeBpm = 0,
          meanHighEpisodeBpm = 0;
      int highEpisodes = 0, lowEpisodes = 0, howManyLow = 0, howManyHigh = 0;
      int meanBpm = 0;

      for (int i = 0; i < minutes - 6; i++) {
        for (int j = i; j < i + 6; j++) {
          sum += minuteRanges[j]!;
        }

        meanMinuteRange = sum / 6;
        sum = 0;

        for (int j = i; j < i + 6; j++) {
          if ((meanMinuteRange * 6 - minuteRanges[j]!) / 5 <= 30) {
            howManyLow++;
          }

          if ((meanMinuteRange * 6 - minuteRanges[j]!) / 5 >= 32) {
            howManyHigh++;
          }
        }

        if (howManyLow >= 5) {
          lowEpisodes++;
          meanLowEpisodeBpm += meanMinuteRange;
        }

        if (howManyHigh >= 5) {
          // ignoring correlation and distribution of original traces for now
          highEpisodes++;
          meanHighEpisodeBpm += meanMinuteRange;
          if (gestAge <= 25) {
            // Do nothing
          } else if (meanHighEpisodeBpm / highEpisodes <
              highFHREpisodePercentiles[gestAge - 26][1]) {
            // checking 3rd percentile criteria

            highEpisodes--;
            meanHighEpisodeBpm -= meanMinuteRange;
          }
        }

        howManyLow = howManyHigh = 0;
      }
      int lengthOfHighFHREpisodes = highEpisodes;
      int lengthOfLowFHREpisodes = lowEpisodes;
    } catch (ex) {
      print(ex.toString());
    }
  }
}
