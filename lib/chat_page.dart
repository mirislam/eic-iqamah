import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:ollama_dart/ollama_dart.dart'; // Import the Ollama Dart package

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
      final client = OllamaClient(); // Create an Ollama client
      final stream = client.generateChatCompletionStream(
        request: GenerateChatCompletionRequest(
          model: 'phi4', // Specify the model
          messages: [
            Message(role: MessageRole.user, content: message),
          ],
        ),
      );

      String streamedResponse = '';
      await for (final res in stream) {
        streamedResponse += (res.message?.content ?? ''); //.trim();
        final htmlResponse = md.markdownToHtml(streamedResponse);
        //final htmlResponse = streamedResponse;
        print(
            'Streamed response: $htmlResponse'); // Debug print to check the streamed response
        setState(() {
          if (_messages.isNotEmpty && _messages.last.containsKey('bot')) {
            _messages.last['bot'] = htmlResponse; // Update the last bot message
          } else {
            _messages.add({'bot': htmlResponse}); // Add a new bot message
          }
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
        title: const Text(
          'EIC Chatbot',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
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
                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) // Show robot icon for bot messages
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.smart_toy_outlined,
                            color: Color.fromARGB(255, 2, 119, 15)),
                      ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
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
                                  onLinkTap: (url, _, __) async {
                                    if (url != null) {
                                      // Open the URL in the browser
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        print('Could not launch $url');
                                      }
                                    }
                                  },
                                ),
                              ),
                      ),
                    ),
                    if (isUser) // Show user icon for user messages
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.person_outlined, color: Colors.blue),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Ask anything about EIC...', // Placeholder text
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
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
