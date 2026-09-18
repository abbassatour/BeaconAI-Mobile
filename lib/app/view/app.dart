// lib/app/view/app.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:beacon_ai/l10n/l10n.dart';
import 'package:beacon_ai/zero_ui/view/zero_ui_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.highContrastDark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ZeroUiPage(),
    );
  }
}