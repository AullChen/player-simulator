import 'dart:math';

enum PeakRatingBand { elite, established, developmental }

class PeakRatingSample {
  const PeakRatingSample({
    required this.initial,
    required this.peak,
    required this.band,
  });

  final int initial;
  final int peak;
  final PeakRatingBand band;
}

/// Shared game-balanced ability distribution for random and life careers.
abstract final class PeakRatingDistribution {
  static PeakRatingSample sample({
    required Random random,
    required int academyTier,
  }) {
    final base = switch (academyTier) {
      1 => 62,
      2 => 59,
      3 => 55,
      _ => 51,
    };
    final bandRoll = random.nextDouble();
    final band = bandRoll < 0.50
        ? PeakRatingBand.elite
        : bandRoll < 0.90
        ? PeakRatingBand.established
        : PeakRatingBand.developmental;
    final candidates = <({int initial, int peak, double weight})>[];
    for (var initial = base; initial < base + 9; initial++) {
      for (final growthBand in _legacyGrowthBands) {
        for (
          var growth = growthBand.minimum;
          growth < growthBand.minimum + growthBand.count;
          growth++
        ) {
          final peak = min(96, initial + growth);
          if (contains(band, peak)) {
            candidates.add((
              initial: initial,
              peak: peak,
              weight: growthBand.weight / growthBand.count,
            ));
          }
        }
      }
    }
    final totalWeight = candidates.fold<double>(
      0,
      (sum, candidate) => sum + candidate.weight,
    );
    var cursor = random.nextDouble() * totalWeight;
    for (final candidate in candidates) {
      cursor -= candidate.weight;
      if (cursor <= 0) {
        return PeakRatingSample(
          initial: candidate.initial,
          peak: candidate.peak,
          band: band,
        );
      }
    }
    final fallback = candidates.last;
    return PeakRatingSample(
      initial: fallback.initial,
      peak: fallback.peak,
      band: band,
    );
  }

  static bool contains(PeakRatingBand band, int rating) => switch (band) {
    PeakRatingBand.elite => rating >= 80,
    PeakRatingBand.established => rating >= 70 && rating < 80,
    PeakRatingBand.developmental => rating < 70,
  };

  static int minimum(PeakRatingBand band) => switch (band) {
    PeakRatingBand.elite => 80,
    PeakRatingBand.established => 70,
    PeakRatingBand.developmental => 1,
  };

  static int maximum(PeakRatingBand band) => switch (band) {
    PeakRatingBand.elite => 96,
    PeakRatingBand.established => 79,
    PeakRatingBand.developmental => 69,
  };
}

const _legacyGrowthBands = <({int minimum, int count, double weight})>[
  (minimum: 27, count: 5, weight: 2),
  (minimum: 20, count: 7, weight: 10),
  (minimum: 13, count: 8, weight: 30),
  (minimum: 7, count: 7, weight: 40),
  (minimum: 2, count: 6, weight: 18),
];
