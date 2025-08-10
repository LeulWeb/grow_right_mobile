import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Header
          CircleAvatar(
            radius: 40,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: primaryColor),
          ),
          const SizedBox(height: 10),
          Text(
            'Farmer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text('farmer@example.com', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          const Divider(),

          // Action List
          _actionTile(context, Icons.language, 'Localization'),
          _actionTile(context, Icons.subscriptions, 'Subscribe'),
          _actionTile(context, Icons.logout, 'Logout'),
          const Divider(),
          _actionTile(context, Icons.contact_mail, 'Contact Us'),
          _actionTile(context, Icons.info_outline, 'About'),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title) {
    final primaryColor = Theme.of(context).primaryColor;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
