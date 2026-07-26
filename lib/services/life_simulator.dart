import 'dart:math';

import '../data/football_catalog.dart';
import '../domain/player_profile.dart';

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
    Random? random,
  }) : _random = random ?? Random();

  final String nationality;
  final String position;
  final Random _random;
  final List<LifeDecision> decisions = [];

  static const stages = <LifeStage>[
    LifeStage(
      age: 15,
      title: '青训岔路',
      context: '两家风格完全不同的青训体系同时发来邀请。',
      choices: [
        LifeChoice(
          title: '加入豪门梯队',
          description: '竞争残酷，但训练资源顶级。',
          ratingDelta: 4,
          reputationDelta: 3,
          stabilityDelta: -2,
        ),
        LifeChoice(
          title: '留在家乡',
          description: '获得稳定出场时间，从成年队开始积累。',
          ratingDelta: 2,
          reputationDelta: 0,
          stabilityDelta: 4,
        ),
        LifeChoice(
          title: '前往海外',
          description: '提前适应陌生联赛与文化。',
          ratingDelta: 3,
          reputationDelta: 2,
          stabilityDelta: -1,
        ),
      ],
    ),
    LifeStage(
      age: 19,
      title: '首份职业合同',
      context: '经纪人带来三份合同，每一份都意味着不同的成长曲线。',
      choices: [
        LifeChoice(
          title: '保证主力位置',
          description: '留在中小俱乐部成为战术核心。',
          ratingDelta: 4,
          reputationDelta: 1,
          stabilityDelta: 4,
        ),
        LifeChoice(
          title: '挑战顶级联赛',
          description: '接受轮换角色，争取更高的舞台。',
          ratingDelta: 3,
          reputationDelta: 4,
          stabilityDelta: -2,
        ),
        LifeChoice(
          title: '短期外租',
          description: '用一个赛季证明自己。',
          ratingDelta: 5,
          reputationDelta: 2,
          stabilityDelta: 0,
        ),
      ],
    ),
    LifeStage(
      age: 24,
      title: '生涯上升期',
      context: '表现引来关注，你需要决定如何使用最宝贵的几年。',
      choices: [
        LifeChoice(
          title: '冲击豪门',
          description: '转会到争冠球队，接受最高强度竞争。',
          ratingDelta: 5,
          reputationDelta: 5,
          stabilityDelta: -3,
        ),
        LifeChoice(
          title: '成为队长',
          description: '与现俱乐部长约续约，承担领袖责任。',
          ratingDelta: 3,
          reputationDelta: 3,
          stabilityDelta: 5,
        ),
        LifeChoice(
          title: '改变位置',
          description: '主动转型，延展自己的比赛影响力。',
          ratingDelta: 2,
          reputationDelta: 2,
          stabilityDelta: 1,
        ),
      ],
    ),
    LifeStage(
      age: 29,
      title: '巅峰抉择',
      context: '国家队大赛和俱乐部关键赛程发生冲突，身体也需要管理。',
      choices: [
        LifeChoice(
          title: '为国出战',
          description: '承担国家队核心责任。',
          ratingDelta: 1,
          reputationDelta: 5,
          stabilityDelta: -2,
        ),
        LifeChoice(
          title: '专注俱乐部',
          description: '控制负荷，争取俱乐部最高荣誉。',
          ratingDelta: 2,
          reputationDelta: 2,
          stabilityDelta: 3,
        ),
        LifeChoice(
          title: '接受轮休',
          description: '优先保障长期健康。',
          ratingDelta: 0,
          reputationDelta: -1,
          stabilityDelta: 6,
        ),
      ],
    ),
    LifeStage(
      age: 34,
      title: '最后一章',
      context: '合同即将结束，是时候决定如何告别职业赛场。',
      choices: [
        LifeChoice(
          title: '回到母队',
          description: '把经验留给下一代。',
          ratingDelta: 0,
          reputationDelta: 3,
          stabilityDelta: 5,
        ),
        LifeChoice(
          title: '海外终章',
          description: '体验新的足球文化。',
          ratingDelta: -1,
          reputationDelta: 2,
          stabilityDelta: 2,
        ),
        LifeChoice(
          title: '巅峰退役',
          description: '在仍有竞争力时结束职业生涯。',
          ratingDelta: 1,
          reputationDelta: 4,
          stabilityDelta: 1,
        ),
      ],
    ),
  ];

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

    final ratingBonus = decisions.fold<int>(
      0,
      (sum, decision) => sum + decision.choice.ratingDelta,
    );
    final reputation = decisions.fold<int>(
      0,
      (sum, decision) => sum + decision.choice.reputationDelta,
    );
    final stability = decisions.fold<int>(
      0,
      (sum, decision) => sum + decision.choice.stabilityDelta,
    );
    final initialRating = 54 + ratingBonus ~/ 3;
    final peakRating = min(94, 68 + ratingBonus + reputation ~/ 3);
    final career = decisions
        .map(
          (decision) => CareerChapter(
            age: decision.stage.age,
            club: _clubFor(decision.choice),
            event: '${decision.stage.title}：${decision.choice.title}',
            rating: min(
              peakRating,
              initialRating + decisions.indexOf(decision) * 6,
            ),
          ),
        )
        .toList();
    final positionStyles =
        FootballCatalog.positionStyles[position] ?? const ['全能型球员'];
    final scoringRate = position == '中锋'
        ? 0.38
        : position == '边锋'
        ? 0.24
        : position == '前腰'
        ? 0.18
        : 0.08;
    final appearances = 260 + stability * 7 + _random.nextInt(70);
    final titles = max(0, reputation ~/ 4);

    return PlayerProfile(
      mode: CareerMode.life,
      name: name,
      nationality: nationality,
      preferredFoot: _random.nextInt(100) < 24 ? '左脚' : '右脚',
      heightCm: 170 + _random.nextInt(20),
      primaryPosition: position,
      secondaryPosition:
          (FootballCatalog.secondaryPositions[position] ?? [position]).first,
      academy: decisions.first.choice.title == '留在家乡' ? '家乡职业青训学院' : '国际职业青训体系',
      debutAge: 17,
      retirementAge: decisions.last.choice.title == '巅峰退役' ? 34 : 37,
      initialRating: initialRating,
      peakRating: peakRating,
      finalRating: max(58, peakRating - 12),
      playStyle: positionStyles[_random.nextInt(positionStyles.length)],
      injuryRecord: stability >= 10 ? '科学管理负荷，职业生涯较为健康' : '经历伤病考验后重返赛场',
      career: career,
      stats: CareerStats(
        appearances: appearances,
        goals: (appearances * scoringRate).round(),
        assists: (appearances * (scoringRate * 0.75 + 0.04)).round(),
        nationalCaps: max(0, reputation * 3 + _random.nextInt(12)),
        nationalGoals: max(0, (reputation * scoringRate * 2).round()),
        transferCount: decisions
            .where(
              (decision) =>
                  decision.choice.title.contains('豪门') ||
                  decision.choice.title.contains('海外') ||
                  decision.choice.title.contains('外租'),
            )
            .length,
        totalTransferFeeMillions: double.parse(
          (reputation * peakRating / 10).toStringAsFixed(1),
        ),
        championships: List.generate(titles, (index) => '重要赛事冠军 ×1'),
        personalHonors: [
          if (reputation >= 12) '联赛最佳阵容',
          if (reputation >= 17) '年度最佳球员候选',
          if (stability >= 12) '俱乐部功勋球员',
        ],
      ),
    );
  }

  String _clubFor(LifeChoice choice) {
    if (choice.title.contains('豪门')) return '欧洲争冠俱乐部';
    if (choice.title.contains('海外')) return '海外职业俱乐部';
    if (choice.title.contains('母队') || choice.title.contains('家乡')) {
      return '家乡职业俱乐部';
    }
    return '生涯阶段俱乐部';
  }
}
