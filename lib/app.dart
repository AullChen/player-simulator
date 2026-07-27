import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'domain/app_settings.dart';
import 'screens/home_screen.dart';
import 'services/app_controller.dart';
import 'services/app_storage.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scope.dart';

class PlayerSimulatorApp extends StatefulWidget {
  const PlayerSimulatorApp({super.key, this.storage});

  final AppStorage? storage;

  @override
  State<PlayerSimulatorApp> createState() => _PlayerSimulatorAppState();
}

class _PlayerSimulatorAppState extends State<PlayerSimulatorApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController(widget.storage ?? SharedPreferencesAppStorage())
      ..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final english = _controller.settings.language == AppLanguage.en;
        return AppScope(
          controller: _controller,
          child: MaterialApp(
            onGenerateTitle: (_) => english ? 'Player Simulator' : '球员模拟器',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(),
            locale: english ? const Locale('en') : const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
