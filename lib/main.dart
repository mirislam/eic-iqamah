import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'screens/iqamah_screen.dart';
import 'dart:math';
import 'screens/about_screen.dart'; // Import the AboutPage
import 'screens/compass_screen.dart'; // Import the CompassPage
import 'screens/chat_screen.dart'; // Import the ChatPage
import 'screens/calendar_screen.dart'; // Import the PrayerCalendarPage
import 'screens/login_screen.dart'; // Import the LoginPage

import 'package:provider/provider.dart';
import 'providers/iqamah_provider.dart';
import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: "eiciqamah",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IqamahProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 25, 114, 0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 25, 114, 0),
          primary: const Color.fromARGB(255, 25, 114, 0),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 25, 114, 0),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 25, 114, 0),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => const HomePage()},
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: AppDrawer(), // Add the drawer here
      body: IqamahPage(), // Your existing page
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 120, // Set the height of the DrawerHeader
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 25, 114, 0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft, // Align logo to the left
                    child: CircleAvatar(
                      radius:
                          25, // Adjusted radius to fit within the new height
                      backgroundColor: const Color.fromARGB(255, 4, 84, 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset("assets/images/eic_logo_200.png"),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 15), // Add spacing between logo and text
                  const Expanded(
                    child: Text(
                      'Evergreen Islamic Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrayerCalendarPage()),
              );
            },
          ),
          /** For future 
          ListTile(
            leading: Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ), **/
          ListTile(
            leading: const Icon(Icons.explore), // Compass icon
            title: const Text('Compass'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompassPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewAboutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login_rounded),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
