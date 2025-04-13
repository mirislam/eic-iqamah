import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Iqamah_page.dart';
import 'dart:math';
import 'new_about_page.dart'; // Import the AboutPage
import 'compass_page.dart'; // Import the CompassPage
import 'chat_page.dart'; // Import the ChatPage
import 'yearly_calendar.dart'; // Import the PrayerCalendarPage
import 'login_page.dart'; // Import the LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp(
  //  name: "eiciqamah",
  //  options: DefaultFirebaseOptions.currentPlatform,
  //);
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    name: "eiciqamah",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
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
    return Scaffold(
      drawer: const AppDrawer(), // Add the drawer here
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
                MaterialPageRoute(builder: (context) => PrayerCalendarPage()),
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
                MaterialPageRoute(builder: (context) => CompassPage()),
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
                MaterialPageRoute(builder: (context) => ChatPage()),
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
                MaterialPageRoute(builder: (context) => NewAboutPage()),
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
