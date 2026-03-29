import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mylibrary/model/objects/BookStatus.dart';
import '../../model/Model.dart';
import '../../model/objects/Book.dart';
import '../behaviors/AppLocalizations.dart';

class DetailsPage extends StatefulWidget {
  final Book book;
  const DetailsPage({super.key, required this.book});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}



class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _textEditingController;
  late BookStatus _selectedStatus;
  String? _location;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.book.details);
    _selectedStatus = widget.book.status;
    _initLocation(widget.book.lastNotePosition);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradiente di sfondo
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
                      ),
                    ),
                  ),
                  // Copertina
                  Center(
                    child: Hero(
                      tag: 'book-cover-${widget.book.id}',
                      child: _buildCoverImage(widget.book.coverUrl), // Metodo helper per l'immagine
                    ),
                  ),
                  // Protezione testo inferiore per il titolo lungo
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, theme.colorScheme.surface],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge posizionato sopra il titolo
                  _buildStatusBadge(context, _selectedStatus),
                  const SizedBox(height: 12),
                  // Titolo che accetta n righe
                  Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2, // Interlinea leggermente ridotta per titoli lunghi
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(widget.book.authors.join(', '),
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 24),
                  Text(widget.book.publicationDate?.toString().split(' ')[0] ??
                      "",
                      style: theme.textTheme.bodySmall),

                  const SizedBox(height: 16),

                  // Generi come Chips rifiniti
                  Wrap(
                    spacing: 8,
                    children: widget.book.genres.map((genre) =>
                        Chip(
                          label: Text(genre, style: const TextStyle(
                              fontSize: 12)),
                          backgroundColor: theme.colorScheme.secondaryContainer
                              .withOpacity(0.5),
                          side: BorderSide.none,
                          shape: StadiumBorder(),
                        )).toList(),
                  ),

                  const Divider(height: 40),

                  // Descrizione con stile migliorato
                  Text(AppLocalizations.of(context)!.translate(
                      "bookDescription"),
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.description ??
                        AppLocalizations.of(context)!.translate(
                            "no description"),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 32),

                  // Sezione Stato
                  Text(AppLocalizations.of(context)!.translate(
                      "status_selection"),
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: BookStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(Model.sharedInstance.getStatus(
                                context, status)),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              if (!selected) return;
                              setState(() {
                                _selectedStatus = status;
                                Model.sharedInstance.changeStatus(widget.book,
                                    Model.sharedInstance.getStatus(
                                        context, status));
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sezione Note Personali
                  _buildNotesSection(theme),

                  const SizedBox(height: 100), // Spazio extra per lo scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.translate("personal_notes"),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          if (_location != null && _location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  Expanded(child: Text(
                      " $_location", style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
          TextField(
            maxLines: null,
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: "Scrivi qualcosa...",
              border: InputBorder.none,
              fillColor: theme.colorScheme.surface,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: _saveNotesAction,
              label: Text(
                  AppLocalizations.of(context)!.translate("save_notes")),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotesAction() async {
    final text = _textEditingController.text;
    if (await Model.sharedInstance.handleLocationPermission(context)) {
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high));
      var output = await Model.sharedInstance.getLocation(
          position.latitude, position.longitude);
      setState(() {
        Model.sharedInstance.saveNotes(
            widget.book, text, GeoPoint(position.latitude, position.longitude));
        _location = output;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Note salvate!")));
    }
  }

  // Widget Badge Reintegrato
  Widget _buildStatusBadge(BuildContext context, dynamic status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color baseColor;

    switch (status.toString()) {
      case "reading": baseColor = Colors.orange; break;
      case "completed": baseColor = Colors.green; break;
      default: baseColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // In Dark Mode usiamo un'opacità più bassa per lo sfondo
        color: baseColor.withOpacity(isDark ? 0.15 : 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withOpacity(isDark ? 0.4 : 0.6)),
      ),
      child: Text(
        Model.sharedInstance.getStatus(context, status).toUpperCase(),
        style: TextStyle(
          color: isDark ? baseColor.withAlpha(200) : baseColor, // Colore leggermente più tenue in Dark
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _initLocation(GeoPoint? g) async {
    if (g == null) return;
    String? output = await Model.sharedInstance.getLocation(
        g.latitude, g.longitude);
    setState(() {
      _location = output;
    });
  }
  Widget _buildCoverImage(String? url) {
    return Container(
      height: 250, // Altezza generosa per risaltare nella SliverAppBar
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 12), // Ombra verso il basso per profondità
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: url == null || url.isEmpty
            ? Container(
          width: 170,
          color: Colors.grey[300],
          child: const Icon(Icons.book, size: 80, color: Colors.grey),
        )
            : Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 170,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 80),
          ),
        ),
      ),
    );
  }
}



