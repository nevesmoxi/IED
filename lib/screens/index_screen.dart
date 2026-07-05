import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/access_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

/// Clickable table of contents: chapters (expandable) -> sections.
/// Chapters beyond `AccessProvider.freeChapterCount` are shown with a lock
/// badge to indicate they require an access code.
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final access = context.watch<AccessProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Índice')),
      body:
          bookProvider.status != BookLoadStatus.loaded ||
              bookProvider.book == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookProvider.book!.chapters.length,
              itemBuilder: (context, chapterIndex) {
                final chapter = bookProvider.book!.chapters[chapterIndex];
                final isLocked = !access.canReadChapter(chapterIndex);
                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    childrenPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            chapter.number,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isLocked)
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.5),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'GRÁTIS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    children: chapter.sections.asMap().entries.map((entry) {
                      final sectionIndex = entry.key;
                      final section = entry.value;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 68,
                          right: 20,
                        ),
                        title: Text(
                          section.heading,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: isLocked ? 0.5 : 0.85),
                          ),
                        ),
                        trailing: isLocked
                            ? Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.4),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(
                                initialChapterIndex: chapterIndex,
                                initialSectionIndex: sectionIndex,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
