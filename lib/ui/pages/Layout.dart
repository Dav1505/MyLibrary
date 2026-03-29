import 'package:flutter/material.dart';
import 'package:mylibrary/ui/pages/HomePage.dart';
import 'package:mylibrary/ui/pages/SearchPage.dart';
import 'package:mylibrary/ui/pages/UserPage.dart';

import '../../model/Model.dart';
import '../behaviors/AppLocalizations.dart';

class Layout extends StatefulWidget {
  final String title;
  final void Function(Locale) changeLanguage;
  final void Function() changeThemeMode;

  const Layout({super.key,required this.title,required this.changeLanguage,required this.changeThemeMode});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: (){
                Model.sharedInstance.signOut();
              },
            ),
            IconButton(
              onPressed: (){
                widget.changeThemeMode();
              },
              icon: const Icon(Icons.wb_sunny_outlined),
            ),
            IconButton(
              onPressed: () {
                // 1. Recuperiamo il locale attuale in modo sicuro
                final currentLocale = Localizations.localeOf(context);

                // 2. Definiamo il nuovo locale
                Locale newLocale = currentLocale.languageCode == "it"
                    ? const Locale("en")
                    : const Locale("it");

                // 3. Chiamiamo la funzione passata dal padre
                widget.changeLanguage(newLocale);

                // Opzionale: un piccolo feedback per l'utente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newLocale.languageCode == "it" ? "Lingua: Italiano" : "Language: English"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.translate_rounded),
            ),
          ],
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary, // Linea sotto la tab selezionata
            labelColor: theme.colorScheme.primary,     // Testo tab selezionata
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6), // Testo non selezionato
            indicatorWeight: 3,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.translate("home"), icon: const Icon(Icons.home_rounded)),
              Tab(text: AppLocalizations.of(context)!.translate("search"), icon: const Icon(Icons.search_rounded)),
              Tab(text: AppLocalizations.of(context)!.translate("user"), icon: const Icon(Icons.person_rounded)),
            ],
          ),
        ),
        body: TabBarView(
            children: [
              HomePage(),
              SearchPage(),
              UserPage(),
            ]
        ),
      ),
    );
  }
}
