import 'dart:math';

class CtgProcessingService {
  // 1. Noise correction (replace 0s by interpolated values)
  List<int> correctNoise(List<int> bpm) {
    List<int> corrected = List.from(bpm);
    for (int i = 0; i < corrected.length; i++) {
      if (corrected[i] == 0) {
        int? prev = i > 0 ? corrected.sublist(0, i).lastWhere((v) => v != 0, orElse: () => -1) : null;
        int? next = corrected.sublist(i + 1).firstWhere((v) => v != 0, orElse: () => -1);
        if (prev != -1 && next != -1) {
          corrected[i] = ((prev! + next!) / 2).round();
        } else if (prev != -1) {
          corrected[i] = prev!;
        } else if (next != -1) {
          corrected[i] = next!;
        }
      }
    }
    return corrected;
  }

  // 2. Convert BPM to RR Intervals in milliseconds (ms)
  List<int> convertToRRms(List<int> bpm) {
    return bpm.map((b) => b == 0 ? 0 : (60000 / b).round()).toList();
  }

  // 3. Segment into 3.75s epochs (1 min = 16 epochs)
  List<List<int>> segmentIntoEpochs(List<int> bpm, {int epochLengthSec = 4}) {
    int samplesPerEpoch = epochLengthSec; // 1 Hz
    int totalEpochs = (bpm.length / samplesPerEpoch).floor();
    List<List<int>> epochs = [];

    for (int i = 0; i < totalEpochs; i++) {
      epochs.add(bpm.sublist(i * samplesPerEpoch, (i + 1) * samplesPerEpoch));
    }
    return epochs;
  }

  // 4. Calculate Baseline FHR from low-variation epochs
  double calculateBaseline(List<List<int>> epochs) {
    List<int> epochAverages = epochs
        .map((e) => e.isNotEmpty ? e.reduce((a, b) => a + b) ~/ e.length : 0)
        .toList();
    double mean = epochAverages.reduce((a, b) => a + b) / epochAverages.length;
    double stdDev = sqrt(epochAverages.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / epochAverages.length);
    return mean; // Could apply stricter filters if needed
  }

  // 5. Detect Accelerations
  List<CtgEvent> detectAccelerations(List<int> bpm, double baseline) {
    List<CtgEvent> accels = [];
    int start = -1;

    for (int i = 0; i < bpm.length; i++) {
      if (bpm[i] - baseline >= 15) {
        if (start == -1) start = i;
      } else {
        if (start != -1 && i - start >= 15) {
          accels.add(CtgEvent('acceleration', start, i - start, bpm.sublist(start, i)));
        }
        start = -1;
      }
    }
    return accels;
  }

  // 6. Detect Decelerations
  List<CtgEvent> detectDecelerations(List<int> bpm, double baseline) {
    List<CtgEvent> decels = [];
    int start = -1;

    for (int i = 0; i < bpm.length; i++) {
      if (baseline - bpm[i] >= 15) {
        if (start == -1) start = i;
      } else {
        if (start != -1 && i - start >= 15) {
          List<int> segment = bpm.sublist(start, i);
          int lostBeats = segment.map((b) => (baseline - b).clamp(0, double.infinity).round()).reduce((a, b) => a + b);
          decels.add(CtgEvent('deceleration', start, i - start, segment, lostBeats: lostBeats));
        }
        start = -1;
      }
    }
    return decels;
  }

  // 7. Calculate Short-Term Variation (STV)
  double calculateSTV(List<int> rr) {
    List<double> diffs = [];
    for (int i = 1; i < rr.length; i++) {
      if (rr[i] != 0 && rr[i - 1] != 0) {
        diffs.add((rr[i] - rr[i - 1]).abs().toDouble());
      }
    }
    return diffs.isEmpty ? 0 : diffs.reduce((a, b) => a + b) / diffs.length;
  }

  // 8. Detect LTV/HTV episodes
  List<VariationEpisode> detectVariationEpisodes(List<List<int>> epochs) {
    List<VariationEpisode> episodes = [];
    for (int i = 0; i < epochs.length; i++) {
      List<int> epoch = epochs[i];
      if (epoch.length < 2) continue;
      double range = (epoch.reduce(max) - epoch.reduce(min)).toDouble();

      String type = range >= 10 ? 'high' : 'low';
      double avg = epoch.reduce((a, b) => a + b) / epoch.length;

      episodes.add(VariationEpisode(
        type: type,
        epochIndex: i,
        avgLTV: range,
        values: epoch,
      ));
    }
    return episodes;
  }
}

class CtgEvent {
  String type; // 'acceleration' | 'deceleration'
  int start;
  int duration; // in seconds
  List<int> segment;
  int lostBeats;

  CtgEvent(this.type, this.start, this.duration, this.segment, {this.lostBeats = 0});

  @override
  String toString() => 'CtgEvent(type: $type, start: $start, segment: $segment)';
}

class VariationEpisode {
  String type; // 'high' or 'low'
  int epochIndex;
  double avgLTV;
  List<int> values;

  VariationEpisode({
    required this.type,
    required this.epochIndex,
    required this.avgLTV,
    required this.values,
  });

  @override
  String toString() => 'VariationEpisode(type: $type, epochIndex: $epochIndex, avgLTV: $avgLTV, values: $values )';

}
