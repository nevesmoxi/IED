import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/reading_settings_provider.dart';
import 'providers/reading_progress_provider.dart';
import 'providers/access_provider.dart';
import 'theme/app_theme.dart';
import 'screens/root_shell.dart';

void main() {
  runApp(const IedReaderApp());
}

class IedReaderApp extends StatelessWidget {
  const IedReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ReadingSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProgressProvider()),
        ChangeNotifierProvider(create: (_) => AccessProvider()),
      ],
      child: Consumer<ReadingSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'IED Reader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.appThemeMode,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
