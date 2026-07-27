import 'player_attributes.dart';

enum CareerMode { random, life, dream }

class CareerChapter {
  const CareerChapter({
    required this.age,
    required this.club,
    required this.event,
    required this.rating,
  });

  final int age;
  final String club;
  final String event;
  final int rating;

  factory CareerChapter.fromJson(Map<String, dynamic> json) => CareerChapter(
    age: _int(json['age']),
    club: _string(json['club']),
    event: _string(json['event']),
    rating: _int(json['rating']),
  );

  Map<String, Object> toJson() => {
    'age': age,
    'club': club,
    'event': event,
    'rating': rating,
  };
}

class TransferRecord {
  const TransferRecord({
    required this.season,
    required this.age,
    required this.fromClub,
    required this.toClub,
    required this.type,
    required this.feeMillions,
  });

  final String season;
  final int age;
  final String fromClub;
  final String toClub;
  final String type;
  final double feeMillions;

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
    season: _string(json['season']),
    age: _int(json['age']),
    fromClub: _string(json['from_club']),
    toClub: _string(json['to_club']),
    type: _string(json['type']),
    feeMillions: _double(json['fee_millions']),
  );

  Map<String, Object> toJson() => {
    'season': season,
    'age': age,
    'from_club': fromClub,
    'to_club': toClub,
    'type': type,
    'fee_millions': feeMillions,
  };
}

class InjurySpell {
  const InjurySpell({
    required this.season,
    required this.type,
    required this.daysAbsent,
    required this.matchesMissed,
  });

  final String season;
  final String type;
  final int daysAbsent;
  final int matchesMissed;

  factory InjurySpell.fromJson(Map<String, dynamic> json) => InjurySpell(
    season: _string(json['season']),
    type: _string(json['type']),
    daysAbsent: _int(json['days_absent']),
    matchesMissed: _int(json['matches_missed']),
  );

  Map<String, Object> toJson() => {
    'season': season,
    'type': type,
    'days_absent': daysAbsent,
    'matches_missed': matchesMissed,
  };
}

class MarketValuePoint {
  const MarketValuePoint({required this.age, required this.valueMillions});

  final int age;
  final double valueMillions;

  factory MarketValuePoint.fromJson(Map<String, dynamic> json) =>
      MarketValuePoint(
        age: _int(json['age']),
        valueMillions: _double(json['value_millions']),
      );

  Map<String, Object> toJson() => {'age': age, 'value_millions': valueMillions};
}

class CompetitionStats {
  const CompetitionStats({
    required this.competition,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.minutesPlayed,
  });

  final String competition;
  final int appearances;
  final int goals;
  final int assists;
  final int minutesPlayed;

  factory CompetitionStats.fromJson(Map<String, dynamic> json) =>
      CompetitionStats(
        competition: _string(json['competition']),
        appearances: _int(json['appearances']),
        goals: _int(json['goals']),
        assists: _int(json['assists']),
        minutesPlayed: _int(json['minutes_played']),
      );

  Map<String, Object> toJson() => {
    'competition': competition,
    'appearances': appearances,
    'goals': goals,
    'assists': assists,
    'minutes_played': minutesPlayed,
  };
}

class CareerStats {
  const CareerStats({
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.nationalCaps,
    required this.nationalGoals,
    required this.transferCount,
    required this.totalTransferFeeMillions,
    required this.championships,
    required this.personalHonors,
    this.starts = 0,
    this.substituteAppearances = 0,
    this.minutesPlayed = 0,
    this.yellowCards = 0,
    this.secondYellowCards = 0,
    this.redCards = 0,
    this.cleanSheets = 0,
    this.penaltiesScored = 0,
  });

  final int appearances;
  final int starts;
  final int substituteAppearances;
  final int minutesPlayed;
  final int goals;
  final int assists;
  final int yellowCards;
  final int secondYellowCards;
  final int redCards;
  final int cleanSheets;
  final int penaltiesScored;
  final int nationalCaps;
  final int nationalGoals;
  final int transferCount;
  final double totalTransferFeeMillions;
  final List<String> championships;
  final List<String> personalHonors;

  factory CareerStats.fromJson(Map<String, dynamic> json) => CareerStats(
    appearances: _int(json['appearances']),
    starts: _int(json['starts']),
    substituteAppearances: _int(json['substitute_appearances']),
    minutesPlayed: _int(json['minutes_played']),
    goals: _int(json['goals']),
    assists: _int(json['assists']),
    yellowCards: _int(json['yellow_cards']),
    secondYellowCards: _int(json['second_yellow_cards']),
    redCards: _int(json['red_cards']),
    cleanSheets: _int(json['clean_sheets']),
    penaltiesScored: _int(json['penalties_scored']),
    nationalCaps: _int(json['national_caps']),
    nationalGoals: _int(json['national_goals']),
    transferCount: _int(json['transfer_count']),
    totalTransferFeeMillions: _double(json['total_transfer_fee_millions']),
    championships: _strings(json['championships']),
    personalHonors: _strings(json['personal_honors']),
  );

  Map<String, Object> toJson() => {
    'appearances': appearances,
    'starts': starts,
    'substitute_appearances': substituteAppearances,
    'minutes_played': minutesPlayed,
    'goals': goals,
    'assists': assists,
    'yellow_cards': yellowCards,
    'second_yellow_cards': secondYellowCards,
    'red_cards': redCards,
    'clean_sheets': cleanSheets,
    'penalties_scored': penaltiesScored,
    'national_caps': nationalCaps,
    'national_goals': nationalGoals,
    'transfer_count': transferCount,
    'total_transfer_fee_millions': totalTransferFeeMillions,
    'championships': championships,
    'personal_honors': personalHonors,
  };
}

class PlayerProfile {
  const PlayerProfile({
    required this.mode,
    required this.name,
    required this.nationality,
    required this.preferredFoot,
    required this.heightCm,
    required this.primaryPosition,
    required this.secondaryPosition,
    required this.academy,
    required this.debutAge,
    required this.retirementAge,
    required this.initialRating,
    required this.peakRating,
    required this.finalRating,
    required this.playStyle,
    required this.injuryRecord,
    required this.career,
    required this.stats,
    this.birthDate = '未记录',
    this.birthPlace = '未记录',
    this.developmentAssociation = '未记录',
    this.citizenships = const [],
    this.weightKg = 0,
    this.shirtNumber = 0,
    this.currentClub = '未记录',
    this.currentLeague = '未记录',
    this.joinedClubDate = '未记录',
    this.contractUntil = '未记录',
    this.agent = '未记录',
    this.marketValueMillions = 0,
    this.nationalTeam = '未入选',
    this.nationalTeamDebut = '未记录',
    this.transferHistory = const [],
    this.injuryHistory = const [],
    this.marketValueHistory = const [],
    this.competitionStats = const [],
    this.characterAttributes,
  });

  final CareerMode mode;
  final String name;
  final String birthDate;
  final String birthPlace;
  final String developmentAssociation;
  final String nationality;
  final List<String> citizenships;
  final String preferredFoot;
  final int heightCm;
  final int weightKg;
  final int shirtNumber;
  final String primaryPosition;
  final String secondaryPosition;
  final String academy;
  final int debutAge;
  final int retirementAge;
  final int initialRating;
  final int peakRating;
  final int finalRating;
  final String playStyle;
  final String injuryRecord;
  final String currentClub;
  final String currentLeague;
  final String joinedClubDate;
  final String contractUntil;
  final String agent;
  final double marketValueMillions;
  final String nationalTeam;
  final String nationalTeamDebut;
  final List<CareerChapter> career;
  final List<TransferRecord> transferHistory;
  final List<InjurySpell> injuryHistory;
  final List<MarketValuePoint> marketValueHistory;
  final List<CompetitionStats> competitionStats;
  final CareerStats stats;
  final PlayerAttributes? characterAttributes;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final personal = _map(json['personal_information']);
    final registration = _map(json['registration_and_contract']);
    final national = _map(json['national_team']);
    final ability = _map(json['ability']);
    final career = _map(json['career_information']);
    final modeName = _string(json['mode'], fallback: 'random');
    var mode = CareerMode.random;
    for (final value in CareerMode.values) {
      if (value.name == modeName) {
        mode = value;
        break;
      }
    }

    return PlayerProfile(
      mode: mode,
      name: _string(personal['name'], fallback: '未命名球员'),
      birthDate: _string(personal['date_of_birth'], fallback: '未记录'),
      birthPlace: _string(personal['place_of_birth'], fallback: '未记录'),
      developmentAssociation: _string(
        personal['development_association'],
        fallback: _string(personal['nationality'], fallback: '未记录'),
      ),
      nationality: _string(personal['nationality'], fallback: '未记录'),
      citizenships: _strings(personal['citizenships']),
      preferredFoot: _string(personal['preferred_foot'], fallback: '未记录'),
      heightCm: _int(personal['height_cm']),
      weightKg: _int(personal['weight_kg']),
      shirtNumber: _int(personal['shirt_number']),
      primaryPosition: _string(personal['primary_position'], fallback: '未记录'),
      secondaryPosition: _string(
        personal['secondary_position'],
        fallback: '未记录',
      ),
      academy: _string(career['academy'], fallback: '未记录'),
      debutAge: _int(career['debut_age']),
      retirementAge: _int(career['retirement_age']),
      initialRating: _int(ability['initial_rating']),
      peakRating: _int(ability['peak_rating']),
      finalRating: _int(ability['final_rating']),
      playStyle: _string(personal['play_style'], fallback: '未记录'),
      injuryRecord: _string(career['injury_summary'], fallback: '未记录'),
      currentClub: _string(registration['club'], fallback: '未记录'),
      currentLeague: _string(registration['league'], fallback: '未记录'),
      joinedClubDate: _string(registration['joined'], fallback: '未记录'),
      contractUntil: _string(registration['contract_until'], fallback: '未记录'),
      agent: _string(registration['agent'], fallback: '未记录'),
      marketValueMillions: _double(registration['market_value_millions']),
      nationalTeam: _string(national['team'], fallback: '未入选'),
      nationalTeamDebut: _string(national['debut'], fallback: '未记录'),
      career: _maps(career['chapters']).map(CareerChapter.fromJson).toList(),
      transferHistory: _maps(
        career['transfer_history'],
      ).map(TransferRecord.fromJson).toList(),
      injuryHistory: _maps(
        career['injury_history'],
      ).map(InjurySpell.fromJson).toList(),
      marketValueHistory: _maps(
        career['market_value_history'],
      ).map(MarketValuePoint.fromJson).toList(),
      competitionStats: _maps(
        career['competition_statistics'],
      ).map(CompetitionStats.fromJson).toList(),
      stats: CareerStats.fromJson(_map(career['statistics'])),
      characterAttributes: _map(json['character_model']).isEmpty
          ? null
          : PlayerAttributes.fromJson(_map(json['character_model'])),
    );
  }

  Map<String, Object> toJson() => {
    'mode': mode.name,
    'personal_information': {
      'name': name,
      'date_of_birth': birthDate,
      'place_of_birth': birthPlace,
      'development_association': developmentAssociation,
      'nationality': nationality,
      'citizenships': citizenships,
      'preferred_foot': preferredFoot,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'shirt_number': shirtNumber,
      'primary_position': primaryPosition,
      'secondary_position': secondaryPosition,
      'play_style': playStyle,
    },
    'registration_and_contract': {
      'club': currentClub,
      'league': currentLeague,
      'joined': joinedClubDate,
      'contract_until': contractUntil,
      'agent': agent,
      'market_value_millions': marketValueMillions,
    },
    'national_team': {
      'team': nationalTeam,
      'debut': nationalTeamDebut,
      'caps': stats.nationalCaps,
      'goals': stats.nationalGoals,
    },
    'ability': {
      'initial_rating': initialRating,
      'peak_rating': peakRating,
      'final_rating': finalRating,
    },
    if (characterAttributes != null)
      'character_model': characterAttributes!.toJson(),
    'career_information': {
      'academy': academy,
      'debut_age': debutAge,
      'retirement_age': retirementAge,
      'injury_summary': injuryRecord,
      'chapters': career.map((chapter) => chapter.toJson()).toList(),
      'transfer_history': transferHistory
          .map((transfer) => transfer.toJson())
          .toList(),
      'injury_history': injuryHistory.map((injury) => injury.toJson()).toList(),
      'market_value_history': marketValueHistory
          .map((point) => point.toJson())
          .toList(),
      'competition_statistics': competitionStats
          .map((competition) => competition.toJson())
          .toList(),
      'statistics': stats.toJson(),
    },
  };
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return const {};
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! List) return const [];
  return value.map(_map).toList();
}

String _string(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}

double _double(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

List<String> _strings(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => '$item').toList();
}
