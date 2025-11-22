
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'chat_page_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  testWidgets('ChatPage has a title and a message field', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatPage()));
    final titleFinder = find.text('EIC Chatbot');
    final textFieldFinder = find.byType(TextField);
    expect(titleFinder, findsOneWidget);
    expect(textFieldFinder, findsOneWidget);
  });

  testWidgets('ChatPage sends a message and displays the response', (WidgetTester tester) async {
    final client = MockClient();

    when(client.post(
      Uri.parse('https://chat.mirislam.com/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gemma3',
        'stream': false,
        'prompt': 'Hello',
      }),
    )).thenAnswer((_) async => http.Response(jsonEncode({'response': 'Hi there!'}), 200));

    await tester.pumpWidget(const MaterialApp(home: ChatPage()));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    final messageFinder = find.text('Hello');
    expect(messageFinder, findsOneWidget);

  });
}
