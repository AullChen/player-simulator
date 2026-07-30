import 'dart:math';

import '../data/football_catalog.dart';
import '../data/life_event_pool.dart';
import '../data/probability_sources.dart';
import '../domain/player_attributes.dart';
import '../domain/player_profile.dart';
import 'peak_rating_distribution.dart';

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
    CareerDecisionDensity.random =>
      '不预设选择总数；每个决定都独立携带退役风险，生涯可能首轮结束，也可能延续到 60 岁。',
    CareerDecisionDensity.milestones => '5 次核心抉择，快速完成一段生涯。',
    CareerDecisionDensity.everyThreeYears => '8 次选择，覆盖成长、巅峰与转型。',
    CareerDecisionDensity.everyTwoYears => '11 次选择，更细致地管理竞技状态。',
    CareerDecisionDensity.everyYear => '15–36 岁每年决策，共 22 次完整体验。',
  };

  String get descriptionEn => switch (this) {
    CareerDecisionDensity.random =>
      'No choice total is fixed in advance. Every decision carries its own '
          'retirement risk, from a first-round exit to an age-60 career.',
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
    CareerDecisionDensity.random => '时长不固定',
    CareerDecisionDensity.milestones => '约 2 分钟',
    CareerDecisionDensity.everyThreeYears => '约 4 分钟',
    CareerDecisionDensity.everyTwoYears => '约 6 分钟',
    CareerDecisionDensity.everyYear => '约 10 分钟',
  };

  String get estimatedTimeEn => switch (this) {
    CareerDecisionDensity.random => 'open-ended',
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
      this == CareerDecisionDensity.random ? '无预设节点数' : '$nodeCount 节点';

  String get nodeSummaryEn => this == CareerDecisionDensity.random
      ? 'no preset total'
      : '$nodeCount nodes';
}

class LifeChoice {
  const LifeChoice({
    required this.id,
    required this.actionId,
    required this.theme,
    required this.titleZh,
    required this.titleEn,
    required this.decisionZh,
    required this.decisionEn,
    required this.retirementProbability,
    required this.accidentProbability,
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
  final String decisionZh;
  final String decisionEn;
  final double retirementProbability;
  final double accidentProbability;
  final AttributeDelta delta;
  final int trainingLoadDelta;
  final int injuryRiskDelta;
  final bool causesTransfer;
}

class LifeStage {
  const LifeStage({
    required this.age,
    required this.phase,
    required this.theme,
    required this.categoryZh,
    required this.categoryEn,
    required this.scenarioId,
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
  final LifeEventTheme theme;
  final String categoryZh;
  final String categoryEn;
  final String scenarioId;
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

enum LifeRetirementCause {
  accident,
  acuteInjury,
  chronicInjury,
  noClub,
  age,
  personal,
  voluntary,
}

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
    final ratingSample = PeakRatingDistribution.sample(
      random: _random,
      academyTier: 1,
    );
    _peakRatingBand = ratingSample.band;
    _targetPeakRating = ratingSample.peak;
    attributes = _initialAttributes;
    _initialOverallRating = min(
      _rawOverall(_initialAttributes),
      _targetPeakRating - 4,
    );
    _stageAges = density == CareerDecisionDensity.random
        ? <int>[17]
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
  final List<_LifeChampionship> _championships = [];
  final List<_LifeCheckpoint> _checkpoints = [];

  late PlayerAttributes attributes;
  late final List<int> _stageAges;
  late ClubDefinition _currentClub;
  late ClubDefinition _initialClub;
  late String _preferredFoot;
  late LifeStage _currentStage;
  late int _peakOverall;
  late final int _initialOverallRating;
  late final PeakRatingBand _peakRatingBand;
  late final int _targetPeakRating;
  LifeEventTheme? _lastTheme;
  String? _lastScenarioId;
  LifeRetirementOutcome? _retirementOutcome;
  int? _lastOverallChange;
  int trainingLoad = 12;
  int injuryRisk = 8;

  int get totalStages => _stageAges.length;
  bool get isOpenEnded => density == CareerDecisionDensity.random;
  bool get isComplete =>
      _retirementOutcome != null ||
      (!isOpenEnded && decisions.length == totalStages);
  LifeRetirementOutcome? get retirementOutcome => _retirementOutcome;
  int? get lastOverallChange => _lastOverallChange;
  LifeStage get currentStage {
    if (isComplete) throw StateError('The career is already complete.');
    return _currentStage;
  }

  String get currentClub => _currentClub.name;

  int get overallRating {
    if (decisions.isEmpty) return _initialOverallRating;
    return min(
      _rawOverall(attributes),
      PeakRatingDistribution.maximum(_peakRatingBand),
    );
  }

  static int _rawOverall(PlayerAttributes model) {
    final technical = model[PlayerAttribute.technique] * 0.28;
    final physical =
        model.average(const [
          PlayerAttribute.speed,
          PlayerAttribute.strength,
          PlayerAttribute.stamina,
          PlayerAttribute.health,
        ]) *
        0.25;
    final mental =
        model.average(const [
          PlayerAttribute.intelligence,
          PlayerAttribute.decisionMaking,
          PlayerAttribute.discipline,
          PlayerAttribute.resilience,
          PlayerAttribute.teamwork,
        ]) *
        0.27;
    final limbs =
        max(model[PlayerAttribute.leftLeg], model[PlayerAttribute.rightLeg]) *
        0.12;
    final fortune =
        model.average(const [
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
    final previousOverall = overallRating;
    attributes = attributes.apply(choice.delta);
    trainingLoad = (trainingLoad + choice.trainingLoadDelta).clamp(0, 100);
    injuryRisk = (injuryRisk + choice.injuryRiskDelta).clamp(0, 100);

    if (choice.actionId == 'voluntary_retirement') {
      _retirementOutcome = _retirementStory(
        stage.age,
        LifeRetirementCause.voluntary,
      );
    } else if (choice.causesTransfer) {
      _makeTransfer(stage.age, choice.actionId == 'loan');
    }
    if (choice.actionId != 'voluntary_retirement') {
      _maybeRecordInjury(stage, choice);
      _maybeRecordChampionships(stage, choice);
    }
    decisions.add(
      LifeDecision(stage: stage, choice: choice, club: _currentClub.name),
    );
    if (density == CareerDecisionDensity.random && _retirementOutcome == null) {
      _maybeTriggerRetirement(stage, choice);
      if (_retirementOutcome == null) {
        if (stage.age >= 60) {
          _retirementOutcome = _retirementStory(
            stage.age,
            LifeRetirementCause.age,
          );
        } else {
          _stageAges.add(_nextOpenEndedAge(stage.age));
        }
      }
    }
    _lastOverallChange = overallRating - previousOverall;
    _peakOverall = max(_peakOverall, overallRating);
    _checkpoints.add(
      _LifeCheckpoint(
        age: stage.age,
        club: _currentClub.name,
        attributes: attributes,
        overallRating: overallRating,
        eventZh: _eventWithChampionships(stage.age, choice.titleZh),
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
    final initialRating = _initialOverallRating;
    final finalRating = overallRating.clamp(45, 94);
    final observedPeak = max(_peakOverall, max(initialRating + 4, finalRating));
    final peakRating = max(_targetPeakRating, observedPeak).clamp(
      PeakRatingDistribution.minimum(_peakRatingBand),
      PeakRatingDistribution.maximum(_peakRatingBand),
    );
    final birthYear = 2011 - _stageAges.first;
    final debutAge = min(16 + _random.nextInt(3), max(16, retirementAge - 1));
    final career = [
      for (var index = 0; index < decisions.length; index++)
        CareerChapter(
          age: decisions[index].stage.age,
          club: decisions[index].club,
          event: _eventWithChampionships(
            decisions[index].stage.age,
            decisions[index].choice.titleZh,
          ),
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
      5,
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
        : min(careerYears * 12, ((reputation - 43) * 1.9).round());
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
        for (final championship in _championships) championship.labelZh,
      ],
      personalHonors: [
        if (reputation >= 65) '联赛最佳阵容',
        if (peakRating >= 82) '年度最佳球员候选',
        if (peakRating >= 90) '世界年度最佳球员',
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
      peakRating: peakRating,
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
    final theme = _pickStageTheme(raw, eligible);
    final themeEligible = eligible
        .where((candidate) => candidate.scenario.theme == theme)
        .toList();
    final themeRaw = raw
        .where((candidate) => candidate.scenario.theme == theme)
        .toList();
    final scenarioSource = themeEligible.length >= 3 ? themeEligible : themeRaw;
    final scenario = _pickScenario(scenarioSource);
    final eligibleActions = themeEligible
        .where((candidate) => candidate.scenario.id == scenario.id)
        .toList();
    final rawActions = themeRaw
        .where((candidate) => candidate.scenario.id == scenario.id)
        .toList();
    final actionSource = eligibleActions.length >= 3
        ? eligibleActions
        : rawActions;
    final visibleCount = min(actionSource.length, 3 + _random.nextInt(3));
    final offerRetirement = _shouldOfferVoluntaryRetirement(age, theme);
    final regularCount = max(2, visibleCount - (offerRetirement ? 1 : 0));
    final selected = _weightedWithoutReplacement(
      actionSource,
      min(actionSource.length, regularCount),
    );
    if (offerRetirement) {
      selected.insert(
        _random.nextInt(selected.length + 1),
        LifeCandidate(scenario: scenario, action: _voluntaryRetirementAction),
      );
    }
    _lastTheme = theme;
    _lastScenarioId = scenario.id;
    return LifeStage(
      age: age,
      phase: phase,
      theme: theme,
      categoryZh: _themeLabelZh(theme),
      categoryEn: _themeLabelEn(theme),
      scenarioId: scenario.id,
      titleZh: scenario.titleZh,
      titleEn: scenario.titleEn,
      contextZh: _eventBackgroundZh(index, age, scenario),
      contextEn: _eventBackgroundEn(index, age, scenario),
      candidatePoolSize: raw.length,
      eligiblePoolSize: eligible.length,
      choices: [
        for (final candidate in selected)
          LifeChoice(
            id: candidate.id,
            actionId: candidate.action.id,
            theme: candidate.scenario.theme,
            titleZh: _choiceTitleZh(candidate),
            titleEn: _choiceTitleEn(candidate),
            decisionZh: _decisionStoryZh(candidate),
            decisionEn: _decisionStoryEn(candidate),
            retirementProbability: _retirementProbabilityForAction(
              age,
              candidate.action,
            ),
            accidentProbability:
                ProbabilitySources.severeOffPitchAccidentProxyPerYear,
            delta: _legendaryCareerDelta(candidate.action.delta),
            trainingLoadDelta: candidate.action.trainingLoadDelta,
            injuryRiskDelta: candidate.action.injuryRiskDelta,
            causesTransfer: candidate.action.causesTransfer,
          ),
      ],
    );
  }

  String _choiceTitleZh(LifeCandidate candidate) {
    final action = candidate.action;
    final summary = switch (action.id) {
      'technical' => '用录像和重复训练修正技术',
      'intensive' => '接受超负荷计划冲击短期提升',
      'tactical' => '把额外训练时间交给战术研究',
      'team_session' => '组织队友合练建立默契',
      'recover' => '放弃加练并执行完整恢复',
      'report' => '停止硬撑并接受队医评估',
      'play_through' => '隐瞒不适继续争取出场',
      'specialist' => '暂停比赛寻找专项专家',
      'rehab_group' => '加入集体康复并按计划复出',
      'gamble' => '提前复出赌一次比赛机会',
      'stay' => '拒绝离队，留下争取位置',
      'move' => '正式提出永久转会',
      'loan' => '接受租借换取比赛时间',
      'negotiate' => '先与教练谈清竞技角色',
      'agent_pressure' => '授权经纪人完成转会',
      'safe' => '服从部署并优先控制风险',
      'creative' => '主动要球并承担创造责任',
      'physical' => '提高逼抢和身体对抗强度',
      'lead' => '接管场上沟通与站位指挥',
      'hero' => '无视保守方案争取个人终结',
      'quiet' => '拒绝回应并把注意力留给足球',
      'speak' => '正面说明事实与个人立场',
      'community' => '把关注转向长期社区项目',
      'commercial' => '接受商业合作扩大影响力',
      'confront' => '公开强硬回应外界批评',
      'voluntary_retirement' => '听从身体与内心，主动结束职业生涯',
      _ => action.titleZh,
    };
    return summary;
  }

  String _choiceTitleEn(LifeCandidate candidate) {
    final action = candidate.action;
    final summary = switch (action.id) {
      'technical' => 'use film and repetition to repair technique',
      'intensive' => 'accept overload training for a short-term leap',
      'tactical' => 'devote the extra work to tactical study',
      'team_session' => 'organise a team session to build chemistry',
      'recover' => 'cancel extra work and complete a recovery block',
      'report' => 'stop pushing through and accept a medical review',
      'play_through' => 'hide the discomfort and keep chasing minutes',
      'specialist' => 'pause competition and consult a specialist',
      'rehab_group' => 'join group rehab and follow the return plan',
      'gamble' => 'return early and gamble on one match',
      'stay' => 'reject the exit and fight for a place',
      'move' => 'submit a permanent transfer request',
      'loan' => 'take a loan for regular minutes',
      'negotiate' => 'agree a clear sporting role first',
      'agent_pressure' => 'authorise the agent to complete a transfer',
      'safe' => 'follow instructions and control the risk',
      'creative' => 'demand the ball and carry the creative burden',
      'physical' => 'raise the press and physical intensity',
      'lead' => 'take charge of positioning and communication',
      'hero' => 'reject caution and chase the decisive moment',
      'quiet' => 'decline a response and return focus to football',
      'speak' => 'state the facts and your position openly',
      'community' => 'redirect the attention into community work',
      'commercial' => 'accept the partnership and grow your profile',
      'confront' => 'answer the criticism in public',
      'voluntary_retirement' => 'leave the game on your own terms',
      _ => action.titleEn.toLowerCase(),
    };
    return summary;
  }

  String _eventBackgroundZh(int index, int age, LifeScenarioSeed scenario) {
    final scene = switch (scenario.theme) {
      LifeEventTheme.training =>
        '清晨的录像室里还留着上一场比赛的剪辑，训练场边已经摆好额外器材。助理教练把未来几周的计划摊开，'
            '说明一线队只会用一个训练周期检验改变，下一阶段的定位取决于你怎样分配训练与恢复。',
      LifeEventTheme.health =>
        '训练结束后，队医把检查影像、疼痛反馈和接下来的赛程放在同一张桌上。医疗组、教练和你对风险的判断并不一致，'
            '周末的名单近在眼前，眼前的出场机会与几个月后的身体状态发生了正面冲突。',
      LifeEventTheme.club =>
        '转会窗口进入倒计时，训练基地楼上的会议室连续亮了几个晚上。合同年限、出场顺位和外部报价同时摆到桌面上，'
            '教练强调球队计划，经纪人则要求你在窗口关闭前给出一份不会被误解的明确答复。',
      LifeEventTheme.match =>
        '比赛日前夜，战术板上的首发站位已经写好，球场外也开始聚集远道而来的球迷。教练交代了整体计划，'
            '但真正进入高压回合以后，传球、对抗和最后一击都必须由你在几秒钟内作出判断。',
      LifeEventTheme.publicLife =>
        '第二天的训练尚未开始，采访邀约、队内消息和社交媒体讨论已经一起涌来。更衣室里有人等你解释，俱乐部公关也准备好了口径，'
            '而你的回应会被队友、管理层和公众同时看见，并改变接下来彼此合作的方式。',
    };
    final status = switch ((overallRating, age, _injuries.isNotEmpty)) {
      (>= 85, _, _) => '你正处在世界级表现区间，任何决定都会被当作核心球员的表态。',
      (>= 76, _, _) => '你已经进入主力竞争的上游，俱乐部希望你承担更多责任。',
      (_, > ProbabilitySources.manualRetirementReferenceAge, true) =>
        '多年比赛和既往伤病让恢复变慢，职业生涯的下一步也被摆上桌面。',
      (_, > ProbabilitySources.manualRetirementReferenceAge, false) =>
        '你已经越过多数职业球员的常见退役区间，每个新赛季都需要重新评估代价。',
      _ => '你仍在争取稳定位置，这次选择会直接影响下一阶段的机会。',
    };
    final recentHonor = _championships.isEmpty
        ? ''
        : '更衣室里仍保留着你随${_championships.last.club}赢得'
              '${_championships.last.competition}后的记忆，但过去的冠军不会替你完成眼前的决定。';
    return '${_stageContextZh(index, age)}\n\n'
        '你当时 $age 岁，效力于${_currentClub.name}。${scenario.contextZh}$scene'
        '$status$recentHonor现在，所有人都在等你从下面几条道路中选出真正要执行的一条。';
  }

  String _eventBackgroundEn(int index, int age, LifeScenarioSeed scenario) {
    final scene = switch (scenario.theme) {
      LifeEventTheme.training =>
        'The previous match is still looping in the early-morning video room, '
            'while extra equipment waits beside the training pitch. The staff '
            'will judge any change over one training cycle, so your next role '
            'depends on how you divide work and recovery.',
      LifeEventTheme.health =>
        'After training, the doctor lays scans, pain reports and the coming '
            'fixtures on one table. You, the medical staff and the coach read '
            'the risk differently, placing this weekend against the condition '
            'of your body months from now.',
      LifeEventTheme.club =>
        'With the transfer window counting down, the meeting room above the '
            'training ground has stayed lit for several nights. Contract terms, '
            'squad order and outside offers are all on the table, and your agent '
            'needs an answer that cannot be mistaken before the deadline.',
      LifeEventTheme.match =>
        'On the eve of the match, the starting shape is already written on the '
            'tactics board and travelling supporters are gathering outside. '
            'The plan is set, but the pass, duel or final touch under pressure '
            'will still be yours to judge in a few seconds.',
      LifeEventTheme.publicLife =>
        'Before the next session begins, interview requests, dressing-room '
            'messages and online debate arrive together. Teammates want an '
            'explanation and the club has prepared its line, but everyone will '
            'see your response and remember how you chose to handle it.',
    };
    final status = switch ((overallRating, age, _injuries.isNotEmpty)) {
      (>= 85, _, _) =>
        'You are performing at world-class level, so every choice is read as '
            'a statement from a cornerstone player.',
      (>= 76, _, _) =>
        'You are now near the top of the selection order and the club expects '
            'greater responsibility.',
      (_, > ProbabilitySources.manualRetirementReferenceAge, true) =>
        'Years of matches and earlier injuries have slowed recovery, bringing '
            'the next stage of your career into the discussion.',
      (_, > ProbabilitySources.manualRetirementReferenceAge, false) =>
        'You have moved beyond the common retirement range, so each new season '
            'requires a fresh judgment of its cost.',
      _ =>
        'You are still fighting for a stable place, and this decision will '
            'shape the next opportunity.',
    };
    final recentHonor = _championships.isEmpty
        ? ''
        : ' The dressing room still remembers winning the '
              '${_championships.last.competition} with '
              '${_championships.last.club}, but that medal cannot make this '
              'decision for you.';
    return '${_stageContextEn(index, age)}\n\n'
        'You are $age and playing for ${_currentClub.name}. '
        '${scenario.contextEn} $scene $status$recentHonor Everyone now waits '
        'for you to choose one course below and carry it through.';
  }

  String _decisionStoryZh(LifeCandidate candidate) {
    return switch (candidate.action.id) {
      'technical' => '你请分析师剪出自己的动作片段，每次训练后重复练习同一项技术，直到教练确认动作已经稳定。',
      'intensive' => '你签下额外的体能与技术计划，把部分恢复日也交给高负荷训练，接受短期提升可能换来伤病的风险。',
      'tactical' => '你把个人加练时间转进战术室，逐段研究对手站位，并请教练按录像复盘你的每一次决策。',
      'team_session' => '你放弃一部分个人训练，召集同位置队友加练跑位、传球和沟通，把机会用于建立整条线路的默契。',
      'recover' => '你取消全部额外训练，按队医安排完成理疗、睡眠与低强度恢复，把下一场的竞争暂时放到身体之后。',
      'report' => '你向队医说明每一处不适并退出当日合练，接受影像检查，再由医疗组决定何时恢复对抗。',
      'play_through' => '你没有完整上报疼痛，只让理疗师做了固定处理便继续参加合练，准备照常争取下一场的名单。',
      'specialist' => '你申请暂停比赛并联系外部专项专家，把检查结果交给双方医疗团队共同制定新的康复方案。',
      'rehab_group' => '你加入伤员康复小组，按统一进度完成力量、跑动和有球测试，达标之前不要求提前复出。',
      'gamble' => '你要求医疗组提前放行，在没有完成全部测试时就回到比赛名单，接受旧伤复发也要抓住这次机会。',
      'stay' => '你拒绝了所有离队方案，继续在${_currentClub.name}训练，并要求教练用接下来的表现重新决定出场顺位。',
      'move' => '你让经纪人递交正式转会申请，明确接受永久离开${_currentClub.name}，并开始与新俱乐部谈合同。',
      'loan' => '你签下租借文件，暂时离开${_currentClub.name}，用一个赛季的稳定出场换取成长和未来位置。',
      'negotiate' => '你暂不离队，与教练写下位置、预计出场和阶段复盘安排，并以这份承诺作为继续留队的条件。',
      'agent_pressure' => '你授权经纪人接受外部报价并完成永久转会，也接受这次强硬离队可能损害原更衣室关系。',
      'safe' => '你严格执行教练分配的位置，减少冒险传球和前插，把控制失误与保护整体阵型放在个人表现之前。',
      'creative' => '你主动向队友要球，连续尝试穿透性传球和一对一突破，接受丢失球权也要创造决定性机会。',
      'physical' => '你把逼抢线向前推，在每次五五开的争夺中主动对抗，用更高跑动强度压迫对手出球。',
      'lead' => '你在场上召集队友，持续提醒站位、盯人与比赛节奏，主动接管原本由教练席完成的即时沟通。',
      'hero' => '你放弃保守处理，在关键回合主动索要最后一传、射门或定位球，决定亲自承担比赛结果。',
      'quiet' => '你拒绝采访和社交媒体回应，把第二天的公开行程全部取消，照常回到训练基地准备比赛。',
      'speak' => '你接受俱乐部安排的正式采访，逐项说明事实、个人立场和应承担的责任，不把问题留给传闻解释。',
      'community' => '你把外界关注转向一项长期社区计划，承诺每周固定投入时间，并让俱乐部公开项目进展。',
      'commercial' => '你签下商业合作并确认拍摄日程，接受竞技准备时间被切分，以此扩大个人品牌和收入。',
      'confront' => '你通过公开采访正面反驳批评，点明争议中的责任方，并承担这番回应可能继续制造冲突。',
      'voluntary_retirement' =>
        '你要求俱乐部安排一次最终体检和坦诚会谈，随后亲自通知教练与队友：完成本赛季告别后，不再签署新的球员合同。',
      _ => '你选择了“${candidate.action.titleZh}”，并与相关人员确认了具体执行方式。',
    };
  }

  String _decisionStoryEn(LifeCandidate candidate) {
    return switch (candidate.action.id) {
      'technical' =>
        'You ask the analyst to cut clips of your movement, then repeat the '
            'same technique after every session until the coach signs it off.',
      'intensive' =>
        'You accept extra physical and technical work, surrendering part of '
            'your recovery days for a quicker gain and its injury risk.',
      'tactical' =>
        'You move your extra work into the tactics room, study the opponent '
            'phase by phase and review each decision with the coach.',
      'team_session' =>
        'You give up solo work to organise a voluntary session on movement, '
            'passing and communication with the players around you.',
      'recover' =>
        'You cancel all extra work and complete the prescribed treatment, '
            'sleep and low-intensity block before competing for the next match.',
      'report' =>
        'You describe every symptom to the doctor, withdraw from training and '
            'accept scans before the medical team clears contact work.',
      'play_through' =>
        'You withhold the full extent of the pain, ask only for strapping and '
            'continue training so you can chase a place in the next squad.',
      'specialist' =>
        'You pause competition, consult an outside specialist and ask both '
            'medical teams to agree a new programme from the test results.',
      'rehab_group' =>
        'You join the injured-player group and complete strength, running and '
            'ball tests in order, refusing to return before every benchmark.',
      'gamble' =>
        'You request early clearance and return to the squad before completing '
            'every test, accepting the chance of recurrence for this match.',
      'stay' =>
        'You reject every exit route and remain at ${_currentClub.name}, asking '
            'the coach to reset the pecking order through your performances.',
      'move' =>
        'You ask your agent to submit a formal request, accept a permanent '
            'departure from ${_currentClub.name} and open contract talks elsewhere.',
      'loan' =>
        'You sign the loan papers and temporarily leave ${_currentClub.name}, '
            'trading one season of comfort for reliable match minutes.',
      'negotiate' =>
        'You postpone an exit and agree a written plan for position, expected '
            'minutes and review dates as the condition for staying.',
      'agent_pressure' =>
        'You authorise the agent to accept an outside offer and complete a '
            'permanent move, accepting the damage to old dressing-room ties.',
      'safe' =>
        'You hold the assigned position, cut out risky passes and forward runs, '
            'and put the team shape ahead of a personal highlight.',
      'creative' =>
        'You demand the ball and repeatedly attempt line-breaking passes and '
            'one-on-ones, accepting turnovers in pursuit of a decisive chance.',
      'physical' =>
        'You push the press higher and attack every even duel, using a greater '
            'running and contact load to disrupt the opponent.',
      'lead' =>
        'You gather teammates on the pitch and take charge of calls on shape, '
            'marking and tempo that would normally come from the touchline.',
      'hero' =>
        'You reject the cautious route and claim the final pass, shot or set '
            'piece, choosing to carry the result yourself.',
      'quiet' =>
        'You decline interviews and social-media replies, cancel the next '
            'day’s public schedule and return to the training ground.',
      'speak' =>
        'You sit for a formal club interview and state the facts, your position '
            'and your responsibility rather than leaving the story to rumour.',
      'community' =>
        'You redirect attention into a long-term community project, commit '
            'weekly time and let the club publish its progress.',
      'commercial' =>
        'You sign the commercial partnership and its filming schedule, '
            'accepting divided preparation time for a larger profile and income.',
      'confront' =>
        'You answer the criticism directly in public, name where responsibility '
            'lies and accept that the response may prolong the conflict.',
      'voluntary_retirement' =>
        'You request a final medical review and an honest meeting, then tell '
            'the coach and dressing room yourself that this farewell season '
            'will be your last as a professional player.',
      _ =>
        'You choose “${candidate.action.titleEn}” and agree the concrete '
            'implementation with everyone involved.',
    };
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
        : '你在${_currentClub.name}把决定落实到日常训练和比赛，队内角色也随表现逐渐变化。';
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
        : 'At ${_currentClub.name}, you carried the decision into daily '
              'training and matches as your role gradually changed.';
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

  LifeEventTheme _pickStageTheme(
    List<LifeCandidate> raw,
    List<LifeCandidate> eligible,
  ) {
    final themes = LifeEventTheme.values.where((theme) {
      final eligibleActions = eligible
          .where((candidate) => candidate.scenario.theme == theme)
          .map((candidate) => candidate.action.id)
          .toSet();
      final rawActions = raw
          .where((candidate) => candidate.scenario.theme == theme)
          .map((candidate) => candidate.action.id)
          .toSet();
      return eligibleActions.length >= 3 || rawActions.length >= 3;
    }).toList();
    final weighted = [
      for (final theme in themes)
        (
          theme: theme,
          weight: themeWeight(theme) * (theme == _lastTheme ? 0.28 : 1.0),
        ),
    ];
    final total = weighted.fold<double>(0, (sum, item) => sum + item.weight);
    var cursor = _random.nextDouble() * total;
    for (final item in weighted) {
      cursor -= item.weight;
      if (cursor <= 0) return item.theme;
    }
    return weighted.last.theme;
  }

  LifeScenarioSeed _pickScenario(List<LifeCandidate> candidates) {
    final scenarios = <String, LifeScenarioSeed>{
      for (final candidate in candidates)
        candidate.scenario.id: candidate.scenario,
    }.values.toList();
    final fresh = scenarios
        .where((scenario) => scenario.id != _lastScenarioId)
        .toList();
    final source = fresh.isEmpty ? scenarios : fresh;
    return source[_random.nextInt(source.length)];
  }

  bool _shouldOfferVoluntaryRetirement(int age, LifeEventTheme theme) {
    if (age <= ProbabilitySources.manualRetirementReferenceAge ||
        (theme != LifeEventTheme.health && theme != LifeEventTheme.club)) {
      return false;
    }
    final chance =
        0.18 +
        (age - ProbabilitySources.manualRetirementReferenceAge) * 0.045 +
        _injuries.length * 0.06 +
        max(0, 62 - attributes[PlayerAttribute.health]) / 340;
    return _random.nextDouble() < chance.clamp(0.18, 0.72);
  }

  AttributeDelta _legendaryCareerDelta(AttributeDelta delta) {
    return AttributeDelta({
      for (final entry in delta.values.entries)
        entry.key: entry.value > 0 ? (entry.value * 1.6).ceil() : entry.value,
    });
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

  void _maybeRecordChampionships(LifeStage stage, LifeChoice choice) {
    if (stage.age < 17) return;
    final clubStrength = switch (_currentClub.level) {
      1 => 1.0,
      2 => 0.72,
      3 => 0.45,
      _ => 0.18,
    };
    final ability = ((overallRating - 58) / 34).clamp(0.0, 1.0);
    final reputation = ((attributes[PlayerAttribute.reputation] - 40) / 45)
        .clamp(0.0, 1.0);
    final season = _seasonForAge(stage.age);
    final injuredThisSeason =
        _injuries.isNotEmpty && _injuries.last.season == season;
    final availability = injuredThisSeason ? 0.72 : 1.0;
    final matchMomentum =
        choice.theme == LifeEventTheme.match &&
            const {'creative', 'lead', 'hero'}.contains(choice.actionId)
        ? 0.025
        : 0.0;

    _rollChampionship(
      age: stage.age,
      season: season,
      competition: _leagueCompetition(_currentClub.country),
      probability:
          (0.035 +
              clubStrength * 0.29 +
              ability * 0.09 +
              reputation * 0.04 +
              matchMomentum) *
          availability,
    );
    _rollChampionship(
      age: stage.age,
      season: season,
      competition: _cupCompetition(_currentClub.country),
      probability:
          (0.025 + clubStrength * 0.12 + ability * 0.055 + matchMomentum) *
          availability,
    );
    if (_currentClub.level <= 3) {
      _rollChampionship(
        age: stage.age,
        season: season,
        competition: _continentalCompetition(_currentClub.country),
        probability:
            (0.004 +
                clubStrength * 0.07 +
                ability * 0.035 +
                matchMomentum / 2) *
            availability,
      );
    }
  }

  void _rollChampionship({
    required int age,
    required String season,
    required String competition,
    required double probability,
  }) {
    if (_random.nextDouble() >= probability.clamp(0.0, 0.55)) return;
    final championship = _LifeChampionship(
      age: age,
      season: season,
      club: _currentClub.name,
      competition: competition,
    );
    if (_championships.any(
      (item) =>
          item.season == championship.season &&
          item.club == championship.club &&
          item.competition == championship.competition,
    )) {
      return;
    }
    _championships.add(championship);
  }

  String _eventWithChampionships(int age, String event) {
    final competitions = _championships
        .where((item) => item.age == age)
        .map((item) => item.competition)
        .toList();
    if (competitions.isEmpty) return event;
    return '$event；随${_championships.firstWhere((item) => item.age == age).club}'
        '赢得${competitions.join('、')}冠军';
  }

  String _seasonForAge(int age) {
    final birthYear = 2011 - _stageAges.first;
    final year = birthYear + age;
    return '$year/${year + 1}';
  }

  String _leagueCompetition(String country) => switch (country) {
    '英格兰' => '英格兰超级联赛',
    '西班牙' => '西班牙足球甲级联赛',
    '德国' => '德国足球甲级联赛',
    '法国' => '法国足球甲级联赛',
    '意大利' => '意大利足球甲级联赛',
    '葡萄牙' => '葡萄牙超级联赛',
    '奥地利' => '奥地利足球甲级联赛',
    '巴西' => '巴西足球甲级联赛',
    '阿根廷' => '阿根廷足球甲级联赛',
    '美国' => '美国职业足球大联盟',
    '墨西哥' => '墨西哥足球超级联赛',
    '日本' => '日本J1联赛',
    '韩国' => '韩国K联赛1',
    '沙特阿拉伯' => '沙特职业联赛',
    '阿联酋' => '阿联酋职业联赛',
    '埃及' => '埃及超级联赛',
    '摩洛哥' => '摩洛哥足球甲级联赛',
    '南非' => '南非足球超级联赛',
    '突尼斯' => '突尼斯足球甲级联赛',
    '新西兰' => '新西兰全国联赛',
    _ => '$country顶级联赛',
  };

  String _cupCompetition(String country) => switch (country) {
    '英格兰' => '英格兰足总杯',
    '西班牙' => '西班牙国王杯',
    '德国' => '德国足协杯',
    '法国' => '法国杯',
    '意大利' => '意大利杯',
    '葡萄牙' => '葡萄牙杯',
    '奥地利' => '奥地利杯',
    '巴西' => '巴西杯',
    '阿根廷' => '阿根廷杯',
    '美国' => '美国公开杯',
    '墨西哥' => '墨西哥冠军杯',
    '日本' => '日本天皇杯',
    '韩国' => '韩国杯',
    '沙特阿拉伯' => '沙特国王杯',
    '阿联酋' => '阿联酋总统杯',
    '埃及' => '埃及杯',
    '摩洛哥' => '摩洛哥王座杯',
    '南非' => '南非足总杯',
    '突尼斯' => '突尼斯杯',
    '新西兰' => '新西兰查塔姆杯',
    _ => '$country全国杯赛',
  };

  String _continentalCompetition(String country) {
    return switch (FootballCatalog.confederationForCountry(country)) {
      'UEFA' => '欧洲冠军联赛',
      'CONMEBOL' => '南美解放者杯',
      'Concacaf' => '中北美洲及加勒比海冠军杯',
      'AFC' => '亚足联冠军精英联赛',
      'CAF' => '非洲冠军联赛',
      'OFC' => '大洋洲冠军联赛',
      _ => '洲际俱乐部冠军赛',
    };
  }

  void _maybeRecordInjury(LifeStage stage, LifeChoice choice) {
    final base =
        injuryRisk +
        trainingLoad ~/ 2 +
        (100 - attributes[PlayerAttribute.health]) ~/ 2;
    final themeBonus = choice.theme == LifeEventTheme.health ? 14 : 0;
    if (_random.nextInt(240) >= base + themeBonus) return;
    final days = 7 + _random.nextInt(55) + injuryRisk ~/ 3;
    _injuries.add(
      InjurySpell(
        season: _seasonForAge(stage.age),
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

  int _nextOpenEndedAge(int currentAge) {
    final seasonsUntilNextDecision = 1 + _random.nextInt(2);
    return min(60, currentAge + seasonsUntilNextDecision);
  }

  void _maybeTriggerRetirement(LifeStage stage, LifeChoice choice) {
    if (_random.nextDouble() < choice.accidentProbability) {
      _retirementOutcome = _retirementStory(
        stage.age,
        LifeRetirementCause.accident,
      );
      return;
    }
    if (_random.nextDouble() < choice.retirementProbability) {
      final cause = _pickRetirementCause(stage.age, choice);
      if (cause == LifeRetirementCause.acuteInjury) {
        _recordCareerEndingInjury(stage.age);
      }
      _retirementOutcome = _retirementStory(stage.age, cause);
    }
  }

  double _retirementProbabilityForAction(int age, LifeActionSeed action) {
    final projected = attributes.apply(_legendaryCareerDelta(action.delta));
    final projectedInjuryRisk = (injuryRisk + action.injuryRiskDelta).clamp(
      0,
      100,
    );
    final projectedTrainingLoad = (trainingLoad + action.trainingLoadDelta)
        .clamp(0, 100);
    var probability = switch (age) {
      <= 20 => 0.003,
      <= 24 => 0.004,
      <= 27 => 0.007,
      <= 29 => 0.012,
      <= 30 => 0.035,
      <= 32 => 0.075,
      <= 34 => 0.160,
      <= 36 => 0.260,
      <= 38 => 0.380,
      <= 40 => 0.500,
      <= 43 => 0.620,
      <= 46 => 0.720,
      <= 50 => 0.800,
      <= 55 => 0.870,
      _ => 0.930,
    };
    probability += max(0, projectedInjuryRisk - 28) / 850;
    probability += max(0, projectedTrainingLoad - 52) / 1100;
    probability += max(0, 58 - projected[PlayerAttribute.health]) / 620;
    probability += min(0.075, _injuries.length * 0.012);
    if (_injuries.isNotEmpty && _injuries.last.daysAbsent >= 90) {
      probability += 0.055;
    }
    probability += switch (action.id) {
      'play_through' || 'gamble' => 0.075,
      'intensive' => 0.040,
      'physical' || 'hero' => 0.022,
      _ => 0,
    };
    if (age >= 29 && projected[PlayerAttribute.reputation] < 45) {
      probability += (45 - projected[PlayerAttribute.reputation]) / 360;
    }
    if (action.id == 'recover' ||
        action.id == 'report' ||
        action.id == 'specialist') {
      probability *= 0.68;
    }
    if (age < 30) {
      probability *= ProbabilitySources.under30RetirementRiskScale;
    }
    return probability.clamp(0.001, age >= 56 ? 0.96 : 0.93).toDouble();
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
      LifeRetirementCause.accident => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '场外严重车祸终止生涯',
        titleEn: 'A serious road crash ended the career',
        contextZh:
            '完成这次决定后的几天，你在离开训练基地的返程途中遭遇严重车祸。'
            '手术保住了日常活动能力，但长期评估确认身体无法再承受职业比赛，'
            '你的球员生涯在 $age 岁意外结束。',
        contextEn:
            'Days after this decision, you were seriously injured in a road '
            'crash while returning from the training ground. Surgery '
            'preserved everyday mobility, but long-term assessment ruled out '
            'professional football, ending the career at $age.',
      ),
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
      LifeRetirementCause.voluntary => LifeRetirementOutcome(
        age: age,
        cause: cause,
        titleZh: '在仍有选择时主动告别',
        titleEn: 'Retired on your own terms',
        contextZh:
            '$age 岁时，你在${_currentClub.name}完成最终体检和赛季复盘。'
            '俱乐部仍愿意讨论下一份合同，但你决定把告别留在自己手中，'
            '亲自通知队友并完成最后一场主场比赛后退役。',
        contextEn:
            'At $age, you completed a final medical review and season debrief '
            'with ${_currentClub.name}. The club was still willing to discuss '
            'another contract, but you chose the timing yourself, told the '
            'dressing room and retired after one last home match.',
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
        attribute: 55 + random.nextInt(16),
    };
    values[PlayerAttribute.leftArm] = 55 + random.nextInt(15);
    values[PlayerAttribute.rightArm] = 55 + random.nextInt(15);
    if (random.nextBool()) {
      values[PlayerAttribute.leftLeg] = 70 + random.nextInt(16);
      values[PlayerAttribute.rightLeg] = 55 + random.nextInt(15);
    } else {
      values[PlayerAttribute.rightLeg] = 70 + random.nextInt(16);
      values[PlayerAttribute.leftLeg] = 55 + random.nextInt(15);
    }
    switch (position) {
      case '门将':
        values[PlayerAttribute.leftArm] = 72 + random.nextInt(16);
        values[PlayerAttribute.rightArm] = 72 + random.nextInt(16);
        values[PlayerAttribute.decisionMaking] = 66 + random.nextInt(15);
        break;
      case '中后卫':
        values[PlayerAttribute.strength] = 70 + random.nextInt(16);
        values[PlayerAttribute.resilience] = 66 + random.nextInt(15);
        break;
      case '边后卫':
      case '边锋':
        values[PlayerAttribute.speed] = 72 + random.nextInt(16);
        values[PlayerAttribute.stamina] = 66 + random.nextInt(16);
        break;
      case '后腰':
      case '中前卫':
        values[PlayerAttribute.stamina] = 70 + random.nextInt(16);
        values[PlayerAttribute.teamwork] = 66 + random.nextInt(16);
        break;
      case '前腰':
        values[PlayerAttribute.technique] = 72 + random.nextInt(16);
        values[PlayerAttribute.intelligence] = 66 + random.nextInt(16);
        break;
      case '中锋':
        values[PlayerAttribute.strength] = 68 + random.nextInt(17);
        values[PlayerAttribute.technique] = 68 + random.nextInt(17);
        break;
    }
    return PlayerAttributes(values);
  }
}

String _themeLabelZh(LifeEventTheme theme) => switch (theme) {
  LifeEventTheme.training => '训练与成长',
  LifeEventTheme.health => '伤病与恢复',
  LifeEventTheme.club => '转会与合同',
  LifeEventTheme.match => '出场与比赛',
  LifeEventTheme.publicLife => '更衣室与场外',
};

String _themeLabelEn(LifeEventTheme theme) => switch (theme) {
  LifeEventTheme.training => 'Training & growth',
  LifeEventTheme.health => 'Injury & recovery',
  LifeEventTheme.club => 'Transfers & contracts',
  LifeEventTheme.match => 'Selection & matches',
  LifeEventTheme.publicLife => 'Dressing room & public life',
};

const _voluntaryRetirementAction = LifeActionSeed(
  id: 'voluntary_retirement',
  titleZh: '主动退役',
  titleEn: 'Retire voluntarily',
  descriptionZh: '在仍有合同和选择时，由球员亲自决定告别。',
  descriptionEn: 'Choose the timing of retirement while another path remains.',
  delta: AttributeDelta({
    PlayerAttribute.resilience: 2,
    PlayerAttribute.morale: 2,
  }),
  trainingLoadDelta: -30,
  injuryRiskDelta: -20,
  baseWeight: 1,
);

const _injuryTypes = ['肌肉拉伤', '脚踝扭伤', '膝部炎症', '腿筋伤势', '撞击伤'];

class _LifeChampionship {
  const _LifeChampionship({
    required this.age,
    required this.season,
    required this.club,
    required this.competition,
  });

  final int age;
  final String season;
  final String club;
  final String competition;

  String get labelZh => '$age 岁 · $season 赛季 · $club · $competition冠军';
}

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
