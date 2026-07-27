import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/app_settings.dart';
import '../domain/player_profile.dart';
import '../domain/saved_player.dart';
import 'app_storage.dart';
import 'story_api_client.dart';

class AppController extends ChangeNotifier {
  AppController(this._storage);

  final AppStorage _storage;

  AppSettings settings = const AppSettings();
  List<SavedPlayer> savedPlayers = const [];
  bool initialized = false;

  Future<void> initialize() async {
    final results = await Future.wait<Object>([
      _storage.loadSettings(),
      _storage.loadPlayers(),
    ]);
    settings = results[0] as AppSettings;
    savedPlayers = List.unmodifiable(results[1] as List<SavedPlayer>);
    initialized = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings value) async {
    settings = value;
    notifyListeners();
    await _storage.saveSettings(value);
  }

  Future<bool> savePlayer(PlayerProfile profile) async {
    final encoded = jsonEncode(profile.toJson());
    if (savedPlayers.any(
      (saved) => jsonEncode(saved.profile.toJson()) == encoded,
    )) {
      return false;
    }
    final saved = SavedPlayer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
      profile: profile,
    );
    savedPlayers = List.unmodifiable([saved, ...savedPlayers].take(50));
    notifyListeners();
    await _storage.savePlayers(savedPlayers);
    return true;
  }

  Future<void> deletePlayer(String id) async {
    savedPlayers = List.unmodifiable(
      savedPlayers.where((player) => player.id != id),
    );
    notifyListeners();
    await _storage.savePlayers(savedPlayers);
  }

  StoryApiClient createStoryClient() {
    final environment = StoryApiClient.fromEnvironment();
    return StoryApiClient(
      endpoint: settings.apiEndpoint.trim().isEmpty
          ? environment.endpoint
          : settings.apiEndpoint.trim(),
      token: settings.apiEndpoint.trim().isEmpty
          ? environment.token
          : settings.apiToken.trim(),
      model: settings.apiModel.trim().isEmpty
          ? environment.model
          : settings.apiModel.trim(),
      language: settings.language == AppLanguage.en ? 'en' : 'zh-CN',
    );
  }
}
