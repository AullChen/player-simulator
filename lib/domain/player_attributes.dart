enum PlayerAttributeGroup { limbs, physical, football, mental, fortune }

enum PlayerAttribute {
  leftLeg,
  rightLeg,
  leftArm,
  rightArm,
  speed,
  strength,
  stamina,
  health,
  recovery,
  technique,
  intelligence,
  decisionMaking,
  discipline,
  resilience,
  teamwork,
  morale,
  reputation,
  luck,
}

extension PlayerAttributeInfo on PlayerAttribute {
  String get labelZh => switch (this) {
    PlayerAttribute.leftLeg => '左腿',
    PlayerAttribute.rightLeg => '右腿',
    PlayerAttribute.leftArm => '左臂',
    PlayerAttribute.rightArm => '右臂',
    PlayerAttribute.speed => '速度',
    PlayerAttribute.strength => '力量',
    PlayerAttribute.stamina => '体力',
    PlayerAttribute.health => '健康',
    PlayerAttribute.recovery => '恢复',
    PlayerAttribute.technique => '技术',
    PlayerAttribute.intelligence => '智力',
    PlayerAttribute.decisionMaking => '决策',
    PlayerAttribute.discipline => '纪律',
    PlayerAttribute.resilience => '韧性',
    PlayerAttribute.teamwork => '团队',
    PlayerAttribute.morale => '士气',
    PlayerAttribute.reputation => '声望',
    PlayerAttribute.luck => '运气',
  };

  String get labelEn => switch (this) {
    PlayerAttribute.leftLeg => 'Left leg',
    PlayerAttribute.rightLeg => 'Right leg',
    PlayerAttribute.leftArm => 'Left arm',
    PlayerAttribute.rightArm => 'Right arm',
    PlayerAttribute.speed => 'Speed',
    PlayerAttribute.strength => 'Strength',
    PlayerAttribute.stamina => 'Stamina',
    PlayerAttribute.health => 'Health',
    PlayerAttribute.recovery => 'Recovery',
    PlayerAttribute.technique => 'Technique',
    PlayerAttribute.intelligence => 'Intelligence',
    PlayerAttribute.decisionMaking => 'Decision making',
    PlayerAttribute.discipline => 'Discipline',
    PlayerAttribute.resilience => 'Resilience',
    PlayerAttribute.teamwork => 'Teamwork',
    PlayerAttribute.morale => 'Morale',
    PlayerAttribute.reputation => 'Reputation',
    PlayerAttribute.luck => 'Luck',
  };

  PlayerAttributeGroup get group => switch (this) {
    PlayerAttribute.leftLeg ||
    PlayerAttribute.rightLeg ||
    PlayerAttribute.leftArm ||
    PlayerAttribute.rightArm => PlayerAttributeGroup.limbs,
    PlayerAttribute.speed ||
    PlayerAttribute.strength ||
    PlayerAttribute.stamina ||
    PlayerAttribute.health ||
    PlayerAttribute.recovery => PlayerAttributeGroup.physical,
    PlayerAttribute.technique => PlayerAttributeGroup.football,
    PlayerAttribute.intelligence ||
    PlayerAttribute.decisionMaking ||
    PlayerAttribute.discipline ||
    PlayerAttribute.resilience ||
    PlayerAttribute.teamwork => PlayerAttributeGroup.mental,
    PlayerAttribute.morale ||
    PlayerAttribute.reputation ||
    PlayerAttribute.luck => PlayerAttributeGroup.fortune,
  };
}

class PlayerAttributes {
  PlayerAttributes(Map<PlayerAttribute, int> values)
    : values = Map.unmodifiable({
        for (final attribute in PlayerAttribute.values)
          attribute: (values[attribute] ?? 50).clamp(1, 99),
      });

  final Map<PlayerAttribute, int> values;

  int operator [](PlayerAttribute attribute) => values[attribute] ?? 50;

  PlayerAttributes apply(AttributeDelta delta) {
    return PlayerAttributes({
      for (final attribute in PlayerAttribute.values)
        attribute: (this[attribute] + delta[attribute]).clamp(1, 99),
    });
  }

  double average(Iterable<PlayerAttribute> attributes) {
    final items = attributes.toList();
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, item) => sum + this[item]) / items.length;
  }

  factory PlayerAttributes.fromJson(Map<String, dynamic> json) {
    return PlayerAttributes({
      for (final attribute in PlayerAttribute.values)
        attribute: _readInt(json[attribute.name], 50),
    });
  }

  Map<String, Object> toJson() => {
    for (final entry in values.entries) entry.key.name: entry.value,
  };
}

class AttributeDelta {
  const AttributeDelta([this.values = const {}]);

  final Map<PlayerAttribute, int> values;

  int operator [](PlayerAttribute attribute) => values[attribute] ?? 0;

  List<MapEntry<PlayerAttribute, int>> get highlights {
    final entries = values.entries.where((entry) => entry.value != 0).toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    return entries.take(4).toList();
  }

  AttributeDelta combine(AttributeDelta other) {
    return AttributeDelta({
      for (final attribute in PlayerAttribute.values)
        if (this[attribute] + other[attribute] != 0)
          attribute: this[attribute] + other[attribute],
    });
  }
}

int _readInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}
