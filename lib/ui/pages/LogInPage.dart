import 'package:flutter/material.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';
import '../../model/Model.dart';
import './RegisterPage.dart';

class LoginPage extends StatefulWidget{

  const LoginPage({super.key,required this.title,required this.changeLanguage,required this.changeThemeMode});

  final String title;
  final void Function(Locale) changeLanguage;
  final void Function() changeThemeMode;

  @override
  State<LoginPage> createState() => _loginpageState();

}

class _loginpageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // AppBar invisibile per un look più pulito
        actions: [
          IconButton(onPressed: widget.changeThemeMode, icon: const Icon(Icons.wb_sunny_outlined)),
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icona o Logo dell'app
              Icon(Icons.auto_stories, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Email Field
              _buildTextField(
                controller: _email,
                label: AppLocalizations.of(context)!.translate('email'),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildTextField(
                controller: _password,
                label: AppLocalizations.of(context)!.translate('password'),
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    await Model.sharedInstance.signIn(_email.text, _password.text);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate('login').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Recuperiamo la traduzione con un valore di fallback se è null
                  final String title = AppLocalizations.of(context)!.translate('createAccount');

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => Registerpage(title: title),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.translate('register')),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper per i campi di testo per evitare ripetizioni
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}