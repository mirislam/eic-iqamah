
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqamah/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication, FirebaseAuth, UserCredential, User])
void main() {
  testWidgets('LoginPage has a title and a Google Sign-In button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    final titleFinder = find.text('Login to EIC');
    final buttonFinder = find.text('Sign in with Google');
    expect(titleFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);
  });
}
