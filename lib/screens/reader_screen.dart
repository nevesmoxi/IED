import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/reading_settings_provider.dart';
import '../providers/reading_progress_provider.dart';
import '../providers/access_provider.dart';
import '../models/book_models.dart';
import '../theme/app_theme.dart';
import 'access_gate_screen.dart';

/// The core reading experience: renders one section's content blocks with
/// serif typography, supports font-size adjustment, light/dark/sepia modes,
/// bookmarking and previous/next section navigation.
class ReaderScreen extends StatefulWidget {
  final int initialChapterIndex;
  final int initialSectionIndex;

  const ReaderScreen({
    super.key,
    required this.initialChapterIndex,
    required this.initialSectionIndex,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late int _chapterIndex;
  late int _sectionIndex;
  final ScrollController _scrollController = ScrollController();
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _chapterIndex = widget.initialChapterIndex;
    _sectionIndex = widget.initialSectionIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _savePosition());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _savePosition() {
    context.read<ReadingProgressProvider>().saveLastPosition(
      _chapterIndex,
      _sectionIndex,
    );
  }

  void _goToSection(int chapterIndex, int sectionIndex) {
    setState(() {
      _chapterIndex = chapterIndex;
      _sectionIndex = sectionIndex;
    });
    _scrollController.jumpTo(0);
    _savePosition();
  }

  void _goNext(List<BookChapter> chapters) {
    final chapter = chapters[_chapterIndex];
    if (_sectionIndex < chapter.sections.length - 1) {
      _goToSection(_chapterIndex, _sectionIndex + 1);
    } else if (_chapterIndex < chapters.length - 1) {
      _goToSection(_chapterIndex + 1, 0);
    }
  }

  void _goPrevious(List<BookChapter> chapters) {
    if (_sectionIndex > 0) {
      _goToSection(_chapterIndex, _sectionIndex - 1);
    } else if (_chapterIndex > 0) {
      final prevChapter = chapters[_chapterIndex - 1];
      _goToSection(_chapterIndex - 1, prevChapter.sections.length - 1);
    }
  }

  Color _bgColor(ReadingThemeMode mode, BuildContext context) {
    switch (mode) {
      case ReadingThemeMode.light:
        return AppColors.lightBackground;
      case ReadingThemeMode.dark:
        return AppColors.darkBackground;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaBackground;
    }
  }

  Color _textColor(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.light:
        return AppColors.charcoal;
      case ReadingThemeMode.dark:
        return AppColors.cream;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final settings = context.watch<ReadingSettingsProvider>();
    final progress = context.watch<ReadingProgressProvider>();
    final access = context.watch<AccessProvider>();

    // Enforcement point: the first `AccessProvider.freeChapterCount`
    // chapters are readable by everyone (a genuine free sample, so the app
    // is a useful free download on Google Play). Chapters beyond that are
    // only rendered once the reader has redeemed a valid access code.
    if (access.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!access.canReadChapter(_chapterIndex)) {
      return const AccessGateScreen();
    }

    if (bookProvider.book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chapters = bookProvider.book!.chapters;
    final chapter = chapters[_chapterIndex];
    final section = chapter.sections[_sectionIndex];

    final bgColor = _bgColor(settings.readingTheme, context);
    final textColor = _textColor(settings.readingTheme);
    final isBookmarked = progress.isBookmarked(_chapterIndex, _sectionIndex);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            if (_controlsVisible)
              _buildTopBar(context, chapter, textColor, isBookmarked),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _controlsVisible = !_controlsVisible),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.displayTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.heading,
                        style: AppTheme.readingTextStyle(
                          fontSize: settings.fontSize + 6,
                          color: textColor,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...section.blocks.map(
                        (b) => _buildBlock(b, settings.fontSize, textColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_controlsVisible) _buildBottomBar(context, chapters, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    BookChapter chapter,
    Color textColor,
    bool isBookmarked,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              chapter.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.gold : textColor,
            ),
            onPressed: () {
              context.read<ReadingProgressProvider>().toggleBookmark(
                _chapterIndex,
                _sectionIndex,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    List<BookChapter> chapters,
    Color textColor,
  ) {
    final isFirst = _chapterIndex == 0 && _sectionIndex == 0;
    final lastChapter = chapters.last;
    final isLast =
        _chapterIndex == chapters.length - 1 &&
        _sectionIndex == lastChapter.sections.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: textColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: isFirst ? null : () => _goPrevious(chapters),
            icon: Icon(
              Icons.chevron_left,
              color: isFirst ? textColor.withValues(alpha: 0.3) : textColor,
            ),
            label: Text(
              'Anterior',
              style: TextStyle(
                color: isFirst ? textColor.withValues(alpha: 0.3) : textColor,
              ),
            ),
          ),
          Text(
            '${_sectionIndex + 1} / ${chapters[_chapterIndex].sections.length}',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          TextButton.icon(
            onPressed: isLast ? null : () => _goNext(chapters),
            icon: Text(
              'Próximo',
              style: TextStyle(
                color: isLast ? textColor.withValues(alpha: 0.3) : textColor,
              ),
            ),
            label: Icon(
              Icons.chevron_right,
              color: isLast ? textColor.withValues(alpha: 0.3) : textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(ContentBlock block, double fontSize, Color textColor) {
    switch (block.kind) {
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            block.text ?? '',
            style: AppTheme.readingTextStyle(
              fontSize: fontSize + 2,
              color: textColor,
              weight: FontWeight.w700,
            ),
          ),
        );
      case 'list_item':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 10),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  block.text ?? '',
                  textAlign: TextAlign.justify,
                  style: AppTheme.readingTextStyle(
                    fontSize: fontSize,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'box':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (block.rows ?? []).map((row) {
              final text = row.join(' — ');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  textAlign: TextAlign.justify,
                  style: AppTheme.readingTextStyle(
                    fontSize: fontSize - 1.5,
                    color: textColor,
                    weight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      case 'paragraph':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            block.text ?? '',
            textAlign: TextAlign.justify,
            style: AppTheme.readingTextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        );
    }
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Consumer<ReadingSettingsProvider>(
          builder: (context, settings, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferências de Leitura',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tamanho da Letra',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: settings.decreaseFontSize,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${settings.fontSize.toInt()}pt',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: settings.increaseFontSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Modo de Leitura',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _themeOption(
                        context,
                        settings,
                        ReadingThemeMode.light,
                        'Claro',
                        Colors.white,
                        Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      _themeOption(
                        context,
                        settings,
                        ReadingThemeMode.sepia,
                        'Sépia',
                        AppColors.sepiaBackground,
                        AppColors.sepiaText,
                      ),
                      const SizedBox(width: 12),
                      _themeOption(
                        context,
                        settings,
                        ReadingThemeMode.dark,
                        'Escuro',
                        AppColors.darkBackground,
                        AppColors.cream,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context,
    ReadingSettingsProvider settings,
    ReadingThemeMode mode,
    String label,
    Color bg,
    Color fg,
  ) {
    final selected = settings.readingTheme == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setReadingTheme(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : Colors.grey.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: fg, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
