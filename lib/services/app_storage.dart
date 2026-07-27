import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/saved_player.dart';

abstract interface class AppStorage {
  Future<AppSettings> loadSettings();

  Future<void> saveSettings(AppSettings settings);

  Future<List<SavedPlayer>> loadPlayers();

  Future<void> savePlayers(List<SavedPlayer> players);
}

class SharedPreferencesAppStorage implements AppStorage {
  SharedPreferencesAppStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _settingsKey = 'player_simulator.settings.v1';
  static const _playersKey = 'player_simulator.players.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettings> loadSettings() async {
    final raw = await _preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      return AppSettings.fromJson(_jsonMap(decoded));
    } on FormatException {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<List<SavedPlayer>> loadPlayers() async {
    final raw = await _preferences.getString(_playersKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map((item) => SavedPlayer.fromJson(_jsonMap(item)))
          .toList();
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<void> savePlayers(List<SavedPlayer> players) {
    return _preferences.setString(
      _playersKey,
      jsonEncode(players.map((player) => player.toJson()).toList()),
    );
  }
}

class MemoryAppStorage implements AppStorage {
  MemoryAppStorage({
    AppSettings settings = const AppSettings(),
    List<SavedPlayer> players = const [],
  }) : _settings = settings,
       _players = List.of(players);

  AppSettings _settings;
  List<SavedPlayer> _players;

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<List<SavedPlayer>> loadPlayers() async => List.of(_players);

  @override
  Future<void> savePlayers(List<SavedPlayer> players) async {
    _players = List.of(players);
  }
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return const {};
}
