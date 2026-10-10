import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/reading_settings_provider.dart';
import 'providers/reading_progress_provider.dart';
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
      ],
      child: Consumer<ReadingSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Introdução ao Estudo do Direito Angolano — IED Reader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.appThemeMode,
            home: const RootShell(),
            // Responsive wrapper: on wide viewports (tablets, laptops,
            // desktops — relevant on Web/PWA) the reading experience is
            // kept at a comfortable, book-like column width instead of
            // stretching edge-to-edge. On phone-sized widths this is a
            // complete no-op and every screen renders exactly as before.
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              final width = MediaQuery.of(context).size.width;
              const breakpoint = 640.0;
              const maxContentWidth = 560.0;
              if (width <= breakpoint) return child;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return ColoredBox(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: child,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
