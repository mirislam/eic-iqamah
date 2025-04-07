import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    print(
        'Sending message: $message'); // Debug print to check the message being sent
    setState(() {
      _messages.add({'user': message});
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.86.47:11434/api/generate'), // Replace with your Ollama server URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': message,
          'model': 'gemma3',
          'stream': false, // Set to false to get the full response at once
        }),
      );

      if (response.statusCode == 200) {
        print(
            'Response body: ${response.body}'); // Debug print for successful response
        final responseData = jsonDecode(response.body);

        // Convert the response from markup to HTML using the markdown package
        final htmlResponse = md.markdownToHtml(responseData['response']);

        setState(() {
          _messages.add({'bot': htmlResponse});
        });
      } else {
        print(
            'Error: ${response.statusCode} - ${response.body}'); // Debug print for error response
        setState(() {
          _messages
              .add({'bot': 'Error: Unable to fetch response from server.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'bot': 'Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EIC Chatbot'),
        backgroundColor: Color.fromARGB(255, 25, 114, 0),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.containsKey('user');
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isUser
                        ? Text(
                            message['user']!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : SingleChildScrollView(
                            child: Html(
                              data: message[
                                  'bot'], // Render the bot's response as HTML
                              style: {
                                "body": Style(
                                  fontSize: FontSize(16.0),
                                ),
                              },
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _controller.clear();
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
