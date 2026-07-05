import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/reading_progress_provider.dart';
import '../providers/access_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';
import 'about_author_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToIndex;

  const HomeScreen({super.key, required this.onGoToIndex});

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final progress = context.watch<ReadingProgressProvider>();
    final access = context.watch<AccessProvider>();

    if (bookProvider.status == BookLoadStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (bookProvider.status == BookLoadStatus.error ||
        bookProvider.book == null) {
      return Scaffold(
        body: Center(
          child: Text(bookProvider.errorMessage ?? 'Erro ao carregar o livro.'),
        ),
      );
    }

    final book = bookProvider.book!;
    final hasProgress = progress.lastPosition != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Book cover
              Container(
                width: 190,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/book_cover.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                book.title,
                style: AppTheme.readingTextStyle(
                  fontSize: 34,
                  color: Theme.of(context).colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.fullTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'por ${book.author}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 28),

              // Primary actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    !access.isUnlocked
                        ? Icons.lock_outline
                        : hasProgress
                        ? Icons.menu_book
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    !access.isUnlocked
                        ? 'Desbloquear Leitura'
                        : hasProgress
                        ? 'Continuar Leitura'
                        : 'Ler Agora',
                  ),
                  onPressed: () {
                    final chapterIdx = hasProgress
                        ? progress.lastPosition!.chapterIndex
                        : 0;
                    final sectionIdx = hasProgress
                        ? progress.lastPosition!.sectionIndex
                        : 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(
                          initialChapterIndex: chapterIdx,
                          initialSectionIndex: sectionIdx,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Ver Índice'),
                  onPressed: onGoToIndex,
                ),
              ),
              const SizedBox(height: 32),

              // Quick links
              Row(
                children: [
                  Expanded(
                    child: _QuickLinkCard(
                      icon: Icons.person_outline,
                      label: 'Sobre o Autor',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutAuthorScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickLinkCard(
                      icon: Icons.mail_outline,
                      label: 'Contacto',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: AppColors.gold, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
