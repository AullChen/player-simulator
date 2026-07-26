import 'dart:math';

import '../data/football_catalog.dart';
import '../domain/player_profile.dart';
import '../domain/weighted_value.dart';

class RandomCareerGenerator {
  RandomCareerGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  PlayerProfile generate() {
    final nationality = FootballCatalog.nationalities.pick(_random);
    final position = FootballCatalog.positions.pick(_random);
    final preferredFoot = FootballCatalog.preferredFeet.pick(_random);
    final academyTier = FootballCatalog.academyTiers.pick(_random);
    final debutAge = 16 + _random.nextInt(6);
    final retirementAge = 33 + _random.nextInt(8);
    final initialRating = _initialRating(academyTier);
    final peakRating = _peakRating(initialRating);
    final finalRating = max(52, peakRating - 8 - _random.nextInt(15));
    final transferCount = FootballCatalog.transferCounts.pick(_random);
    final heightCm = _heightFor(position);
    final academyPool = FootballCatalog.academies[academyTier]!;
    final academy = academyPool[_random.nextInt(academyPool.length)];
    final chapters = _careerChapters(
      debutAge: debutAge,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      transferCount: transferCount,
    );
    final stats = _careerStats(
      position: position,
      peakRating: peakRating,
      careerLength: retirementAge - debutAge,
      transferCount: transferCount,
    );

    return PlayerProfile(
      mode: CareerMode.random,
      name: '无名新星 ${100 + _random.nextInt(900)}',
      nationality: nationality,
      preferredFoot: preferredFoot,
      heightCm: heightCm,
      primaryPosition: position,
      secondaryPosition: _pick(FootballCatalog.secondaryPositions[position]!),
      academy: academy,
      debutAge: debutAge,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: finalRating,
      playStyle: _pick(FootballCatalog.positionStyles[position]!),
      injuryRecord: FootballCatalog.injuryRecords.pick(_random),
      career: chapters,
      stats: stats,
    );
  }

  int _initialRating(int academyTier) {
    final base = switch (academyTier) {
      1 => 62,
      2 => 59,
      3 => 55,
      _ => 51,
    };
    return base + _random.nextInt(9);
  }

  int _peakRating(int initialRating) {
    final roll = _random.nextInt(100);
    final growth = switch (roll) {
      < 2 => 27 + _random.nextInt(5),
      < 12 => 20 + _random.nextInt(7),
      < 42 => 13 + _random.nextInt(8),
      < 82 => 7 + _random.nextInt(7),
      _ => 2 + _random.nextInt(6),
    };
    return min(96, initialRating + growth);
  }

  int _heightFor(String position) {
    final (minHeight, spread) = switch (position) {
      '门将' => (184, 17),
      '中后卫' => (180, 17),
      '中锋' => (175, 22),
      '边锋' => (165, 22),
      _ => (168, 23),
    };
    return minHeight + _random.nextInt(spread);
  }

  List<CareerChapter> _careerChapters({
    required int debutAge,
    required int retirementAge,
    required int initialRating,
    required int peakRating,
    required int transferCount,
  }) {
    final chapterCount = transferCount + 1;
    final careerLength = retirementAge - debutAge;
    final clubs = <ClubDefinition>[];
    for (var index = 0; index < chapterCount; index++) {
      final progress = chapterCount == 1 ? 0.5 : index / (chapterCount - 1);
      final preferredLevel = progress < 0.3
          ? 4
          : progress < 0.7
          ? (peakRating >= 80 ? 2 : 3)
          : (peakRating >= 85 ? 1 : 2);
      final candidates = FootballCatalog.clubs
          .where((club) => club.level == preferredLevel)
          .where((club) => !clubs.any((used) => used.name == club.name))
          .toList();
      final pool = candidates.isEmpty ? FootballCatalog.clubs : candidates;
      clubs.add(pool[_random.nextInt(pool.length)]);
    }

    return List.generate(chapterCount, (index) {
      final fraction = index / chapterCount;
      final age = debutAge + (careerLength * fraction).round();
      final progress = (age - debutAge) / max(1, careerLength);
      final rating = progress <= 0.55
          ? initialRating +
                ((peakRating - initialRating) * (progress / 0.55)).round()
          : peakRating -
                ((peakRating - 58) * ((progress - 0.55) / 0.45)).round();
      final event = index == 0
          ? '完成职业首秀'
          : index == chapterCount - 1
          ? '迎来生涯最后一站'
          : '以新的合同开启挑战';
      return CareerChapter(
        age: age,
        club: clubs[index].name,
        event: event,
        rating: rating.clamp(48, 96),
      );
    });
  }

  CareerStats _careerStats({
    required String position,
    required int peakRating,
    required int careerLength,
    required int transferCount,
  }) {
    final qualityFactor = (peakRating - 50) / 46;
    final appearances = max(
      35,
      (careerLength * (18 + qualityFactor * 18 + _random.nextInt(8))).round(),
    );
    final scoringRate = switch (position) {
      '门将' => 0.001,
      '中后卫' => 0.04,
      '边后卫' => 0.06,
      '后腰' => 0.07,
      '中前卫' => 0.12,
      '前腰' => 0.18,
      '边锋' => 0.24,
      '中锋' => 0.38,
      _ => 0.1,
    };
    final assistRate = switch (position) {
      '门将' => 0.005,
      '中后卫' => 0.02,
      '边后卫' => 0.11,
      '后腰' => 0.08,
      '中前卫' => 0.16,
      '前腰' => 0.22,
      '边锋' => 0.2,
      '中锋' => 0.09,
      _ => 0.1,
    };
    final nationalCaps = peakRating < 70
        ? _random.nextInt(4)
        : ((peakRating - 67) * (1.2 + _random.nextDouble() * 2.5)).round();
    final championships = _championships(peakRating, careerLength);
    final honors = _personalHonors(peakRating, appearances);

    return CareerStats(
      appearances: appearances,
      goals: (appearances * scoringRate * (0.75 + _random.nextDouble() * 0.5))
          .round(),
      assists: (appearances * assistRate * (0.75 + _random.nextDouble() * 0.5))
          .round(),
      nationalCaps: nationalCaps,
      nationalGoals: (nationalCaps * scoringRate * 0.8).round(),
      transferCount: transferCount,
      totalTransferFeeMillions: double.parse(
        (transferCount * qualityFactor * (8 + _random.nextDouble() * 28))
            .toStringAsFixed(1),
      ),
      championships: championships,
      personalHonors: honors,
    );
  }

  List<String> _championships(int peakRating, int careerLength) {
    final expected = max(0, ((peakRating - 68) / 7).floor());
    final count = min(9, expected + _random.nextInt(3));
    const pool = [
      '国内顶级联赛冠军',
      '国内杯赛冠军',
      '洲际俱乐部赛事冠军',
      '国家队洲际赛事冠军',
      '世界冠军',
      '国内超级杯冠军',
    ];
    return List.generate(
      count,
      (index) => '${pool[_random.nextInt(pool.length)]} ×1',
    );
  }

  List<String> _personalHonors(int peakRating, int appearances) {
    final honors = <String>[];
    if (appearances >= 300) honors.add('俱乐部百场纪念');
    if (peakRating >= 78) honors.add('联赛赛季最佳阵容');
    if (peakRating >= 84) honors.add('年度最佳球员候选');
    if (peakRating >= 89) honors.add('世界年度最佳球员');
    return honors;
  }

  T _pick<T>(List<T> values) => values[_random.nextInt(values.length)];
}
