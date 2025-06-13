import 'package:dio/dio.dart';
import '../models/book.dart';

class BooksService {
  static const String _baseUrl = 'https://reactnd-books-api.udacity.com';
  static const String _token = 'whatever-you-want';
  late final Dio _dio;

  BooksService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Authorization': _token,
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<List<Book>> getAllBooks() async {
    try {
      final response = await _dio.get('/books');

      if (response.statusCode == 200) {
        final data = response.data;
        final books = data['books'] as List<dynamic>? ?? [];
        
        return books.map((item) => Book.fromUdacityJson(item)).toList();
      } else {
        throw Exception('Error al obtener libros: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de conexión');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout de respuesta');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Demasiadas solicitudes. Intenta más tarde.');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<List<Book>> searchBooks({
    required String query,
  }) async {
    try {
      final response = await _dio.post(
        '/search',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final books = data['books'] as List<dynamic>? ?? [];
        
        return books.map((item) => Book.fromUdacityJson(item)).toList();
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout de conexión');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout de respuesta');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Demasiadas solicitudes. Intenta más tarde.');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId');

      if (response.statusCode == 200) {
        return Book.fromUdacityJson(response.data);
      } else {
        throw Exception('Error al obtener libro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<Book> updateBookShelf(String bookId, String shelf) async {
    try {
      final response = await _dio.put(
        '/books/$bookId',
        data: {
          'shelf': shelf,
        },
      );

      if (response.statusCode == 200) {
        return Book.fromUdacityJson(response.data);
      } else {
        throw Exception('Error al actualizar libro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  
  Future<List<Book>> getPopularBooks() async {
    final allBooks = await getAllBooks();
    return allBooks.take(20).toList();
  }

  Future<List<Book>> getBooksByCategory(String category) async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) => 
      book.categories.any((cat) => 
        cat.toLowerCase().contains(category.toLowerCase())
      )
    ).toList();
  }

  Future<List<Book>> getBooksByAuthor(String author) async {
    final allBooks = await getAllBooks();
    return allBooks.where((book) => 
      book.author.toLowerCase().contains(author.toLowerCase())
    ).toList();
  }
}