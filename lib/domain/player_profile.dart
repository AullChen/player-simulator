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
  });

  final CareerMode mode;
  final String name;
  final String birthDate;
  final String birthPlace;
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

  Map<String, Object> toJson() => {
    'mode': mode.name,
    'personal_information': {
      'name': name,
      'date_of_birth': birthDate,
      'place_of_birth': birthPlace,
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
