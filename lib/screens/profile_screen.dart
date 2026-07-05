import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_settings_provider.dart';
import '../providers/reading_progress_provider.dart';
import '../providers/book_provider.dart';
import '../theme/app_theme.dart';
import 'about_author_screen.dart';
import 'contact_screen.dart';
import 'reader_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ReadingSettingsProvider>();
    final progress = context.watch<ReadingProgressProvider>();
    final bookProvider = context.watch<BookProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User summary card (placeholder for auth integration)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.gold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leitor(a)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Acesso: Versão de leitura',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Preferências'),
            Card(
              child: SwitchListTile(
                title: const Text('Modo Escuro do Aplicativo'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: settings.appThemeMode == ThemeMode.dark,
                onChanged: (_) => settings.toggleAppTheme(),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Marcadores'),
            if (progress.bookmarks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Ainda não tem páginas marcadas. Toque no ícone de marcador durante a leitura para guardar aqui.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              )
            else
              Card(
                child: Column(
                  children: progress.bookmarks.map((bm) {
                    final book = bookProvider.book;
                    if (book == null) return const SizedBox.shrink();
                    final chapter = book.chapters[bm.chapterIndex];
                    final section = chapter.sections[bm.sectionIndex];
                    return ListTile(
                      leading: const Icon(
                        Icons.bookmark,
                        color: AppColors.gold,
                      ),
                      title: Text(
                        section.heading,
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      subtitle: Text(
                        chapter.displayTitle,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(
                              initialChapterIndex: bm.chapterIndex,
                              initialSectionIndex: bm.sectionIndex,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),

            _SectionLabel('Institucional'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Sobre o Autor'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutAuthorScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text('Contacto'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'IED Reader · v1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
