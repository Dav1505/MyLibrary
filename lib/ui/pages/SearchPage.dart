import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mylibrary/model/objects/BookStatus.dart';
import 'package:mylibrary/model/objects/GoogleBook.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';

import '../../model/Model.dart';
import '../../model/objects/Book.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<GoogleBook> _results = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Barra di ricerca "flottante"
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate("searchBook"),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _loading
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: _search,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // Risultati in Griglia
          _results.isEmpty && !_loading
              ? SliverFillRemaining(
            child: Center(
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.library_books, size: 64),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.translate("search_instruction") ),
                  ],
                ),
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 libri per riga nella ricerca per dare più spazio ai dettagli
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSearchResultCard(_results[index]),
                childCount: _results.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget per la singola card dei risultati di Google Books
  Widget _buildSearchResultCard(GoogleBook book) {
    return GestureDetector(
      onTap: () => _addToCatalog(book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.thumbnail != null
                    ? CachedNetworkImage(
                  imageUrl: book.thumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 40),
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
            book.authors.isNotEmpty ? book.authors.first : "Autore sconosciuto",
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Future<void> _search() async{
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try{
      _results = await Model.sharedInstance.searchBooks(query);
    }catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate("searchError")))
      );
    }

    setState(() {
      _loading = false;
    });
  }

  void _addToCatalog(GoogleBook book) async{
    await Model.sharedInstance.addBook(Book(
      id: book.id,
      title: book.title,
      authors: book.authors,
      coverUrl: book.thumbnail,
      description: book.description,
      status: BookStatus.notStarted,
      publicationDate: Model.sharedInstance.formatDate(book.publicationDate),
      genres: book.genres ?? [],
      details: ""
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${book.title} ${AppLocalizations.of(context)!.translate("addCatalog")}"))
    );
  }
}