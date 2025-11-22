
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('NewAboutPage has a title and a back button', (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'iqamah',
      packageName: 'com.eic.iqamah',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'buildSignature',
    );
    await tester.pumpWidget(const MaterialApp(home: NewAboutPage()));
    final titleFinder = find.text('Evergreen Islamic Center');
    final backButtonFinder = find.byIcon(Icons.arrow_back);
    expect(titleFinder, findsOneWidget);
    expect(backButtonFinder, findsOneWidget);
  });
}
