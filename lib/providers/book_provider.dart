import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/book_models.dart';

enum BookLoadStatus { loading, loaded, error }

class BookProvider extends ChangeNotifier {
  Book? _book;
  BookLoadStatus _status = BookLoadStatus.loading;
  String? _errorMessage;

  Book? get book => _book;
  BookLoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  BookProvider() {
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final raw = await rootBundle.loadString('assets/data/book.json');
      final Map<String, dynamic> jsonData =
          json.decode(raw) as Map<String, dynamic>;
      _book = Book.fromJson(jsonData);
      _status = BookLoadStatus.loaded;
    } catch (e) {
      _errorMessage = 'Não foi possível carregar o conteúdo do livro.';
      _status = BookLoadStatus.error;
    }
    notifyListeners();
  }

  /// Simple case-insensitive full text search across all chapters/sections.
  List<SearchResult> search(String query) {
    if (_book == null || query.trim().length < 2) return [];
    final q = query.trim().toLowerCase();
    final results = <SearchResult>[];

    for (int ci = 0; ci < _book!.chapters.length; ci++) {
      final chapter = _book!.chapters[ci];
      for (int si = 0; si < chapter.sections.length; si++) {
        final section = chapter.sections[si];
        final buffer = StringBuffer(section.heading);
        buffer.write(' ');
        for (final b in section.blocks) {
          if (b.text != null) buffer.write('${b.text} ');
          if (b.rows != null) {
            for (final row in b.rows!) {
              buffer.write('${row.join(' ')} ');
            }
          }
        }
        final fullText = buffer.toString();
        final lower = fullText.toLowerCase();
        final idx = lower.indexOf(q);
        if (idx != -1) {
          final start = (idx - 50).clamp(0, fullText.length);
          final end = (idx + q.length + 80).clamp(0, fullText.length);
          String snippet = fullText.substring(start, end).trim();
          if (start > 0) snippet = '…$snippet';
          if (end < fullText.length) snippet = '$snippet…';
          results.add(
            SearchResult(
              chapterIndex: ci,
              sectionIndex: si,
              chapterTitle: '${chapter.displayTitle} — ${chapter.title}',
              sectionHeading: section.heading,
              snippet: snippet,
            ),
          );
        }
        if (results.length >= 60) return results;
      }
    }
    return results;
  }
}
