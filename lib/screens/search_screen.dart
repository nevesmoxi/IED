import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/access_provider.dart';
import '../models/book_models.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _results = [];

  void _onChanged(String query) {
    final bookProvider = context.read<BookProvider>();
    setState(() {
      _results = bookProvider.search(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Pesquisar palavras ou temas...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: _controller.text.trim().length < 2
                  ? _EmptyState()
                  : _results.isEmpty
                  ? const _NoResultsState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        final isLocked = !access.canReadChapter(r.chapterIndex);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          title: Text(
                            r.sectionHeading,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isLocked
                                  ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.5)
                                  : null,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              r.snippet,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                          leading: Icon(
                            isLocked
                                ? Icons.lock_outline
                                : Icons.description_outlined,
                            color: isLocked
                                ? Theme.of(context).textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.5)
                                : AppColors.gold,
                          ),
                          trailing: isLocked
                              ? const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppColors.gold,
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(
                                  initialChapterIndex: r.chapterIndex,
                                  initialSectionIndex: r.sectionIndex,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Pesquise por palavras-chave, conceitos ou temas dentro do livro.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum resultado encontrado.',
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }
}
