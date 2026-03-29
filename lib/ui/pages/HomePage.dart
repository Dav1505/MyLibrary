import 'package:flutter/material.dart';
import 'package:mylibrary/model/objects/Book.dart';
import 'package:mylibrary/model/Model.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';
import '../../model/objects/BookFilters.dart';
import '../widgets/BookGridTile.dart'; // Assicurati che sia importato

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BookFilters _selectedFilter = BookFilters.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder(
      stream: Model.sharedInstance.getBooks(_selectedFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text(AppLocalizations.of(context)!.translate('no books')));
        }

        final books = snapshot.data!.docs.map((doc) => Book.fromMap(doc.data())).toList();
        final favouriteGenre = Model.sharedInstance.favouriteGenre(books);
        final sortedBooks = Model.sharedInstance.sortByFavouriteGenre(books, favouriteGenre);

        return CustomScrollView(
          slivers: [
            // Header con Filtro
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate("my_collection"),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BookFilters>(
                          value: _selectedFilter,
                          icon: const Icon(Icons.filter_list, size: 20),
                          onChanged: (BookFilters? newValue) {
                            setState(() => _selectedFilter = newValue!);
                          },
                          items: BookFilters.values.map((filter) {
                            return DropdownMenuItem<BookFilters>(
                              value: filter,
                              child: Text(
                                Model.sharedInstance.getFilterLabel(context, filter),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Griglia di Libri
            sortedBooks.isEmpty
                ? const SliverFillRemaining(
              child: Center(child: Text("Nessun libro trovato")),
            )
                : SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 libri per riga
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.55, // Rapporto altezza/larghezza per i libri
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return BookGridTile(book: sortedBooks[index]);
                  },
                  childCount: sortedBooks.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
