// Data models representing the structure of the "IED" book:
// Book -> Chapters -> Sections -> Content blocks (paragraph, list_item, subheading, box)

class ContentBlock {
  final String kind; // 'paragraph' | 'list_item' | 'subheading' | 'box'
  final String? text;
  final List<List<String>>? rows; // for 'box' kind (rendered as highlight card)

  ContentBlock({required this.kind, this.text, this.rows});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == 'box') {
      final rawRows = json['rows'] as List<dynamic>? ?? [];
      final rows = rawRows
          .map<List<String>>(
            (row) => (row as List<dynamic>).map((c) => c.toString()).toList(),
          )
          .toList();
      return ContentBlock(kind: 'box', rows: rows);
    }
    return ContentBlock(
      kind: json['kind'] as String,
      text: json['text'] as String?,
    );
  }
}

class BookSection {
  final String id;
  final String heading;
  final List<ContentBlock> blocks;

  BookSection({required this.id, required this.heading, required this.blocks});

  factory BookSection.fromJson(Map<String, dynamic> json) {
    final rawBlocks = json['blocks'] as List<dynamic>? ?? [];
    return BookSection(
      id: json['id'] as String,
      heading: json['heading'] as String,
      blocks: rawBlocks
          .map((b) => ContentBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Approximate word count used for search & reading-time estimation.
  int get wordCount {
    var count = heading.split(RegExp(r'\s+')).length;
    for (final b in blocks) {
      if (b.text != null) {
        count += b.text!.split(RegExp(r'\s+')).length;
      }
      if (b.rows != null) {
        for (final row in b.rows!) {
          for (final cell in row) {
            count += cell.split(RegExp(r'\s+')).length;
          }
        }
      }
    }
    return count;
  }
}

class BookChapter {
  final String id;
  final String number; // roman numeral: "I", "II", ...
  final int index; // 1-based
  final String title;
  final String? subtitle;
  final List<BookSection> sections;

  BookChapter({
    required this.id,
    required this.number,
    required this.index,
    required this.title,
    this.subtitle,
    required this.sections,
  });

  factory BookChapter.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    return BookChapter(
      id: json['id'] as String,
      number: json['number'] as String,
      index: json['index'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      sections: rawSections
          .map((s) => BookSection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  String get displayTitle => 'Capítulo $number';
}

class FrontMatterBlock {
  final String kind; // 'heading' | 'paragraph' | 'list_item' | 'box'
  final String? text;
  final List<List<String>>? rows;

  FrontMatterBlock({required this.kind, this.text, this.rows});

  factory FrontMatterBlock.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == 'box') {
      final rawRows = json['rows'] as List<dynamic>? ?? [];
      final rows = rawRows
          .map<List<String>>(
            (row) => (row as List<dynamic>).map((c) => c.toString()).toList(),
          )
          .toList();
      return FrontMatterBlock(kind: 'box', rows: rows);
    }
    return FrontMatterBlock(
      kind: json['kind'] as String,
      text: json['text'] as String?,
    );
  }
}

class Book {
  final String title;
  final String fullTitle;
  final String subtitle;
  final String author;
  final List<FrontMatterBlock> frontMatter;
  final List<BookChapter> chapters;

  Book({
    required this.title,
    required this.fullTitle,
    required this.subtitle,
    required this.author,
    required this.frontMatter,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final rawFront = json['front_matter'] as List<dynamic>? ?? [];
    final rawChapters = json['chapters'] as List<dynamic>? ?? [];
    return Book(
      title: json['title'] as String,
      fullTitle: json['full_title'] as String,
      subtitle: json['subtitle'] as String,
      author: json['author'] as String,
      frontMatter: rawFront
          .map((f) => FrontMatterBlock.fromJson(f as Map<String, dynamic>))
          .toList(),
      chapters: rawChapters
          .map((c) => BookChapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A flat reading-position pointer used for bookmarking / "continue reading".
class ReadingPosition {
  final int chapterIndex; // index into Book.chapters
  final int sectionIndex; // index into chapter.sections

  const ReadingPosition({
    required this.chapterIndex,
    required this.sectionIndex,
  });

  Map<String, dynamic> toJson() => {
    'chapterIndex': chapterIndex,
    'sectionIndex': sectionIndex,
  };

  factory ReadingPosition.fromJson(Map<String, dynamic> json) =>
      ReadingPosition(
        chapterIndex: json['chapterIndex'] as int,
        sectionIndex: json['sectionIndex'] as int,
      );
}

/// Search result entry pointing to a specific section, with a text snippet.
class SearchResult {
  final int chapterIndex;
  final int sectionIndex;
  final String chapterTitle;
  final String sectionHeading;
  final String snippet;

  SearchResult({
    required this.chapterIndex,
    required this.sectionIndex,
    required this.chapterTitle,
    required this.sectionHeading,
    required this.snippet,
  });
}
