import 'package:flutter/widgets.dart';

import '../domain/app_settings.dart';
import '../widgets/app_scope.dart';

extension AppLocalizations on BuildContext {
  bool get isEnglish {
    return AppScope.maybeOf(this)?.settings.language == AppLanguage.en;
  }

  String tr(String zhHans, String english) => isEnglish ? english : zhHans;
}
