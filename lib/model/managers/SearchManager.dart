import 'dart:convert';

import 'package:mylibrary/model/objects/GoogleBook.dart';
import 'package:http/http.dart' as http;

class SearchManager {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<GoogleBook>> searchBooks(String query) async{
    final url = Uri.parse('$_baseUrl?q=$query&maxResults=20&printType=books');
    final response = await http.get(url);

    if (response.statusCode != 200){
      throw Exception('Errore durante la ricerca');
    }

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>?;

    if (items == null) return [];

    return items.map((e) => GoogleBook.fromJson(e)).toList();
  }
}