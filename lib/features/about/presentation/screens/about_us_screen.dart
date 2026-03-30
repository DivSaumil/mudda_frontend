import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Widget sectionCard(BuildContext context, IconData icon, String title, String content) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: cs.primary.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Icon(icon, color: cs.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content, 
              style: TextStyle(
                fontSize: 15, 
                height: 1.6, 
                color: cs.onSurfaceVariant
              )
            ),
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
                  context,
                  Icons.flag_rounded,
                  'Our Mission',
                  'Mudda is a civic issue reporting and tracking platform designed to connect citizens and government authorities seamlessly. '
                      'Our mission is to empower citizens to report issues in their communities, track their progress, and ensure timely resolutions.',
                ),
                sectionCard(
                  context,
                  Icons.group_rounded,
                  'Our Team',
                  'We are a dedicated team of developers, designers, and civic enthusiasts committed to making city governance more accessible and responsive. '
                      'With expertise in Flutter, Spring Boot, PostgreSQL, and Machine Learning, we aim to provide a seamless user experience for both citizens and authorities.',
                ),
                sectionCard(
                  context,
                  Icons.contact_mail_rounded,
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
