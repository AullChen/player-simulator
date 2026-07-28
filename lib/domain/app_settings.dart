enum AppLanguage { zhHans, en }

enum StoryApiProvider { openAi, anthropic, deepSeek }

extension StoryApiProviderDetails on StoryApiProvider {
  String get defaultEndpoint => switch (this) {
    StoryApiProvider.openAi => 'https://api.openai.com/v1/chat/completions',
    StoryApiProvider.anthropic => 'https://api.anthropic.com/v1/messages',
    StoryApiProvider.deepSeek => 'https://api.deepseek.com/chat/completions',
  };

  String get defaultModel => switch (this) {
    StoryApiProvider.openAi => '',
    StoryApiProvider.anthropic => 'claude-opus-4-8',
    StoryApiProvider.deepSeek => 'deepseek-v4-pro',
  };

  static StoryApiProvider inferFromEndpoint(String endpoint) {
    final host = Uri.tryParse(endpoint.trim())?.host.toLowerCase() ?? '';
    if (host.contains('anthropic.com')) return StoryApiProvider.anthropic;
    if (host.contains('deepseek.com')) return StoryApiProvider.deepSeek;
    return StoryApiProvider.openAi;
  }
}

class AppSettings {
  const AppSettings({
    this.language = AppLanguage.zhHans,
    this.apiProvider = StoryApiProvider.openAi,
    this.apiEndpoint = '',
    this.apiToken = '',
    this.apiModel = '',
    this.autoSavePlayers = false,
  });

  final AppLanguage language;
  final StoryApiProvider apiProvider;
  final String apiEndpoint;
  final String apiToken;
  final String apiModel;
  final bool autoSavePlayers;

  AppSettings copyWith({
    AppLanguage? language,
    StoryApiProvider? apiProvider,
    String? apiEndpoint,
    String? apiToken,
    String? apiModel,
    bool? autoSavePlayers,
  }) {
    return AppSettings(
      language: language ?? this.language,
      apiProvider: apiProvider ?? this.apiProvider,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      apiToken: apiToken ?? this.apiToken,
      apiModel: apiModel ?? this.apiModel,
      autoSavePlayers: autoSavePlayers ?? this.autoSavePlayers,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final languageName = '${json['language'] ?? ''}';
    final language = languageName == AppLanguage.en.name
        ? AppLanguage.en
        : AppLanguage.zhHans;
    final endpoint = '${json['api_endpoint'] ?? ''}';
    final providerName = '${json['api_provider'] ?? ''}';
    final provider = StoryApiProvider.values
        .where((value) => value.name == providerName)
        .firstOrNull;
    return AppSettings(
      language: language,
      apiProvider:
          provider ?? StoryApiProviderDetails.inferFromEndpoint(endpoint),
      apiEndpoint: endpoint,
      apiToken: '${json['api_token'] ?? ''}',
      apiModel: '${json['api_model'] ?? ''}',
      autoSavePlayers: json['auto_save_players'] == true,
    );
  }

  Map<String, Object> toJson() => {
    'language': language.name,
    'api_provider': apiProvider.name,
    'api_endpoint': apiEndpoint,
    'api_token': apiToken,
    'api_model': apiModel,
    'auto_save_players': autoSavePlayers,
  };
}
