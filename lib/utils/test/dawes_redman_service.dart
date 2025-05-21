import 'ctg_processing_service.dart';

class DawesRedmanResult {
  final bool isNormal;
  final List<String> failedCriteria;

  DawesRedmanResult({
    required this.isNormal,
    required this.failedCriteria,
  });
}

class DawesRedmanService {
  DawesRedmanResult evaluate({
    required List<int> correctedBpm,
    required List<int> rrIntervals,
    required List<List<int>> epochs,
    required double baseline,
    required double stv,
    required List<CtgEvent> accelerations,
    required List<CtgEvent> decelerations,
    required List<VariationEpisode> variationEpisodes,
    required List<int> fetalMovements,
    required int recordingDurationSec,
  }) {
    final List<String> failed = [];

    // Criteria 1 (placeholder logic)
    final hasHighVariation = variationEpisodes.any((ep) => ep.type == "high");
    if (!hasHighVariation) failed.add("Missing episode of high variation");

    // Criteria 2 (placeholder)
    if (stv <= 3) {
      failed.add("STV ≤ 3 ms");
    }

    // Criteria 3 - Sinusoidal rhythm detection (not implemented yet)

    // Criteria 4 - Acceleration or movements + LTV (not implemented yet)

    // ... Implement other criteria similarly ...

    bool isNormal = failed.isEmpty;

    return DawesRedmanResult(
      isNormal: isNormal,
      failedCriteria: failed,
    );
  }
}
