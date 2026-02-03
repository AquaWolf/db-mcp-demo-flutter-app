import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:db_mcp_demo_flutter_app/widgets/ai_rich_data_card.dart';
import 'package:db_mcp_demo_flutter_app/widgets/ai_text_message.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? richData;
  final String? type;

  ChatMessage({required this.text, required this.isUser, this.richData, this.type});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Sprachsteuerung
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _messages.add(ChatMessage(
      text: 'Hallo! Ich bin dein DB Begleiter. Wie kann ich dir helfen?',
      isUser: false,
      type: 'GENERAL',
    ));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
            // Falls der Nutzer aufhört zu sprechen, sende automatisch
            if (val.finalResult) {
              setState(() => _isListening = false);
              _sendMessage(val.recognizedWords);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  List<Map<String, dynamic>> _getHistory() {
    return _messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'content': [{'text': msg.text}],
      };
    }).toList();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final historyBeforeRequest = _getHistory();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('smartAssistantFlow')
          .call({
            'prompt': text,
            'history': historyBeforeRequest,
          });

      final data = Map<String, dynamic>.from(result.data);
      
      setState(() {
        _messages.add(ChatMessage(
          text: data['text'] ?? '',
          isUser: false,
          type: data['responseType'],
          richData: data['richCard'],
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Fehler: $e',
          isUser: false,
          type: 'GENERAL',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    final Color surfaceColor = isDark ? const Color(0xFF192233) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('DB Expert AI', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isUser) {
                  return _buildUserMessage(msg.text);
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AiTextMessage(text: msg.text),
                      if (msg.type == 'TRAIN_STATUS' && msg.richData != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 16),
                          child: AiRichDataCard(data: msg.richData!),
                        ),
                    ],
                  );
                }
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputField(isDark, surfaceColor),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF135BEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInputField(bool isDark, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.grey),
            onPressed: _listen,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(hintText: 'Wohin willst du?', border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF135BEC)),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
