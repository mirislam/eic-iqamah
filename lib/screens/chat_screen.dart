import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

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
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              Card(
                child: ListTile(
                    leading: robot,
                    title: const Text(
                        'Our ChatBot is Under Development. May return inaccurate results.')),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isUser = message.containsKey('user');
                    return Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) // Show robot icon for bot messages
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              child: Icon(Icons.smart_toy_outlined,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isUser
                                    ? const Radius.circular(12)
                                    : const Radius.circular(0),
                                bottomRight: isUser
                                    ? const Radius.circular(0)
                                    : const Radius.circular(12),
                              ),
                              border: Border.all(
                                color: isUser
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.2)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: isUser
                                ? Text(
                                    message['user']!,
                                    style: const TextStyle(fontSize: 16),
                                  )
                                : SingleChildScrollView(
                                    child: Html(
                                      data: message['bot'],
                                      style: {
                                        "body": Style(
                                          fontSize: FontSize(16.0),
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                      },
                                      onLinkTap: (url, _, __) async {
                                        if (url != null) {
                                          if (await canLaunchUrl(
                                              Uri.parse(url))) {
                                            await launchUrl(Uri.parse(url),
                                                mode: LaunchMode
                                                    .externalApplication);
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
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (chatProvider.isLoading) const CircularProgressIndicator(),
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
                          hintText:
                              'Ask anything about EIC...', // Placeholder text
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
                          chatProvider.sendMessage(message);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
