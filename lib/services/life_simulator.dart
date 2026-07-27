import 'dart:math';

import '../data/football_catalog.dart';
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

  String get description => switch (this) {
    CareerDecisionDensity.milestones => '5 次核心抉择，快速完成一段生涯。',
    CareerDecisionDensity.everyThreeYears => '8 次选择，覆盖成长、巅峰与转型。',
    CareerDecisionDensity.everyTwoYears => '11 次选择，更细致地管理竞技状态。',
    CareerDecisionDensity.everyYear => '15–36 岁每年决策，共 22 次完整体验。',
  };

  String get estimatedTime => switch (this) {
    CareerDecisionDensity.milestones => '约 2 分钟',
    CareerDecisionDensity.everyThreeYears => '约 4 分钟',
    CareerDecisionDensity.everyTwoYears => '约 6 分钟',
    CareerDecisionDensity.everyYear => '约 10 分钟',
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

  List<LifeStage> buildStages() {
    return [for (final age in ages) _yearlyTemplates[age - 15].build(age)];
  }
}

class LifeChoice {
  const LifeChoice({
    required this.title,
    required this.description,
    required this.ratingDelta,
    required this.reputationDelta,
    required this.stabilityDelta,
  });

  final String title;
  final String description;
  final int ratingDelta;
  final int reputationDelta;
  final int stabilityDelta;
}

class LifeStage {
  const LifeStage({
    required this.age,
    required this.title,
    required this.context,
    required this.choices,
  });

  final int age;
  final String title;
  final String context;
  final List<LifeChoice> choices;
}

class LifeDecision {
  const LifeDecision(this.stage, this.choice);

  final LifeStage stage;
  final LifeChoice choice;
}

class LifeSimulator {
  LifeSimulator({
    required this.nationality,
    required this.position,
    this.density = CareerDecisionDensity.milestones,
    Random? random,
  }) : _random = random ?? Random(),
       stages = density.buildStages();

  final String nationality;
  final String position;
  final CareerDecisionDensity density;
  final Random _random;
  final List<LifeStage> stages;
  final List<LifeDecision> decisions = [];

  void choose(int stageIndex, int choiceIndex) {
    if (stageIndex != decisions.length) {
      throw StateError('Choices must be made in stage order.');
    }
    final stage = stages[stageIndex];
    decisions.add(LifeDecision(stage, stage.choices[choiceIndex]));
  }

  PlayerProfile finish({String name = '我的球员'}) {
    if (decisions.length != stages.length) {
      throw StateError('Every career stage needs a choice.');
    }

    final ratingBonus = _normalizedScore(
      (decision) => decision.choice.ratingDelta,
    );
    final reputation = _normalizedScore(
      (decision) => decision.choice.reputationDelta,
    );
    final stability = _normalizedScore(
      (decision) => decision.choice.stabilityDelta,
    );
    final initialRating = (54 + ratingBonus ~/ 3).clamp(50, 70);
    final peakRating = (68 + ratingBonus + reputation ~/ 3).clamp(
      initialRating + 4,
      94,
    );
    final retirementAge = _retirementAge();
    final finalRating = max(58, peakRating - 12);
    final birthYear = 2006 + _random.nextInt(5);
    final careerBuild = _buildCareer(
      birthYear: birthYear,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: finalRating,
      retirementAge: retirementAge,
    );
    final career = careerBuild.chapters;
    final transfers = careerBuild.transfers;
    final positionStyles =
        FootballCatalog.positionStyles[position] ?? const ['全能型球员'];
    final scoringRate = _scoringRate();
    final careerYears = retirementAge - 16;
    final appearances = max(
      100,
      (careerYears * (25 + stability * 0.45) + _random.nextInt(45)).round(),
    );
    final starts = min(
      appearances,
      (appearances * (0.68 + ratingBonus * 0.006)).round(),
    );
    final substituteAppearances = appearances - starts;
    final minutesPlayed =
        starts * (74 + _random.nextInt(12)) +
        substituteAppearances * (17 + _random.nextInt(17));
    final goals = (appearances * scoringRate).round();
    final assists = (appearances * (scoringRate * 0.75 + 0.04)).round();
    final nationalCaps = max(0, reputation * 3 + _random.nextInt(12));
    final titles = max(0, reputation ~/ 4);
    final transferFee = transfers.fold<double>(
      0,
      (sum, transfer) => sum + transfer.feeMillions,
    );
    final stats = CareerStats(
      appearances: appearances,
      starts: starts,
      substituteAppearances: substituteAppearances,
      minutesPlayed: minutesPlayed,
      goals: goals,
      assists: assists,
      yellowCards: (appearances * _cardRate()).round(),
      secondYellowCards: (appearances * _cardRate() * 0.035).round(),
      redCards: (appearances * _cardRate() * 0.02).round(),
      cleanSheets: position == '门将'
          ? (appearances * (0.22 + ratingBonus * 0.004)).round()
          : 0,
      penaltiesScored: position == '中锋' || position == '前腰'
          ? (goals * 0.1).round()
          : 0,
      nationalCaps: nationalCaps,
      nationalGoals: max(0, (nationalCaps * scoringRate * 0.75).round()),
      transferCount: transfers.length,
      totalTransferFeeMillions: double.parse(transferFee.toStringAsFixed(1)),
      championships: List.generate(titles, (index) => '重要赛事冠军 ×1'),
      personalHonors: [
        if (reputation >= 12) '联赛最佳阵容',
        if (reputation >= 17) '年度最佳球员候选',
        if (stability >= 12) '俱乐部功勋球员',
      ],
    );
    final injuries = _injuries(
      birthYear: birthYear,
      stability: stability,
      retirementAge: retirementAge,
    );
    final marketValues = _marketValues(
      career: career,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: finalRating,
    );
    final lastClub = career.last.club;
    final lastMoveAge = transfers.isEmpty ? 17 : transfers.last.age;

    return PlayerProfile(
      mode: CareerMode.life,
      name: name,
      birthDate: _randomDate(birthYear),
      birthPlace: _birthPlace(),
      developmentAssociation: nationality,
      nationality: nationality,
      citizenships: [nationality],
      preferredFoot: _random.nextInt(100) < 24 ? '左脚' : '右脚',
      heightCm: 170 + _random.nextInt(20),
      weightKg: 64 + _random.nextInt(20),
      shirtNumber: _shirtNumber(),
      primaryPosition: position,
      secondaryPosition:
          (FootballCatalog.secondaryPositions[position] ?? [position]).first,
      academy: decisions.first.choice.title == '留在家乡' ? '家乡职业青训学院' : '国际职业青训体系',
      debutAge: 17,
      retirementAge: retirementAge,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: finalRating,
      playStyle: positionStyles[_random.nextInt(positionStyles.length)],
      injuryRecord: injuries.isEmpty
          ? '科学管理负荷，职业生涯较为健康'
          : stability >= 6
          ? '经历短期伤病后稳定回归'
          : '经历伤病考验后重返赛场',
      currentClub: lastClub,
      currentLeague: _leagueFor(lastClub),
      joinedClubDate: '01/07/${birthYear + lastMoveAge}',
      contractUntil: '30/06/${birthYear + retirementAge}',
      agent: FootballCatalog
          .agents[_random.nextInt(FootballCatalog.agents.length)],
      marketValueMillions: marketValues.fold<double>(
        0,
        (highest, point) =>
            point.valueMillions > highest ? point.valueMillions : highest,
      ),
      nationalTeam: nationalCaps == 0 ? '未入选成年国家队' : '$nationality国家队',
      nationalTeamDebut: nationalCaps == 0
          ? '未记录'
          : _randomDate(birthYear + 20 + _random.nextInt(4)),
      career: career,
      transferHistory: transfers,
      injuryHistory: injuries,
      marketValueHistory: marketValues,
      competitionStats: _competitionStats(stats),
      stats: stats,
    );
  }

  int _normalizedScore(int Function(LifeDecision decision) valueOf) {
    final raw = decisions.fold<int>(
      0,
      (sum, decision) => sum + valueOf(decision),
    );
    return (raw * 5 / decisions.length).round();
  }

  int _retirementAge() {
    final finalChoice = decisions.last.choice.title;
    if (finalChoice.contains('巅峰退役') ||
        finalChoice.contains('立即告别') ||
        finalChoice.contains('本季退役')) {
      return decisions.last.stage.age;
    }
    return max(37, decisions.last.stage.age + 1);
  }

  _CareerBuild _buildCareer({
    required int birthYear,
    required int initialRating,
    required int peakRating,
    required int finalRating,
    required int retirementAge,
  }) {
    final chapters = <CareerChapter>[];
    final transfers = <TransferRecord>[];
    var currentClub = decisions.first.choice.title.contains('家乡')
        ? '家乡职业俱乐部'
        : '国际职业青训体系';

    for (var index = 0; index < decisions.length; index++) {
      final decision = decisions[index];
      final nextClub = _destinationClub(decision.choice, currentClub);
      if (index > 0 && nextClub != currentClub) {
        final type = _transferType(decision.choice);
        final fee = type == '永久转会'
            ? double.parse(
                (4 + index * 2.7 + _random.nextDouble() * 12)
                    .clamp(0.2, 120)
                    .toStringAsFixed(1),
              )
            : 0.0;
        final year = birthYear + decision.stage.age;
        transfers.add(
          TransferRecord(
            season: _seasonFor(year),
            age: decision.stage.age,
            fromClub: currentClub,
            toClub: nextClub,
            type: type,
            feeMillions: fee,
          ),
        );
        currentClub = nextClub;
      }
      chapters.add(
        CareerChapter(
          age: decision.stage.age,
          club: currentClub,
          event: '${decision.stage.title}：${decision.choice.title}',
          rating: _ratingAtAge(
            age: decision.stage.age,
            initialRating: initialRating,
            peakRating: peakRating,
            finalRating: finalRating,
            retirementAge: retirementAge,
          ),
        ),
      );
    }
    return _CareerBuild(chapters, transfers);
  }

  int _ratingAtAge({
    required int age,
    required int initialRating,
    required int peakRating,
    required int finalRating,
    required int retirementAge,
  }) {
    const peakAge = 27;
    if (age <= peakAge) {
      final progress = ((age - 15) / (peakAge - 15)).clamp(0.0, 1.0);
      return (initialRating + (peakRating - initialRating) * progress).round();
    }
    final progress = ((age - peakAge) / max(1, retirementAge - peakAge)).clamp(
      0.0,
      1.0,
    );
    return (peakRating - (peakRating - finalRating) * progress).round();
  }

  String _destinationClub(LifeChoice choice, String currentClub) {
    final title = choice.title;
    if (title.contains('豪门') || title.contains('争冠')) return '欧洲争冠俱乐部';
    if (title.contains('外租')) return '租借培养俱乐部';
    if (title.contains('海外') || title.contains('新联赛')) {
      return '海外职业俱乐部';
    }
    if (title.contains('母队') || title.contains('家乡')) return '家乡职业俱乐部';
    if (title.contains('转会') ||
        title.contains('报价') ||
        title.contains('顶级联赛')) {
      return '欧洲顶级联赛俱乐部';
    }
    return currentClub;
  }

  String _transferType(LifeChoice choice) {
    if (choice.title.contains('外租')) return '租借';
    if (choice.title.contains('合同结束') ||
        choice.title.contains('新联赛') ||
        choice.title.contains('母队')) {
      return '自由转会';
    }
    return '永久转会';
  }

  List<InjurySpell> _injuries({
    required int birthYear,
    required int stability,
    required int retirementAge,
  }) {
    final count = stability >= 14
        ? 0
        : stability >= 6
        ? 1
        : 2;
    return List.generate(count, (index) {
      final age = 21 + _random.nextInt(max(1, retirementAge - 21));
      final days = stability < 0
          ? 70 + _random.nextInt(100)
          : 14 + _random.nextInt(45);
      return InjurySpell(
        season: _seasonFor(birthYear + age),
        type: days >= 70 ? '膝关节伤势' : '肌肉损伤',
        daysAbsent: days,
        matchesMissed: max(1, (days / 7.2).round()),
      );
    })..sort((a, b) => a.season.compareTo(b.season));
  }

  List<MarketValuePoint> _marketValues({
    required List<CareerChapter> career,
    required int retirementAge,
    required int initialRating,
    required int peakRating,
    required int finalRating,
  }) {
    final ages = {
      for (final chapter in career) chapter.age,
      retirementAge,
    }.toList()..sort();
    return [
      for (final age in ages)
        MarketValuePoint(
          age: age,
          valueMillions: age == retirementAge
              ? 0
              : double.parse(
                  (pow(
                            max(
                              0,
                              _ratingAtAge(
                                    age: age,
                                    initialRating: initialRating,
                                    peakRating: peakRating,
                                    finalRating: finalRating,
                                    retirementAge: retirementAge,
                                  ) -
                                  55,
                            ),
                            2,
                          ) /
                          10 *
                          max(0.25, 1 - max(0, age - 29) * 0.08))
                      .clamp(0.1, 180)
                      .toStringAsFixed(1),
                ),
        ),
    ];
  }

  List<CompetitionStats> _competitionStats(CareerStats stats) {
    final leagueAppearances = (stats.appearances * 0.7).round();
    final cupAppearances = (stats.appearances * 0.12).round();
    final leagueGoals = (stats.goals * 0.7).round();
    final cupGoals = (stats.goals * 0.12).round();
    final leagueAssists = (stats.assists * 0.7).round();
    final cupAssists = (stats.assists * 0.12).round();
    final leagueMinutes = (stats.minutesPlayed * 0.7).round();
    final cupMinutes = (stats.minutesPlayed * 0.12).round();
    return [
      CompetitionStats(
        competition: '国内联赛',
        appearances: leagueAppearances,
        goals: leagueGoals,
        assists: leagueAssists,
        minutesPlayed: leagueMinutes,
      ),
      CompetitionStats(
        competition: '国内杯赛',
        appearances: cupAppearances,
        goals: cupGoals,
        assists: cupAssists,
        minutesPlayed: cupMinutes,
      ),
      CompetitionStats(
        competition: '洲际俱乐部赛事',
        appearances: stats.appearances - leagueAppearances - cupAppearances,
        goals: stats.goals - leagueGoals - cupGoals,
        assists: stats.assists - leagueAssists - cupAssists,
        minutesPlayed: stats.minutesPlayed - leagueMinutes - cupMinutes,
      ),
    ];
  }

  double _scoringRate() => switch (position) {
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

  double _cardRate() => switch (position) {
    '门将' => 0.025,
    '中后卫' || '边后卫' || '后腰' => 0.16,
    '中前卫' => 0.12,
    _ => 0.07,
  };

  int _shirtNumber() {
    final numbers = FootballCatalog.squadNumbers[position] ?? const [10];
    return numbers[_random.nextInt(numbers.length)];
  }

  String _birthPlace() {
    final places = FootballCatalog.birthPlaces[nationality];
    if (places == null) return '$nationality某城市';
    return places[_random.nextInt(places.length)];
  }

  String _leagueFor(String club) {
    if (club.contains('欧洲')) return '欧洲顶级联赛';
    if (club.contains('海外')) return '海外顶级联赛';
    return '$nationality顶级联赛';
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
}

class _CareerBuild {
  const _CareerBuild(this.chapters, this.transfers);

  final List<CareerChapter> chapters;
  final List<TransferRecord> transfers;
}

class _EventTemplate {
  const _EventTemplate({
    required this.title,
    required this.context,
    required this.options,
  });

  final String title;
  final String context;
  final List<(String, String)> options;

  LifeStage build(int age) {
    return LifeStage(
      age: age,
      title: title,
      context: context,
      choices: [
        for (var index = 0; index < options.length; index++)
          LifeChoice(
            title: options[index].$1,
            description: options[index].$2,
            ratingDelta: _choiceScores[index].$1,
            reputationDelta: _choiceScores[index].$2,
            stabilityDelta: _choiceScores[index].$3,
          ),
      ],
    );
  }
}

const _choiceScores = <(int, int, int)>[(4, 3, -2), (2, 2, 2), (1, 0, 4)];

const _yearlyTemplates = <_EventTemplate>[
  _EventTemplate(
    title: '青训岔路',
    context: '两家风格完全不同的青训体系同时发来邀请。',
    options: [
      ('加入豪门梯队', '竞争残酷，但训练资源顶级。'),
      ('前往海外学院', '学习新的足球语言，保持成长与风险的平衡。'),
      ('留在家乡', '获得稳定出场时间，从熟悉的环境开始积累。'),
    ],
  ),
  _EventTemplate(
    title: '身体成长',
    context: '身体进入快速发育期，教练组希望你选择一套长期训练方向。',
    options: [
      ('强化爆发力', '高强度训练争取更快进入成年队。'),
      ('全面发展', '均衡技术、力量与耐力。'),
      ('保护性训练', '控制负荷，优先降低发育期伤病风险。'),
    ],
  ),
  _EventTemplate(
    title: '职业首秀窗口',
    context: '一线队出现临时空缺，你必须决定是否提前跨级竞争。',
    options: [
      ('争取立即首秀', '主动要求进入比赛名单。'),
      ('接受轮换', '在一线队训练并等待合适机会。'),
      ('继续梯队主力', '用完整赛季打磨基础。'),
    ],
  ),
  _EventTemplate(
    title: '出场时间',
    context: '新赛季的角色尚未确定，三条道路通向不同的比赛强度。',
    options: [
      ('挑战顶级联赛', '接受有限时间，争取在最高舞台站稳。'),
      ('短期外租', '用稳定比赛证明自己。'),
      ('留队竞争', '维持熟悉节奏，逐步增加出场。'),
    ],
  ),
  _EventTemplate(
    title: '首份职业合同',
    context: '经纪人带来三份合同，每一份都意味着不同的成长曲线。',
    options: [
      ('接受豪门报价', '进入争冠阵容，承担最高强度竞争。'),
      ('签下成长合同', '选择重视年轻人的俱乐部。'),
      ('与母队长约续约', '换取明确角色和长期信任。'),
    ],
  ),
  _EventTemplate(
    title: '外租窗口',
    context: '俱乐部认为你需要更多成年比赛，但目的地风格差异很大。',
    options: [
      ('外租海外强队', '更快适应高压比赛。'),
      ('外租同级球队', '保证比赛强度与适应成本平衡。'),
      ('拒绝外租', '留队争取教练的长期计划。'),
    ],
  ),
  _EventTemplate(
    title: '战术角色',
    context: '新教练希望重塑球队，你可以争取核心位置或接受功能性角色。',
    options: [
      ('竞争战术核心', '承担更多球权与责任。'),
      ('学习复合位置', '提升多位置适应能力。'),
      ('专注本职位置', '用稳定表现巩固熟悉角色。'),
    ],
  ),
  _EventTemplate(
    title: '教练更迭',
    context: '主教练突然离任，新的战术体系可能改变你的顺位。',
    options: [
      ('主动要求转会', '趁市场关注度高寻找更大舞台。'),
      ('说服新教练', '通过季前训练争取位置。'),
      ('接受轮换角色', '先维持出场，再等待体系稳定。'),
    ],
  ),
  _EventTemplate(
    title: '经纪人与续约',
    context: '合同进入关键年，经纪团队对你的下一步提出不同判断。',
    options: [
      ('冲击顶薪合同', '用短期压力争取市场地位。'),
      ('加入长期计划', '接受合理薪资和清晰竞技承诺。'),
      ('留在原团队', '减少场外变化，专注赛季。'),
    ],
  ),
  _EventTemplate(
    title: '转会市场关注',
    context: '多家俱乐部同时考察，你需要决定如何回应报价。',
    options: [
      ('接受跨联赛转会', '进入陌生环境追求竞技上限。'),
      ('等待合适报价', '保持开放，但不仓促离队。'),
      ('公开承诺留队', '换取教练和球迷的长期信任。'),
    ],
  ),
  _EventTemplate(
    title: '生涯上升期',
    context: '连续稳定表现让你站到更大的舞台入口。',
    options: [
      ('冲击豪门', '加入争冠球队，接受最高强度竞争。'),
      ('成为球队核心', '承担更多责任并继续成长。'),
      ('与现俱乐部续约', '锁定角色和长期稳定。'),
    ],
  ),
  _EventTemplate(
    title: '位置转型',
    context: '数据团队认为你在另一个位置上可能拥有更长的巅峰期。',
    options: [
      ('彻底改变位置', '承担短期波动，争取能力突破。'),
      ('增加第二位置', '扩大适用场景，不放弃原有优势。'),
      ('保持原有定位', '继续精进最成熟的比赛方式。'),
    ],
  ),
  _EventTemplate(
    title: '冠军窗口',
    context: '球队距离重要冠军只差最后一步，赛程负荷也来到极限。',
    options: [
      ('全力冲击冠军', '接受疲劳风险，争取决定性表现。'),
      ('科学分配体能', '在关键场次投入更多精力。'),
      ('服从轮换计划', '优先维持整个赛季的可用性。'),
    ],
  ),
  _EventTemplate(
    title: '国家队竞争',
    context: '国家队大名单竞争激烈，俱乐部同时希望你专注联赛。',
    options: [
      ('争取国家队核心', '承担双线压力，追求最高声望。'),
      ('平衡双线赛程', '与双方教练共同管理负荷。'),
      ('暂缓国家队比赛', '优先保证俱乐部稳定出场。'),
    ],
  ),
  _EventTemplate(
    title: '商业与竞技',
    context: '个人影响力快速上升，商业活动开始挤占恢复时间。',
    options: [
      ('扩大个人品牌', '把握巅峰期的公众关注。'),
      ('限制商业日程', '保留少量合作并确保训练。'),
      ('专注足球', '暂停大部分场外活动。'),
    ],
  ),
  _EventTemplate(
    title: '巅峰抉择',
    context: '国家队大赛和俱乐部关键赛程发生冲突，身体也需要管理。',
    options: [
      ('为国出战', '承担国家队核心责任。'),
      ('平衡俱乐部与国家队', '通过轮换兼顾两条战线。'),
      ('接受完整轮休', '优先保障长期健康。'),
    ],
  ),
  _EventTemplate(
    title: '负荷管理',
    context: '恢复速度开始变化，教练组邀请你共同制定出场计划。',
    options: [
      ('继续全勤', '维持核心身份并承受更高身体风险。'),
      ('选择性轮休', '优先参加关键比赛。'),
      ('减少连续首发', '主动延长职业生涯。'),
    ],
  ),
  _EventTemplate(
    title: '更衣室领袖',
    context: '年轻球员需要榜样，而你仍希望保持自己的竞技影响力。',
    options: [
      ('担任场上队长', '承担成绩与更衣室的双重压力。'),
      ('共享领导职责', '兼顾个人表现和团队建设。'),
      ('专注传帮带', '把更多机会让给下一代。'),
    ],
  ),
  _EventTemplate(
    title: '资深合同',
    context: '现合同即将到期，俱乐部与外部市场给出不同角色。',
    options: [
      ('接受新联赛挑战', '在陌生环境争取最后一次突破。'),
      ('续约并调整角色', '以轮换核心身份留队。'),
      ('签下短期合同', '逐季评估身体与竞技状态。'),
    ],
  ),
  _EventTemplate(
    title: '伤病恢复',
    context: '一次伤停打断赛季，你必须决定复出节奏。',
    options: [
      ('提前复出', '赶上关键赛程，但复发风险更高。'),
      ('按计划恢复', '遵循医疗团队的完整周期。'),
      ('延长康复期', '确保身体准备充分再回归。'),
    ],
  ),
  _EventTemplate(
    title: '最后一章',
    context: '合同即将结束，是时候决定如何书写职业生涯尾声。',
    options: [
      ('再冲一次冠军', '留在高强度环境争取重要奖杯。'),
      ('回到母队', '把经验留给下一代。'),
      ('巅峰退役', '在仍有竞争力时结束职业生涯。'),
    ],
  ),
  _EventTemplate(
    title: '告别方式',
    context: '身体和竞技状态都给出了信号，最终决定权仍在你手中。',
    options: [
      ('前往新联赛', '用最后一个赛季体验新的足球文化。'),
      ('完成告别赛季', '减少出场并完成传承。'),
      ('本季退役', '把最后一次主场掌声作为终点。'),
    ],
  ),
];
