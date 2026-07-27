import 'weighted_value.dart';

enum RandomDrawTrack { personal, club, nationalTeam }

enum DrawProbabilityKind { official, calibrated, modeled }

class RandomDrawStep {
  const RandomDrawStep({
    required this.id,
    required this.track,
    required this.titleZh,
    required this.titleEn,
    required this.categoryZh,
    required this.categoryEn,
    required this.resultZh,
    required this.resultEn,
    required this.segments,
    required this.selectedSegment,
    required this.probabilityKind,
    required this.sourceNoteZh,
    required this.sourceNoteEn,
    this.age,
  });

  final String id;
  final RandomDrawTrack track;
  final int? age;
  final String titleZh;
  final String titleEn;
  final String categoryZh;
  final String categoryEn;
  final String resultZh;
  final String resultEn;
  final List<WeightedValue<String>> segments;
  final String selectedSegment;
  final DrawProbabilityKind probabilityKind;
  final String sourceNoteZh;
  final String sourceNoteEn;

  int get totalWeight =>
      segments.fold<int>(0, (sum, segment) => sum + segment.weight);

  int get selectedWeight {
    for (final segment in segments) {
      if (segment.value == selectedSegment) return segment.weight;
    }
    return 0;
  }

  double get selectedProbability {
    if (totalWeight == 0) return 0;
    return selectedWeight / totalWeight;
  }
}
