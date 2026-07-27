import 'dart:math';

import '../data/football_catalog.dart';
import '../data/life_event_pool.dart';
import '../domain/player_attributes.dart';
import '../domain/player_profile.dart';

enum CareerDecisionDensity {
  milestones,
  everyThreeYears,
  everyTwoYears,
  everyYear,
}

extension CareerDecisionDensityInfo on CareerDecisionDensity {
  String get label => switch (this) {
    CareerDecisionDensity.milestones => '关键节点',
    CareerDecisionDensity.everyThreeYears => '每 3 年',
    CareerDecisionDensity.everyTwoYears => '每 2 年',
    CareerDecisionDensity.everyYear => '逐年选择',
  };

  String get labelEn => switch (this) {
    CareerDecisionDensity.milestones => 'Milestones',
    CareerDecisionDensity.everyThreeYears => 'Every 3 years',
    CareerDecisionDensity.everyTwoYears => 'Every 2 years',
    CareerDecisionDensity.everyYear => 'Every year',
  };

  String get description => switch (this) {
    CareerDecisionDensity.milestones => '5 次核心抉择，快速完成一段生涯。',
    CareerDecisionDensity.everyThreeYears => '8 次选择，覆盖成长、巅峰与转型。',
    CareerDecisionDensity.everyTwoYears => '11 次选择，更细致地管理竞技状态。',
    CareerDecisionDensity.everyYear => '15–36 岁每年决策，共 22 次完整体验。',
  };

  String get descriptionEn => switch (this) {
    CareerDecisionDensity.milestones =>
      'Five defining choices for a quick career.',
    CareerDecisionDensity.everyThreeYears =>
      'Eight choices across growth, peak and transition.',
    CareerDecisionDensity.everyTwoYears =>
      'Eleven choices with finer form management.',
    CareerDecisionDensity.everyYear =>
      'Make a choice every year from age 15 to 36.',
  };

  String get estimatedTime => switch (this) {
    CareerDecisionDensity.milestones => '约 2 分钟',
    CareerDecisionDensity.everyThreeYears => '约 4 分钟',
    CareerDecisionDensity.everyTwoYears => '约 6 分钟',
    CareerDecisionDensity.everyYear => '约 10 分钟',
  };

  String get estimatedTimeEn => switch (this) {
    CareerDecisionDensity.milestones => 'about 2 min',
    CareerDecisionDensity.everyThreeYears => 'about 4 min',
    CareerDecisionDensity.everyTwoYears => 'about 6 min',
    CareerDecisionDensity.everyYear => 'about 10 min',
  };

  List<int> get ages => switch (this) {
    CareerDecisionDensity.milestones => const [15, 19, 24, 29, 34],
    CareerDecisionDensity.everyThreeYears => const [
      15,
      18,
      21,
      24,
      27,
      30,
      33,
      36,
    ],
    CareerDecisionDensity.everyTwoYears => const [
      15,
      17,
      19,
      21,
      23,
      25,
      27,
      29,
      31,
      33,
      35,
    ],
    CareerDecisionDensity.everyYear => List.generate(22, (index) => 15 + index),
  };

  int get nodeCount => ages.length;
}

class LifeChoice {
  const LifeChoice({
    required this.id,
    required this.actionId,
    required this.theme,
    required this.titleZh,
    required this.titleEn,
    required this.descriptionZh,
    required this.descriptionEn,
    required this.delta,
    required this.trainingLoadDelta,
    required this.injuryRiskDelta,
    required this.causesTransfer,
  });

  final String id;
  final String actionId;
  final LifeEventTheme theme;
  final String titleZh;
  final String titleEn;
  final String descriptionZh;
  final String descriptionEn;
  final AttributeDelta delta;
  final int trainingLoadDelta;
  final int injuryRiskDelta;
  final bool causesTransfer;
}

class LifeStage {
  const LifeStage({
    required this.age,
    required this.phase,
    required this.titleZh,
    required this.titleEn,
    required this.contextZh,
    required this.contextEn,
    required this.candidatePoolSize,
    required this.eligiblePoolSize,
    required this.choices,
  });

  final int age;
  final CareerPhase phase;
  final String titleZh;
  final String titleEn;
  final String contextZh;
  final String contextEn;
  final int candidatePoolSize;
  final int eligiblePoolSize;
  final List<LifeChoice> choices;
}

class LifeDecision {
  const LifeDecision({
    required this.stage,
    required this.choice,
    required this.club,
  });

  final LifeStage stage;
  final LifeChoice choice;
  final String club;
}

class LifeSimulator {
  LifeSimulator({
    required this.nationality,
    required this.position,
    this.density = CareerDecisionDensity.milestones,
    Random? random,
    PlayerAttributes? initialAttributes,
  }) : _random = random ?? Random(),
       _initialAttributes =
           initialAttributes ??
           _createInitialAttributes(position, random ?? Random()) {
    attributes = _initialAttributes;
    _preferredFoot =
        attributes[PlayerAttribute.leftLeg] >
            attributes[PlayerAttribute.rightLeg]
        ? '左脚'
        : '右脚';
    _currentClub = _pickInitialClub();
    _initialClub = _currentClub;
    _peakOverall = overallRating;
    _currentStage = _buildStage(0);
  }

  final String nationality;
  final String position;
  final CareerDecisionDensity density;
  final Random _random;
  final PlayerAttributes _initialAttributes;
  final List<LifeDecision> decisions = [];
  final List<TransferRecord> _transfers = [];
  final List<InjurySpell> _injuries = [];

  late PlayerAttributes attributes;
  late ClubDefinition _currentClub;
  late ClubDefinition _initialClub;
  late String _preferredFoot;
  late LifeStage _currentStage;
  late int _peakOverall;
  int trainingLoad = 12;
  int injuryRisk = 8;

  int get totalStages => density.ages.length;
  bool get isComplete => decisions.length == totalStages;
  LifeStage get currentStage {
    if (isComplete) throw StateError('The career is already complete.');
    return _currentStage;
  }

  String get currentClub => _currentClub.name;

  int get overallRating {
    final technical = attributes[PlayerAttribute.technique] * 0.28;
    final physical =
        attributes.average(const [
          PlayerAttribute.speed,
          PlayerAttribute.strength,
          PlayerAttribute.stamina,
          PlayerAttribute.health,
        ]) *
        0.25;
    final mental =
        attributes.average(const [
          PlayerAttribute.intelligence,
          PlayerAttribute.decisionMaking,
          PlayerAttribute.discipline,
          PlayerAttribute.resilience,
          PlayerAttribute.teamwork,
        ]) *
        0.27;
    final limbs =
        max(
          attributes[PlayerAttribute.leftLeg],
          attributes[PlayerAttribute.rightLeg],
        ) *
        0.12;
    final fortune =
        attributes.average(const [
          PlayerAttribute.morale,
          PlayerAttribute.reputation,
          PlayerAttribute.luck,
        ]) *
        0.08;
    return (technical + physical + mental + limbs + fortune).round().clamp(
      1,
      99,
    );
  }

  /// Exposed for balancing tests and planner tooling.
  double themeWeight(LifeEventTheme theme) {
    return switch (theme) {
      LifeEventTheme.training =>
        0.8 + (100 - attributes[PlayerAttribute.technique]) / 80,
      LifeEventTheme.health =>
        0.35 +
            (trainingLoad +
                        injuryRisk +
                        (100 - attributes[PlayerAttribute.health]))
                    .clamp(0, 240) /
                60,
      LifeEventTheme.club => 0.7 + attributes[PlayerAttribute.reputation] / 75,
      LifeEventTheme.match =>
        0.8 +
            attributes.average(const [
                  PlayerAttribute.technique,
                  PlayerAttribute.decisionMaking,
                  PlayerAttribute.luck,
                ]) /
                110,
      LifeEventTheme.publicLife =>
        0.55 +
            (attributes[PlayerAttribute.reputation] +
                        (100 - attributes[PlayerAttribute.discipline]))
                    .clamp(0, 200) /
                130,
    };
  }

  void choose(int stageIndex, int choiceIndex) {
    if (stageIndex != decisions.length || isComplete) {
      throw StateError('Choices must be made in stage order.');
    }
    if (choiceIndex < 0 || choiceIndex >= _currentStage.choices.length) {
      throw RangeError.index(choiceIndex, _currentStage.choices);
    }

    final stage = _currentStage;
    final choice = stage.choices[choiceIndex];
    attributes = attributes.apply(choice.delta);
    trainingLoad = (trainingLoad + choice.trainingLoadDelta).clamp(0, 100);
    injuryRisk = (injuryRisk + choice.injuryRiskDelta).clamp(0, 100);

    if (choice.causesTransfer) {
      _makeTransfer(stage.age, choice.actionId == 'loan');
    }
    _maybeRecordInjury(stage, choice);
    _peakOverall = max(_peakOverall, overallRating);
    decisions.add(
      LifeDecision(stage: stage, choice: choice, club: _currentClub.name),
    );

    if (!isComplete) {
      _currentStage = _buildStage(decisions.length);
    }
  }

  PlayerProfile finish({String name = '我的球员'}) {
    if (!isComplete) {
      throw StateError('Every career stage needs a choice.');
    }

    final retirementAge = density.ages.last.clamp(34, 39);
    final initialRating = _ratingFor(_initialAttributes);
    final finalRating = overallRating.clamp(45, 94);
    final peakRating = max(_peakOverall, max(initialRating + 4, finalRating));
    final birthYear = 2011 - density.ages.first;
    final career = [
      for (var index = 0; index < decisions.length; index++)
        CareerChapter(
          age: decisions[index].stage.age,
          club: decisions[index].club,
          event: decisions[index].choice.titleZh,
          rating: _chapterRating(index, initialRating, peakRating),
        ),
    ];
    final careerYears = max(1, retirementAge - 16);
    final fitness =
        attributes.average(const [
          PlayerAttribute.stamina,
          PlayerAttribute.health,
          PlayerAttribute.recovery,
        ]) /
        100;
    final appearances = max(
      80,
      (careerYears * (20 + fitness * 24) - _injuries.length * 8).round(),
    );
    final starts = (appearances * (0.58 + peakRating / 300)).round().clamp(
      0,
      appearances,
    );
    final scoringRate = _scoringRate();
    final goals = (appearances * scoringRate).round();
    final assists = (appearances * (scoringRate * 0.65 + 0.04)).round();
    final reputation = attributes[PlayerAttribute.reputation];
    final nationalCaps = reputation < 48
        ? 0
        : ((reputation - 43) * 1.9).round();
    final championships = max(0, (reputation + _peakOverall - 115) ~/ 12);
    final totalFees = _transfers.fold<double>(
      0,
      (total, transfer) => total + transfer.feeMillions,
    );
    final stats = CareerStats(
      appearances: appearances,
      starts: starts,
      substituteAppearances: appearances - starts,
      minutesPlayed: starts * 78 + (appearances - starts) * 21,
      goals: goals,
      assists: assists,
      yellowCards: (appearances * 0.08).round(),
      secondYellowCards: (appearances * 0.002).round(),
      redCards: (appearances * 0.0015).round(),
      cleanSheets: position == '门将' ? (appearances * 0.27).round() : 0,
      penaltiesScored: position == '中锋' || position == '前腰'
          ? (goals * 0.09).round()
          : 0,
      nationalCaps: nationalCaps,
      nationalGoals: (nationalCaps * scoringRate * 0.72).round(),
      transferCount: _transfers.length,
      totalTransferFeeMillions: double.parse(totalFees.toStringAsFixed(1)),
      championships: [
        for (var index = 0; index < championships; index++) '重要赛事冠军 ×1',
      ],
      personalHonors: [
        if (reputation >= 65) '联赛最佳阵容',
        if (reputation >= 76) '年度最佳球员候选',
        if (attributes[PlayerAttribute.teamwork] >= 72) '俱乐部功勋球员',
      ],
    );
    final values = [
      for (var age = 17; age <= retirementAge; age += 3)
        MarketValuePoint(
          age: age,
          valueMillions: double.parse(
            max(
              0.2,
              (peakRating - 54) *
                  (1 - (age - 27).abs() * 0.045).clamp(0.18, 1) *
                  1.7,
            ).toStringAsFixed(1),
          ),
        ),
    ];
    final competitionStats = _competitionStats(
      appearances: appearances,
      goals: goals,
      assists: assists,
    );

    return PlayerProfile(
      mode: CareerMode.life,
      name: name,
      birthDate:
          '$birthYear-${1 + _random.nextInt(12)}-${1 + _random.nextInt(28)}',
      birthPlace: nationality,
      developmentAssociation: nationality,
      nationality: nationality,
      citizenships: [nationality],
      preferredFoot: _preferredFoot,
      heightCm: 168 + _random.nextInt(25),
      weightKg: 62 + _random.nextInt(25),
      shirtNumber: _shirtNumber(),
      primaryPosition: position,
      secondaryPosition: _secondaryPosition(),
      academy: '${_initialClub.name} 青训学院',
      debutAge: 16 + _random.nextInt(3),
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating.clamp(initialRating + 4, 96),
      finalRating: finalRating,
      playStyle:
          (FootballCatalog.positionStyles[position] ?? const ['全能型']).first,
      injuryRecord: _injuries.isEmpty
          ? '生涯无长期伤停'
          : '${_injuries.length} 次伤停，共缺席 '
                '${_injuries.fold<int>(0, (sum, injury) => sum + injury.daysAbsent)} 天',
      currentClub: _currentClub.name,
      currentLeague: '${_currentClub.country}职业联赛',
      joinedClubDate: _transfers.isEmpty
          ? '$birthYear'
          : _transfers.last.season.split('/').first,
      contractUntil: '${birthYear + retirementAge + 1}-06-30',
      agent: '玩家自定义经纪团队',
      marketValueMillions: values.isEmpty ? 0 : values.last.valueMillions,
      nationalTeam: nationalCaps == 0 ? '未入选' : nationality,
      nationalTeamDebut: nationalCaps == 0 ? '未记录' : '${birthYear + 21}-09-01',
      career: career,
      transferHistory: List.unmodifiable(_transfers),
      injuryHistory: List.unmodifiable(_injuries),
      marketValueHistory: values,
      competitionStats: competitionStats,
      stats: stats,
      characterAttributes: attributes,
    );
  }

  LifeStage _buildStage(int index) {
    final age = density.ages[index];
    final phase = LifeEventPool.phaseForAge(age);
    final raw = LifeEventPool.rawOptionsFor(phase);
    final eligible = raw.where(_isEligible).toList();
    final source = eligible.length >= 5 ? eligible : raw;
    final visibleCount = 3 + _random.nextInt(3);
    final selected = _weightedWithoutReplacement(source, visibleCount);
    return LifeStage(
      age: age,
      phase: phase,
      titleZh: _phaseTitleZh(phase),
      titleEn: _phaseTitleEn(phase),
      contextZh:
          '人物模型从 ${raw.length} 个候选中筛选出 ${eligible.length} 个可行分支，'
          '你当前效力于 ${_currentClub.name}。',
      contextEn:
          'The character model found ${eligible.length} eligible branches '
          'from ${raw.length} candidates. You currently play for '
          '${_currentClub.name}.',
      candidatePoolSize: raw.length,
      eligiblePoolSize: eligible.length,
      choices: [
        for (final candidate in selected)
          LifeChoice(
            id: candidate.id,
            actionId: candidate.action.id,
            theme: candidate.scenario.theme,
            titleZh:
                '${candidate.scenario.titleZh} · ${candidate.action.titleZh}',
            titleEn:
                '${candidate.scenario.titleEn} · ${candidate.action.titleEn}',
            descriptionZh: candidate.action.descriptionZh,
            descriptionEn: candidate.action.descriptionEn,
            delta: candidate.action.delta,
            trainingLoadDelta: candidate.action.trainingLoadDelta,
            injuryRiskDelta: candidate.action.injuryRiskDelta,
            causesTransfer: candidate.action.causesTransfer,
          ),
      ],
    );
  }

  bool _isEligible(LifeCandidate candidate) {
    for (final entry in candidate.action.minimums.entries) {
      if (attributes[entry.key] < entry.value) return false;
    }
    for (final entry in candidate.action.maximums.entries) {
      if (attributes[entry.key] > entry.value) return false;
    }
    if (candidate.action.causesTransfer &&
        candidate.action.id == 'move' &&
        attributes[PlayerAttribute.reputation] < 38) {
      return false;
    }
    return true;
  }

  List<LifeCandidate> _weightedWithoutReplacement(
    List<LifeCandidate> candidates,
    int count,
  ) {
    final remaining = List<LifeCandidate>.from(candidates);
    final result = <LifeCandidate>[];
    while (result.length < count && remaining.isNotEmpty) {
      final total = remaining.fold<double>(
        0,
        (sum, item) => sum + _candidateWeight(item),
      );
      var cursor = _random.nextDouble() * total;
      var selectedIndex = 0;
      for (var index = 0; index < remaining.length; index++) {
        cursor -= _candidateWeight(remaining[index]);
        if (cursor <= 0) {
          selectedIndex = index;
          break;
        }
      }
      result.add(remaining.removeAt(selectedIndex));
    }
    return result;
  }

  double _candidateWeight(LifeCandidate candidate) {
    var score =
        candidate.action.baseWeight * themeWeight(candidate.scenario.theme);
    for (final attribute in candidate.action.delta.values.keys) {
      if (candidate.action.delta[attribute] > 0) {
        score *= 0.9 + (100 - attributes[attribute]) / 220;
      }
    }
    return max(0.1, score);
  }

  void _makeTransfer(int age, bool loan) {
    final oldClub = _currentClub;
    final possible = FootballCatalog.clubs
        .where((club) => club.name != oldClub.name)
        .toList();
    final reputation = attributes[PlayerAttribute.reputation];
    final desiredLevel = reputation >= 72
        ? 1
        : reputation >= 58
        ? 2
        : reputation >= 45
        ? 3
        : 4;
    final close = possible
        .where((club) => (club.level - desiredLevel).abs() <= 1)
        .toList();
    _currentClub = (close.isEmpty
        ? possible
        : close)[_random.nextInt((close.isEmpty ? possible : close).length)];
    final birthYear = 2011 - density.ages.first;
    final year = birthYear + age;
    final fee = loan
        ? 0.0
        : max(0.5, (reputation - 30) * (5 - _currentClub.level) * 0.42);
    _transfers.add(
      TransferRecord(
        season: '$year/${year + 1}',
        age: age,
        fromClub: oldClub.name,
        toClub: _currentClub.name,
        type: loan ? '租借' : '永久转会',
        feeMillions: double.parse(fee.toStringAsFixed(1)),
      ),
    );
  }

  void _maybeRecordInjury(LifeStage stage, LifeChoice choice) {
    final base =
        injuryRisk +
        trainingLoad ~/ 2 +
        (100 - attributes[PlayerAttribute.health]) ~/ 2;
    final themeBonus = choice.theme == LifeEventTheme.health ? 14 : 0;
    if (_random.nextInt(240) >= base + themeBonus) return;
    final days = 7 + _random.nextInt(55) + injuryRisk ~/ 3;
    final birthYear = 2011 - density.ages.first;
    final year = birthYear + stage.age;
    _injuries.add(
      InjurySpell(
        season: '$year/${year + 1}',
        type: _injuryTypes[_random.nextInt(_injuryTypes.length)],
        daysAbsent: days,
        matchesMissed: max(1, (days / 7 * 1.4).round()),
      ),
    );
    attributes = attributes.apply(
      const AttributeDelta({
        PlayerAttribute.health: -2,
        PlayerAttribute.morale: -1,
      }),
    );
    injuryRisk = (injuryRisk + 4).clamp(0, 100);
  }

  int _chapterRating(int index, int initial, int peak) {
    if (decisions.length == 1) return peak;
    final progress = index / (decisions.length - 1);
    final age = decisions[index].stage.age;
    final curve = age <= 29 ? progress : (1 - (age - 29) * 0.055);
    return (initial + (peak - initial) * curve).round().clamp(1, 99);
  }

  int _ratingFor(PlayerAttributes model) {
    final original = attributes;
    attributes = model;
    final rating = overallRating;
    attributes = original;
    return rating;
  }

  ClubDefinition _pickInitialClub() {
    final candidates = FootballCatalog.clubs
        .where((club) => club.level >= 3)
        .toList();
    return candidates[_random.nextInt(candidates.length)];
  }

  double _scoringRate() => switch (position) {
    '中锋' => 0.45,
    '边锋' => 0.27,
    '前腰' => 0.22,
    '中前卫' => 0.13,
    '后腰' => 0.07,
    '边后卫' => 0.055,
    '中后卫' => 0.045,
    _ => 0.004,
  };

  List<CompetitionStats> _competitionStats({
    required int appearances,
    required int goals,
    required int assists,
  }) {
    final leagueApps = (appearances * 0.72).round();
    final cupApps = (appearances * 0.12).round();
    final continentalApps = appearances - leagueApps - cupApps;
    final leagueGoals = (goals * 0.72).round();
    final cupGoals = (goals * 0.12).round();
    final leagueAssists = (assists * 0.72).round();
    final cupAssists = (assists * 0.12).round();
    return [
      CompetitionStats(
        competition: '国内联赛',
        appearances: leagueApps,
        goals: leagueGoals,
        assists: leagueAssists,
        minutesPlayed: leagueApps * 70,
      ),
      CompetitionStats(
        competition: '国内杯赛',
        appearances: cupApps,
        goals: cupGoals,
        assists: cupAssists,
        minutesPlayed: cupApps * 64,
      ),
      CompetitionStats(
        competition: '洲际赛事',
        appearances: continentalApps,
        goals: goals - leagueGoals - cupGoals,
        assists: assists - leagueAssists - cupAssists,
        minutesPlayed: continentalApps * 68,
      ),
    ];
  }

  int _shirtNumber() => switch (position) {
    '门将' => 1,
    '中后卫' => 4,
    '边后卫' => 2,
    '后腰' => 6,
    '中前卫' => 8,
    '前腰' => 10,
    '边锋' => 11,
    _ => 9,
  };

  String _secondaryPosition() => switch (position) {
    '门将' => '门将',
    '中后卫' => '后腰',
    '边后卫' => '边锋',
    '后腰' => '中前卫',
    '中前卫' => '前腰',
    '前腰' => '中前卫',
    '边锋' => '中锋',
    _ => '边锋',
  };

  static PlayerAttributes _createInitialAttributes(
    String position,
    Random random,
  ) {
    final values = {
      for (final attribute in PlayerAttribute.values)
        attribute: 42 + random.nextInt(18),
    };
    values[PlayerAttribute.leftArm] = 45 + random.nextInt(15);
    values[PlayerAttribute.rightArm] = 45 + random.nextInt(15);
    if (random.nextBool()) {
      values[PlayerAttribute.leftLeg] = 62 + random.nextInt(16);
      values[PlayerAttribute.rightLeg] = 42 + random.nextInt(16);
    } else {
      values[PlayerAttribute.rightLeg] = 62 + random.nextInt(16);
      values[PlayerAttribute.leftLeg] = 42 + random.nextInt(16);
    }
    switch (position) {
      case '门将':
        values[PlayerAttribute.leftArm] = 68 + random.nextInt(15);
        values[PlayerAttribute.rightArm] = 68 + random.nextInt(15);
        values[PlayerAttribute.decisionMaking] = 58 + random.nextInt(14);
        break;
      case '中后卫':
        values[PlayerAttribute.strength] = 62 + random.nextInt(16);
        values[PlayerAttribute.resilience] = 58 + random.nextInt(15);
        break;
      case '边后卫':
      case '边锋':
        values[PlayerAttribute.speed] = 65 + random.nextInt(16);
        values[PlayerAttribute.stamina] = 58 + random.nextInt(16);
        break;
      case '后腰':
      case '中前卫':
        values[PlayerAttribute.stamina] = 62 + random.nextInt(16);
        values[PlayerAttribute.teamwork] = 58 + random.nextInt(16);
        break;
      case '前腰':
        values[PlayerAttribute.technique] = 65 + random.nextInt(16);
        values[PlayerAttribute.intelligence] = 58 + random.nextInt(16);
        break;
      case '中锋':
        values[PlayerAttribute.strength] = 60 + random.nextInt(17);
        values[PlayerAttribute.technique] = 60 + random.nextInt(17);
        break;
    }
    return PlayerAttributes(values);
  }
}

String _phaseTitleZh(CareerPhase phase) => switch (phase) {
  CareerPhase.youth => '青训岔路',
  CareerPhase.rise => '上升期抉择',
  CareerPhase.prime => '巅峰期博弈',
  CareerPhase.veteran => '生涯后段',
};

String _phaseTitleEn(CareerPhase phase) => switch (phase) {
  CareerPhase.youth => 'Academy crossroads',
  CareerPhase.rise => 'Choices on the rise',
  CareerPhase.prime => 'Decisions at the peak',
  CareerPhase.veteran => 'The final chapters',
};

const _injuryTypes = ['肌肉拉伤', '脚踝扭伤', '膝部炎症', '腿筋伤势', '撞击伤'];
