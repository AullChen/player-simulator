import '../domain/weighted_value.dart';

class ClubDefinition {
  const ClubDefinition(this.name, this.country, this.level);

  final String name;
  final String country;
  final int level;
}

abstract final class FootballCatalog {
  static const nationalities = <WeightedValue<String>>[
    WeightedValue('巴西', 10),
    WeightedValue('法国', 9),
    WeightedValue('西班牙', 8),
    WeightedValue('英格兰', 8),
    WeightedValue('德国', 7),
    WeightedValue('阿根廷', 7),
    WeightedValue('葡萄牙', 5),
    WeightedValue('意大利', 5),
    WeightedValue('荷兰', 4),
    WeightedValue('比利时', 3),
    WeightedValue('克罗地亚', 2),
    WeightedValue('乌拉圭', 2),
    WeightedValue('日本', 3),
    WeightedValue('韩国', 2),
    WeightedValue('中国', 3),
    WeightedValue('美国', 3),
    WeightedValue('墨西哥', 3),
    WeightedValue('哥伦比亚', 3),
    WeightedValue('尼日利亚', 3),
    WeightedValue('塞内加尔', 2),
    WeightedValue('摩洛哥', 2),
    WeightedValue('其他国家', 8),
  ];

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

  static const clubs = <ClubDefinition>[
    ClubDefinition('马德里竞技', '西班牙', 1),
    ClubDefinition('北伦敦竞技', '英格兰', 1),
    ClubDefinition('米兰蓝黑', '意大利', 1),
    ClubDefinition('慕尼黑之星', '德国', 1),
    ClubDefinition('巴黎之光', '法国', 1),
    ClubDefinition('里斯本雄狮', '葡萄牙', 2),
    ClubDefinition('阿姆斯特丹红白', '荷兰', 2),
    ClubDefinition('布鲁塞尔联合', '比利时', 2),
    ClubDefinition('布宜诺斯艾利斯河岸', '阿根廷', 2),
    ClubDefinition('圣保罗竞技', '巴西', 2),
    ClubDefinition('横滨港湾', '日本', 3),
    ClubDefinition('首尔之翼', '韩国', 3),
    ClubDefinition('上海海港城', '中国', 3),
    ClubDefinition('洛杉矶群星', '美国', 3),
    ClubDefinition('卡萨布兰卡竞技', '摩洛哥', 3),
    ClubDefinition('家乡职业俱乐部', '本国', 4),
    ClubDefinition('地区联赛新军', '本国', 4),
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
