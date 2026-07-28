import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/domain/app_settings.dart';
import 'package:player_simulator/domain/player_profile.dart';
import 'package:player_simulator/services/app_controller.dart';
import 'package:player_simulator/services/app_storage.dart';
import 'package:player_simulator/services/random_career_generator.dart';

void main() {
  test('player profiles survive local JSON round trips', () {
    final original = RandomCareerGenerator(random: Random(18)).generate();
    final decoded = jsonDecode(jsonEncode(original.toJson()));
    final restored = PlayerProfile.fromJson(decoded as Map<String, dynamic>);

    expect(restored.toJson(), original.toJson());
  });

  test('controller persists API and language settings', () async {
    final storage = MemoryAppStorage();
    final controller = AppController(storage);
    await controller.initialize();

    await controller.updateSettings(
      const AppSettings(
        language: AppLanguage.en,
        apiProvider: StoryApiProvider.deepSeek,
        apiEndpoint: 'https://story.example.test/generate',
        apiToken: 'local-token',
        apiModel: 'custom-model',
        autoSavePlayers: true,
      ),
    );
    final reloaded = AppController(storage);
    await reloaded.initialize();
    final client = reloaded.createStoryClient();

    expect(reloaded.settings.language, AppLanguage.en);
    expect(reloaded.settings.autoSavePlayers, isTrue);
    expect(client.provider, StoryApiProvider.deepSeek);
    expect(client.endpoint, 'https://story.example.test/generate');
    expect(client.token, 'local-token');
    expect(client.model, 'custom-model');
    expect(client.language, 'en');
  });

  test('legacy API settings infer the provider from the endpoint', () {
    final anthropic = AppSettings.fromJson({
      'api_endpoint': 'https://api.anthropic.com/v1/messages',
      'api_token': 'legacy-token',
      'api_model': 'legacy-model',
    });
    final deepSeek = AppSettings.fromJson({
      'api_endpoint': 'https://api.deepseek.com/chat/completions',
    });
    final custom = AppSettings.fromJson({
      'api_endpoint': 'https://gateway.example.test/v1/chat/completions',
    });

    expect(anthropic.apiProvider, StoryApiProvider.anthropic);
    expect(deepSeek.apiProvider, StoryApiProvider.deepSeek);
    expect(custom.apiProvider, StoryApiProvider.openAi);
    expect(anthropic.toJson()['api_provider'], 'anthropic');
  });

  test('saved dossiers persist without duplicates', () async {
    final storage = MemoryAppStorage();
    final controller = AppController(storage);
    await controller.initialize();
    final profile = RandomCareerGenerator(random: Random(24)).generate();

    expect(await controller.savePlayer(profile), isTrue);
    expect(await controller.savePlayer(profile), isFalse);

    final reloaded = AppController(storage);
    await reloaded.initialize();
    expect(reloaded.savedPlayers, hasLength(1));
    expect(reloaded.savedPlayers.single.profile.toJson(), profile.toJson());
  });
}
