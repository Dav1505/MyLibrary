import 'package:flutter/material.dart';
import '../../model/Model.dart';
import '../../model/objects/MyUser.dart';
import '../behaviors/AppLocalizations.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<MyUser>(
      future: Model.sharedInstance.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.error_outline, size: 48, color: Colors.red));
        }

        final user = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- HEADER PROFILO ---
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${user.name} ${user.surname}",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // --- CARD INFORMAZIONI ---
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _buildUserTile(
                      context,
                      icon: Icons.email_outlined,
                      label: AppLocalizations.of(context)!.translate("email"),
                      value: user.email,
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildUserTile(
                      context,
                      icon: Icons.calendar_month_outlined,
                      label: AppLocalizations.of(context)!.translate("birth"),
                      value: user.birth.toLocal().toString().split(" ")[0],
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildUserTile(
                      context,
                      icon: Icons.face_outlined,
                      label: AppLocalizations.of(context)!.translate("genre"),
                      value: Model.sharedInstance.getGenreLabel(context, user.genre),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- AZIONI ACCOUNT ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(AppLocalizations.of(context)!.translate("deleteAccount")),
                  onPressed: () async {
                    _showDeleteConfirmDialog(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper per le righe di informazione
  Widget _buildUserTile(BuildContext context, {required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  // Dialog di conferma per eliminazione account (UX migliorata)
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("warning")),
        content: Text(AppLocalizations.of(context)!.translate("confirm_delete")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Model.sharedInstance.deleteAccount(context);
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
