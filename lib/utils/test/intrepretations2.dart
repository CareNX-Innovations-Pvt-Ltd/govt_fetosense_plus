import 'dart:math'; // Import dart:math for max/min functions
import 'package:flutter/foundation.dart'; // Use foundation for debugPrint
import 'package:l8fe/models/marker_indices.dart';

// --- Constants ---
const int _SIXTY_THOUSAND_MS = 60000;
const int _FACTOR = 4; // Samples per epoch
const int _NO_OF_SAMPLES_PER_MINUTE = 15; // Epochs per minute (60 sec / 4 sec/epoch)

// FHR Thresholds
const int _MIN_VALID_BPM = 60;
const int _MAX_VALID_BPM = 210;
const int _MAX_BPM_JUMP = 35;

// Smoothing Parameters
const int _SMOOTHING_WINDOW_FACTOR = 4;
const double _FINAL_SMOOTHING_FACTOR_TINY = 0.33;

// Baseline Calculation Parameters
const int _BASELINE_BUCKETS = 1001; // For ms intervals (approx 272ms to 1000ms for 60-220bpm)
const double _BASELINE_MODE_LIMIT_FRACTION = 0.125;
const double _BASELINE_PEAK_MIN_FRACTION = 0.005;
const int _BASELINE_PEAK_MODE_DISTANCE_THRESHOLD = 30; // ms
const int _BASELINE_FILTER_BAND_MS = 100; // +/- ms around selected peak/mode
const int _BASELINE_FILTER_BAND_MS_INNER = 50; // +/- ms inner band
const double _BASELINE_SMOOTHING_A_TINY = 0.75;
const int _BASELINE_WINDOW_SMOOTHING_WINDOW = 2; // epochs
const double _BASELINE_FINAL_SMOOTHING_TINY = 0.3;
const double _BASELINE_LOW_VAR_SMOOTHING_TINY = 0.25;

// Acceleration Thresholds (NICE Guidelines - approximated)
const int _ACCEL_MIN_DIFF_BPM = 1; // Minimum increase over baseline
const int _ACCEL_MIN_DURATION_S_LT32 = 10; // >= 10s for < 32 weeks
const int _ACCEL_MIN_PEAK_BPM_LT32 = 9; // >= 10 bpm peak for < 32 weeks (using 9 due to >=)
const int _ACCEL_MIN_DURATION_S_GE32 = 15; // >= 15s for >= 32 weeks
const int _ACCEL_MIN_PEAK_BPM_GE32 = 14; // >= 15 bpm peak for >= 32 weeks (using 14 due to >=)

// Deceleration Thresholds (Approximation - needs clinical validation)
// Based on common definitions: >15bpm drop for >15s, OR >10bpm drop for >60s
const int _DECEL_MIN_DIFF_BPM = 0; // Minimum decrease below baseline
const int _DECEL_DURATION_THRESHOLD_S_1 = 15; // seconds (approx 4 epochs) - Short duration
const int _DECEL_BPM_THRESHOLD_1 = 15; // bpm drop - For short duration
const int _DECEL_DURATION_THRESHOLD_S_2 = 60; // seconds (approx 15 epochs) - Long duration
const int _DECEL_BPM_THRESHOLD_2 = 10; // bpm drop - For long duration

// Variability Thresholds
const int _LOW_VARIATION_THRESHOLD_LTV = 30; // bpm range per minute segment
const int _HIGH_VARIATION_THRESHOLD_LTV = 32; // bpm range per minute segment
const int _VARIATION_EPISODE_MINUTES = 6;
const int _VARIATION_EPISODE_MIN_SEGMENTS = 5; // Segments within episode meeting criteria

// Fisher Score Constants
const int _FISHER_POST_ACCEL_SAMPLES = 120; // Samples (seconds * FACTOR) to analyze after first accel

/// Holds the results of the CTG interpretation.
class InterpretationResult {
  final int basalHeartRate;
  final int nAccelerations;
  final int nDecelerations;
  final double shortTermVariationBpm;
  final int shortTermVariationMilli;
  final int longTermVariation; // Bandwidth in BPM
  final List<MarkerIndices> accelerationsList;
  final List<MarkerIndices> decelerationsList;
  final List<MarkerIndices> noiseList;
  final List<int> baselineBpmList; // Baseline FHR per sample
  final int fisherScore;
  final Map<String, dynamic> fisherScoreDetails;
  final bool isSkipped; // Indicates if calculation was skipped (e.g., due to insufficient data)

  InterpretationResult({
    required this.basalHeartRate,
    required this.nAccelerations,
    required this.nDecelerations,
    required this.shortTermVariationBpm,
    required this.shortTermVariationMilli,
    required this.longTermVariation,
    required this.accelerationsList,
    required this.decelerationsList,
    required this.noiseList,
    required this.baselineBpmList,
    required this.fisherScore,
    required this.fisherScoreDetails,
    this.isSkipped = false,
  });

  // Factory constructor for skipped state
  factory InterpretationResult.skipped() {
    return InterpretationResult(
      basalHeartRate: 0,
      nAccelerations: 0,
      nDecelerations: 0,
      shortTermVariationBpm: 0.0,
      shortTermVariationMilli: 0,
      longTermVariation: 0,
      accelerationsList: [],
      decelerationsList: [],
      noiseList: [],
      baselineBpmList: [],
      fisherScore: 0,
      fisherScoreDetails: {},
      isSkipped: true,
    );
  }
}

/// Performs CTG analysis based on FHR data.
///
/// Follows a specific algorithm involving cleaning, smoothing, baseline detection,
/// event detection (accelerations, decelerations), variability calculation,
/// and Fisher scoring.
class Interpretations {
  // --- Input Data ---
  final List<int> _originalBpmList;
  final int _gestAgeWeeks; // Gestational Age capped at 41 weeks

  // --- Processed Data (Internal State during calculation) ---
  late List<int> _bpmList; // Working copy, potentially cleaned
  late List<int> _bpmListSmooth;
  late List<int> _beatsInMilliseconds;
  late List<int> _beatsInMillisecondsSmooth;
  late List<int> _millisecondsEpoch; // 4-sample average in ms
  late List<int> _millisecondsEpochSmooth;
  late List<int> _millisecondsEpochBpm; // Epoch data converted back to BPM
  late List<int> _baselineEpoch; // Baseline FHR in ms per epoch
  late List<int> _baselineEpochBpm; // Baseline FHR in BPM per epoch
  late List<int> _baselineBpmList; // Baseline FHR in BPM per original sample

  // Cleaned data after removing noise/deceleration minutes for final calculations
  late List<int> _cleanMillisecondsEpoch;
  late List<int> _cleanMillisecondsEpochBpm;
  late List<int> _cleanBaselineEpoch;
  late List<int> _cleanBaselineEpochBpm;

  // --- Detected Events ---
  late List<MarkerIndices> _accelerationsList;
  late List<MarkerIndices> _decelerationsList;
  late List<MarkerIndices> _noiseList;
  late List<int> _bpmCorrectedIndices; // Indices where corrections were applied

  // --- Calculated Results ---
  late int _nAccelerations;
  late int _nDecelerations;
  late int _basalHeartRate; // In BPM
  late int _longTermVariation; // In BPM
  late double _shortTermVariationBpm;
  late int _shortTermVariationMilli;
  late int _fisherScore;
  late Map<String, dynamic> _fisherScoreDetails;

  int _correctionCount = 0;

  // Percentiles for high FHR episode confirmation (Consider moving to a separate config/data file)
  static final List<List<dynamic>> _highFHREpisodePercentiles = [
    // gestAge, 3rd percentile, 10th percentile of LTV for healthy fetus
    [26, 11.75, 12.75], [27, 11.75, 12.75], [28, 11.5, 12.75],
    [29, 11.5, 13], [30, 11.5, 13], [31, 11.75, 13],
    [32, 11.75, 13.25], [33, 12, 13.25], [34, 12, 13.5],
    [35, 12.25, 14], [36, 12.5, 14.25], [37, 12.5, 14.5],
    [38, 12.75, 14.5], [39, 12.75, 14.75], [40, 12.5, 14.75],
    [41, 12.75, 14.75]
  ];

  /// Performs CTG interpretation on the provided FHR list and gestational age.
  ///
  /// Throws [ArgumentError] if [bpm] list is null or too short.
  /// Returns an [InterpretationResult] object containing the analysis.
  static InterpretationResult interpret(List<int>? bpm, int? gAge) {
    // Basic input validation
    if (bpm == null || bpm.length < _NO_OF_SAMPLES_PER_MINUTE * 5) { // Require at least 5 mins of data
      debugPrint("Interpretations :: Insufficient data. Need at least ${ _NO_OF_SAMPLES_PER_MINUTE * 5} samples (5 mins). Found ${bpm?.length ?? 0}.");
      // Instead of throwing, return a skipped result for graceful handling
      return InterpretationResult.skipped();
      // throw ArgumentError("Input BPM list is null or too short for reliable analysis.");
    }
    /*if (gAge == null || gAge < 24 || gAge > 42) { // Gestational age bounds
      debugPrint("Interpretations2 :: Invalid gestational age: $gAge. Must be between 24 and 42.");
      // Consider if this should be an error or use a default/capped value
      return InterpretationResult.skipped();
      // throw ArgumentError("Gestational age must be provided and between 24 and 42 weeks.");
    }*/

    // Cap gestational age at 41 for percentile lookups
    final int effectiveGestAge = min(gAge!.clamp(24, 41), 41);

    // Create an instance and run the calculations
    try {
      final interpreter = Interpretations._internal(bpm, effectiveGestAge);
      interpreter._calculate();
      return interpreter._createResult();
    } catch (e, stackTrace) {
      debugPrint("Error during CTG interpretation: $e\n$stackTrace");
      // Return a skipped/error state
      return InterpretationResult.skipped();
      // Or rethrow if the caller should handle it: throw Exception("CTG Interpretation failed: $e");
    }
  }


  // Private constructor
  Interpretations._internal(List<int> bpm, int gAge)
      : _originalBpmList = List.from(bpm), // Keep original if needed
        _gestAgeWeeks = gAge {
    // Initialize lists that will be populated by _calculate()
    _bpmList = [];
    _bpmListSmooth = [];
    _beatsInMilliseconds = [];
    _beatsInMillisecondsSmooth = [];
    _millisecondsEpoch = [];
    _millisecondsEpochSmooth = [];
    _millisecondsEpochBpm = [];
    _baselineEpoch = [];
    _baselineEpochBpm = [];
    _baselineBpmList = [];
    _cleanMillisecondsEpoch = [];
    _cleanMillisecondsEpochBpm = [];
    _cleanBaselineEpoch = [];
    _cleanBaselineEpochBpm = [];
    _accelerationsList = [];
    _decelerationsList = [];
    _noiseList = [];
    _bpmCorrectedIndices = [];
    _nAccelerations = 0;
    _nDecelerations = 0;
    _basalHeartRate = 0;
    _longTermVariation = 0;
    _shortTermVariationBpm = 0.0;
    _shortTermVariationMilli = 0;
    _fisherScore = 0;
    _fisherScoreDetails = {};
    _correctionCount = 0;
  }

  /// Main calculation pipeline.
  void _calculate() {
    debugPrint("Interpretations2 :: Starting calculation for ${_originalBpmList.length} samples, GA: $_gestAgeWeeks weeks");

    // 1. Initial Data Preparation & Noise Detection
    _bpmList = List.from(_originalBpmList);
    _bpmCorrectedIndices = _getNoiseAreas(_bpmList); // Detect noise first
    _cleanBpmList(); // Clean based on general rules

    // Convert to milliseconds and epochs (raw data)
    _beatsInMilliseconds = _convertBpmToMilli(_bpmList);
    _millisecondsEpoch = _convertMilliToEpoch(_beatsInMilliseconds);
    _millisecondsEpochBpm = _calculateEpochBpm(_millisecondsEpoch);

    // 2. Smoothing and Baseline Calculation
    _bpmListSmooth = List.from(_bpmList); // Start smooth version from cleaned list
    _smoothBpm();
    _beatsInMillisecondsSmooth = _convertBpmToMilli(_bpmListSmooth);
    _millisecondsEpochSmooth = _convertMilliToEpoch(_beatsInMillisecondsSmooth);
    _baselineEpoch = _calculateBaseLine(_millisecondsEpochSmooth); // Baseline from SMOOTHED data
    _baselineEpochBpm = _convertEpochToBpm(_baselineEpoch);
    _baselineBpmList = _convertBaselineEpochToBpmList(_baselineEpoch);

    // 3. Re-correct BPM list based on Baseline (if noise was initially found)
    if (_correctionCount > 0) {
      _removeNoiseMinutes(); // Overwrite noisy minutes in _bpmList with baseline values
      // Recalculate raw epoch data after noise removal
      _beatsInMilliseconds = _convertBpmToMilli(_bpmList);
      _millisecondsEpoch = _convertMilliToEpoch(_beatsInMilliseconds);
      _millisecondsEpochBpm = _calculateEpochBpm(_millisecondsEpoch);
    }

    // 4. Prepare "Clean" Data for Final Calculations
    // Initially, clean data is the same as processed data
    _cleanMillisecondsEpoch = List.from(_millisecondsEpoch);
    _cleanMillisecondsEpochBpm = List.from(_millisecondsEpochBpm);
    _cleanBaselineEpoch = List.from(_baselineEpoch);
    _cleanBaselineEpochBpm = List.from(_baselineEpochBpm);

    // 5. Detect Accelerations and Decelerations (using original epochs vs baseline epochs)
    _nAccelerations = _calculateAccelerations();
    _nDecelerations = _calculateDecelerations();

    // 6. Remove Deceleration Minutes for Variability/Basal Rate Calculation
    if (_nDecelerations > 0) {
      _removeDecelerationMinutes(); // Updates the 'clean' lists
    }

    // 7. Calculate Final Metrics using "Clean" Data
    _calculateEpisodesOfLowAndHighVariation(); // Calculates LTV (_longTermVariation)
    _basalHeartRate = _calculateBasalHeartRate(_cleanBaselineEpochBpm);
    _calculateShortTermVariability(); // Calculates STV (_shortTermVariationBpm/Milli)

    // 8. Calculate Fisher Score
    _calculateFisherScore();

    debugPrint("Interpretations2 :: Calculation Complete. Acc: $_nAccelerations, Dec: $_nDecelerations, Basal: $_basalHeartRate, STV: ${_shortTermVariationBpm.toStringAsFixed(2)}, LTV: $_longTermVariation, Fisher: $_fisherScore");
  }

  /// Creates the final result object.
  InterpretationResult _createResult() {
    return InterpretationResult(
      basalHeartRate: _basalHeartRate,
      nAccelerations: _nAccelerations,
      nDecelerations: _nDecelerations,
      shortTermVariationBpm: _shortTermVariationBpm,
      shortTermVariationMilli: _shortTermVariationMilli,
      longTermVariation: _longTermVariation,
      accelerationsList: _accelerationsList,
      decelerationsList: _decelerationsList,
      noiseList: _noiseList,
      baselineBpmList: _baselineBpmList,
      fisherScore: _fisherScore,
      fisherScoreDetails: _fisherScoreDetails,
      isSkipped: false, // Calculation completed
    );
  }


  // --- Helper Methods: Data Preparation ---

  /// Cleans the BPM list by removing trailing zeros and smoothing jumps/zeros.
  /// Modifies the `_bpmList`.
  void _cleanBpmList() {
    _removeTrailingZeros(_bpmList);
    if (_bpmList.isEmpty) return; // Exit if list became empty

    // Replace zeros with the next non-zero value
    for (int i = 0; i < _bpmList.length; i++) {
      if (_bpmList[i] == 0) {
        _bpmList[i] = _getNextNonZeroBpm(i, _bpmList);
      }
    }

    // Smooth large jumps or invalid values
    for (int i = 1; i < _bpmList.length; i++) {
      int startData = _bpmList[i - 1];
      int stopData = _bpmList[i];
      if (startData < _MIN_VALID_BPM ||
          stopData < _MIN_VALID_BPM ||
          startData > _MAX_VALID_BPM ||
          stopData > _MAX_VALID_BPM ||
          (startData - stopData).abs() > _MAX_BPM_JUMP) {
        // Use a window average around the problematic point
        _bpmList[i] = _getWindowAverage(_bpmList, i, 60 ~/ _FACTOR); // ~1 min window
      }
    }
  }

  /// Removes trailing zeros from a list in place.
  void _removeTrailingZeros(List<int> list) {
    if (list.isEmpty) return;
    // More robust way to remove trailing zeros
    int lastNonZero = -1;
    for(int i = list.length -1; i >= 0; i--) {
      if (list[i] != 0) {
        lastNonZero = i;
        break;
      }
    }
    // If all were zero or list was empty, result is empty list
    if (lastNonZero == -1) {
      list.clear();
    } else if (lastNonZero < list.length - 1) {
      list.removeRange(lastNonZero + 1, list.length);
    }
  }

  /// Finds the next non-zero BPM value in the list starting from `index`.
  int _getNextNonZeroBpm(int index, List<int> list) {
    for (int i = index + 1; i < list.length; i++) {
      if (list[i] != 0 && list[i] != -1) { // Assuming -1 might also be invalid
        return list[i];
      }
    }
    // If no non-zero found later, use the previous value (or 0 if index is 0)
    return index > 0 ? list[index - 1] : 0;
  }

  /// Finds the next BPM value that doesn't represent a large jump.
  int _getNextValidBpm(int index, List<int> list) {
    if (index <= 0 || index >= list.length) return list.isEmpty ? 0 : list[max(0, index -1)]; // Handle edge cases

    int startData = list[index - 1];
    if (startData < _MIN_VALID_BPM) { // If previous is invalid, search forward more broadly
      return _getNextNonZeroBpm(index, list);
    }

    for (int i = index; i < list.length; i++) {
      int stopData = list[i];
      if (stopData >= _MIN_VALID_BPM && stopData <= _MAX_VALID_BPM && (startData - stopData).abs() <= _MAX_BPM_JUMP) {
        return stopData; // Found a valid next value
      }
    }
    // If no valid value found afterwards, return the previous value
    return startData;
  }


  /// Calculates the average value within a window around the index.
  int _getWindowAverage(List<int> list, int index, int window) {
    int start = max(0, index - window);
    int stop = min(list.length - 1, index + window);
    if (start >= stop) return list[index]; // Avoid division by zero if window is invalid

    int sum = 0;
    int count = 0;
    for (int i = start; i <= stop; i++) {
      // Include only reasonably valid points in the average
      if (list[i] >= _MIN_VALID_BPM && list[i] <= _MAX_VALID_BPM) {
        // Add a check to avoid including points that are part of a large jump relative to neighbors (optional, adds complexity)
        bool isJump = false;
        if (i > start && (list[i] - list[i-1]).abs() > _MAX_BPM_JUMP) isJump = true;
        if (i < stop && (list[i] - list[i+1]).abs() > _MAX_BPM_JUMP) isJump = true;

        if (!isJump) { // Only average non-jump points
          sum += list[i];
          count++;
        }
      }
    }

    return (count > 0) ? (sum / count).round() : list[index]; // Use round for better averaging
  }


  /// Smooths the `_bpmListSmooth` using jump detection, window averaging, and final smoothing.
  void _smoothBpm() {
    // Initial pass: Handle zeros and large jumps (similar to _cleanBpmList but on the smooth list)
    for (int i = 1; i < _bpmListSmooth.length; i++) {
      if (_bpmListSmooth[i] <= 0) { // Handle 0 or potential -1
        _bpmListSmooth[i] = _getNextNonZeroBpm(i, _bpmListSmooth);
        // Note: Original code incremented correctionCount here, moved to _getNoiseAreas
      }
    }

    for (int i = 1; i < _bpmListSmooth.length; i++) {
      int startData = _bpmListSmooth[i - 1];
      int stopData = _bpmListSmooth[i];
      if (startData < _MIN_VALID_BPM || stopData < _MIN_VALID_BPM ||
          startData > _MAX_VALID_BPM || stopData > _MAX_VALID_BPM ||
          (startData - stopData).abs() > _MAX_BPM_JUMP)
      {
        // More aggressive jump handling: if diff > 60, average; otherwise, find next valid
        if (stopData - startData > 60 && startData > _MIN_VALID_BPM && stopData > _MIN_VALID_BPM + 50) { // Heuristic from original
          // Average the jump point and the previous one - might be problematic
          // Consider replacing the current point 'i' with the previous one 'i-1' or next valid instead
          _bpmListSmooth[i] = _getNextValidBpm(i, _bpmListSmooth);
          // _bpmListSmooth[i] = ((startData + stopData) / 2).round(); // Original approach - risky
          // If averaging, maybe need to adjust 'i' back? Original code had --i, maybe unintended?
        } else {
          _bpmListSmooth[i] = _getNextValidBpm(i, _bpmListSmooth);
        }
        // Note: Original code incremented correctionCount here, moved to _getNoiseAreas
      }
    }


    // Apply window smoothing
    int window = _FACTOR * _SMOOTHING_WINDOW_FACTOR;
    List<int> tempSmoothed = List.from(_bpmListSmooth); // Smooth into a new list to avoid influencing subsequent calculations in the same loop
    for (int i = window; i < _bpmListSmooth.length - window; i++) { // Adjust loop bounds
      tempSmoothed[i] = _getWindowAverage(_bpmListSmooth, i, window);
    }
    _bpmListSmooth = tempSmoothed; // Assign smoothed result back


    // Final slight smoothing pass (exponential moving average like) - applied across the whole list
    if (_bpmListSmooth.length > 1) {
      for (int i = 0; i < _bpmListSmooth.length - 1; i++) {
        _bpmListSmooth[i + 1] = (_FINAL_SMOOTHING_FACTOR_TINY * _bpmListSmooth[i] + (1.0 - _FINAL_SMOOTHING_FACTOR_TINY) * _bpmListSmooth[i + 1]).round();
      }
    }
  }

  /// Identifies indices likely corresponding to noise or signal loss.
  List<int> _getNoiseAreas(List<int> list) {
    List<int> correctedIndices = [];
    _correctionCount = 0; // Reset correction count for this run
    List<int> workingList = List.from(list); // Work on a copy

    // Pass 1: Mark indices of zeros
    for (int i = 0; i < workingList.length; i++) {
      if (workingList[i] == 0) {
        workingList[i] = _getNextNonZeroBpm(i, workingList); // Tentatively replace
        if (!correctedIndices.contains(i)) {
          correctedIndices.add(i);
          _correctionCount++;
        }
      }
    }

    // Pass 2: Mark indices of jumps or invalid ranges
    for (int i = 1; i < workingList.length; i++) {
      int startData = workingList[i - 1];
      int stopData = workingList[i];
      if (startData < _MIN_VALID_BPM ||
          stopData < _MIN_VALID_BPM ||
          startData > _MAX_VALID_BPM ||
          stopData > _MAX_VALID_BPM ||
          (startData - stopData).abs() > _MAX_BPM_JUMP) {
        // Tentatively replace with next valid value
        workingList[i] = _getNextValidBpm(i, workingList);
        if (!correctedIndices.contains(i)) {
          correctedIndices.add(i);
          _correctionCount++;
        }
        // Original code had a complex condition here involving averaging; simplifying to marking as noise
      }
    }

    correctedIndices.sort();
    return correctedIndices;
  }


  /// Replaces BPM values in noisy minutes with corresponding baseline values.
  /// Modifies `_bpmList`.
  void _removeNoiseMinutes() {
    if (_bpmCorrectedIndices.isEmpty || _baselineBpmList.isEmpty) return;

    List<MarkerIndices> noiseGroups = _groupConsecutiveIndices(_bpmCorrectedIndices, 7); // Group noisy indices

    int samplesPerMinute = _FACTOR * _NO_OF_SAMPLES_PER_MINUTE; // e.g., 4 * 15 = 60
    int totalMinutes = (_bpmList.length / samplesPerMinute).ceil();
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
      _noiseList.add(group);
    }


    // Apply baseline to the identified minutes
    for (int minute in minutesToClean) {
      int startSample = minute * samplesPerMinute;
      int endSample = min((minute + 1) * samplesPerMinute, _bpmList.length);
      int baselineEndSample = min(endSample, _baselineBpmList.length); // Ensure baseline index is valid

      for (int i = startSample; i < endSample; i++) {
        // Only replace if baseline data is available for that index
        if (i < baselineEndSample && _baselineBpmList[i] > 0) {
          _bpmList[i] = _baselineBpmList[i];
        } else if (i > startSample) {
          // Fallback: use previous value if baseline is missing
          _bpmList[i] = _bpmList[i-1];
        } // Else: leave as is (might be start of trace without baseline yet)
      }
    }
    // Original code added groups to _noiseList within _removeNoiseMinutes, moved grouping logic here.
  }

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


  // --- Helper Methods: Conversions ---

  /// Converts a list of BPM values to milliseconds per beat interval.
  List<int> _convertBpmToMilli(List<int> bpmList) {
    List<int> milliseconds = List.filled(bpmList.length, 0);
    for (int i = 0; i < bpmList.length; i++) {
      if (bpmList[i] > 0) {
        milliseconds[i] = (_SIXTY_THOUSAND_MS / bpmList[i]).round();
      } else {
        milliseconds[i] = 0; // Or handle as error/invalid
      }
    }
    return milliseconds;
  }

  /// Converts beat interval list (ms) to epoch list (average ms over FACTOR samples).
  List<int> _convertMilliToEpoch(List<int> millisecondBeats) {
    if (millisecondBeats.isEmpty || _FACTOR <= 0) return [];

    int size = (millisecondBeats.length / _FACTOR).ceil(); // Use ceil to include partial last epoch
    List<int> epoch = List.filled(size, 0);

    for (int i = 0; i < size; i++) {
      int milliSum = 0;
      int count = 0;
      int start = i * _FACTOR;
      int end = min(start + _FACTOR, millisecondBeats.length);

      for (int j = start; j < end; j++) {
        if (millisecondBeats[j] > 0) { // Only average valid millisecond values
          milliSum += millisecondBeats[j];
          count++;
        }
      }

      if (count > 0) {
        epoch[i] = (milliSum / count).round();
      } else {
        epoch[i] = 0; // Epoch is invalid if no valid data points within it
      }
    }
    return epoch;
  }

  /// Calculates BPM for each epoch from millisecond epoch data.
  List<int> _calculateEpochBpm(List<int> millisecondsEpoch) {
    return _convertEpochToBpm(millisecondsEpoch); // Reuse common conversion
  }

  /// Converts epoch data (ms) back to BPM.
  List<int> _convertEpochToBpm(List<int> epochMs) {
    List<int> epochBpm = List.filled(epochMs.length, 0);
    for (int i = 0; i < epochMs.length; i++) {
      if (epochMs[i] > 0) {
        epochBpm[i] = (_SIXTY_THOUSAND_MS / epochMs[i]).round();
      } else {
        epochBpm[i] = 0; // Or some indicator of invalidity
      }
    }
    return epochBpm;
  }

  /// Expands the baseline epoch data (ms or bpm) to match the original sample rate.
  List<int> _convertBaselineEpochToBpmList(List<int> baselineEpochMs) {
    List<int> baselineBpmList = List.filled(_originalBpmList.length, 0); // Match original length
    List<int> baselineEpochBpm = _convertEpochToBpm(baselineEpochMs);

    for (int i = 0; i < baselineEpochBpm.length; i++) {
      int bpmValue = baselineEpochBpm[i];
      int startSample = i * _FACTOR;
      int endSample = min((i + 1) * _FACTOR, baselineBpmList.length);

      for (int j = startSample; j < endSample; j++) {
        baselineBpmList[j] = bpmValue;
      }
    }

    // Optional: Apply light smoothing to the sample-rate baseline for visual appeal?
    // Be cautious not to alter it significantly if used for calculations.
    // Example: Very light moving average
    /*
      if (baselineBpmList.length > 2) {
          List<int> smoothed = List.from(baselineBpmList);
          for (int i = 1; i < baselineBpmList.length - 1; i++) {
              smoothed[i] = ((baselineBpmList[i-1] + baselineBpmList[i] * 2 + baselineBpmList[i+1]) / 4).round();
          }
          // Handle endpoints
          smoothed[0] = ((baselineBpmList[0] * 2 + baselineBpmList[1]) / 3).round();
          smoothed[baselineBpmList.length - 1] = ((baselineBpmList[baselineBpmList.length - 2] + baselineBpmList[baselineBpmList.length - 1] * 2) / 3).round();
          return smoothed;
      }
      */

    return baselineBpmList;
  }


  // --- Helper Methods: Baseline Calculation ---

  /// Calculates the baseline FHR epoch array from smoothed epoch data (ms).
  List<int> _calculateBaseLine(List<int> millisecondsEpochSmooth) {
    int size = millisecondsEpochSmooth.length;
    if (size == 0) return [];

    List<int> baselineArray = List.filled(size, 0);

    // --- Mode/Peak Detection ---
    List<int> freq = List.filled(_BASELINE_BUCKETS, 0);
    int validEpochCount = 0;

    for (int epochMs in millisecondsEpochSmooth) {
      if (epochMs > 0 && epochMs < _BASELINE_BUCKETS) {
        freq[epochMs]++;
        validEpochCount++;
      } else if (epochMs >= _BASELINE_BUCKETS) {
        freq[_BASELINE_BUCKETS - 1]++; // Add to last bucket if too large
        validEpochCount++;
      }
      // Ignore epochMs == 0
    }

    if (validEpochCount == 0) return List.filled(size, 0); // No valid data

    int modeIndex = 0;
    int modeValue = 0;
    for (int i = 1; i < _BASELINE_BUCKETS; i++) { // Start from 1 to ignore freq[0] potentially
      if (freq[i] > modeValue) {
        modeValue = freq[i];
        modeIndex = i;
      }
    }

    // Find limiting peak (scan from high ms down)
    int selectedPeak = 0;
    int sumOfValues = 0;
    double limitingFraction = _BASELINE_MODE_LIMIT_FRACTION * validEpochCount;
    double peakMinFraction = _BASELINE_PEAK_MIN_FRACTION * validEpochCount;

    for (int i = _BASELINE_BUCKETS - 1; i >= 5; i--) { // Need i-5, so stop at 5
      sumOfValues += freq[i];
      // Check if sum exceeds threshold AND if current bin is a local peak
      if (sumOfValues > limitingFraction) {
        bool isLocalPeak = freq[i] >= freq[i - 1] && freq[i] >= freq[i - 2] &&
            freq[i] >= freq[i - 3] && freq[i] >= freq[i - 4] &&
            freq[i] >= freq[i - 5];

        if (isLocalPeak) {
          // Check significance or proximity to mode
          if (freq[i] > peakMinFraction || (modeIndex - i).abs() <= _BASELINE_PEAK_MODE_DISTANCE_THRESHOLD) {
            selectedPeak = i;
            break;
          }
        }
      }
    }

    // If no peak found, use the mode
    if (selectedPeak == 0) selectedPeak = modeIndex;
    if (selectedPeak == 0 && validEpochCount > 0) {
      // Fallback if mode/peak detection failed but there's data: calculate simple average ms
      int totalMs = 0;
      int count = 0;
      for(int ms in millisecondsEpochSmooth) {
        if (ms > 0) {
          totalMs += ms;
          count++;
        }
      }
      selectedPeak = count > 0 ? (totalMs / count).round() : 400; // Default ~150bpm if avg fails
      debugPrint("Baseline Warning: Mode/Peak detection failed, using average ms: $selectedPeak");
    }


    // --- Filtering and Smoothing ---
    baselineArray[0] = millisecondsEpochSmooth[0] > 0 ? millisecondsEpochSmooth[0] : selectedPeak; // Initialize first point

    // Apply band filter based on selectedPeak
    for (int i = 0; i < size; i++) { // Iterate through all including index 0
      int currentEpochMs = millisecondsEpochSmooth[i];
      if (currentEpochMs <= 0) {
        // If current epoch is invalid, use the previous baseline value or selectedPeak
        baselineArray[i] = (i > 0) ? baselineArray[i-1] : selectedPeak;
        continue;
      }

      if (currentEpochMs >= selectedPeak + _BASELINE_FILTER_BAND_MS) {
        baselineArray[i] = selectedPeak + _BASELINE_FILTER_BAND_MS;
      } else if (currentEpochMs <= selectedPeak - _BASELINE_FILTER_BAND_MS) {
        baselineArray[i] = selectedPeak - _BASELINE_FILTER_BAND_MS;
      } else {
        baselineArray[i] = currentEpochMs; // Within the wide band
      }
    }

    // Apply inner band filter and interpolation (Iterate again based on the first pass)
    List<int> tempBaseline = List.from(baselineArray); // Work on a copy
    for (int i = 1; i < size; i++) { // Start from 1 as we use previous value
      if (tempBaseline[i] == 0){ // Should have been handled above, but check again
        tempBaseline[i] = tempBaseline[i-1];
        continue;
      }
      // Check if value is outside the *inner* band
      if (tempBaseline[i] < (selectedPeak - _BASELINE_FILTER_BAND_MS_INNER) ||
          tempBaseline[i] > (selectedPeak + _BASELINE_FILTER_BAND_MS_INNER))
      {
        // If outside inner band, replace with the *previous* baseline value
        tempBaseline[i] = tempBaseline[i - 1];
      }
      // else: Keep the value if it's within the inner band
    }
    if (size > 0) tempBaseline[0] = tempBaseline.length > 1 ? tempBaseline[1] : selectedPeak; // Ensure first element is reasonable
    baselineArray = tempBaseline;


    // Smoothing pass 1 (towards selectedPeak)
    if (size > 1) {
      for (int i = 0; i < size - 1; i++) {
        baselineArray[i + 1] = (_BASELINE_SMOOTHING_A_TINY * baselineArray[i + 1] + (1.0 - _BASELINE_SMOOTHING_A_TINY) * selectedPeak).round();
      }
    }

    // Smoothing pass 2 (window average)
    int window = _BASELINE_WINDOW_SMOOTHING_WINDOW;
    if (size > window * 2) {
      List<int> tempSmoothed = List.from(baselineArray);
      for (int i = window; i < size - window; i++) {
        tempSmoothed[i] = _getBaselineWindowSmoothAverage(baselineArray, i, window);
      }
      baselineArray = tempSmoothed;
    }

    // Smoothing pass 3 (towards average HR, potentially low variation average)
    int avgHR_ms = _calculateAvgHeartRateMs(baselineArray); // Calculate average in MS
    if (avgHR_ms == 0) avgHR_ms = selectedPeak; // Fallback

    // Optional: Refine avgHR_ms based on low variation periods (original logic)
    // int lowVarAvgHR_ms = _calculateLowVariationAvgMs(baselineArray, avgHR_ms);
    // avgHR_ms = (lowVarAvgHR_ms > 0) ? lowVarAvgHR_ms : avgHR_ms; // Use low var avg if valid

    // Final smooth towards the calculated average HR (in ms)
    if (size > 1) {
      for (int i = 0; i < size - 1; i++) {
        // Apply smoothing using _BASELINE_FINAL_SMOOTHING_TINY
        baselineArray[i + 1] = (_BASELINE_FINAL_SMOOTHING_TINY * avgHR_ms + (1.0 - _BASELINE_FINAL_SMOOTHING_TINY) * baselineArray[i + 1]).round();
      }
      // Smooth the beginning part as well
      for (int i = 0; i < min(window * 2, size - 1); i++) {
        baselineArray[i] = (_BASELINE_FINAL_SMOOTHING_TINY * avgHR_ms + (1.0 - _BASELINE_FINAL_SMOOTHING_TINY) * baselineArray[i+1]).round();
      }
    }

    return baselineArray;
  }

  /// Window averaging specifically for baseline (ms), handling jumps differently.
  int _getBaselineWindowSmoothAverage(List<int> list, int index, int window) {
    int start = max(0, index - window);
    int stop = min(list.length - 1, index + window);
    if (start >= stop) return list[index];

    int sum = 0;
    int count = 0;
    for (int i = start; i <= stop; i++) {
      if (list[i] > 0) {
        // Check for large jumps relative to the center point (index) for baseline smoothing
        if ((list[i] - list[index]).abs() <= 30) { // Only average values close to the center
          sum += list[i];
          count++;
        }
      }
    }
    // Include the center point itself if it was initially excluded but is valid
    if (count == 0 && list[index] > 0) {
      return list[index];
    }

    return (count > 0) ? (sum / count).round() : list[index]; // Fallback to original if no valid points in window
  }


  // --- Helper Methods: Event Detection (Accelerations/Decelerations) ---

  /// Calculates the number and location of accelerations.
  /// Updates `_accelerationsList`.
  int _calculateAccelerations() {
    _accelerationsList = []; // Clear previous results
    int n = 0;
    int size = _millisecondsEpochBpm.length;
    if (size == 0 || _baselineEpochBpm.length != size) return 0;

    int counter = 0; // Counts consecutive samples above baseline
    int maxExcursion = 0; // Max BPM difference within the potential acceleration
    int startIndex = -1; // Start index of the current potential acceleration

    // Define thresholds based on gestational age
    final bool isEarlyGestAge = _gestAgeWeeks < 32;
    final int minDurationSamples = ((isEarlyGestAge ? _ACCEL_MIN_DURATION_S_LT32 : _ACCEL_MIN_DURATION_S_GE32) / (_FACTOR)).round(); // Duration in epochs
    final int minPeakBpm = (isEarlyGestAge ? _ACCEL_MIN_PEAK_BPM_LT32 : _ACCEL_MIN_PEAK_BPM_GE32);

    for (int i = 0; i < size; i++) {
      // Ensure both data points are valid
      if (_millisecondsEpochBpm[i] <= 0 || _baselineEpochBpm[i] <= 0) {
        // End of a potential acceleration if criteria met
        if (counter >= minDurationSamples && maxExcursion >= minPeakBpm && startIndex != -1) {
          _accelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: i * _FACTOR));
          n++;
        }
        // Reset tracking
        counter = 0;
        maxExcursion = 0;
        startIndex = -1;
        continue;
      }

      int difference = _millisecondsEpochBpm[i] - _baselineEpochBpm[i];

      if (difference >= _ACCEL_MIN_DIFF_BPM) { // Sample is above baseline
        if (counter == 0) {
          startIndex = i; // Mark start of potential acceleration
        }
        counter++;
        if (difference > maxExcursion) {
          maxExcursion = difference;
        }
      } else { // Sample is not above baseline (or not sufficiently)
        // Check if the *previous* segment met acceleration criteria
        if (counter >= minDurationSamples && maxExcursion >= minPeakBpm && startIndex != -1) {
          _accelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: i * _FACTOR)); // End index is current 'i'
          n++;
        }
        // Reset tracking
        counter = 0;
        maxExcursion = 0;
        startIndex = -1;
      }
    }

    // Check for an acceleration ending at the very end of the trace
    if (counter >= minDurationSamples && maxExcursion >= minPeakBpm && startIndex != -1) {
      _accelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: size * _FACTOR));
      n++;
    }

    return n;
  }


  /// Calculates the number and location of decelerations.
  /// Updates `_decelerationsList`.
  int _calculateDecelerations() {
    _decelerationsList = []; // Clear previous results
    int n = 0;
    int size = _millisecondsEpochBpm.length;
    if (size == 0 || _baselineEpochBpm.length != size) return 0;

    int counter = 0; // Counts consecutive samples below baseline
    int maxExcursion = 0; // Max BPM drop within the potential deceleration
    int startIndex = -1; // Start index of the potential deceleration

    // Convert duration thresholds to samples (epochs)
    final int durationSamples1 = (_DECEL_DURATION_THRESHOLD_S_1 / _FACTOR).round(); // ~4 epochs for 15s
    final int durationSamples2 = (_DECEL_DURATION_THRESHOLD_S_2 / _FACTOR).round(); // ~15 epochs for 60s


    for (int i = 0; i < size; i++) {
      // Ensure both data points are valid
      if (_millisecondsEpochBpm[i] <= 0 || _baselineEpochBpm[i] <= 0) {
        // End of a potential deceleration if criteria met
        if (startIndex != -1) {
          bool meetsCriteria1 = (counter >= durationSamples1 && maxExcursion >= _DECEL_BPM_THRESHOLD_1);
          bool meetsCriteria2 = (counter >= durationSamples2 && maxExcursion >= _DECEL_BPM_THRESHOLD_2);
          if (meetsCriteria1 || meetsCriteria2) {
            _decelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: i * _FACTOR));
            n++;
          }
        }
        // Reset tracking
        counter = 0;
        maxExcursion = 0;
        startIndex = -1;
        continue;
      }

      int difference = _baselineEpochBpm[i] - _millisecondsEpochBpm[i]; // Positive value indicates drop

      if (difference > _DECEL_MIN_DIFF_BPM) { // Sample is below baseline
        if (counter == 0) {
          startIndex = i; // Mark start of potential deceleration
        }
        counter++;
        if (difference > maxExcursion) {
          maxExcursion = difference;
        }
      } else { // Sample is not below baseline (or not sufficiently)
        // Check if the *previous* segment met deceleration criteria
        if (startIndex != -1) {
          // Check both criteria: (duration >= 15s AND drop >= 15bpm) OR (duration >= 60s AND drop >= 10bpm)
          bool meetsCriteria1 = (counter >= durationSamples1 && maxExcursion >= _DECEL_BPM_THRESHOLD_1);
          bool meetsCriteria2 = (counter >= durationSamples2 && maxExcursion >= _DECEL_BPM_THRESHOLD_2);

          if (meetsCriteria1 || meetsCriteria2) {
            _decelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: i * _FACTOR)); // End index is current 'i'
            n++;
          }
        }
        // Reset tracking
        counter = 0;
        maxExcursion = 0;
        startIndex = -1;
      }
    }

    // Check for a deceleration ending at the very end of the trace
    if (startIndex != -1) {
      bool meetsCriteria1 = (counter >= durationSamples1 && maxExcursion >= _DECEL_BPM_THRESHOLD_1);
      bool meetsCriteria2 = (counter >= durationSamples2 && maxExcursion >= _DECEL_BPM_THRESHOLD_2);
      if (meetsCriteria1 || meetsCriteria2) {
        _decelerationsList.add(MarkerIndices.from(from: startIndex * _FACTOR, to: size * _FACTOR));
        n++;
      }
    }
    // Debug print statement from original code, adapted:
    /* if (maxExcursion >= 10 && counter > 0) {
        debugPrint("Potential Decel near end: counter=$counter epochs, maxDrop=$maxExcursion bpm, endEpoch=${size -1}");
     }*/

    return n;
  }

  /// Removes minutes containing decelerations from the 'clean' data lists.
  /// Modifies `_clean*` lists.
  void _removeDecelerationMinutes() {
    if (_decelerationsList.isEmpty) return; // No decelerations to remove

    int epochsPerMinute = _NO_OF_SAMPLES_PER_MINUTE; // e.g., 15
    int totalEpochs = _millisecondsEpoch.length;
    int totalMinutes = (totalEpochs / epochsPerMinute).ceil();

    Set<int> minutesToRemove = {};

    // Identify minutes affected by decelerations
    for (MarkerIndices decel in _decelerationsList) {
      int fromEpoch = ((decel.getFrom() ?? 0) / _FACTOR).floor();
      int toEpoch = ((decel.getTo() ?? 0) / _FACTOR).ceil(); // Use ceil to include end epoch

      int startMinute = (fromEpoch / epochsPerMinute).floor();
      int endMinute = (toEpoch / epochsPerMinute).floor(); // Minute containing the end epoch

      for (int minIdx = startMinute; minIdx <= endMinute; minIdx++) {
        if (minIdx < totalMinutes) {
          minutesToRemove.add(minIdx);
        }
      }
    }

    if (minutesToRemove.isEmpty) return;


    // Create new lists excluding the identified minutes
    List<int> newCleanMsEpoch = [];
    List<int> newCleanMsEpochBpm = [];
    List<int> newCleanBaselineEpoch = [];
    List<int> newCleanBaselineEpochBpm = [];

    for (int minIdx = 0; minIdx < totalMinutes; minIdx++) {
      if (!minutesToRemove.contains(minIdx)) {
        int startEpoch = minIdx * epochsPerMinute;
        int endEpoch = min((minIdx + 1) * epochsPerMinute, totalEpochs);

        for (int i = startEpoch; i < endEpoch; i++) {
          // Check bounds just in case original lists are shorter
          if (i < _millisecondsEpoch.length) newCleanMsEpoch.add(_millisecondsEpoch[i]);
          if (i < _millisecondsEpochBpm.length) newCleanMsEpochBpm.add(_millisecondsEpochBpm[i]);
          if (i < _baselineEpoch.length) newCleanBaselineEpoch.add(_baselineEpoch[i]);
          if (i < _baselineEpochBpm.length) newCleanBaselineEpochBpm.add(_baselineEpochBpm[i]);
        }
      }
    }

    // Update the instance variables
    _cleanMillisecondsEpoch = newCleanMsEpoch;
    _cleanMillisecondsEpochBpm = newCleanMsEpochBpm;
    _cleanBaselineEpoch = newCleanBaselineEpoch;
    _cleanBaselineEpochBpm = newCleanBaselineEpochBpm;

    debugPrint("Removed ${minutesToRemove.length} minute(s) containing decelerations. Clean data size: ${_cleanMillisecondsEpoch.length} epochs.");
  }


  // --- Helper Methods: Variability and Basal Rate Calculation ---

  /// Calculates the average heart rate in milliseconds from a list of epoch ms values.
  int _calculateAvgHeartRateMs(List<int> list) {
    if (list.isEmpty) return 0;

    int sum = 0;
    int count = 0;
    for (int val in list) {
      if (val > 0) { // Only count valid (non-zero) ms values
        sum += val;
        count++;
      }
    }
    return (count > 0) ? (sum / count).round() : 0;
  }


  /// Calculates the final Basal Heart Rate (BPM) from the cleaned baseline epoch BPM data.
  int _calculateBasalHeartRate(List<int> cleanBaselineEpochBpm) {
    if (cleanBaselineEpochBpm.isEmpty) return 0;

    double sum = 0;
    int count = 0;
    for (int bpm in cleanBaselineEpochBpm) {
      // Use a reasonable range for baseline calculation
      if (bpm >= _MIN_VALID_BPM && bpm <= _MAX_VALID_BPM) {
        sum += bpm;
        count++;
      }
    }

    if (count == 0) return 0; // No valid data points

    double averageBpm = sum / count;

    // Round to the nearest 5 BPM
    int roundedBpm = ((averageBpm / 5).round() * 5);

    return roundedBpm;
  }


  /// Calculates Short Term Variability (STV) in BPM and Milliseconds.
  /// Uses the `_clean*` lists. Updates `_shortTermVariation*` fields.
  void _calculateShortTermVariability() {
    if (_cleanMillisecondsEpoch.length < 2) {
      _shortTermVariationBpm = 0.0;
      _shortTermVariationMilli = 0;
      return;
    }

    double sumDiffBpm = 0;
    int sumDiffMilli = 0;
    int validPairs = 0;

    for (int i = 1; i < _cleanMillisecondsEpoch.length; i++) {
      // Ensure both consecutive points are valid for difference calculation
      if (_cleanMillisecondsEpochBpm[i-1] > 0 && _cleanMillisecondsEpochBpm[i] > 0 &&
          _cleanMillisecondsEpoch[i-1] > 0 && _cleanMillisecondsEpoch[i] > 0)
      {
        sumDiffBpm += (_cleanMillisecondsEpochBpm[i - 1] - _cleanMillisecondsEpochBpm[i]).abs();
        sumDiffMilli += (_cleanMillisecondsEpoch[i - 1] - _cleanMillisecondsEpoch[i]).abs();
        validPairs++;
      }
    }

    if (validPairs > 0) {
      _shortTermVariationBpm = sumDiffBpm / validPairs;
      _shortTermVariationMilli = (sumDiffMilli / validPairs).round();
    } else {
      _shortTermVariationBpm = 0.0;
      _shortTermVariationMilli = 0;
    }
  }


  /// Calculates Long Term Variability (LTV) and analyzes episodes of low/high variation.
  /// Uses the `_clean*` lists. Updates `_longTermVariation`.
  void _calculateEpisodesOfLowAndHighVariation() {
    int epochsPerMinute = _NO_OF_SAMPLES_PER_MINUTE;
    int totalCleanEpochs = _cleanBaselineEpochBpm.length;
    int totalMinutes = (totalCleanEpochs / epochsPerMinute).floor(); // Use floor for full minutes

    if (totalMinutes == 0) {
      _longTermVariation = 0;
      // high/low episode counts remain 0
      return;
    }

    List<int> minuteRanges = List.filled(totalMinutes, 0);
    int validMinutesCount = 0;
    int totalRangeSum = 0;

    // Calculate BPM range (max-min difference from baseline) for each minute
    for (int minIdx = 0; minIdx < totalMinutes; minIdx++) {
      int maxDiff = 0; // Max deviation above baseline
      int minDiff = 0; // Max deviation below baseline (most negative difference)
      int startEpoch = minIdx * epochsPerMinute;
      int endEpoch = startEpoch + epochsPerMinute; // Exclusive end
      bool minuteIsValid = false;

      for (int i = startEpoch; i < endEpoch; i++) {
        // Ensure index is within bounds and data is valid
        if (i < _cleanMillisecondsEpochBpm.length &&
            i < _cleanBaselineEpochBpm.length &&
            _cleanMillisecondsEpochBpm[i] > 0 &&
            _cleanBaselineEpochBpm[i] > 0)
        {
          // Exclude extreme outliers from range calculation?
          if (_cleanMillisecondsEpochBpm[i] < _cleanBaselineEpochBpm[i] - 50 || // Big drop
              _cleanMillisecondsEpochBpm[i] > _cleanBaselineEpochBpm[i] + 50)   // Big rise
              {
            continue; // Skip this point for range calculation
          }

          int diff = _cleanMillisecondsEpochBpm[i] - _cleanBaselineEpochBpm[i];
          if (diff > maxDiff) maxDiff = diff;
          if (diff < minDiff) minDiff = diff;
          minuteIsValid = true; // Mark minute as having at least one valid comparison
        }
      }

      if (minuteIsValid) {
        minuteRanges[minIdx] = maxDiff + minDiff.abs(); // Total range for the minute
        totalRangeSum += minuteRanges[minIdx];
        validMinutesCount++;
      } else {
        minuteRanges[minIdx] = -1; // Mark minute as invalid (e.g., all noise/missing)
      }
    }

    // Calculate overall Long Term Variation (average minute range)
    if (validMinutesCount > 0) {
      _longTermVariation = (totalRangeSum / validMinutesCount).round();
    } else {
      _longTermVariation = 0;
    }

    // --- Episode Analysis (Low/High Variation) ---
    // This part seems complex and potentially requires careful clinical validation.
    // The original code's logic for identifying episodes is kept but commented.
    // It calculates counts but doesn't seem to use them further in this snippet.
    /*
      int highEpisodes = 0, lowEpisodes = 0;
      double meanHighEpisodeBpmSum = 0; // Sum of mean ranges for high episodes

      if (totalMinutes >= _VARIATION_EPISODE_MINUTES) {
          for (int i = 0; i <= totalMinutes - _VARIATION_EPISODE_MINUTES; i++) {
              double episodeSum = 0;
              int validSegmentsInEpisode = 0;
              for (int j = i; j < i + _VARIATION_EPISODE_MINUTES; j++) {
                  if (minuteRanges[j] >= 0) { // Only consider valid minutes
                       episodeSum += minuteRanges[j];
                       validSegmentsInEpisode++;
                  }
              }

              if (validSegmentsInEpisode < _VARIATION_EPISODE_MIN_SEGMENTS) continue; // Skip if not enough valid data in window

              double meanMinuteRange = episodeSum / validSegmentsInEpisode;
              int howManyLow = 0;
              int howManyHigh = 0;

              // Check individual minutes within the episode against the episode's mean
              for (int j = i; j < i + _VARIATION_EPISODE_MINUTES; j++) {
                   if (minuteRanges[j] >= 0) { // Check only valid minutes
                       // This condition seems odd: (mean * N - current) / (N-1)
                       // Let's simplify the check: is the current minute's range low/high?
                       if (minuteRanges[j] <= _LOW_VARIATION_THRESHOLD_LTV) { // Using a direct threshold might be clearer
                           howManyLow++;
                       }
                       if (minuteRanges[j] >= _HIGH_VARIATION_THRESHOLD_LTV) {
                           howManyHigh++;
                       }
                   }
              }

              if (howManyLow >= _VARIATION_EPISODE_MIN_SEGMENTS) {
                  lowEpisodes++;
              }

              if (howManyHigh >= _VARIATION_EPISODE_MIN_SEGMENTS) {
                  // Original code had complex percentile check for high episodes based on GA
                  bool confirmedHighEpisode = true; // Assume high unless proven otherwise by percentile check
                  if (_gestAgeWeeks >= 26) { // Check only if GA allows lookup
                      int percentileIndex = _gestAgeWeeks - 26;
                      if (percentileIndex < _highFHREpisodePercentiles.length) {
                           double thirdPercentile = _highFHREpisodePercentiles[percentileIndex][1];
                           if (meanMinuteRange < thirdPercentile) {
                                confirmedHighEpisode = false; // Below 3rd percentile, reject this high episode
                           }
                      }
                  }

                  if (confirmedHighEpisode) {
                      highEpisodes++;
                      meanHighEpisodeBpmSum += meanMinuteRange;
                  }
              }
          }
      }
      // 'lengthOfHighFHREpisodes' and 'lengthOfLowFHREpisodes' are now `highEpisodes` and `lowEpisodes`
      // These counts are calculated but not stored in the InterpretationResult currently.
      // debugPrint("Low Var Episodes: $lowEpisodes, High Var Episodes: $highEpisodes");
      */
  }


  // --- Helper Methods: Fisher Score ---

  /// Calculates the Fisher score based on computed parameters.
  void _calculateFisherScore() {
    int score = 0;
    int baselineScore = 0;
    int variabilityScore = 0; // LTV Bandwidth Score
    int stvScore = 0; // STV Score (Zero Crossings approximation)
    int accelScore = 0;
    int decelScore = 0;

    // --- 1. Baseline Score ---
    if (_basalHeartRate < 100 || _basalHeartRate > 180) {
      baselineScore = 0;
    } else if ((_basalHeartRate >= 100 && _basalHeartRate <= 110) || (_basalHeartRate > 160 && _basalHeartRate <= 180)) {
      baselineScore = 1;
    } else { // 111 - 160
      baselineScore = 2;
    }
    score += baselineScore;

    // --- 2. Variability (Bandwidth - LTV) Score ---
    // Original code calculated minMaxDiff strangely after first accel.
    // Standard Fisher uses LTV (Bandwidth). Using _longTermVariation calculated earlier.
    int bandwidth = _longTermVariation;
    if (bandwidth < 5) {
      variabilityScore = 0;
    } else if ((bandwidth >= 5 && bandwidth <= 10) || bandwidth > 25) { // Modified Dawes/Redman uses >25 for 1pt
      variabilityScore = 1;
    } else { // 11 - 25
      variabilityScore = 2;
    }
    score += variabilityScore;


    // --- 3. Short Term Variability (Approximated by Zero Crossings) Score ---
    // Calculate zero crossings between baseline and raw signal *per minute*?
    // Original code counts total crossings. Let's stick to that for replicating.
    int zeroCrossings = 0;
    if (_baselineBpmList.length == _bpmList.length) { // Ensure lists are comparable
      // Check crossings around the baseline
      bool wasAbove = false;
      bool initialised = false;
      for(int i = 0; i < _baselineBpmList.length; i++) {
        if (_baselineBpmList[i] > 0 && _bpmList[i] > 0) { // Only compare valid points
          bool isAbove = _bpmList[i] >= _baselineBpmList[i]; // >= to handle exact match consistently
          if (!initialised) {
            wasAbove = isAbove;
            initialised = true;
          } else {
            if (isAbove != wasAbove) {
              zeroCrossings++;
              wasAbove = isAbove; // Update state
            }
          }
        } else {
          initialised = false; // Reset if there's a gap in valid data
        }
      }
    } else {
      debugPrint("Fisher Score Warning: Baseline and BPM list lengths differ, cannot calculate zero crossings.");
    }

    // Convert total crossings to crossings per minute for scoring (approx)
    int durationMinutes = (_bpmList.length / (_FACTOR * _NO_OF_SAMPLES_PER_MINUTE)).floor();
    int crossingsPerMinute = (durationMinutes > 0) ? (zeroCrossings / durationMinutes).round() : 0;

    if (crossingsPerMinute < 2) { // Changed thresholds based on common Fisher score descriptions (crossings/min)
      stvScore = 0;
    } else if (crossingsPerMinute <= 6) { // 2-6 crossings/min
      stvScore = 1;
    } else { // > 6 crossings/min
      stvScore = 2;
    }
    score += stvScore;

    // --- 4. Accelerations Score ---
    // Score based on *total* number of accelerations detected.
    if (_nAccelerations == 0) {
      accelScore = 0;
    } else if (_nAccelerations <= 4) { // 1-4 accelerations
      accelScore = 1; // Original code had 1 point for 1-4
    } else { // > 4 accelerations
      accelScore = 2;
    }
    // Note: Some Fisher versions require >=2 accels in 20min for full points. This is simpler.
    score += accelScore;


    // --- 5. Decelerations Score ---
    // Score based on *total* number of decelerations.
    // Type of deceleration is often considered, but this seems based only on count.
    if (_nDecelerations == 0) {
      decelScore = 2; // No decelerations gets full points
    } else if (_nDecelerations == 1) {
      decelScore = 1; // One deceleration
    } else { // >= 2 decelerations
      decelScore = 0;
    }
    score += decelScore;

    // --- Store Results ---
    _fisherScore = score;
    _fisherScoreDetails = {
      "score": _fisherScore,
      "baseline": _basalHeartRate,
      "baselineScore": baselineScore,
      "bandwidth (LTV)": bandwidth,
      "variabilityScore": variabilityScore,
      "zeroCrossingsTotal": zeroCrossings,
      "zeroCrossingsPerMin": crossingsPerMinute,
      "stvScore": stvScore,
      "accelerations": _nAccelerations,
      "accelScore": accelScore,
      "decelerations": _nDecelerations,
      "decelScore": decelScore,
    };
  }

}