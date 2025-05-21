import 'package:flutter/cupertino.dart';

import '../../models/test_model.dart';
import 'ctg_processing_service.dart';
import 'dawes_redman_service.dart';

class Interpretation {
  final CtgTest ctgTest;
  final CtgProcessingService _processor = CtgProcessingService();
  final DawesRedmanService _evaluator = DawesRedmanService();

  late List<int> correctedBpm;
  late List<int> rrIntervals;
  late List<List<int>> epochs;
  late double baseline;
  late double stv;
  late List<CtgEvent> accelerations;
  late List<CtgEvent> decelerations;
  late List<VariationEpisode> variationEpisodes;

  bool isNormal = false;
  List<String> failedCriteria = [];

  Interpretation(this.ctgTest) {
    _runFullAnalysis();
    debugPrint(toString());
  }

  @override
  String toString() {
    return 'Interpretation('
        'ctgTest: $ctgTest, '
        //'correctedBpm: $correctedBpm, '
        //'rrIntervals: $rrIntervals, '
        //'epochs: $epochs, '
        //'baseline: $baseline, '
        'stv: $stv, '
        'accelerations: ${accelerations.length}, '
        'decelerations: ${decelerations.length}, '
        'variationEpisodes: ${variationEpisodes.length}, '
        'isNormal: $isNormal, '
        'failedCriteria: $failedCriteria'
        ')';
  }

  void _runFullAnalysis() {
    correctedBpm = _processor.correctNoise(ctgTest.bpmEntries);
    rrIntervals = _processor.convertToRRms(correctedBpm);
    epochs = _processor.segmentIntoEpochs(correctedBpm);
    baseline = _processor.calculateBaseline(epochs);
    stv = _processor.calculateSTV(rrIntervals);
    accelerations = _processor.detectAccelerations(correctedBpm, baseline);
    decelerations = _processor.detectDecelerations(correctedBpm, baseline);
    variationEpisodes = _processor.detectVariationEpisodes(epochs);

    final result = _evaluator.evaluate(
      correctedBpm: correctedBpm,
      rrIntervals: rrIntervals,
      epochs: epochs,
      baseline: baseline,
      stv: stv,
      accelerations: accelerations,
      decelerations: decelerations,
      variationEpisodes: variationEpisodes,
      fetalMovements: ctgTest.autoFetalMovement,
      recordingDurationSec: ctgTest.lengthOfTest,
    );

    isNormal = result.isNormal;
    failedCriteria = result.failedCriteria;
  }
}
