import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Widget sectionCard(IconData icon, String title, String content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Logo
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Page Title
                const Text(
                  'About Mudda',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Sections
                sectionCard(
                  Icons.flag,
                  'Our Mission',
                  'Mudda is a civic issue reporting and tracking platform designed to connect citizens and government authorities seamlessly. '
                      'Our mission is to empower citizens to report issues in their communities, track their progress, and ensure timely resolutions.',
                ),
                sectionCard(
                  Icons.group,
                  'Our Team',
                  'We are a dedicated team of developers, designers, and civic enthusiasts committed to making city governance more accessible and responsive. '
                      'With expertise in Flutter, Spring Boot, PostgreSQL, and Machine Learning, we aim to provide a seamless user experience for both citizens and authorities.',
                ),
                sectionCard(
                  Icons.contact_mail,
                  'Contact Us',
                  'For any queries or suggestions, reach out to us at: contact@muddaapp.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
