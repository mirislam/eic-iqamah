
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/about_page.dart';

void main() {
  testWidgets('AboutPage has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AboutPage()));
    final titleFinder = find.text('About');
    final messageFinder = find.text('All rights reserved. Copyright held by EIC (Evergreen Islamic Center) 2022-2025.');
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
