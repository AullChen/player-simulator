enum AppLanguage { zhHans, en }

class AppSettings {
  const AppSettings({
    this.language = AppLanguage.zhHans,
    this.apiEndpoint = '',
    this.apiToken = '',
    this.apiModel = '',
    this.autoSavePlayers = false,
  });

  final AppLanguage language;
  final String apiEndpoint;
  final String apiToken;
  final String apiModel;
  final bool autoSavePlayers;

  AppSettings copyWith({
    AppLanguage? language,
    String? apiEndpoint,
    String? apiToken,
    String? apiModel,
    bool? autoSavePlayers,
  }) {
    return AppSettings(
      language: language ?? this.language,
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
    return AppSettings(
      language: language,
      apiEndpoint: '${json['api_endpoint'] ?? ''}',
      apiToken: '${json['api_token'] ?? ''}',
      apiModel: '${json['api_model'] ?? ''}',
      autoSavePlayers: json['auto_save_players'] == true,
    );
  }

  Map<String, Object> toJson() => {
    'language': language.name,
    'api_endpoint': apiEndpoint,
    'api_token': apiToken,
    'api_model': apiModel,
    'auto_save_players': autoSavePlayers,
  };
}
