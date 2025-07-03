
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/yearly_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'yearly_calendar_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  testWidgets('PrayerCalendarPage has a title and a progress indicator when loading', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PrayerCalendarPage()));
    final titleFinder = find.text('Yearly Prayer Calendar');
    final progressFinder = find.byType(CircularProgressIndicator);
    expect(titleFinder, findsOneWidget);
    expect(progressFinder, findsOneWidget);
  });

  testWidgets('PrayerCalendarPage displays data after loading', (WidgetTester tester) async {
    final client = MockClient();
    when(client.get(any)).thenAnswer((_) async => http.Response('{"2025-01-01":{"fajr":"5:30","duhr":"1:00","asr":"4:00","maghrib":"7:00","isha":"8:30"}}', 200));

    await tester.pumpWidget(MaterialApp(home: PrayerCalendarPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Fajr: 5:30'), findsOneWidget);
    expect(find.textContaining('Dhur: 1:00'), findsOneWidget);
    expect(find.textContaining('Asr: 4:00'), findsOneWidget);
    expect(find.textContaining('Maghrib: 7:00'), findsOneWidget);
    expect(find.textContaining('Isha: 8:30'), findsOneWidget);
    debugDumpApp();
  });
}
