// Da aggiungere in un nuovo file o in fondo a HomePage.dart
import 'package:flutter/material.dart';

import '../../model/objects/Book.dart';
import '../pages/DetailsPage.dart';

class BookGridTile extends StatelessWidget {
  final Book book;
  const BookGridTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500), // Più lento = più fluido
            reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) {
              // FadeTransition rende l'ingresso della nuova pagina meno brusco
              return FadeTransition(
                opacity: animation,
                child: DetailsPage(book: book),
              );
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'book-cover-${book.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.coverUrl == null
                      ? Container(color: Colors.grey[300], child: const Icon(Icons.book))
                      : Image.network(book.coverUrl!, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            book.authors.isNotEmpty ? book.authors.first : "",
            maxLines: 1,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }
}