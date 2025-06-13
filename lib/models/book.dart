class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final String? isbn;
  final int? publishedYear;
  final List<String> categories;
  final double? averageRating;
  final int? ratingsCount;
  final String? shelf;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.isbn,
    this.publishedYear,
    this.categories = const [],
    this.averageRating,
    this.ratingsCount,
    this.shelf,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['volumeInfo']?['title'] ?? 'Título desconocido',
      author: _getAuthors(json['volumeInfo']?['authors']),
      description: json['volumeInfo']?['description'],
      coverUrl: json['volumeInfo']?['imageLinks']?['thumbnail'],
      isbn: _getIsbn(json['volumeInfo']?['industryIdentifiers']),
      publishedYear: _getPublishedYear(json['volumeInfo']?['publishedDate']),
      categories: List<String>.from(json['volumeInfo']?['categories'] ?? []),
      averageRating: json['volumeInfo']?['averageRating']?.toDouble(),
      ratingsCount: json['volumeInfo']?['ratingsCount'],
    );
  }

  factory Book.fromUdacityJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Título desconocido',
      author: _getUdacityAuthors(json['authors']),
      description: json['description'],
      coverUrl: json['imageLinks']?['thumbnail'] ?? json['imageLinks']?['smallThumbnail'],
      isbn: json['industryIdentifiers']?.isNotEmpty == true 
          ? json['industryIdentifiers'][0]['identifier'] 
          : null,
      publishedYear: _getPublishedYear(json['publishedDate']),
      categories: List<String>.from(json['categories'] ?? []),
      averageRating: json['averageRating']?.toDouble(),
      ratingsCount: json['ratingsCount'],
      shelf: json['shelf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'isbn': isbn,
      'publishedYear': publishedYear,
      'categories': categories,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'shelf': shelf,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? isbn,
    int? publishedYear,
    List<String>? categories,
    double? averageRating,
    int? ratingsCount,
    String? shelf,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      isbn: isbn ?? this.isbn,
      publishedYear: publishedYear ?? this.publishedYear,
      categories: categories ?? this.categories,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      shelf: shelf ?? this.shelf,
    );
  }

  static String _getAuthors(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 'Autor desconocido';
    return authors.join(', ');
  }

  static String _getUdacityAuthors(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 'Autor desconocido';
    return authors.join(', ');
  }

  static String? _getIsbn(List<dynamic>? identifiers) {
    if (identifiers == null || identifiers.isEmpty) return null;
    for (var identifier in identifiers) {
      if (identifier['type'] == 'ISBN_13') {
        return identifier['identifier'];
      }
    }
    return identifiers.first['identifier'];
  }

  static int? _getPublishedYear(String? publishedDate) {
    if (publishedDate == null) return null;
    try {
      return DateTime.parse(publishedDate).year;
    } catch (e) {
      return null;
    }
  }

  String get shelfDisplayName {
    switch (shelf) {
      case 'currentlyReading':
        return 'Leyendo actualmente';
      case 'wantToRead':
        return 'Quiero leer';
      case 'read':
        return 'Leído';
      default:
        return 'Sin clasificar';
    }
  }
}