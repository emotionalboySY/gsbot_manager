class Phase {
  final int phaseNumber;
  final int hp;
  final int? shield;
  final int? monsterLevel;
  final int? authenticForce;

  Phase({
    required this.phaseNumber,
    required this.hp,
    this.shield,
    this.monsterLevel,
    this.authenticForce,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      phaseNumber: json['phaseNumber'],
      hp: json['hp'],
      shield: json['shield'],
      monsterLevel: json['monsterLevel'],
      authenticForce: json['authenticForce'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaseNumber': phaseNumber,
      'hp': hp,
      'shield': shield,
      'monsterLevel': monsterLevel,
      'authenticForce': authenticForce,
    };
  }
}

class SpecialItems {
  final List<String> chilheuk;
  final List<String> eternal;
  final List<String> gwanghwi;
  final List<String> guarantee;
  final List<String> exceptional;

  SpecialItems({
    this.chilheuk = const [],
    this.eternal = const [],
    this.gwanghwi = const [],
    this.guarantee = const [],
    this.exceptional = const [],
  });

  factory SpecialItems.fromJson(Map<String, dynamic> json) {
    return SpecialItems(
      chilheuk: List<String>.from(json['chilheuk'] ?? []),
      eternal: List<String>.from(json['eternal'] ?? []),
      gwanghwi: List<String>.from(json['gwanghwi'] ?? []),
      guarantee: List<String>.from(json['guarantee'] ?? []),
      exceptional: List<String>.from(json['exceptional'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chilheuk': chilheuk,
      'eternal': eternal,
      'gwanghwi': gwanghwi,
      'guarantee': guarantee,
      'exceptional': exceptional,
    };
  }
}

class Rewards {
  final int crystalPrice;
  final int? solErda;
  final List<String> items;
  final SpecialItems specialItems;

  Rewards({
    required this.crystalPrice,
    this.solErda,
    required this.items,
    required this.specialItems,
  });

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(
      crystalPrice: json['crystalPrice'],
      solErda: json['solErda'],
      items: List<String>.from(json['items']),
      specialItems: SpecialItems.fromJson(json['specialItems'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crystalPrice': crystalPrice,
      'solErda': solErda,
      'items': items,
      'specialItems': specialItems.toJson(),
    };
  }
}

class Difficulty {
  final int monsterLevel;
  final int defenseRate;
  final int? arcaneForce;
  final int? authenticForce;
  final List<Phase> phases;
  final Rewards rewards;

  Difficulty({
    required this.monsterLevel,
    required this.defenseRate,
    this.arcaneForce,
    this.authenticForce,
    required this.phases,
    required this.rewards,
  });

  factory Difficulty.fromJson(Map<String, dynamic> json) {
    return Difficulty(
      monsterLevel: json['monsterLevel'],
      defenseRate: json['defenseRate'],
      arcaneForce: json['arcaneForce'],
      authenticForce: json['authenticForce'],
      phases: (json['phases'] as List)
          .map((phase) => Phase.fromJson(phase))
          .toList(),
      rewards: Rewards.fromJson(json['rewards']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monsterLevel': monsterLevel,
      'defenseRate': defenseRate,
      'arcaneForce': arcaneForce,
      'authenticForce': authenticForce,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'rewards': rewards.toJson(),
    };
  }
}

class Boss {
  final String? id;
  final String name;
  final List<String> aliases;
  final int entryLevel;
  final List<String> availableDifficulties;
  final Map<String, Difficulty> difficulties;
  final String? imageName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Boss({
    this.id,
    required this.name,
    this.aliases = const [],
    required this.entryLevel,
    required this.availableDifficulties,
    required this.difficulties,
    this.imageName,
    this.createdAt,
    this.updatedAt,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    Map<String, Difficulty> difficulties = {};

    if (json['difficulties'] != null) {
      (json['difficulties'] as Map<String, dynamic>).forEach((key, value) {
        difficulties[key] = Difficulty.fromJson(value);
      });
    }

    return Boss(
      id: json['_id'],
      name: json['name'],
      aliases: List<String>.from(json['aliases'] ?? []),
      entryLevel: json['entryLevel'],
      availableDifficulties: List<String>.from(json['availableDifficulties']),
      difficulties: difficulties,
      imageName: json['imageName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> difficultiesJson = {};
    difficulties.forEach((key, value) {
      difficultiesJson[key] = value.toJson();
    });

    return {
      'name': name,
      'aliases': aliases,
      'entryLevel': entryLevel,
      'availableDifficulties': availableDifficulties,
      'difficulties': difficultiesJson,
      'imageName': imageName,
    };
  }

  // 헬퍼 메서드들
  Difficulty? getDifficulty(String difficulty) {
    return difficulties[difficulty];
  }

  int getTotalHP(String difficulty) {
    final diff = getDifficulty(difficulty);
    if (diff == null) return 0;
    return diff.phases.fold(0, (sum, phase) => sum + phase.hp);
  }

  int getPhaseCount(String difficulty) {
    final diff = getDifficulty(difficulty);
    return diff?.phases.length ?? 0;
  }

  // 보스 복사 메서드 (불변성을 위해)
  Boss copyWith({
    String? id,
    String? name,
    List<String>? aliases,
    int? entryLevel,
    List<String>? availableDifficulties,
    Map<String, Difficulty>? difficulties,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Boss(
      id: id ?? this.id,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      entryLevel: entryLevel ?? this.entryLevel,
      availableDifficulties: availableDifficulties ?? this.availableDifficulties,
      difficulties: difficulties ?? this.difficulties,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}