import 'dart:math';

import '../data/football_catalog.dart';
import '../data/life_event_pool.dart';
import '../data/probability_sources.dart';
import '../domain/player_attributes.dart';
import '../domain/player_profile.dart';

enum CareerDecisionDensity {
  random,
  milestones,
  everyThreeYears,
  everyTwoYears,
  everyYear,
}

extension CareerDecisionDensityInfo on CareerDecisionDensity {
  String get label => switch (this) {
    CareerDecisionDensity.random => '随机长度',
    CareerDecisionDensity.milestones => '关键节点',
    CareerDecisionDensity.everyThreeYears => '每 3 年',
    CareerDecisionDensity.everyTwoYears => '每 2 年',
    CareerDecisionDensity.everyYear => '逐年选择',
  };

  String get labelEn => switch (this) {
    CareerDecisionDensity.random => 'Random length',
    CareerDecisionDensity.milestones => 'Milestones',
    CareerDecisionDensity.everyThreeYears => 'Every 3 years',
    CareerDecisionDensity.everyTwoYears => 'Every 2 years',
    CareerDecisionDensity.everyYear => 'Every year',
  };

  String get description => switch (this) {
    CareerDecisionDensity.random => '随机生成 6–22 个预定节点；每次选择后都可能因伤病、合同、高龄等原因提前退役。',
    CareerDecisionDensity.milestones => '5 次核心抉择，快速完成一段生涯。',
    CareerDecisionDensity.everyThreeYears => '8 次选择，覆盖成长、巅峰与转型。',
    CareerDecisionDensity.everyTwoYears => '11 次选择，更细致地管理竞技状态。',
    CareerDecisionDensity.everyYear => '15–36 岁每年决策，共 22 次完整体验。',
  };

  String get descriptionEn => switch (this) {
    CareerDecisionDensity.random =>
      'Plan 6–22 random nodes; injury, contracts, age or personal reasons '
          'can end the career after any choice.',
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
    CareerDecisionDensity.random => '约 2–10 分钟',
    CareerDecisionDensity.milestones => '约 2 分钟',
    CareerDecisionDensity.everyThreeYears => '约 4 分钟',
    CareerDecisionDensity.everyTwoYears => '约 6 分钟',
    CareerDecisionDensity.everyYear => '约 10 分钟',
  };

  String get estimatedTimeEn => switch (this) {
    CareerDecisionDensity.random => 'about 2–10 min',
    CareerDecisionDensity.milestones => 'about 2 min',
    CareerDecisionDensity.everyThreeYears => 'about 4 min',
    CareerDecisionDensity.everyTwoYears => 'about 6 min',
    CareerDecisionDensity.everyYear => 'about 10 min',
  };

  List<int> get ages => switch (this) {
    CareerDecisionDensity.random => const [],
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

  String get nodeSummary =>
      this == CareerDecisionDensity.random ? '6–22 节点' : '$nodeCount 节点';

  String get nodeSummaryEn =>
      this == CareerDecisionDensity.random ? '6–22 nodes' : '$nodeCount nodes';
}

class LifeChoice {
  const LifeChoice({
    required this.id,
    required this.actionId,
    required this.theme,
    required this.titleZh,
    required this.titleEn,
    required this.backgroundZh,
    required this.backgroundEn,
    required this.descriptionZh,
    required this.descriptionEn,
    required this.actionLabelZh,
    required this.actionLabelEn,
    required this.outcomeZh,
    required this.outcomeEn,
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
  final String backgroundZh;
  final String backgroundEn;
  final String descriptionZh;
  final String descriptionEn;
  final String actionLabelZh;
  final String actionLabelEn;
  final String outcomeZh;
  final String outcomeEn;
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

enum LifeRetirementCause { acuteInjury, chronicInjury, noClub, age, personal }

class LifeRetirementOutcome {
  const LifeRetirementOutcome({
    required this.age,
    required this.cause,
    required this.titleZh,
    required this.titleEn,
    required this.contextZh,
    required this.contextEn,
  });

  final int age;
  final LifeRetirementCause cause;
  final String titleZh;
  final String titleEn;
  final String contextZh;
  final String contextEn;
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
    _stageAges = density == CareerDecisionDensity.random
        ? _randomStageAges()
        : List<int>.unmodifiable(density.ages);
    _preferredFoot =
        attributes[PlayerAttribute.leftLeg] >
            attributes[PlayerAttribute.rightLeg]
        ? '左脚'
        : '右脚';
    _currentClub = _pickInitialClub();
    _initialClub = _currentClub;
    _peakOverall = overallRating;
    _checkpoints.add(
      _LifeCheckpoint(
        age: _stageAges.first - 1,
        club: _currentClub.name,
        attributes: attributes,
        overallRating: overallRating,
        eventZh: '进入职业生涯模拟',
      ),
    );
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
  final List<_LifeCheckpoint> _checkpoints = [];

  late PlayerAttributes attributes;
  late final List<int> _stageAges;
  late ClubDefinition _currentClub;
  late ClubDefinition _initialClub;
  late String _preferredFoot;
  late LifeStage _currentStage;
  late int _peakOverall;
  LifeRetirementOutcome? _retirementOutcome;
  int trainingLoad = 12;
  int injuryRisk = 8;

  int get totalStages => _stageAges.length;
  bool get isComplete =>
      _retirementOutcome != null || decisions.length == totalStages;
  bool get retiredEarly =>
      _retirementOutcome != null && decisions.length < totalStages;
  LifeRetirementOutcome? get retirementOutcome => _retirementOutcome;
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
    decisions.add(
      LifeDecision(stage: stage, choice: choice, club: _currentClub.name),
    );
    if (density == CareerDecisionDensity.random) {
      _maybeTriggerRetirement(
        stage,
        choice,
        forceNaturalEnd: decisions.length == totalStages,
      );
    }
    _peakOverall = max(_peakOverall, overallRating);
    _checkpoints.add(
      _LifeCheckpoint(
        age: stage.age,
        club: _currentClub.name,
        attributes: attributes,
        overallRating: overallRating,
        eventZh: choice.titleZh,
      ),
    );

    if (!isComplete) {
      _currentStage = _buildStage(decisions.length);
    }
  }

  PlayerProfile finish({String name = '我的球员'}) {
    if (!isComplete) {
      throw StateError('Every career stage needs a choice.');
    }

    final retirementAge =
        (_retirementOutcome?.age ?? _stageAges.last.clamp(34, 39)).toInt();
    final initialRating = _ratingFor(_initialAttributes);
    final finalRating = overallRating.clamp(45, 94);
    final peakRating = max(_peakOverall, max(initialRating + 4, finalRating));
    final birthYear = 2011 - _stageAges.first;
    final debutAge = min(16 + _random.nextInt(3), max(16, retirementAge - 1));
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
    final annualSnapshots = _annualSnapshots(
      birthYear: birthYear,
      debutAge: debutAge,
      retirementAge: retirementAge,
    );
    final retirementReason = _retirementOutcome?.titleZh ?? '自然结束职业生涯';
    final retirementContext =
        _retirementOutcome?.contextZh ?? '在完成既定生涯节点后，球员与最后一家俱乐部共同确认退役。';

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
      academyEntryAge: 11,
      debutAge: debutAge,
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
          ? '${birthYear + debutAge}-07-01'
          : _transfers.last.season.split('/').first,
      contractStartDate:
          '${max(_transfers.isEmpty ? birthYear + debutAge : int.parse(_transfers.last.season.split('/').first), birthYear + retirementAge - 2)}-07-01',
      contractUntil: '${birthYear + retirementAge}-06-30',
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
      careerYearSnapshots: annualSnapshots,
      retirementReason: retirementReason,
      retirementContext: retirementContext,
      characterAttributes: attributes,
    );
  }

  LifeStage _buildStage(int index) {
    final age = _stageAges[index];
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
      contextZh: _stageContextZh(index, age),
      contextEn: _stageContextEn(index, age),
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
            backgroundZh:
                '${candidate.scenario.contextZh} '
                '你目前注册在${_currentClub.name}，本轮决定会立即按“确认结果”执行。',
            backgroundEn:
                '${candidate.scenario.contextEn} You are currently registered '
                'with ${_currentClub.name}; the confirmed outcome below takes '
                'effect this round.',
            descriptionZh: candidate.action.descriptionZh,
            descriptionEn: candidate.action.descriptionEn,
            actionLabelZh: _actionLabelZh(candidate.action),
            actionLabelEn: _actionLabelEn(candidate.action),
            outcomeZh: _outcomeZh(candidate.action),
            outcomeEn: _outcomeEn(candidate.action),
            delta: candidate.action.delta,
            trainingLoadDelta: candidate.action.trainingLoadDelta,
            injuryRiskDelta: candidate.action.injuryRiskDelta,
            causesTransfer: candidate.action.causesTransfer,
          ),
      ],
    );
  }

  String _actionLabelZh(LifeActionSeed action) {
    if (action.id == 'loan') return '租借离队';
    if (action.causesTransfer) return '永久转会';
    if (action.id == 'stay' || action.id == 'negotiate') return '留队';
    return switch (action.id) {
      'report' || 'specialist' || 'rehab_group' || 'recover' => '留队 · 恢复',
      'play_through' || 'gamble' => '留队 · 冒险复出',
      'technical' || 'intensive' || 'tactical' || 'team_session' => '留队 · 训练',
      'safe' || 'creative' || 'physical' || 'lead' || 'hero' => '留队 · 比赛',
      _ => '留队 · 场外选择',
    };
  }

  String _actionLabelEn(LifeActionSeed action) {
    if (action.id == 'loan') return 'LOAN EXIT';
    if (action.causesTransfer) return 'PERMANENT TRANSFER';
    if (action.id == 'stay' || action.id == 'negotiate') return 'STAY';
    return switch (action.id) {
      'report' ||
      'specialist' ||
      'rehab_group' ||
      'recover' => 'STAY · RECOVER',
      'play_through' || 'gamble' => 'STAY · RISK RETURN',
      'technical' ||
      'intensive' ||
      'tactical' ||
      'team_session' => 'STAY · TRAIN',
      'safe' || 'creative' || 'physical' || 'lead' || 'hero' => 'STAY · MATCH',
      _ => 'STAY · OFF-PITCH',
    };
  }

  String _outcomeZh(LifeActionSeed action) {
    if (action.id == 'loan') {
      return '确认后：你本轮离开${_currentClub.name}，以租借形式加盟另一家真实俱乐部。';
    }
    if (action.causesTransfer) {
      return '确认后：你本轮永久离开${_currentClub.name}，并加盟另一家真实俱乐部。';
    }
    return '确认后：你本轮不会转会，继续效力${_currentClub.name}。';
  }

  String _outcomeEn(LifeActionSeed action) {
    if (action.id == 'loan') {
      return 'On confirmation: you leave ${_currentClub.name} this round and '
          'join another real club on loan.';
    }
    if (action.causesTransfer) {
      return 'On confirmation: you permanently leave ${_currentClub.name} '
          'this round and join another real club.';
    }
    return 'On confirmation: no transfer occurs this round; you remain with '
        '${_currentClub.name}.';
  }

  String _stageContextZh(int index, int age) {
    if (index == 0) {
      return '你在${_initialClub.name}的青训体系里度过了数年。'
          '$age 岁这个夏天，教练第一次把“职业球员”四个字放到你面前。'
          '下面每条路都来自此刻真实发生的一种处境。';
    }
    final previous = decisions.last;
    final seasons = max(1, age - previous.stage.age);
    final transferText = previous.choice.causesTransfer
        ? '那次决定把你带到${_currentClub.name}，你重新适应了训练节奏和更衣室。'
        : '你留在${_currentClub.name}，角色在连续比赛和日常训练中逐渐变化。';
    final physicalText = _injuries.isNotEmpty
        ? '期间一次${_injuries.last.type}打断了原定计划，复出后的出场顺位也发生了变化。'
        : trainingLoad >= 55
        ? '密集训练和赛程让身体恢复变慢，教练组开始更谨慎地安排你的出场。'
        : '你保持了相对稳定的出勤，也积累了更多比赛经验。';
    return '从 ${previous.stage.age} 岁到 $age 岁的 $seasons 个赛季里，'
        '你选择了“${previous.choice.titleZh}”。$transferText$physicalText'
        '现在，新的合同、比赛和场外关系同时来到桌面上。';
  }

  String _stageContextEn(int index, int age) {
    if (index == 0) {
      return 'You have spent several years inside ${_initialClub.name}’s '
          'academy. This summer, at $age, the coach speaks to you about '
          'becoming a professional for the first time. Each path below '
          'begins with a concrete situation now unfolding around you.';
    }
    final previous = decisions.last;
    final seasons = max(1, age - previous.stage.age);
    final transferText = previous.choice.causesTransfer
        ? 'That decision took you to ${_currentClub.name}, where you had to '
              'learn a new training rhythm and dressing room.'
        : 'You stayed at ${_currentClub.name}, while matches and daily '
              'training gradually changed your role.';
    final physicalText = _injuries.isNotEmpty
        ? ' A ${_injuries.last.type} interrupted the plan and altered your '
              'place in the team after recovery.'
        : trainingLoad >= 55
        ? ' Heavy training and fixtures slowed recovery, so the staff became '
              'more careful with your minutes.'
        : ' Reliable availability gave you a steadier run of matches.';
    return 'Across the $seasons seasons from age ${previous.stage.age} to '
        '$age, you lived with the consequences of '
        '“${previous.choice.titleEn}”. $transferText$physicalText '
        'A new mix of contracts, matches and relationships now demands a decision.';
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
    final birthYear = 2011 - _stageAges.first;
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
    final birthYear = 2011 - _stageAges.first;
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

  List<int> _randomStageAges() {
    final terminalAge = 33 + _random.nextInt(7);
    final maximumCount = min(22, terminalAge - 16);
    final count = 6 + _random.nextInt(maximumCount - 5);
    final middleAges = [for (var age = 18; age < terminalAge; age++) age]
      ..shuffle(_random);
    return [17, ...middleAges.take(count - 2), terminalAge]..sort();
  }

  void _maybeTriggerRetirement(
    LifeStage stage,
    LifeChoice choice, {
    required bool forceNaturalEnd,
  }) {
    final probability = _retirementHazard(stage.age, choice);
    if (_random.nextDouble() < probability) {
      final cause = _pickRetirementCause(stage.age, choice);
      if (cause == LifeRetirementCause.acuteInjury) {
        _recordCareerEndingInjury(stage.age);
      }
      _retirementOutcome = _retirementStory(stage.age, cause);
      return;
    }
    if (forceNaturalEnd) {
      _retirementOutcome = _retirementStory(stage.age, LifeRetirementCause.age);
    }
  }

  double _retirementHazard(int age, LifeChoice choice) {
    var probability = switch (age) {
      <= 20 => 0.003,
      <= 24 => 0.006,
      <= 28 => 0.012,
      <= 30 => 0.022,
      <= 32 => 0.040,
      <= 34 => 0.075,
      <= 36 => 0.140,
      <= 38 => 0.240,
      _ => 0.380,
    };
    probability += max(0, injuryRisk - 28) / 850;
    probability += max(0, trainingLoad - 52) / 1100;
    probability += max(0, 58 - attributes[PlayerAttribute.health]) / 620;
    probability += min(0.075, _injuries.length * 0.012);
    if (_injuries.isNotEmpty && _injuries.last.daysAbsent >= 90) {
      probability += 0.055;
    }
    probability += switch (choice.actionId) {
      'play_through' || 'gamble' => 0.075,
      'intensive' => 0.040,
      'physical' || 'hero' => 0.022,
      _ => 0,
    };
    if (age >= 29 && attributes[PlayerAttribute.reputation] < 45) {
      probability += (45 - attributes[PlayerAttribute.reputation]) / 360;
    }
    if (choice.actionId == 'recover' ||
        choice.actionId == 'report' ||
        choice.actionId == 'specialist') {
      probability *= 0.68;
    }
    return probability.clamp(0.001, 0.62).toDouble();
  }

  LifeRetirementCause _pickRetirementCause(int age, LifeChoice choice) {
    final totalInjuryDays = _injuries.fold<int>(
      0,
      (sum, injury) => sum + injury.daysAbsent,
    );
    final isRiskyReturn =
        choice.actionId == 'play_through' || choice.actionId == 'gamble';
    final acuteWeight =
        ProbabilitySources.retirementAcuteInjuryCausePercent *
        (isRiskyReturn ? 1.8 : 1) *
        (choice.injuryRiskDelta > 0 ? 1.25 : 1);
    final chronicWeight =
        ProbabilitySources.retirementChronicInjuryCausePercent *
        (_injuries.isEmpty
            ? 0.04
            : 1 + min(2.2, totalInjuryDays / 260 + _injuries.length / 5));
    final ageWeight =
        ProbabilitySources.retirementAgeCausePercent *
        (age < 27 ? 0.02 : max(0.15, (age - 27) / 7));
    final marketPressure =
        1 +
        max(0, 50 - attributes[PlayerAttribute.reputation]) / 12 +
        max(0, age - 30) / 8;
    final noClubWeight =
        ProbabilitySources.retirementAlternativeCareerCausePercent *
        marketPressure;
    final personalWeight =
        ProbabilitySources.retirementPersonalCausePercent *
        (1 + max(0, 52 - attributes[PlayerAttribute.morale]) / 10);
    final weighted = <(LifeRetirementCause, double)>[
      (LifeRetirementCause.acuteInjury, acuteWeight),
      (LifeRetirementCause.chronicInjury, chronicWeight),
      (LifeRetirementCause.noClub, noClubWeight),
      (LifeRetirementCause.age, ageWeight),
      (LifeRetirementCause.personal, personalWeight),
    ];
    final total = weighted.fold<double>(0, (sum, item) => sum + item.$2);
    var cursor = _random.nextDouble() * total;
    for (final item in weighted) {
      cursor -= item.$2;
      if (cursor <= 0) return item.$1;
    }
    return weighted.last.$1;
  }

  void _recordCareerEndingInjury(int age) {
    final birthYear = 2011 - _stageAges.first;
    final year = birthYear + age;
    final type = _random.nextBool() ? '前十字韧带重伤' : '复杂膝关节伤势';
    final days = 240 + _random.nextInt(181);
    _injuries.add(
      InjurySpell(
        season: '$year/${year + 1}',
        type: type,
        daysAbsent: days,
        matchesMissed: max(20, (days / 7 * 1.35).round()),
      ),
    );
    attributes = attributes.apply(
      const AttributeDelta({
        PlayerAttribute.health: -10,
        PlayerAttribute.recovery: -7,
        PlayerAttribute.morale: -5,
      }),
    );
  }

  LifeRetirementOutcome _retirementStory(int age, LifeRetirementCause cause) {
    final totalDays = _injuries.fold<int>(
      0,
      (sum, injury) => sum + injury.daysAbsent,
    );
    return switch (cause) {
      LifeRetirementCause.acuteInjury => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '重伤后结束职业生涯',
        titleEn: 'Retired after a major injury',
        contextZh:
            '$age 岁时，你在${_currentClub.name}遭遇'
            '${_injuries.last.type}。手术与长期评估显示，继续职业比赛的风险已经无法接受，'
            '你在康复期内宣布退役。',
        contextEn:
            'At $age, you suffered ${_injuries.last.type} with '
            '${_currentClub.name}. Surgery and long-term assessment made the '
            'risk of continuing unacceptable, so you retired during rehab.',
      ),
      LifeRetirementCause.chronicInjury => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '反复伤病耗尽身体',
        titleEn: 'Recurring injuries ended the career',
        contextZh:
            '到 $age 岁，你已经因反复伤病累计缺阵 $totalDays 天。'
            '恢复周期越来越长，连续训练也难以维持，你与${_currentClub.name}共同决定不再冒险。',
        contextEn:
            'By $age, recurring injuries had cost $totalDays days. Recovery '
            'kept getting longer and full training was no longer sustainable, '
            'so you and ${_currentClub.name} decided to stop.',
      ),
      LifeRetirementCause.noClub => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: age <= 19 ? '未能获得职业合同' : '合同结束后无合适去处',
        titleEn: age <= 19
            ? 'No professional contract arrived'
            : 'No suitable club after the contract ended',
        contextZh: age <= 19
            ? '${_currentClub.name}的青训评估结束后，一线队没有提供职业合同；'
                  '其他试训也未能转化为正式注册，你选择结束球员道路。'
            : '$age 岁赛季结束后，${_currentClub.name}没有续约。经纪团队联系了多家俱乐部，'
                  '但报价与出场计划都无法支撑继续职业生涯，你在转会窗关闭后宣布退役。',
        contextEn: age <= 19
            ? '${_currentClub.name} did not offer a senior contract after the '
                  'academy review, and other trials produced no registration.'
            : 'After the age-$age season, ${_currentClub.name} did not renew. '
                  'Several approaches produced no viable role, and you retired '
                  'when the window closed.',
      ),
      LifeRetirementCause.age => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '高龄与恢复速度促成退役',
        titleEn: 'Age and recovery led to retirement',
        contextZh:
            '$age 岁赛季结束时，赛后恢复已经占据训练周的大部分时间。'
            '在与${_currentClub.name}完成最后一场内部复盘后，你选择在还能完整告别时退役。',
        contextEn:
            'At the end of the age-$age season, recovery consumed most of each '
            'training week. After a final review with ${_currentClub.name}, '
            'you chose to retire while you could still leave on your terms.',
      ),
      LifeRetirementCause.personal => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '长期压力后主动离开',
        titleEn: 'Stepped away after sustained pressure',
        contextZh:
            '到 $age 岁，长期竞争、迁徙和恢复安排已经让足球不再带来同样的投入感。'
            '你履行完在${_currentClub.name}的赛季责任后，主动结束职业生涯。',
        contextEn:
            'By $age, sustained competition, relocation and recovery had '
            'changed your relationship with football. After completing the '
            'season with ${_currentClub.name}, you chose to step away.',
      ),
    };
  }

  List<CareerYearSnapshot> _annualSnapshots({
    required int birthYear,
    required int debutAge,
    required int retirementAge,
  }) {
    final result = <CareerYearSnapshot>[];
    var checkpointIndex = 0;
    for (var age = debutAge; age <= retirementAge; age++) {
      while (checkpointIndex + 1 < _checkpoints.length &&
          _checkpoints[checkpointIndex + 1].age <= age) {
        checkpointIndex += 1;
      }
      final checkpoint = _checkpoints[checkpointIndex];
      final model = checkpoint.attributes;
      final year = birthYear + age;
      final keyEvent = checkpoint.age == age
          ? checkpoint.eventZh
          : '在${checkpoint.club}延续上一阶段选择后的赛季';
      result.add(
        CareerYearSnapshot(
          season: '$year/${((year + 1) % 100).toString().padLeft(2, '0')}',
          age: age,
          club: checkpoint.club,
          squadRole: _squadRole(age, checkpoint.overallRating, model),
          overallRating: checkpoint.overallRating,
          technical: model[PlayerAttribute.technique],
          physical: model.average(const [
            PlayerAttribute.speed,
            PlayerAttribute.strength,
            PlayerAttribute.stamina,
          ]).round(),
          mental: model.average(const [
            PlayerAttribute.intelligence,
            PlayerAttribute.decisionMaking,
            PlayerAttribute.discipline,
            PlayerAttribute.resilience,
            PlayerAttribute.teamwork,
          ]).round(),
          fitness: model.average(const [
            PlayerAttribute.health,
            PlayerAttribute.recovery,
            PlayerAttribute.stamina,
          ]).round(),
          morale: model[PlayerAttribute.morale],
          reputation: model[PlayerAttribute.reputation],
          keyEvent: keyEvent,
        ),
      );
    }
    return result;
  }

  String _squadRole(int age, int rating, PlayerAttributes model) {
    final reputation = model[PlayerAttribute.reputation];
    if (age <= 18 && rating < 58) return '青训 / 预备队';
    if (rating < 56 || reputation < 40) return '替补与轮换';
    if (rating >= 76 && reputation >= 68) return '核心球员';
    if (rating >= 66 || reputation >= 55) return '常规主力';
    if (age >= 33) return '经验型轮换';
    return '轮换球员';
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

class _LifeCheckpoint {
  const _LifeCheckpoint({
    required this.age,
    required this.club,
    required this.attributes,
    required this.overallRating,
    required this.eventZh,
  });

  final int age;
  final String club;
  final PlayerAttributes attributes;
  final int overallRating;
  final String eventZh;
}
