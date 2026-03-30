import 'package:flutter/material.dart';

/// Represents a single account activity entry.
class AccountActivity {
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;

  const AccountActivity({
    // Added const keyword here
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });
}

class AccountActivityPage extends StatelessWidget {
  const AccountActivityPage({super.key});

  final List<AccountActivity> dummyAccountActivities = const [
    // Using initializer list to ensure const constructor requirements are met
    AccountActivity(
      title: 'Account created',
      description:
          'Your account was successfully created. Welcome to the platform!',
      timestamp: '5d ago',
      icon: Icons.person_add,
    ),
    AccountActivity(
      title: 'Email updated',
      description:
          'Your primary email address has been successfully updated to example@example.com.',
      timestamp: '3d ago',
      icon: Icons.email,
    ),
    AccountActivity(
      title: 'Password changed',
      description:
          'Your password was successfully changed. If this was not you, please contact support.',
      timestamp: '2d ago',
      icon: Icons.lock,
    ),
    AccountActivity(
      title: 'Profile picture changed',
      description: 'Your profile picture has been updated.',
      timestamp: '1d ago',
      icon: Icons.account_circle,
    ),
    AccountActivity(
      title: 'Two-factor authentication enabled',
      description:
          'Two-factor authentication has been enabled for your account, adding an extra layer of security.',
      timestamp: '12h ago',
      icon: Icons.security,
    ),
    AccountActivity(
      title: 'Login from new device',
      description:
          'Someone logged into your account from a new device (Mobile Chrome on Android).',
      timestamp: '2h ago',
      icon: Icons.devices_other,
    ),
    AccountActivity(
      title: 'Payment method added',
      description:
          'A new payment method (Visa ending in **** 1234) has been added to your account.',
      timestamp: '1h ago',
      icon: Icons.payment,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Account Activity', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        backgroundColor: cs.surfaceContainerLow,
        forceMaterialTransparency: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyAccountActivities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (BuildContext context, int index) {
          final AccountActivity activity = dummyAccountActivities[index];
          return AccountActivityCard(activity: activity);
        },
      ),
    );
  }
}

class AccountActivityCard extends StatelessWidget {
  const AccountActivityCard({super.key, required this.activity});

  final AccountActivity activity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  activity.icon,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3, // Limit description to 3 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                activity.timestamp,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
