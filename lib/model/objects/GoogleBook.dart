
class GoogleBook {
  final String id;
  final String title;
  final List<String> authors;
  final String? thumbnail;
  final String? description;
  final String? publicationDate;
  final List<String>? genres;

  GoogleBook({required this.id, required this.title, required this.authors, required this.thumbnail,
  required this.description, required this.publicationDate, required this.genres});

  static GoogleBook fromJson(Map<String, dynamic> json){
    final volumeInfo = json['volumeInfo'] ?? {};

    return GoogleBook(
      id: json['id'],
      title: volumeInfo['title'] ?? "Titolo sconosciuto",
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      thumbnail: _normalizeImage(volumeInfo),
      description: volumeInfo['description'],
      publicationDate: volumeInfo['publishedDate'],
      genres: List<String>.from(volumeInfo['categories'] ?? [])
    );
  }
}

  String? _normalizeImage(Map<String,dynamic> volumeInfo) { //avevo problemi con i link delle immagini restituiti da Google Books
  final imageLinks = volumeInfo['imageLinks'];
  if (imageLinks == null) return null;

  String? raw = imageLinks['smallThumbnail'];
  if (raw == null) return null;

  final uri = Uri.parse(raw);

  return Uri(
    scheme: 'https',
    host: 'books.googleusercontent.com',
    path:uri.path,
    queryParameters: {
      ...uri.queryParameters,
      'printsec': 'frontcover',
      'img': '1',
      'zoom': '1',
      'source': 'gbs_api'
    },
  ).toString();
}