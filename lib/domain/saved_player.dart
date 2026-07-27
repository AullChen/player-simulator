import 'player_profile.dart';

class SavedPlayer {
  const SavedPlayer({
    required this.id,
    required this.savedAt,
    required this.profile,
  });

  final String id;
  final DateTime savedAt;
  final PlayerProfile profile;

  factory SavedPlayer.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    return SavedPlayer(
      id: '${json['id'] ?? ''}',
      savedAt: DateTime.tryParse('${json['saved_at'] ?? ''}') ?? DateTime(2000),
      profile: PlayerProfile.fromJson(
        rawProfile is Map<String, dynamic> ? rawProfile : const {},
      ),
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'saved_at': savedAt.toIso8601String(),
    'profile': profile.toJson(),
  };
}
