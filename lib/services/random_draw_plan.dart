import 'dart:math';

import '../data/football_catalog.dart';
import '../domain/player_profile.dart';
import '../domain/random_draw_step.dart';
import '../domain/weighted_value.dart';

abstract final class RandomDrawPlan {
  static List<RandomDrawStep> build(PlayerProfile profile) {
    final steps = <RandomDrawStep>[];
    _addPersonalSteps(steps, profile);
    _addClubSteps(steps, profile);
    _addNationalTeamSteps(steps, profile);
    return steps;
  }

  static void _addPersonalSteps(
    List<RandomDrawStep> steps,
    PlayerProfile profile,
  ) {
    final associationIsPublished = FootballCatalog
        .professionalAssociationPopulations
        .any((item) => item.value == profile.developmentAssociation);
    final associationSegment = associationIsPublished
        ? profile.developmentAssociation
        : '其他 FIFA 协会';
    steps.add(
      _step(
        id: 'association',
        track: RandomDrawTrack.personal,
        titleZh: '职业足球从哪里开始',
        titleEn: 'Where professional football begins',
        categoryZh: '成长协会',
        categoryEn: 'Development association',
        resultZh: profile.developmentAssociation,
        resultEn: _english(profile.developmentAssociation),
        segments: FootballCatalog.professionalAssociationPopulations,
        selected: associationSegment,
        kind: DrawProbabilityKind.official,
        noteZh: 'FIFA 2023 各协会职业球员人数；其他扇区为精确余数。',
        noteEn:
            'FIFA 2023 professional-player counts by association; the other sector is the exact remainder.',
      ),
    );

    final confederation = FootballCatalog
        .associationConfederations[profile.developmentAssociation];
    final homegrown =
        FootballCatalog.homegrownPercentByConfederation[confederation] ?? 77;
    final nationalityRelation =
        profile.nationality == profile.developmentAssociation ? '本土' : '外籍';
    steps.add(
      _step(
        id: 'nationality',
        track: RandomDrawTrack.personal,
        titleZh: '护照与成长体系是否一致',
        titleEn: 'Passport versus development system',
        categoryZh: '国籍',
        categoryEn: 'Nationality',
        resultZh: '${profile.nationality} · $nationalityRelation',
        resultEn:
            '${_english(profile.nationality)} · '
            '${nationalityRelation == '本土' ? 'domestic' : 'foreign'}',
        segments: [
          WeightedValue('本土', homegrown),
          WeightedValue('外籍', 100 - homegrown),
        ],
        selected: nationalityRelation,
        kind: DrawProbabilityKind.official,
        noteZh: 'FIFA 2023 各洲本土/外籍球员占比。',
        noteEn: 'FIFA 2023 domestic/foreign player share by confederation.',
      ),
    );

    final birthYear = _yearFromDate(profile.birthDate);
    steps.add(
      _step(
        id: 'birth_year',
        track: RandomDrawTrack.personal,
        titleZh: '这一代球员的起点',
        titleEn: 'The starting year',
        categoryZh: '出生年份',
        categoryEn: 'Birth year',
        resultZh: profile.birthDate,
        resultEn: profile.birthDate,
        segments: [
          for (var year = 2005; year <= 2010; year++) WeightedValue('$year', 1),
        ],
        selected: '$birthYear',
        noteZh: '当前虚构生涯时间窗内等权抽样。',
        noteEn: 'Uniform sampling within the current fictional career window.',
      ),
    );
    steps.add(
      _step(
        id: 'preferred_foot',
        track: RandomDrawTrack.personal,
        titleZh: '第一次触球的习惯',
        titleEn: 'First-touch preference',
        categoryZh: '惯用脚',
        categoryEn: 'Preferred foot',
        resultZh: profile.preferredFoot,
        resultEn: _english(profile.preferredFoot),
        segments: FootballCatalog.preferredFeet,
        selected: profile.preferredFoot,
        noteZh: '产品模型权重；等待统一口径球员数据集校准。',
        noteEn: 'Product-model weights pending a consistently scoped dataset.',
      ),
    );
    steps.add(
      _step(
        id: 'primary_position',
        track: RandomDrawTrack.personal,
        titleZh: '球场上的第一职责',
        titleEn: 'Primary duty on the pitch',
        categoryZh: '主位置',
        categoryEn: 'Primary position',
        resultZh: profile.primaryPosition,
        resultEn: _english(profile.primaryPosition),
        segments: FootballCatalog.positions,
        selected: profile.primaryPosition,
        noteZh: '按职业队常见阵容构成建模。',
        noteEn: 'Modelled from common professional squad composition.',
      ),
    );
    final secondaryValues =
        FootballCatalog.secondaryPositions[profile.primaryPosition] ??
        [profile.primaryPosition];
    steps.add(
      _equalStep(
        id: 'secondary_position',
        track: RandomDrawTrack.personal,
        titleZh: '战术板上的第二答案',
        titleEn: 'A second answer on the tactics board',
        categoryZh: '第二位置',
        categoryEn: 'Secondary position',
        result: profile.secondaryPosition,
        values: secondaryValues,
      ),
    );
    steps.add(
      _bandStep(
        id: 'height',
        track: RandomDrawTrack.personal,
        titleZh: '身体轮廓',
        titleEn: 'Physical profile',
        categoryZh: '身高',
        categoryEn: 'Height',
        resultZh: '${profile.heightCm} cm',
        resultEn: '${profile.heightCm} cm',
        value: profile.heightCm,
        bands: const [
          ('≤169 cm', 169, 10),
          ('170–174 cm', 174, 20),
          ('175–179 cm', 179, 27),
          ('180–184 cm', 184, 24),
          ('185–189 cm', 189, 14),
          ('≥190 cm', 999, 5),
        ],
      ),
    );
    steps.add(
      _bandStep(
        id: 'weight',
        track: RandomDrawTrack.personal,
        titleZh: '对抗所需的重量',
        titleEn: 'Weight for the duel',
        categoryZh: '体重',
        categoryEn: 'Weight',
        resultZh: '${profile.weightKg} kg',
        resultEn: '${profile.weightKg} kg',
        value: profile.weightKg,
        bands: const [
          ('≤64 kg', 64, 10),
          ('65–69 kg', 69, 18),
          ('70–74 kg', 74, 28),
          ('75–79 kg', 79, 24),
          ('80–84 kg', 84, 14),
          ('≥85 kg', 999, 6),
        ],
      ),
    );
    final numbers =
        FootballCatalog.squadNumbers[profile.primaryPosition] ?? [10];
    steps.add(
      _equalStep(
        id: 'shirt_number',
        track: RandomDrawTrack.personal,
        titleZh: '背后的号码',
        titleEn: 'The number on the shirt',
        categoryZh: '球衣号码',
        categoryEn: 'Shirt number',
        result: '${profile.shirtNumber}',
        values: numbers.map((value) => '$value').toList(),
      ),
    );
    steps.add(
      _equalStep(
        id: 'play_style',
        track: RandomDrawTrack.personal,
        titleZh: '球探报告的第一行',
        titleEn: 'The first line of the scout report',
        categoryZh: '比赛风格',
        categoryEn: 'Playing style',
        result: profile.playStyle,
        values:
            FootballCatalog.positionStyles[profile.primaryPosition] ??
            [profile.playStyle],
      ),
    );
    steps.add(
      _weightedIntStep(
        id: 'debut_age',
        track: RandomDrawTrack.personal,
        titleZh: '职业大门打开',
        titleEn: 'The professional door opens',
        categoryZh: '首秀年龄',
        categoryEn: 'Debut age',
        value: profile.debutAge,
        values: const [
          WeightedValue(16, 8),
          WeightedValue(17, 18),
          WeightedValue(18, 27),
          WeightedValue(19, 23),
          WeightedValue(20, 16),
          WeightedValue(21, 8),
        ],
      ),
    );
    final careerLength = profile.retirementAge - profile.debutAge;
    steps.add(
      _bandStep(
        id: 'career_length',
        track: RandomDrawTrack.personal,
        titleZh: '能在职业赛场走多远',
        titleEn: 'How long the career can last',
        categoryZh: '生涯长度',
        categoryEn: 'Career length',
        resultZh: '$careerLength 年',
        resultEn: '$careerLength years',
        value: careerLength,
        bands: const [
          ('12–14', 14, 12),
          ('15–17', 17, 27),
          ('18–20', 20, 34),
          ('21–22', 22, 19),
          ('≥23', 99, 8),
        ],
      ),
    );
    steps.add(
      _ratingStep(
        id: 'initial_rating',
        track: RandomDrawTrack.personal,
        titleZh: '踏入职业时的底色',
        titleEn: 'Baseline at the professional gate',
        categoryZh: '初始能力',
        categoryEn: 'Initial rating',
        rating: profile.initialRating,
      ),
    );
    steps.add(
      _ratingStep(
        id: 'peak_rating',
        track: RandomDrawTrack.personal,
        titleZh: '天花板逐渐显现',
        titleEn: 'The ceiling comes into view',
        categoryZh: '巅峰能力',
        categoryEn: 'Peak rating',
        rating: profile.peakRating,
      ),
    );
  }

  static void _addClubSteps(List<RandomDrawStep> steps, PlayerProfile profile) {
    final academyTier = _academyTier(profile.academy);
    steps.add(
      _step(
        id: 'academy_tier',
        track: RandomDrawTrack.club,
        age: 15,
        titleZh: '第一套职业训练服',
        titleEn: 'The first professional training kit',
        categoryZh: '青训层级',
        categoryEn: 'Academy tier',
        resultZh: '第 $academyTier 级',
        resultEn: 'Tier $academyTier',
        segments: [
          for (final item in FootballCatalog.academyTiers)
            WeightedValue('第 ${item.value} 级', item.weight),
        ],
        selected: '第 $academyTier 级',
        noteZh: '产品模型：资源越顶级，进入概率越低。',
        noteEn: 'Product model: elite resources are less common.',
      ),
    );
    steps.add(
      _equalStep(
        id: 'academy',
        track: RandomDrawTrack.club,
        age: 15,
        titleZh: '塑造技术习惯的地方',
        titleEn: 'Where technique takes shape',
        categoryZh: '青训',
        categoryEn: 'Academy',
        result: profile.academy,
        values: FootballCatalog.academies[academyTier] ?? [profile.academy],
      ),
    );
    if (profile.career.isNotEmpty) {
      steps.add(
        _clubStep(
          id: 'first_club',
          age: profile.debutAge,
          titleZh: '第一份出场名单',
          titleEn: 'The first team sheet',
          categoryZh: '首家俱乐部',
          categoryEn: 'First club',
          club: profile.career.first.club,
          earlyCareer: true,
        ),
      );
    }
    steps.add(
      _step(
        id: 'transfer_count',
        track: RandomDrawTrack.club,
        titleZh: '多少次重新收拾行李',
        titleEn: 'How often the bags are packed',
        categoryZh: '转会次数',
        categoryEn: 'Transfer count',
        resultZh: '${profile.stats.transferCount} 次',
        resultEn: '${profile.stats.transferCount}',
        segments: [
          for (final item in FootballCatalog.transferCounts)
            WeightedValue('${item.value}', item.weight),
        ],
        selected: '${profile.stats.transferCount}',
        noteZh: '产品模型的离散生涯流动分布。',
        noteEn: 'Product-model distribution of career mobility.',
      ),
    );

    for (var index = 0; index < profile.transferHistory.length; index++) {
      final transfer = profile.transferHistory[index];
      final number = index + 1;
      steps.add(
        _weightedIntStep(
          id: 'transfer_${number}_age',
          track: RandomDrawTrack.club,
          age: transfer.age,
          titleZh: '第 $number 次转会窗口',
          titleEn: 'Transfer window $number',
          categoryZh: '转会年龄',
          categoryEn: 'Transfer age',
          value: transfer.age,
          values: [
            for (var age = 16; age <= 39; age++)
              WeightedValue(age, _transferAgeWeight(age)),
          ],
          kind: DrawProbabilityKind.calibrated,
          noteZh: '以 FIFA 2025 国际转会平均年龄 24.9 岁为中心。',
          noteEn:
              'Centred on FIFA’s 2025 average international transfer age of 24.9.',
        ),
      );
      steps.add(
        _step(
          id: 'transfer_${number}_type',
          track: RandomDrawTrack.club,
          age: transfer.age,
          titleZh: '合同如何跨过边界',
          titleEn: 'How the contract crosses the border',
          categoryZh: '转会形式',
          categoryEn: 'Transfer type',
          resultZh: transfer.type,
          resultEn: _english(transfer.type),
          segments: FootballCatalog.transferTypes,
          selected: transfer.type,
          kind: DrawProbabilityKind.calibrated,
          noteZh: '按 FIFA 国际转会公开关系校准。',
          noteEn: 'Calibrated to FIFA’s published international-transfer mix.',
        ),
      );
      steps.add(
        _clubStep(
          id: 'transfer_${number}_club',
          age: transfer.age,
          titleZh: '更衣室门牌发生变化',
          titleEn: 'A new name on the dressing-room door',
          categoryZh: '新俱乐部',
          categoryEn: 'New club',
          club: transfer.toClub,
        ),
      );
      steps.add(
        _feeStep(
          id: 'transfer_${number}_fee',
          age: transfer.age,
          fee: transfer.feeMillions,
        ),
      );
    }

    final contractYears = max(
      1,
      _yearFromDate(profile.contractUntil) -
          _yearFromDate(profile.joinedClubDate),
    );
    steps.add(
      _step(
        id: 'contract_length',
        track: RandomDrawTrack.club,
        titleZh: '最后一份合同的厚度',
        titleEn: 'Length of the final contract',
        categoryZh: '合同年限',
        categoryEn: 'Contract length',
        resultZh: '$contractYears 年',
        resultEn: '$contractYears years',
        segments: [
          for (final item in FootballCatalog.contractLengthsYears)
            WeightedValue('${item.value}', item.weight),
        ],
        selected: '$contractYears',
        noteZh: '产品模型合同年限分布。',
        noteEn: 'Product-model contract-length distribution.',
      ),
    );
    steps.add(
      _equalStep(
        id: 'agent',
        track: RandomDrawTrack.club,
        titleZh: '谈判桌另一侧',
        titleEn: 'Across the negotiation table',
        categoryZh: '经纪人',
        categoryEn: 'Agent',
        result: profile.agent,
        values: FootballCatalog.agents,
      ),
    );

    steps.add(
      _bandStep(
        id: 'market_value',
        track: RandomDrawTrack.club,
        titleZh: '市场给出的峰值标签',
        titleEn: 'The market’s peak label',
        categoryZh: '模拟身价峰值',
        categoryEn: 'Simulated peak value',
        resultZh: '€${profile.marketValueMillions.toStringAsFixed(1)}M',
        resultEn: '€${profile.marketValueMillions.toStringAsFixed(1)}M',
        value: profile.marketValueMillions.round(),
        bands: const [
          ('< €1M', 0, 18),
          ('€1–10M', 10, 30),
          ('€10–30M', 30, 24),
          ('€30–60M', 60, 15),
          ('€60–100M', 100, 9),
          ('> €100M', 999, 4),
        ],
      ),
    );
    steps.add(
      _bandStep(
        id: 'injury_count',
        track: RandomDrawTrack.club,
        titleZh: '医疗室留下多少页记录',
        titleEn: 'How many pages in the medical file',
        categoryZh: '伤病次数',
        categoryEn: 'Injury spells',
        resultZh: '${profile.injuryHistory.length} 次',
        resultEn: '${profile.injuryHistory.length}',
        value: profile.injuryHistory.length,
        bands: const [
          ('0', 0, 28),
          ('1', 1, 32),
          ('2', 2, 23),
          ('3', 3, 11),
          ('≥4', 99, 6),
        ],
      ),
    );
    for (var index = 0; index < profile.injuryHistory.length; index++) {
      final injury = profile.injuryHistory[index];
      steps.add(
        _step(
          id: 'injury_${index + 1}_type',
          track: RandomDrawTrack.club,
          titleZh: '第 ${index + 1} 次身体警报',
          titleEn: 'Physical warning ${index + 1}',
          categoryZh: '伤病类型',
          categoryEn: 'Injury type',
          resultZh: injury.type,
          resultEn: _english(injury.type),
          segments: FootballCatalog.injuryTypes,
          selected: injury.type,
          noteZh: '产品模型伤病类型权重。',
          noteEn: 'Product-model injury-type weights.',
        ),
      );
      steps.add(
        _bandStep(
          id: 'injury_${index + 1}_duration',
          track: RandomDrawTrack.club,
          titleZh: '恢复日历被划掉多少天',
          titleEn: 'Days crossed off the recovery calendar',
          categoryZh: '缺阵天数',
          categoryEn: 'Days absent',
          resultZh: '${injury.daysAbsent} 天',
          resultEn: '${injury.daysAbsent} days',
          value: injury.daysAbsent,
          bands: const [
            ('≤14', 14, 35),
            ('15–30', 30, 30),
            ('31–60', 60, 20),
            ('61–120', 120, 10),
            ('>120', 999, 5),
          ],
        ),
      );
    }

    _addCareerStatSteps(steps, profile);
    _addClubHonourSteps(steps, profile);
  }

  static void _addCareerStatSteps(
    List<RandomDrawStep> steps,
    PlayerProfile profile,
  ) {
    final stats = profile.stats;
    final values = <(String, String, String, int, List<(String, int, int)>)>[
      (
        'appearances',
        '俱乐部出场',
        'Club appearances',
        stats.appearances,
        const [
          ('<100', 99, 12),
          ('100–249', 249, 23),
          ('250–399', 399, 30),
          ('400–549', 549, 23),
          ('≥550', 9999, 12),
        ],
      ),
      (
        'starts',
        '首发',
        'Starts',
        stats.starts,
        const [
          ('<100', 99, 18),
          ('100–249', 249, 30),
          ('250–399', 399, 30),
          ('400–549', 549, 17),
          ('≥550', 9999, 5),
        ],
      ),
      (
        'minutes',
        '累计分钟',
        'Minutes',
        stats.minutesPlayed,
        const [
          ('<10k', 9999, 15),
          ('10k–20k', 19999, 25),
          ('20k–30k', 29999, 30),
          ('30k–40k', 39999, 20),
          ('≥40k', 999999, 10),
        ],
      ),
      (
        'goals',
        '俱乐部进球',
        'Club goals',
        stats.goals,
        const [
          ('0–9', 9, 25),
          ('10–49', 49, 32),
          ('50–99', 99, 22),
          ('100–199', 199, 14),
          ('≥200', 9999, 7),
        ],
      ),
      (
        'assists',
        '俱乐部助攻',
        'Club assists',
        stats.assists,
        const [
          ('0–9', 9, 22),
          ('10–49', 49, 35),
          ('50–99', 99, 25),
          ('100–199', 199, 14),
          ('≥200', 9999, 4),
        ],
      ),
      (
        'yellow_cards',
        '黄牌',
        'Yellow cards',
        stats.yellowCards,
        const [
          ('0–9', 9, 22),
          ('10–29', 29, 32),
          ('30–59', 59, 28),
          ('60–99', 99, 13),
          ('≥100', 9999, 5),
        ],
      ),
      (
        'red_cards',
        '红牌',
        'Red cards',
        stats.redCards + stats.secondYellowCards,
        const [
          ('0', 0, 45),
          ('1–2', 2, 30),
          ('3–5', 5, 17),
          ('6–9', 9, 6),
          ('≥10', 9999, 2),
        ],
      ),
    ];
    for (final value in values) {
      steps.add(
        _bandStep(
          id: value.$1,
          track: RandomDrawTrack.club,
          titleZh: '生涯账本写下一项总计',
          titleEn: 'Another career total enters the ledger',
          categoryZh: value.$2,
          categoryEn: value.$3,
          resultZh: '${value.$4}',
          resultEn: '${value.$4}',
          value: value.$4,
          bands: value.$5,
        ),
      );
    }
    if (profile.primaryPosition == '门将') {
      steps.add(
        _bandStep(
          id: 'clean_sheets',
          track: RandomDrawTrack.club,
          titleZh: '多少场比赛没有失球',
          titleEn: 'Matches without conceding',
          categoryZh: '零封',
          categoryEn: 'Clean sheets',
          resultZh: '${stats.cleanSheets}',
          resultEn: '${stats.cleanSheets}',
          value: stats.cleanSheets,
          bands: const [
            ('0–24', 24, 25),
            ('25–74', 74, 35),
            ('75–124', 124, 25),
            ('125–199', 199, 12),
            ('≥200', 9999, 3),
          ],
        ),
      );
    }
    for (final competition in profile.competitionStats) {
      steps.add(
        _bandStep(
          id: 'competition_${competition.competition}_apps',
          track: RandomDrawTrack.club,
          titleZh: '赛事维度拆开生涯',
          titleEn: 'The career split by competition',
          categoryZh: '${competition.competition}出场',
          categoryEn: '${_english(competition.competition)} appearances',
          resultZh: '${competition.appearances} 场',
          resultEn: '${competition.appearances}',
          value: competition.appearances,
          bands: const [
            ('0–24', 24, 16),
            ('25–74', 74, 24),
            ('75–149', 149, 27),
            ('150–299', 299, 22),
            ('≥300', 9999, 11),
          ],
        ),
      );
      steps.add(
        _bandStep(
          id: 'competition_${competition.competition}_goals',
          track: RandomDrawTrack.club,
          titleZh: '同一项赛事留下多少进球',
          titleEn: 'Goals in this competition',
          categoryZh: '${competition.competition}进球',
          categoryEn: '${_english(competition.competition)} goals',
          resultZh: '${competition.goals} 球',
          resultEn: '${competition.goals}',
          value: competition.goals,
          bands: const [
            ('0–4', 4, 28),
            ('5–19', 19, 30),
            ('20–49', 49, 24),
            ('50–99', 99, 13),
            ('≥100', 9999, 5),
          ],
        ),
      );
    }
  }

  static void _addClubHonourSteps(
    List<RandomDrawStep> steps,
    PlayerProfile profile,
  ) {
    const trophies = [
      ('domestic_league', '国内顶级联赛冠军', 'Domestic league title'),
      ('domestic_cup', '国内杯赛冠军', 'Domestic cup'),
      ('super_cup', '国内超级杯冠军', 'Domestic super cup'),
      ('continental_club', '洲际俱乐部赛事冠军', 'Continental club title'),
      ('club_world', '世界俱乐部冠军', 'Club world title'),
    ];
    final titleCount = profile.stats.championships.length;
    for (var index = 0; index < trophies.length; index++) {
      final trophy = trophies[index];
      final won = index < min(titleCount, trophies.length);
      final chance = (8 + max(0, profile.peakRating - 68) * (5 - index)).clamp(
        3,
        72,
      );
      steps.add(
        _yesNoStep(
          id: 'trophy_${trophy.$1}',
          track: RandomDrawTrack.club,
          titleZh: '奖杯柜逐格打开',
          titleEn: 'Opening another trophy-cabinet slot',
          categoryZh: trophy.$2,
          categoryEn: trophy.$3,
          yes: won,
          yesWeight: chance,
          resultYesZh: '获得',
          resultYesEn: 'Won',
        ),
      );
    }
    const honors = [
      ('best_xi', '联赛最佳阵容', 'League best XI'),
      ('player_year', '年度最佳球员候选', 'Player of the year shortlist'),
      ('world_player', '世界年度最佳球员', 'World player of the year'),
    ];
    for (var index = 0; index < honors.length; index++) {
      final honor = honors[index];
      final won = profile.stats.personalHonors.any(
        (value) => value.contains(honor.$2.replaceAll('候选', '')),
      );
      final chance = (5 + max(0, profile.peakRating - 74) * (4 - index)).clamp(
        2,
        55,
      );
      steps.add(
        _yesNoStep(
          id: 'honor_${honor.$1}',
          track: RandomDrawTrack.club,
          titleZh: '个人荣誉进入评选',
          titleEn: 'Entering an individual-award vote',
          categoryZh: honor.$2,
          categoryEn: honor.$3,
          yes: won,
          yesWeight: chance,
          resultYesZh: '入选 / 获得',
          resultYesEn: 'Selected / won',
        ),
      );
    }
  }

  static void _addNationalTeamSteps(
    List<RandomDrawStep> steps,
    PlayerProfile profile,
  ) {
    final calledUp = profile.stats.nationalCaps > 0;
    final callUpChance = (8 + max(0, profile.peakRating - 65) * 4).clamp(4, 88);
    steps.add(
      _yesNoStep(
        id: 'national_call_up',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '国家队电话是否响起',
        titleEn: 'Does the national-team phone ring?',
        categoryZh: '成年国家队入选',
        categoryEn: 'Senior national-team call-up',
        yes: calledUp,
        yesWeight: callUpChance,
        resultYesZh: profile.nationalTeam,
        resultYesEn: _english(profile.nationalTeam),
      ),
    );
    steps.add(
      _bandStep(
        id: 'national_caps',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '国家队比赛日累积',
        titleEn: 'International matchdays accumulate',
        categoryZh: '国家队出场',
        categoryEn: 'International caps',
        resultZh: '${profile.stats.nationalCaps} 场',
        resultEn: '${profile.stats.nationalCaps}',
        value: profile.stats.nationalCaps,
        bands: const [
          ('0', 0, 34),
          ('1–9', 9, 22),
          ('10–29', 29, 20),
          ('30–59', 59, 14),
          ('60–99', 99, 7),
          ('≥100', 9999, 3),
        ],
      ),
    );
    steps.add(
      _bandStep(
        id: 'national_goals',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '为国家队改写多少次比分',
        titleEn: 'Scorelines changed for the national team',
        categoryZh: '国家队进球',
        categoryEn: 'International goals',
        resultZh: '${profile.stats.nationalGoals} 球',
        resultEn: '${profile.stats.nationalGoals}',
        value: profile.stats.nationalGoals,
        bands: const [
          ('0', 0, 40),
          ('1–4', 4, 28),
          ('5–14', 14, 20),
          ('15–29', 29, 8),
          ('≥30', 9999, 4),
        ],
      ),
    );
    final worldCupSquad =
        profile.stats.nationalCaps >= 20 && profile.peakRating >= 76;
    final continentalSquad =
        profile.stats.nationalCaps >= 10 && profile.peakRating >= 72;
    final worldChampion = profile.stats.championships.any(
      (value) => value.contains('世界冠军'),
    );
    final continentalChampion = profile.stats.championships.any(
      (value) => value.contains('国家队洲际'),
    );
    steps.addAll([
      _yesNoStep(
        id: 'world_cup_squad',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '四年一次的大名单',
        titleEn: 'The once-in-four-years squad list',
        categoryZh: '世界杯参赛',
        categoryEn: 'World Cup squad',
        yes: worldCupSquad,
        yesWeight: (profile.stats.nationalCaps + profile.peakRating - 65).clamp(
          2,
          70,
        ),
      ),
      _yesNoStep(
        id: 'continental_squad',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '洲际大赛名单',
        titleEn: 'Continental tournament squad',
        categoryZh: '洲际国家队赛事参赛',
        categoryEn: 'Continental national-team tournament',
        yes: continentalSquad,
        yesWeight: (profile.stats.nationalCaps + 20).clamp(5, 82),
      ),
      _yesNoStep(
        id: 'world_champion',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '世界冠军只有一个',
        titleEn: 'Only one world champion',
        categoryZh: '世界杯冠军',
        categoryEn: 'World Cup champion',
        yes: worldChampion,
        yesWeight: worldCupSquad ? 8 : 1,
      ),
      _yesNoStep(
        id: 'continental_champion',
        track: RandomDrawTrack.nationalTeam,
        titleZh: '大洲之巅',
        titleEn: 'Champion of the continent',
        categoryZh: '洲际国家队冠军',
        categoryEn: 'Continental champion',
        yes: continentalChampion,
        yesWeight: continentalSquad ? 14 : 2,
      ),
    ]);
  }

  static RandomDrawStep _clubStep({
    required String id,
    required int age,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required String club,
    bool earlyCareer = false,
  }) {
    return _step(
      id: id,
      track: RandomDrawTrack.club,
      age: age,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: club,
      resultEn: club,
      segments: [
        for (final definition in FootballCatalog.clubs)
          WeightedValue(
            definition.name,
            earlyCareer
                ? switch (definition.level) {
                    1 => 4,
                    2 => 8,
                    3 => 16,
                    _ => 28,
                  }
                : switch (definition.level) {
                    1 => 10,
                    2 => 14,
                    3 => 18,
                    _ => 8,
                  },
          ),
      ],
      selected: club,
      noteZh: '真实俱乐部来自 FIFA 2025 世俱杯官方参赛名单；权重为生涯模型。',
      noteEn:
          'Real clubs come from FIFA’s official 2025 Club World Cup list; weights are modelled.',
    );
  }

  static RandomDrawStep _feeStep({
    required String id,
    required int age,
    required double fee,
  }) {
    return _bandStep(
      id: id,
      track: RandomDrawTrack.club,
      age: age,
      titleZh: '交易数字写进档案',
      titleEn: 'The transaction enters the ledger',
      categoryZh: '转会费',
      categoryEn: 'Transfer fee',
      resultZh: fee == 0 ? '€0M' : '€${fee.toStringAsFixed(1)}M',
      resultEn: fee == 0 ? '€0M' : '€${fee.toStringAsFixed(1)}M',
      value: fee.round(),
      bands: const [
        ('€0M', 0, 82),
        ('€0.1–5M', 5, 6),
        ('€5–20M', 20, 5),
        ('€20–50M', 50, 4),
        ('€50–100M', 100, 2),
        ('>€100M', 999, 1),
      ],
      kind: DrawProbabilityKind.calibrated,
      noteZh: '零费用扇区对齐 FIFA 17.7% 有偿国际转会比例。',
      noteEn:
          'The zero-fee sector aligns with FIFA’s 17.7% paid international-transfer share.',
    );
  }

  static RandomDrawStep _ratingStep({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required int rating,
  }) {
    return _bandStep(
      id: id,
      track: track,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: '$rating',
      resultEn: '$rating',
      value: rating,
      bands: const [
        ('≤59', 59, 25),
        ('60–69', 69, 35),
        ('70–79', 79, 25),
        ('80–84', 84, 10),
        ('85–89', 89, 4),
        ('≥90', 999, 1),
      ],
    );
  }

  static RandomDrawStep _weightedIntStep({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required int value,
    required List<WeightedValue<int>> values,
    DrawProbabilityKind kind = DrawProbabilityKind.modeled,
    String noteZh = '产品模型权重。',
    String noteEn = 'Product-model weights.',
    int? age,
  }) {
    return _step(
      id: id,
      track: track,
      age: age,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: '$value',
      resultEn: '$value',
      segments: [
        for (final item in values) WeightedValue('${item.value}', item.weight),
      ],
      selected: '$value',
      kind: kind,
      noteZh: noteZh,
      noteEn: noteEn,
    );
  }

  static RandomDrawStep _equalStep({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required String result,
    required List<String> values,
    int? age,
  }) {
    return _step(
      id: id,
      track: track,
      age: age,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: result,
      resultEn: _english(result),
      segments: [for (final value in values) WeightedValue(value, 1)],
      selected: result,
      noteZh: '同层候选等权；候选集合由前置结果限定。',
      noteEn:
          'Equal weights within a candidate set constrained by earlier draws.',
    );
  }

  static RandomDrawStep _bandStep({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required String resultZh,
    required String resultEn,
    required int value,
    required List<(String, int, int)> bands,
    DrawProbabilityKind kind = DrawProbabilityKind.modeled,
    String noteZh = '产品模型区间权重。',
    String noteEn = 'Product-model band weights.',
    int? age,
  }) {
    var selected = bands.last.$1;
    for (final band in bands) {
      if (value <= band.$2) {
        selected = band.$1;
        break;
      }
    }
    return _step(
      id: id,
      track: track,
      age: age,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: resultZh,
      resultEn: resultEn,
      segments: [for (final band in bands) WeightedValue(band.$1, band.$3)],
      selected: selected,
      kind: kind,
      noteZh: noteZh,
      noteEn: noteEn,
    );
  }

  static RandomDrawStep _yesNoStep({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required bool yes,
    required int yesWeight,
    String resultYesZh = '是',
    String resultYesEn = 'Yes',
  }) {
    final safeYesWeight = yesWeight.clamp(1, 99);
    return _step(
      id: id,
      track: track,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: yes ? resultYesZh : '未获得',
      resultEn: yes ? resultYesEn : 'No',
      segments: [
        WeightedValue('是', safeYesWeight),
        WeightedValue('否', 100 - safeYesWeight),
      ],
      selected: yes ? '是' : '否',
      noteZh: '由球员能力、履历和赛事难度动态计算。',
      noteEn:
          'Dynamically calculated from ability, career record, and competition difficulty.',
    );
  }

  static RandomDrawStep _step({
    required String id,
    required RandomDrawTrack track,
    required String titleZh,
    required String titleEn,
    required String categoryZh,
    required String categoryEn,
    required String resultZh,
    required String resultEn,
    required List<WeightedValue<String>> segments,
    required String selected,
    String noteZh = '产品模型权重。',
    String noteEn = 'Product-model weights.',
    DrawProbabilityKind kind = DrawProbabilityKind.modeled,
    int? age,
  }) {
    return RandomDrawStep(
      id: id,
      track: track,
      age: age,
      titleZh: titleZh,
      titleEn: titleEn,
      categoryZh: categoryZh,
      categoryEn: categoryEn,
      resultZh: resultZh,
      resultEn: resultEn,
      segments: segments,
      selectedSegment: selected,
      probabilityKind: kind,
      sourceNoteZh: noteZh,
      sourceNoteEn: noteEn,
    );
  }

  static int _academyTier(String academy) {
    for (final entry in FootballCatalog.academies.entries) {
      if (entry.value.contains(academy)) return entry.key;
    }
    return 3;
  }

  static int _transferAgeWeight(int age) {
    final distance = (age - 25).abs();
    return max(1, 24 - distance * 3);
  }

  static int _yearFromDate(String date) {
    final match = RegExp(r'(\d{4})').allMatches(date).toList();
    return match.isEmpty ? 2006 : int.parse(match.last.group(1)!);
  }

  static String _english(String value) {
    return const {
          '本土': 'Domestic',
          '外籍': 'Foreign',
          '右脚': 'Right foot',
          '左脚': 'Left foot',
          '双足': 'Both feet',
          '门将': 'Goalkeeper',
          '中后卫': 'Centre-back',
          '边后卫': 'Full-back',
          '后腰': 'Defensive midfield',
          '中前卫': 'Central midfield',
          '前腰': 'Attacking midfield',
          '边锋': 'Winger',
          '中锋': 'Centre-forward',
          '自由转会': 'Free transfer',
          '租借': 'Loan',
          '永久转会': 'Permanent transfer',
          '国内联赛': 'Domestic league',
          '国内杯赛': 'Domestic cup',
          '洲际俱乐部赛事': 'Continental club competition',
        }[value] ??
        value;
  }
}
