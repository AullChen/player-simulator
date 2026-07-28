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
  static const dataVersion = '2026.07-public-v4';

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
      title: 'FIFA Club World Cup 2025 squad lists and nationalities',
      publisher: 'FIFA',
      publishedYear: 2025,
      scope: '32 家参赛俱乐部完整名单中的 81 个球员国籍，属于精英样本',
      url:
          'https://www.fifa.com/en/tournaments/mens/club-world-cup/usa-2025/articles/world-cup-winners-fcwc25-usa-lionel-messi-neuer-griezmann',
      appliedTo: ['洲足联国籍权重', '洲内具体国家权重'],
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
    ProbabilitySource(
      id: 'koch-retirement-reasons-2021',
      title:
          'Health-related issues and injury as the cause of retirement from professional soccer',
      publisher: 'Knee Surgery, Sports Traumatology, Arthroscopy',
      publishedYear: 2021,
      scope: '116 名已退役德国男子职业球员的回顾性样本；用于校准退役原因的相对权重，不代表全球精确发生率',
      url: 'https://pubmed.ncbi.nlm.nih.gov/34370085/',
      appliedTo: ['随机长度模式的伤病、高龄与其他退役原因权重'],
    ),
    ProbabilitySource(
      id: 'fifpro-global-employment-report-2016',
      title: 'FIFPRO Global Employment Report 2016',
      publisher: 'FIFPRO',
      publishedYear: 2016,
      scope: '覆盖 54 个国家、87 个联赛、约 14,000 名球员；职业合同平均长度不足两年',
      url:
          'https://www.fifpro.org/en/articles/2019/11/mens-football-global-report-2016',
      appliedTo: ['随机长度模式的合同脆弱性与无合适去处剧情'],
    ),
    ProbabilitySource(
      id: 'football-return-to-play-reinjury-2025',
      title:
          'Injury Risk Following Return-to-Play From an Injury in Professional Football',
      publisher: 'Orthopaedic Journal of Sports Medicine',
      publishedYear: 2025,
      scope: '职业足球伤愈复出后的非接触伤病风险研究',
      url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC11787231/',
      appliedTo: ['既往伤病和冒险复出对后续退役风险的动态修正'],
    ),
  ];

  static const professionalPlayers2023 = 128694;
  static const professionalClubs2023 = 3986;
  static const professionalCountries2023 = 135;

  static const januaryInternationalTransfers2025 = 5863;
  static const averageInternationalTransferAge2025 = 24.9;
  static const transfersWithFeePercent2025 = 17.7;

  // Conditional shares from Koch et al. They calibrate the mix of retirement
  // story causes after a retirement roll succeeds, not a global annual hazard.
  static const retirementAcuteInjuryCausePercent = 38.8;
  static const retirementChronicInjuryCausePercent = 24.1;
  static const retirementAgeCausePercent = 26.7;
  static const retirementAlternativeCareerCausePercent = 6.9;
  static const retirementPersonalCausePercent = 3.4;
}
