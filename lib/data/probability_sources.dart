class ProbabilitySource {
  const ProbabilitySource({
    required this.id,
    required this.title,
    required this.publisher,
    required this.publishedYear,
    required this.scope,
    required this.url,
    required this.appliedTo,
  });

  final String id;
  final String title;
  final String publisher;
  final int publishedYear;
  final String scope;
  final String url;
  final List<String> appliedTo;
}

abstract final class ProbabilitySources {
  static const dataVersion = '2026.07-public-v2';

  static const sources = <ProbabilitySource>[
    ProbabilitySource(
      id: 'fifa-professional-football-report-2023',
      title: 'Professional Football Report 2023',
      publisher: 'FIFA',
      publishedYear: 2024,
      scope: '全球男子职业足球人口、俱乐部和协会调查',
      url:
          'https://inside.fifa.com/legal/news/fifa-publishes-professional-football-report-2023',
      appliedTo: ['职业人口口径', '协会注册人数转盘', '各洲本土球员比例'],
    ),
    ProbabilitySource(
      id: 'fifa-club-world-cup-clubs-2025',
      title: 'FIFA Club World Cup 2025 draw and participating clubs',
      publisher: 'FIFA',
      publishedYear: 2024,
      scope: '2025 年赛事的 32 支洲际代表俱乐部',
      url: 'https://www.fifa.com/en/articles/draw-procedures-confirmed',
      appliedTo: ['随机模式与人生模拟的真实俱乐部基础目录'],
    ),
    ProbabilitySource(
      id: 'fifa-club-world-cup-squads-2025',
      title: 'The squads in stats — FIFA Club World Cup 2025',
      publisher: 'FIFA',
      publishedYear: 2025,
      scope: '32 家洲际冠军级俱乐部的参赛名单，属于精英样本',
      url:
          'https://www.fifa.com/en/tournaments/mens/club-world-cup/usa-2025/articles/squads-numbers-stats',
      appliedTo: ['精英球员国籍权重'],
    ),
    ProbabilitySource(
      id: 'fifa-january-transfer-snapshot-2025',
      title: 'Men’s January transfer snapshot 2025',
      publisher: 'FIFA',
      publishedYear: 2025,
      scope: 'FIFA TMS 中男子职业球员的国际转会',
      url:
          'https://inside.fifa.com/transfer-system/transfer-reports?tab=Men%27s+January+transfer+snapshot+2025',
      appliedTo: ['转会年龄', '有偿转会比例', '转会类型'],
    ),
    ProbabilitySource(
      id: 'fifa-transfer-methodology',
      title: 'FIFA Transfer Reports Methodology',
      publisher: 'FIFA',
      publishedYear: 2026,
      scope: '11 人制职业球员国际转会；数据来自俱乐部和协会提交的 TMS 交易',
      url:
          'https://inside.fifa.com/transfer-system/transfer-reports/methodology',
      appliedTo: ['转会数据适用范围'],
    ),
    ProbabilitySource(
      id: 'transfermarkt-player-profile',
      title: 'Transfermarkt player profile and facts',
      publisher: 'Transfermarkt',
      publishedYear: 2026,
      scope: '公开球员资料页的字段类型；不用于抓取或复刻专有估值',
      url: 'https://www.transfermarkt.com/eder-militao/profil/spieler/401530',
      appliedTo: ['身份', '身体', '位置', '合同', '经纪人', '国家队', '身价'],
    ),
    ProbabilitySource(
      id: 'transfermarkt-detailed-stats',
      title: 'Transfermarkt detailed player statistics',
      publisher: 'Transfermarkt',
      publishedYear: 2026,
      scope: '按赛季、俱乐部和赛事组织的公开表现字段',
      url:
          'https://www.transfermarkt.com/jumplist/leistungsdaten/spieler/398184',
      appliedTo: ['出场', '进球', '助攻', '纪律', '累计分钟'],
    ),
  ];

  static const professionalPlayers2023 = 128694;
  static const professionalClubs2023 = 3986;
  static const professionalCountries2023 = 135;

  static const januaryInternationalTransfers2025 = 5863;
  static const averageInternationalTransferAge2025 = 24.9;
  static const transfersWithFeePercent2025 = 17.7;
}
