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
  });

  final int appearances;
  final int goals;
  final int assists;
  final int nationalCaps;
  final int nationalGoals;
  final int transferCount;
  final double totalTransferFeeMillions;
  final List<String> championships;
  final List<String> personalHonors;

  Map<String, Object> toJson() => {
    'appearances': appearances,
    'goals': goals,
    'assists': assists,
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
  });

  final CareerMode mode;
  final String name;
  final String nationality;
  final String preferredFoot;
  final int heightCm;
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
  final List<CareerChapter> career;
  final CareerStats stats;

  Map<String, Object> toJson() => {
    'mode': mode.name,
    'personal_information': {
      'name': name,
      'nationality': nationality,
      'preferred_foot': preferredFoot,
      'height_cm': heightCm,
      'primary_position': primaryPosition,
      'secondary_position': secondaryPosition,
      'play_style': playStyle,
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
      'injury_record': injuryRecord,
      'chapters': career.map((chapter) => chapter.toJson()).toList(),
      'statistics': stats.toJson(),
    },
  };
}
