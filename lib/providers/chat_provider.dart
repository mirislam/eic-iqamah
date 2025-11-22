import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:markdown/markdown.dart' as md;

class ChatProvider with ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final String chatUrl = "https://chat.mirislam.com/api/generate";
  final String llmModel = "gemma3";

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String message) async {
    _messages.add({'user': message});
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(chatUrl);
      final requestBody = jsonEncode({
        "model": llmModel,
        "stream": false,
        "prompt": message,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final htmlResponse = md.markdownToHtml(responseData['response'] ?? '');
        
        _messages.add({
          'bot': htmlResponse.replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        });
      } else {
        _messages.add({'bot': 'Error: Unable to fetch response from server.'});
      }
    } catch (e) {
      _messages.add({'bot': 'Error: $e'});
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
