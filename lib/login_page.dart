import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'iqamah_page.dart'; // Import the Iqamah page

class LoginPage extends StatelessWidget {
  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login to EIC',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 25, 114, 0),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/eic_logo_square4.png', // Replace with your logo asset
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 50),

            // Google Sign-In Button
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/images/google_logo1.png', // Add a Google logo asset
                height: 36,
              ),
              /** */
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              onPressed: () async {
                final user = await _signInWithGoogle();
                if (user != null) {
                  // Navigate to the Iqamah page after successful login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => IqamahPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Login failed. Please try again.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
