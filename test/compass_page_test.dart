
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/screens/compass_screen.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FlutterCompass])
void main() {
  testWidgets('CompassPage has a title and a compass', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CompassPage()));
    final titleFinder = find.text('Compass');
    final compassFinder = find.byType(Stack);
    expect(titleFinder, findsOneWidget);
    expect(compassFinder, findsOneWidget);
  });
}
