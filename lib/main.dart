import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Iqamah_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

Future<void> setupToken() async {
  // Get the token each time the application loads
  String? token = await FirebaseMessaging.instance.getToken().then((token) {
    print('Got the token 1 ');
    print(token);
  });

  print('Got token ');
  print(token);
  // Save the initial token to the database
  print('Calling saveToken');
  //await saveTokenToDatabase(token!);

  // Any time the token refreshes, store this in the database too.
  //FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
}

/** 
Future<void> saveTokenToDatabase(String token) async {
  String userId = getRandomString(10);
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}
**/

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
      initialRoute: '/',
      routes: {'/': (context) => IqamahPage()},
    );
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
