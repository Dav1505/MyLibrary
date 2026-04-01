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
  final List<Map<String, String>> _messages = [];
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _messages.add({"role": "model", "content": ""}); // Placeholder per la risposta
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    int lastIndex = _messages.length - 1;
    String fullResponse = "";

    // Utilizziamo promptStream per l'effetto scrittura e per evitare blocchi UI
    gemini.promptStream(parts: [
      Part.text(AppLocalizations.of(context)!.translate("System_Instruction")),
      Part.text(userMessage),
    ]).listen((value) {
      // Riceviamo i chunk di testo
      final String chunk = value?.output ?? "";
      fullResponse += chunk;

      setState(() {
        _messages[lastIndex]["content"] = fullResponse;
      });
      _scrollToBottom();
    }, onDone: () {
      setState(() => _isTyping = false);
    }, onError: (e) {
      setState(() {
        _messages[lastIndex]["content"] = "Spiacente, si è verificato un errore di connessione.";
        _isTyping = false;
      });
    });
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
          _buildInputBar(theme),
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

  Widget _buildMessageBubble(Map<String, String> msg, bool isUser, ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
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
            p: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            strong: const TextStyle(fontWeight: FontWeight.bold),
            listBullet: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: "Scrivi un messaggio...",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: _isTyping ? null : _sendMessage,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}