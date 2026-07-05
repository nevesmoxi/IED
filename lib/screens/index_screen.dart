import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

/// Clickable table of contents: chapters (expandable) -> sections.
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();

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
                                ?.withValues(alpha: 0.85),
                          ),
                        ),
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
