import 'package:flutter/material.dart';
import 'package:mylibrary/model/objects/Book.dart';
import '../../model/Model.dart';
import '../pages/DetailsPage.dart';

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: Hero(
            tag: 'book-cover-${book.id}', // Animazione fluida verso i dettagli
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 90,
                child: book.coverUrl == null
                    ? Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.book, color: Colors.grey),
                )
                    : Image.network(
                  book.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          title: Text(
            book.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.authors.join(', '), style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                _buildStatusBadge(context, book.status),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DetailsPage(book: book)),
            );
          },
        ),
      ),
    );
  }

  // Widget per creare un'etichetta colorata in base allo stato
  Widget _buildStatusBadge(BuildContext context, dynamic status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Model.sharedInstance.getStatus(context, status),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}