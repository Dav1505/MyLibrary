import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lista messaggi: ogni mappa ha "role" (user/model) e "content"
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "content": userText});
      _messages.add({"role": "model", "content": "Sto pensando...", "isFinished": false});
      _isTyping = true;
    });

    final lastIndex = _messages.length - 1;

    try {
      // PASSAGGIO A PROMPT (Risposta completa, non stream)
      final response = await gemini.prompt(parts: [
        Part.text(AppLocalizations.of(context)!.translate("System_Instruction")),
        Part.text(userText),
      ]);

      setState(() {
        // Puliamo il testo e lo assegniamo tutto in una volta
        _messages[lastIndex]["content"] = response?.output?.trim() ?? "Nessuna risposta ricevuta.";
        _messages[lastIndex]["isFinished"] = true;
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint("Errore Gemini: $e");
      setState(() {
        _isTyping = false;
        _messages[lastIndex]["content"] = "⚠️ Errore di connessione o server non disponibile (503).";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Per vedere lo sfondo del Layout principale
      body: Column(
        children: [
          // Area dei messaggi
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeState(theme)
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return _buildMessageBubble(msg, isUser, theme);
              },
            ),
          ),

          // Indicatore di caricamento
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          // Barra di Input
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            "Chiedimi consigli sui tuoi libri!",
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser, ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: isUser
            ? Text(
          msg["content"]!,
          style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 15, letterSpacing: 0.5, height: 1.5),
        )
            : MarkdownBody(
          data: msg["content"]!,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 15),
            strong: const TextStyle(fontWeight: FontWeight.bold),
            listBullet: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: "Scrivi un messaggio...",
                filled: true,
                fillColor: Theme.of(context).colorScheme.inversePrimary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            child: IconButton(
              onPressed: _isTyping ? null : _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}