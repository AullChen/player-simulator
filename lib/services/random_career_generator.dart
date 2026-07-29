import 'dart:math';

import '../data/football_catalog.dart';
import '../data/probability_sources.dart';
import '../domain/player_profile.dart';
import '../domain/weighted_value.dart';
import 'peak_rating_distribution.dart';

class RandomCareerGenerator {
  RandomCareerGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  PlayerProfile generate() {
    final associationBucket = FootballCatalog.professionalAssociationPopulations
        .pick(_random);
    final developmentAssociation = associationBucket == '其他 FIFA 协会'
        ? _pick(FootballCatalog.otherAssociations)
        : associationBucket;
    final nationalityConfederation = FootballCatalog
        .nationalityConfederationWeights
        .pick(_random);
    final nationality = FootballCatalog
        .nationalitiesByConfederation[nationalityConfederation]!
        .pick(_random);
    final position = FootballCatalog.positions.pick(_random);
    final preferredFoot = FootballCatalog.preferredFeet.pick(_random);
    final academyTier = FootballCatalog.academyTiers.pick(_random);
    final academyEntryAge = 8 + _random.nextInt(8);
    final debutAge = 16 + _random.nextInt(6);
    final retirementAge = 33 + _random.nextInt(8);
    final retirementYear = DateTime.now().year - _random.nextInt(5);
    final birthYear = retirementYear - retirementAge;
    final ratings = sampleRatings(academyTier);
    final initialRating = ratings.initial;
    final peakRating = ratings.peak;
    final finalRating = max(52, peakRating - 8 - _random.nextInt(15));
    final transferCount = FootballCatalog.transferCounts.pick(_random);
    final heightCm = _heightFor(position);
    final weightKg = _weightFor(heightCm, position);
    final academyPool = FootballCatalog.academies[academyTier]!;
    final academy = _pick(academyPool);
    final chapters = _careerChapters(
      debutAge: debutAge,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      transferCount: transferCount,
    );
    final transferHistory = _transferHistory(
      chapters: chapters,
      birthYear: birthYear,
      peakRating: peakRating,
    );
    final totalTransferFee = transferHistory.fold<double>(
      0,
      (sum, transfer) => sum + transfer.feeMillions,
    );
    final stats = _careerStats(
      position: position,
      peakRating: peakRating,
      careerLength: retirementAge - debutAge,
      transferCount: transferCount,
      totalTransferFeeMillions: totalTransferFee,
    );
    final injuryHistory = _injuryHistory(
      birthYear: birthYear,
      debutAge: debutAge,
      retirementAge: retirementAge,
    );
    final marketValueHistory = _marketValueHistory(
      debutAge: debutAge,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
    );
    final competitionStats = _competitionStats(
      stats: stats,
      peakRating: peakRating,
    );
    final lastChapter = chapters.last;
    final nationalDebutAge = 19 + _random.nextInt(7);
    final contractLength = FootballCatalog.contractLengthsYears.pick(_random);
    final lastContractStartAge = max(
      lastChapter.age,
      retirementAge - contractLength,
    );

    return PlayerProfile(
      mode: CareerMode.random,
      name: '无名新星 ${100 + _random.nextInt(900)}',
      birthDate: _randomDate(birthYear),
      birthPlace: _birthPlace(nationality),
      developmentAssociation: developmentAssociation,
      nationality: nationality,
      citizenships: _citizenships(nationality),
      preferredFoot: preferredFoot,
      heightCm: heightCm,
      weightKg: weightKg,
      shirtNumber: _pick(FootballCatalog.squadNumbers[position]!),
      primaryPosition: position,
      secondaryPosition: _pick(FootballCatalog.secondaryPositions[position]!),
      academy: academy,
      academyEntryAge: min(academyEntryAge, debutAge - 1),
      debutAge: debutAge,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: finalRating,
      playStyle: _pick(FootballCatalog.positionStyles[position]!),
      injuryRecord: _injurySummary(injuryHistory),
      currentClub: lastChapter.club,
      currentLeague: _leagueForClub(lastChapter.club, nationality),
      joinedClubDate: '01/07/${birthYear + lastChapter.age}',
      contractStartDate: '01/07/${birthYear + lastContractStartAge}',
      contractUntil: '30/06/${birthYear + retirementAge}',
      agent: _pick(FootballCatalog.agents),
      marketValueMillions: marketValueHistory.fold<double>(
        0,
        (highest, point) => max(highest, point.valueMillions),
      ),
      nationalTeam: stats.nationalCaps == 0 ? '未入选成年国家队' : '$nationality国家队',
      nationalTeamDebut: stats.nationalCaps == 0
          ? '未记录'
          : _randomDate(birthYear + nationalDebutAge),
      career: chapters,
      transferHistory: transferHistory,
      injuryHistory: injuryHistory,
      marketValueHistory: marketValueHistory,
      competitionStats: competitionStats,
      stats: stats,
    );
  }

  /// Samples the initial/peak pair used by the ability wheels.
  ///
  /// Peak bands are game-balanced first; the legacy development curve remains
  /// the conditional distribution within the selected band.
  ({int initial, int peak}) sampleRatings(int academyTier) {
    final sample = PeakRatingDistribution.sample(
      random: _random,
      academyTier: academyTier,
    );
    return (initial: sample.initial, peak: sample.peak);
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

  int _weightFor(int heightCm, String position) {
    final heightMetres = heightCm / 100;
    final baseBmi = position == '门将' || position == '中后卫' ? 23.2 : 22.1;
    final bmi = baseBmi + (_random.nextDouble() - 0.5) * 2.2;
    return (heightMetres * heightMetres * bmi).round();
  }

  List<CareerChapter> _careerChapters({
    required int debutAge,
    required int retirementAge,
    required int initialRating,
    required int peakRating,
    required int transferCount,
  }) {
    final chapterAges = [
      debutAge,
      ..._transferAges(
        debutAge: debutAge,
        retirementAge: retirementAge,
        count: transferCount,
      ),
    ];
    final clubs = <ClubDefinition>[];
    for (var index = 0; index < chapterAges.length; index++) {
      final progress = chapterAges.length == 1
          ? 0.5
          : index / (chapterAges.length - 1);
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
      clubs.add(_pick(pool));
    }

    return List.generate(chapterAges.length, (index) {
      final age = chapterAges[index];
      final rating = _ratingAtAge(
        age: age,
        debutAge: debutAge,
        retirementAge: retirementAge,
        initialRating: initialRating,
        peakRating: peakRating,
      );
      final event = index == 0
          ? '完成职业首秀'
          : index == chapterAges.length - 1
          ? '迎来生涯最后一站'
          : '以新的合同开启挑战';
      return CareerChapter(
        age: age,
        club: clubs[index].name,
        event: event,
        rating: rating,
      );
    });
  }

  List<int> _transferAges({
    required int debutAge,
    required int retirementAge,
    required int count,
  }) {
    final ages = <int>{};
    var attempts = 0;
    while (ages.length < count && attempts < 200) {
      attempts += 1;
      final centredRoll =
          _random.nextDouble() +
          _random.nextDouble() +
          _random.nextDouble() -
          1.5;
      final candidate =
          (ProbabilitySources.averageInternationalTransferAge2025 +
                  centredRoll * 7)
              .round()
              .clamp(debutAge + 1, retirementAge - 1)
              .toInt();
      ages.add(candidate);
    }
    for (
      var fallbackAge = debutAge + 1;
      ages.length < count && fallbackAge < retirementAge;
      fallbackAge++
    ) {
      ages.add(fallbackAge);
    }
    return ages.toList()..sort();
  }

  List<TransferRecord> _transferHistory({
    required List<CareerChapter> chapters,
    required int birthYear,
    required int peakRating,
  }) {
    return List.generate(max(0, chapters.length - 1), (index) {
      final destination = chapters[index + 1];
      final type = FootballCatalog.transferTypes.pick(_random);
      final fee = type == '永久转会'
          ? _transferFee(peakRating, destination.age)
          : 0.0;
      final year = birthYear + destination.age;
      return TransferRecord(
        season: _seasonFor(year),
        age: destination.age,
        fromClub: chapters[index].club,
        toClub: destination.club,
        type: type,
        feeMillions: fee,
      );
    });
  }

  double _transferFee(int peakRating, int age) {
    final quality = max(0, peakRating - 62) / 8;
    final ageFactor = max(0.25, 1 - (age - 25).abs() * 0.055);
    final fee = quality * quality * ageFactor * (4 + _random.nextDouble() * 8);
    return double.parse(fee.clamp(0.2, 180).toStringAsFixed(1));
  }

  CareerStats _careerStats({
    required String position,
    required int peakRating,
    required int careerLength,
    required int transferCount,
    required double totalTransferFeeMillions,
  }) {
    final qualityFactor = (peakRating - 50) / 46;
    final appearances = max(
      35,
      (careerLength * (18 + qualityFactor * 18 + _random.nextInt(8))).round(),
    );
    final starts = min(
      appearances,
      (appearances * (0.62 + qualityFactor * 0.22)).round(),
    );
    final substituteAppearances = appearances - starts;
    final minutesPlayed =
        starts * (74 + _random.nextInt(13)) +
        substituteAppearances * (18 + _random.nextInt(16));
    final scoringRate = _scoringRate(position);
    final assistRate = _assistRate(position);
    final goals =
        (appearances * scoringRate * (0.75 + _random.nextDouble() * 0.5))
            .round();
    final assists =
        (appearances * assistRate * (0.75 + _random.nextDouble() * 0.5))
            .round();
    final nationalCaps = peakRating < 70
        ? _random.nextInt(4)
        : ((peakRating - 67) * (1.2 + _random.nextDouble() * 2.5)).round();
    final championships = _championships(peakRating);
    final honors = _personalHonors(peakRating, appearances);
    final cardRate = switch (position) {
      '门将' => 0.025,
      '中后卫' || '边后卫' || '后腰' => 0.16,
      '中前卫' => 0.12,
      _ => 0.07,
    };

    return CareerStats(
      appearances: appearances,
      starts: starts,
      substituteAppearances: substituteAppearances,
      minutesPlayed: minutesPlayed,
      goals: goals,
      assists: assists,
      yellowCards: (appearances * cardRate).round(),
      secondYellowCards: (appearances * cardRate * 0.035).round(),
      redCards: (appearances * cardRate * 0.025).round(),
      cleanSheets: position == '门将'
          ? (appearances * (0.22 + qualityFactor * 0.14)).round()
          : 0,
      penaltiesScored: position == '中锋' || position == '前腰'
          ? (goals * 0.11).round()
          : 0,
      nationalCaps: nationalCaps,
      nationalGoals: (nationalCaps * scoringRate * 0.8).round(),
      transferCount: transferCount,
      totalTransferFeeMillions: double.parse(
        totalTransferFeeMillions.toStringAsFixed(1),
      ),
      championships: championships,
      personalHonors: honors,
    );
  }

  List<CompetitionStats> _competitionStats({
    required CareerStats stats,
    required int peakRating,
  }) {
    final leagueAppearances = (stats.appearances * 0.69).round();
    final cupAppearances = (stats.appearances * 0.12).round();
    final continentalAppearances =
        stats.appearances - leagueAppearances - cupAppearances;
    final leagueGoals = (stats.goals * 0.7).round();
    final cupGoals = (stats.goals * 0.12).round();
    final continentalGoals = stats.goals - leagueGoals - cupGoals;
    final leagueAssists = (stats.assists * 0.7).round();
    final cupAssists = (stats.assists * 0.12).round();
    final continentalAssists = stats.assists - leagueAssists - cupAssists;

    return [
      CompetitionStats(
        competition: '国内联赛',
        appearances: leagueAppearances,
        goals: leagueGoals,
        assists: leagueAssists,
        minutesPlayed: (stats.minutesPlayed * 0.69).round(),
      ),
      CompetitionStats(
        competition: '国内杯赛',
        appearances: cupAppearances,
        goals: cupGoals,
        assists: cupAssists,
        minutesPlayed: (stats.minutesPlayed * 0.12).round(),
      ),
      CompetitionStats(
        competition: peakRating >= 74 ? '洲际俱乐部赛事' : '其他正式赛事',
        appearances: continentalAppearances,
        goals: continentalGoals,
        assists: continentalAssists,
        minutesPlayed:
            stats.minutesPlayed -
            (stats.minutesPlayed * 0.69).round() -
            (stats.minutesPlayed * 0.12).round(),
      ),
    ];
  }

  List<InjurySpell> _injuryHistory({
    required int birthYear,
    required int debutAge,
    required int retirementAge,
  }) {
    const counts = [
      WeightedValue(0, 28),
      WeightedValue(1, 32),
      WeightedValue(2, 23),
      WeightedValue(3, 11),
      WeightedValue(4, 6),
    ];
    final count = counts.pick(_random);
    return List.generate(count, (index) {
      final age = debutAge + _random.nextInt(retirementAge - debutAge);
      final type = FootballCatalog.injuryTypes.pick(_random);
      final isSevere = type == '韧带重伤' || type == '膝关节伤势';
      final days = isSevere
          ? 90 + _random.nextInt(181)
          : 7 + _random.nextInt(55);
      final year = birthYear + age;
      return InjurySpell(
        season: _seasonFor(year),
        type: type,
        daysAbsent: days,
        matchesMissed: max(1, (days / 7.2).round()),
      );
    })..sort((a, b) => a.season.compareTo(b.season));
  }

  List<MarketValuePoint> _marketValueHistory({
    required int debutAge,
    required int retirementAge,
    required int initialRating,
    required int peakRating,
  }) {
    final ages = <int>{
      debutAge,
      20,
      23,
      26,
      29,
      32,
      retirementAge,
    }.where((age) => age >= debutAge && age <= retirementAge).toList()..sort();
    return ages.map((age) {
      if (age == retirementAge) {
        return MarketValuePoint(age: age, valueMillions: 0);
      }
      final rating = _ratingAtAge(
        age: age,
        debutAge: debutAge,
        retirementAge: retirementAge,
        initialRating: initialRating,
        peakRating: peakRating,
      );
      final ageFactor = max(0.2, 1 - max(0, age - 29) * 0.09);
      final value = pow(max(0, rating - 55), 2) / 10 * ageFactor;
      return MarketValuePoint(
        age: age,
        valueMillions: double.parse(value.clamp(0.1, 200).toStringAsFixed(1)),
      );
    }).toList();
  }

  int _ratingAtAge({
    required int age,
    required int debutAge,
    required int retirementAge,
    required int initialRating,
    required int peakRating,
  }) {
    const peakAge = 27;
    if (age <= peakAge) {
      final growthProgress = (age - debutAge) / max(1, peakAge - debutAge);
      return (initialRating + (peakRating - initialRating) * growthProgress)
          .round()
          .clamp(48, 96)
          .toInt();
    }
    final declineProgress = (age - peakAge) / max(1, retirementAge - peakAge);
    return (peakRating - (peakRating - 58) * declineProgress)
        .round()
        .clamp(48, 96)
        .toInt();
  }

  List<String> _championships(int peakRating) {
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
    return List.generate(count, (index) => '${_pick(pool)} ×1');
  }

  List<String> _personalHonors(int peakRating, int appearances) {
    final honors = <String>[];
    if (appearances >= 300) honors.add('俱乐部百场纪念');
    if (peakRating >= 78) honors.add('联赛赛季最佳阵容');
    if (peakRating >= 84) honors.add('年度最佳球员候选');
    if (peakRating >= 89) honors.add('世界年度最佳球员');
    return honors;
  }

  double _scoringRate(String position) => switch (position) {
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

  double _assistRate(String position) => switch (position) {
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

  String _birthPlace(String nationality) {
    final values = FootballCatalog.birthPlaces[nationality];
    return values == null ? '$nationality某城市' : _pick(values);
  }

  List<String> _citizenships(String nationality) {
    final values = [nationality];
    final secondary = FootballCatalog.secondaryCitizenships[nationality];
    if (secondary != null && _random.nextInt(100) < 18) {
      values.add(_pick(secondary));
    }
    return values;
  }

  String _leagueForClub(String clubName, String nationality) {
    ClubDefinition? club;
    for (final definition in FootballCatalog.clubs) {
      if (definition.name == clubName) {
        club = definition;
        break;
      }
    }
    if (club == null || club.country == '本国') return '$nationality顶级联赛';
    return '${club.country}顶级联赛';
  }

  String _injurySummary(List<InjurySpell> injuries) {
    if (injuries.isEmpty) return '几乎保持全勤，只有轻微不适';
    final totalDays = injuries.fold<int>(
      0,
      (sum, injury) => sum + injury.daysAbsent,
    );
    if (totalDays >= 240) return '经历长期重伤并完成复出';
    if (injuries.length >= 3) return '多次伤病影响了部分赛季';
    return '偶有伤停，但整体出勤稳定';
  }

  String _randomDate(int year) {
    final month = 1 + _random.nextInt(12);
    final day = 1 + _random.nextInt(28);
    return '${day.toString().padLeft(2, '0')}/'
        '${month.toString().padLeft(2, '0')}/$year';
  }

  String _seasonFor(int year) {
    final nextYear = ((year + 1) % 100).toString().padLeft(2, '0');
    return '$year/$nextYear';
  }

  T _pick<T>(List<T> values) => values[_random.nextInt(values.length)];
}
