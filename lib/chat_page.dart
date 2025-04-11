import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ollama_dart/ollama_dart.dart'; // Import the Ollama Dart package
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final String chatUrl = "https://chat.mirislam.com/api/generate";
  final String llmModel =
      "gemma3"; // This actually does not matter as RAG server will determine which model to use

  Future<void> _sendMessage(String message) async {
    print(
        'Sending message: $message'); // Debug print to check the message being sent
    setState(() {
      _messages.add({'user': message});
      _isLoading = true;
    });

    try {
      // Define the API endpoint
      final url = Uri.parse(chatUrl);

      // Create the request body
      final requestBody = jsonEncode({
        "model": llmModel, // Specify the model
        "stream": false, // Disable streaming
        "prompt": message, // User input
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final htmlResponse = md.markdownToHtml(responseData['response'] ?? '');
        print('Response: $htmlResponse'); // Debug print to check the response

        setState(() {
          _messages.add({
            'bot': htmlResponse
          }); // Add the bot's response to the chat history
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
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
    Icon robot =
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EIC Chatbot',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color.fromARGB(255, 25, 114, 0),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
                leading: robot,
                title: const Text(
                    'Our ChatBot is Under Development. May return inaccurate results.')),
          ),
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
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 25, 114, 0)),
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
