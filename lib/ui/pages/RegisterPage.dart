import 'package:flutter/material.dart';
import 'package:mylibrary/model/objects/UserGenres.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';

import '../../model/Model.dart';

class Registerpage extends StatefulWidget{

  final String title;
  const Registerpage({super.key,required this.title});

  @override
  State<Registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<Registerpage> {

  Usergenres _selectedgenre = Usergenres.male;
  DateTime? _dataNascita;
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _cognome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Inizia il tuo viaggio letterario",
                style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 32),

            _buildTextField(
                controller: _nome, label: "Nome", icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(controller: _cognome,
                label: "Cognome",
                icon: Icons.person_outline),
            const SizedBox(height: 16),

            // Data di Nascita con un look più rifinito
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(_dataNascita == null
                  ? "Data di Nascita"
                  : _dataNascita!.toLocal().toString().split(' ')[0]),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _dataNascita = date);
              },
            ),

            const SizedBox(height: 16),

            // Genere con ChoiceChip invece di Dropdown (molto più moderno)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate("select_genre"),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0, // Spazio orizzontale tra i chip
                    children: Usergenres.values.map((genre) {
                      final isSelected = _selectedgenre == genre;
                      return ChoiceChip(
                        label: Text(Model.sharedInstance.getGenreLabel(context, genre)),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedgenre = genre;
                            });
                          }
                        },
                        // Stile del chip
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        showCheckmark: false, // Rimuoviamo la spunta per un look più pulito
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildTextField(
                controller: _email, label: "Email", icon: Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(controller: _password,
                label: "Password",
                icon: Icons.lock_outline,
                obscureText: true),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                /* Logica di signup... */
              },
              child: const Text("CREA ACCOUNT",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: theme.colorScheme.primary,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),

        // Bordo quando il campo non è selezionato
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),

        // Bordo quando il campo è selezionato (Focus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),

        // Bordo in caso di errore (opzionale se userai i Form)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),

        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 18),
      ),
    );
  }
}