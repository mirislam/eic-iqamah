import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart' as UrlLauncher;
import 'package:package_info_plus/package_info_plus.dart';

class NewAboutPage extends StatefulWidget {
  const NewAboutPage({Key? key}) : super(key: key);

  @override
  _NewAboutPageState createState() => _NewAboutPageState();
}

class _NewAboutPageState extends State<NewAboutPage> {
  Icon instaIcon = const Icon(FontAwesomeIcons.instagram);
  Icon youtubeIcon = const Icon(FontAwesomeIcons.youtube);
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  String aboutUsText = '''
Evergreen Islamic Center (EIC) is a non-profit organization dedicated to serving the Muslim community in San Jose, California. Our mission is to provide a welcoming and inclusive environment for all individuals, regardless of their background or beliefs. We strive to promote understanding and respect among diverse communities through education, outreach, and interfaith dialogue.The journey of Evergreen Islamic Center traces back to the acquisition of land nestled within the beautiful hills of Evergreen in 1989 by the community members who recognized the growing need for a mosque in the Evergreen area. Subsequent efforts were made to start offering prayers at the facility, and construction of a full-blown mosque was kicked off in 2010. Through fundraising efforts, community support, and tireless dedication, the EIC community worked towards the realization of their dream.
    ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Overlay
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/eg_mosque_evening1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: Text(
                    '$version-$buildNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Evergreen Islamic Center',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Features Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureIcon(Icons.facebook, 'Facebook', () async {
                    const url = 'https://www.facebook.com/evergreenmasjid';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      print('Clicked Facebook');
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  }),
                  _buildFeatureIcon(youtubeIcon.icon!, 'YouTube', () async {
                    const url = 'https://www.youtube.com/@evergreenmasjid8757';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  }),
                  _buildFeatureIcon(instaIcon.icon!, 'Instagram', () async {
                    const url =
                        'https://www.instagram.com/evergreenislamiccenter/';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  }),
                  _buildFeatureIcon(Icons.email, 'Email', () async {
                    const email = 'mailto:info@eicsanjose.org';
                    UrlLauncher.launchUrlString(email);
                  }),
                  _buildFeatureIcon(Icons.phone, 'Phone', () async {
                    const phone = 'tel://+14082396668';
                    UrlLauncher.launchUrlString(phone);
                  }),
                  _buildFeatureIcon(Icons.location_on, 'Location', () async {
                    const location =
                        'https://maps.app.goo.gl/LKhqszQY8jN6sJ8JA';
                    if (await canLaunchUrl(Uri.parse(location))) {
                      await launchUrl(Uri.parse(location),
                          mode: LaunchMode.externalApplication);
                    }
                  }),
                ],
              ),
            ),

            // About Us Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCard('About Us', aboutUsText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build feature icons
  Widget _buildFeatureIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to build cards
  Widget _buildCard(String title, String body) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              body,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
