import '../domain/weighted_value.dart';

class ClubDefinition {
  const ClubDefinition(this.name, this.country, this.level);

  final String name;
  final String country;
  final int level;
}

abstract final class FootballCatalog {
  /// FIFA Professional Football Report 2023 top-five association counts by
  /// confederation. The tail is the exact remainder of the 128,694 global
  /// total after these 27 reported associations.
  static const professionalAssociationPopulations = <WeightedValue<String>>[
    WeightedValue('墨西哥', 9464),
    WeightedValue('西班牙', 8560),
    WeightedValue('英格兰', 5582),
    WeightedValue('苏格兰', 4796),
    WeightedValue('土耳其', 3917),
    WeightedValue('俄罗斯', 3633),
    WeightedValue('阿根廷', 3613),
    WeightedValue('美国', 2791),
    WeightedValue('日本', 2126),
    WeightedValue('巴西', 2123),
    WeightedValue('伊朗', 1800),
    WeightedValue('萨尔瓦多', 1700),
    WeightedValue('澳大利亚', 1597),
    WeightedValue('中国', 1586),
    WeightedValue('印度', 1506),
    WeightedValue('智利', 1350),
    WeightedValue('喀麦隆', 1225),
    WeightedValue('哥伦比亚', 1163),
    WeightedValue('乌干达', 991),
    WeightedValue('新西兰', 963),
    WeightedValue('危地马拉', 945),
    WeightedValue('厄瓜多尔', 897),
    WeightedValue('哥斯达黎加', 773),
    WeightedValue('刚果（金）', 800),
    WeightedValue('尼日利亚', 790),
    WeightedValue('加纳', 704),
    WeightedValue('斐济', 307),
    WeightedValue('其他 FIFA 协会', 62992),
  ];

  static const otherAssociations = <String>[
    '法国',
    '德国',
    '意大利',
    '葡萄牙',
    '荷兰',
    '比利时',
    '克罗地亚',
    '瑞士',
    '奥地利',
    '塞尔维亚',
    '韩国',
    '沙特阿拉伯',
    '阿联酋',
    '泰国',
    '印度尼西亚',
    '智利',
    '乌拉圭',
    '巴拉圭',
    '秘鲁',
    '摩洛哥',
    '埃及',
    '南非',
    '塞内加尔',
    '加拿大',
    '牙买加',
  ];

  static const associationConfederations = <String, String>{
    '日本': 'AFC',
    '伊朗': 'AFC',
    '澳大利亚': 'AFC',
    '中国': 'AFC',
    '印度': 'AFC',
    '喀麦隆': 'CAF',
    '乌干达': 'CAF',
    '刚果（金）': 'CAF',
    '尼日利亚': 'CAF',
    '加纳': 'CAF',
    '墨西哥': 'Concacaf',
    '美国': 'Concacaf',
    '萨尔瓦多': 'Concacaf',
    '危地马拉': 'Concacaf',
    '哥斯达黎加': 'Concacaf',
    '阿根廷': 'CONMEBOL',
    '巴西': 'CONMEBOL',
    '智利': 'CONMEBOL',
    '哥伦比亚': 'CONMEBOL',
    '厄瓜多尔': 'CONMEBOL',
    '新西兰': 'OFC',
    '斐济': 'OFC',
    '西班牙': 'UEFA',
    '英格兰': 'UEFA',
    '苏格兰': 'UEFA',
    '土耳其': 'UEFA',
    '俄罗斯': 'UEFA',
  };

  /// Percentage of players who play in their domestic association according
  /// to the FIFA report. UEFA's 66 is the inverse of its 34% foreign share.
  static const homegrownPercentByConfederation = <String, int>{
    'AFC': 81,
    'CAF': 92,
    'Concacaf': 82,
    'CONMEBOL': 83,
    'OFC': 94,
    'UEFA': 66,
  };

  /// Complete 81-country nationality table published with the FIFA Club
  /// World Cup 2025 squads, grouped by confederation. The two-stage draw first
  /// selects a confederation using its subtotal and then a concrete country;
  /// there is deliberately no ambiguous "other country" bucket.
  static const nationalitiesByConfederation =
      <String, List<WeightedValue<String>>>{
        'AFC': [
          WeightedValue('日本', 29),
          WeightedValue('韩国', 27),
          WeightedValue('沙特阿拉伯', 25),
          WeightedValue('阿联酋', 8),
          WeightedValue('中国', 1),
          WeightedValue('伊朗', 1),
          WeightedValue('巴勒斯坦', 1),
          WeightedValue('叙利亚', 1),
          WeightedValue('乌兹别克斯坦', 1),
        ],
        'CAF': [
          WeightedValue('摩洛哥', 31),
          WeightedValue('南非', 31),
          WeightedValue('突尼斯', 25),
          WeightedValue('埃及', 23),
          WeightedValue('马里', 8),
          WeightedValue('尼日利亚', 5),
          WeightedValue('阿尔及利亚', 4),
          WeightedValue('加纳', 3),
          WeightedValue('塞内加尔', 3),
          WeightedValue('安哥拉', 2),
          WeightedValue('喀麦隆', 2),
          WeightedValue('科特迪瓦', 2),
          WeightedValue('布基纳法索', 1),
          WeightedValue('刚果（布）', 1),
          WeightedValue('加蓬', 1),
          WeightedValue('几内亚', 1),
          WeightedValue('莫桑比克', 1),
          WeightedValue('纳米比亚', 1),
          WeightedValue('坦桑尼亚', 1),
          WeightedValue('多哥', 1),
          WeightedValue('乌干达', 1),
          WeightedValue('津巴布韦', 1),
        ],
        'Concacaf': [
          WeightedValue('墨西哥', 41),
          WeightedValue('美国', 40),
          WeightedValue('加拿大', 3),
          WeightedValue('萨尔瓦多', 2),
          WeightedValue('多米尼加', 1),
          WeightedValue('危地马拉', 1),
          WeightedValue('圭亚那', 1),
          WeightedValue('海地', 1),
          WeightedValue('洪都拉斯', 1),
          WeightedValue('牙买加', 1),
        ],
        'CONMEBOL': [
          WeightedValue('巴西', 141),
          WeightedValue('阿根廷', 103),
          WeightedValue('乌拉圭', 24),
          WeightedValue('哥伦比亚', 14),
          WeightedValue('智利', 6),
          WeightedValue('巴拉圭', 6),
          WeightedValue('委内瑞拉', 6),
          WeightedValue('厄瓜多尔', 5),
          WeightedValue('秘鲁', 1),
        ],
        'OFC': [WeightedValue('新西兰', 23)],
        'UEFA': [
          WeightedValue('西班牙', 54),
          WeightedValue('葡萄牙', 49),
          WeightedValue('法国', 37),
          WeightedValue('德国', 36),
          WeightedValue('意大利', 36),
          WeightedValue('英格兰', 25),
          WeightedValue('奥地利', 13),
          WeightedValue('瑞典', 9),
          WeightedValue('比利时', 8),
          WeightedValue('荷兰', 8),
          WeightedValue('挪威', 8),
          WeightedValue('土耳其', 6),
          WeightedValue('克罗地亚', 5),
          WeightedValue('塞尔维亚', 5),
          WeightedValue('瑞士', 5),
          WeightedValue('丹麦', 4),
          WeightedValue('波兰', 4),
          WeightedValue('希腊', 3),
          WeightedValue('斯洛文尼亚', 3),
          WeightedValue('乌克兰', 3),
          WeightedValue('阿尔巴尼亚', 2),
          WeightedValue('以色列', 2),
          WeightedValue('卢森堡', 2),
          WeightedValue('亚美尼亚', 1),
          WeightedValue('波黑', 1),
          WeightedValue('格鲁吉亚', 1),
          WeightedValue('黑山', 1),
          WeightedValue('爱尔兰', 1),
          WeightedValue('俄罗斯', 1),
          WeightedValue('斯洛伐克', 1),
        ],
      };

  static final nationalityConfederationWeights = nationalitiesByConfederation
      .entries
      .map(
        (entry) => WeightedValue(
          entry.key,
          entry.value.fold<int>(0, (total, country) => total + country.weight),
        ),
      )
      .toList(growable: false);

  static final nationalities = nationalitiesByConfederation.values
      .expand((countries) => countries)
      .toList(growable: false);

  static String? confederationForCountry(String country) {
    final reported = associationConfederations[country];
    if (reported != null) return reported;
    for (final entry in nationalitiesByConfederation.entries) {
      if (entry.value.any((item) => item.value == country)) return entry.key;
    }
    return const {
      '澳大利亚': 'AFC',
      '印度': 'AFC',
      '泰国': 'AFC',
      '印度尼西亚': 'AFC',
      '斐济': 'OFC',
      '刚果（金）': 'CAF',
    }[country];
  }

  static const positions = <WeightedValue<String>>[
    WeightedValue('门将', 9),
    WeightedValue('中后卫', 16),
    WeightedValue('边后卫', 13),
    WeightedValue('后腰', 10),
    WeightedValue('中前卫', 13),
    WeightedValue('前腰', 8),
    WeightedValue('边锋', 14),
    WeightedValue('中锋', 17),
  ];

  static const preferredFeet = <WeightedValue<String>>[
    WeightedValue('右脚', 73),
    WeightedValue('左脚', 22),
    WeightedValue('双足', 5),
  ];

  static const academyTiers = <WeightedValue<int>>[
    WeightedValue(1, 8),
    WeightedValue(2, 22),
    WeightedValue(3, 40),
    WeightedValue(4, 30),
  ];

  static const transferCounts = <WeightedValue<int>>[
    WeightedValue(0, 8),
    WeightedValue(1, 19),
    WeightedValue(2, 25),
    WeightedValue(3, 20),
    WeightedValue(4, 13),
    WeightedValue(5, 8),
    WeightedValue(6, 4),
    WeightedValue(7, 2),
    WeightedValue(8, 1),
  ];

  /// FIFA reports that permanent international moves typically account for
  /// less than 20%, most moves involve out-of-contract players, and the
  /// remainder are loans. These weights encode that published relationship.
  static const transferTypes = <WeightedValue<String>>[
    WeightedValue('自由转会', 62),
    WeightedValue('租借', 20),
    WeightedValue('永久转会', 18),
  ];

  static const contractLengthsYears = <WeightedValue<int>>[
    WeightedValue(1, 18),
    WeightedValue(2, 25),
    WeightedValue(3, 28),
    WeightedValue(4, 18),
    WeightedValue(5, 9),
    WeightedValue(6, 2),
  ];

  static const injuryTypes = <WeightedValue<String>>[
    WeightedValue('肌肉损伤', 32),
    WeightedValue('腿筋伤势', 20),
    WeightedValue('踝关节伤势', 16),
    WeightedValue('膝关节伤势', 12),
    WeightedValue('撞击伤', 12),
    WeightedValue('韧带重伤', 5),
    WeightedValue('其他伤病', 3),
  ];

  static const agents = <String>[
    'North Star Sports',
    'Eleven Careers',
    'Global Pitch Agency',
    '家族代理',
    '无经纪人',
  ];

  static const leagues = <String>[
    '英格兰顶级联赛',
    '西班牙顶级联赛',
    '德国顶级联赛',
    '意大利顶级联赛',
    '法国顶级联赛',
    '葡萄牙顶级联赛',
    '荷兰顶级联赛',
    '巴西顶级联赛',
    '阿根廷顶级联赛',
    '美国职业联赛',
    '日本职业联赛',
    '其他顶级联赛',
  ];

  static const birthPlaces = <String, List<String>>{
    '巴西': ['圣保罗', '里约热内卢', '萨尔瓦多', '累西腓'],
    '阿根廷': ['布宜诺斯艾利斯', '罗萨里奥', '科尔多瓦', '门多萨'],
    '西班牙': ['马德里', '巴塞罗那', '瓦伦西亚', '塞维利亚'],
    '葡萄牙': ['里斯本', '波尔图', '布拉加', '丰沙尔'],
    '法国': ['巴黎', '里昂', '马赛', '里尔'],
    '德国': ['柏林', '慕尼黑', '科隆', '汉堡'],
    '意大利': ['米兰', '罗马', '都灵', '那不勒斯'],
    '英格兰': ['伦敦', '曼彻斯特', '利物浦', '伯明翰'],
    '中国': ['上海', '北京', '广州', '成都'],
    '日本': ['东京', '大阪', '横滨', '神户'],
    '韩国': ['首尔', '釜山', '仁川', '水原'],
    '美国': ['洛杉矶', '纽约', '达拉斯', '迈阿密'],
    '墨西哥': ['墨西哥城', '瓜达拉哈拉', '蒙特雷', '普埃布拉'],
  };

  static const secondaryCitizenships = <String, List<String>>{
    '巴西': ['葡萄牙', '西班牙', '意大利'],
    '阿根廷': ['西班牙', '意大利'],
    '法国': ['阿尔及利亚', '塞内加尔', '摩洛哥'],
    '西班牙': ['阿根廷', '摩洛哥'],
    '葡萄牙': ['巴西', '安哥拉'],
    '德国': ['土耳其', '波兰'],
    '英格兰': ['爱尔兰', '尼日利亚'],
    '美国': ['墨西哥', '德国'],
    '摩洛哥': ['法国', '荷兰', '西班牙'],
  };

  static const squadNumbers = <String, List<int>>{
    '门将': [1, 13, 22, 25, 31],
    '中后卫': [2, 3, 4, 5, 15, 24],
    '边后卫': [2, 3, 12, 18, 21, 23],
    '后腰': [4, 5, 6, 16, 18],
    '中前卫': [6, 8, 14, 16, 20],
    '前腰': [8, 10, 14, 21],
    '边锋': [7, 11, 17, 19, 20],
    '中锋': [9, 10, 18, 19, 27],
  };

  static const injuryRecords = <WeightedValue<String>>[
    WeightedValue('几乎保持全勤，只有轻微伤停', 35),
    WeightedValue('偶有肌肉伤病，但恢复良好', 35),
    WeightedValue('经历过一次长期伤病', 20),
    WeightedValue('伤病反复，显著影响了出场时间', 10),
  ];

  static const academies = <int, List<String>>{
    1: ['拉玛西亚青训营', '克莱枫丹青训中心', '阿贾克斯青训营', '本菲卡青训营'],
    2: ['里斯本竞技青训营', '萨尔茨堡青训营', '河床青训营', '圣保罗青训营'],
    3: ['本国顶级联赛俱乐部梯队', '地区职业青训学院', '职业俱乐部卫星学院'],
    4: ['社区足球学校', '校园足球队', '地方半职业俱乐部'],
  };

  /// Real clubs from FIFA's official 2025 Club World Cup participant list.
  static const clubs = <ClubDefinition>[
    ClubDefinition('Real Madrid C.F.', '西班牙', 1),
    ClubDefinition('Manchester City', '英格兰', 1),
    ClubDefinition('FC Bayern München', '德国', 1),
    ClubDefinition('Paris Saint-Germain', '法国', 1),
    ClubDefinition('Chelsea FC', '英格兰', 1),
    ClubDefinition('FC Internazionale Milano', '意大利', 1),
    ClubDefinition('Atlético de Madrid', '西班牙', 1),
    ClubDefinition('CR Flamengo', '巴西', 1),
    ClubDefinition('SE Palmeiras', '巴西', 1),
    ClubDefinition('CA River Plate', '阿根廷', 1),
    ClubDefinition('Borussia Dortmund', '德国', 2),
    ClubDefinition('Juventus FC', '意大利', 2),
    ClubDefinition('SL Benfica', '葡萄牙', 2),
    ClubDefinition('FC Porto', '葡萄牙', 2),
    ClubDefinition('Fluminense FC', '巴西', 2),
    ClubDefinition('Botafogo', '巴西', 2),
    ClubDefinition('CA Boca Juniors', '阿根廷', 2),
    ClubDefinition('Al Hilal', '沙特阿拉伯', 2),
    ClubDefinition('Al Ahly FC', '埃及', 2),
    ClubDefinition('FC Salzburg', '奥地利', 2),
    ClubDefinition('Inter Miami CF', '美国', 3),
    ClubDefinition('Los Angeles FC', '美国', 3),
    ClubDefinition('Seattle Sounders FC', '美国', 3),
    ClubDefinition('CF Monterrey', '墨西哥', 3),
    ClubDefinition('CF Pachuca', '墨西哥', 3),
    ClubDefinition('Urawa Red Diamonds', '日本', 3),
    ClubDefinition('Ulsan HD', '韩国', 3),
    ClubDefinition('Al Ain FC', '阿联酋', 3),
    ClubDefinition('Wydad AC', '摩洛哥', 3),
    ClubDefinition('Mamelodi Sundowns FC', '南非', 3),
    ClubDefinition('Espérance de Tunis', '突尼斯', 3),
    ClubDefinition('Auckland City FC', '新西兰', 4),
  ];

  static const positionStyles = <String, List<String>>{
    '门将': ['门线反应型', '出击控制型', '现代清道夫门将'],
    '中后卫': ['上抢型中卫', '出球型中卫', '制空领袖'],
    '边后卫': ['攻守平衡型边卫', '内收组织型边卫', '边路冲击型翼卫'],
    '后腰': ['防守屏障', '拖后组织核心', '全能拦截者'],
    '中前卫': ['B2B全能中场', '节奏控制者', '后插上得分手'],
    '前腰': ['古典组织核心', '肋部创造者', '影子前锋'],
    '边锋': ['逆足内切手', '边路爆点', '创造型边锋'],
    '中锋': ['禁区终结者', '支点中锋', '机动型九号'],
  };

  static const secondaryPositions = <String, List<String>>{
    '门将': ['门将'],
    '中后卫': ['后腰', '边后卫'],
    '边后卫': ['边锋', '中后卫'],
    '后腰': ['中前卫', '中后卫'],
    '中前卫': ['后腰', '前腰'],
    '前腰': ['中前卫', '边锋'],
    '边锋': ['前腰', '中锋'],
    '中锋': ['边锋', '前腰'],
  };
}
