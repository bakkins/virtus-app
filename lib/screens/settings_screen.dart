import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'App',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.storage),
          title: Text('Storage'),
          subtitle: Text('Local SQLite database'),
        ),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('0.1.0'),
        ),
        SizedBox(height: 16),
        Text(
          'Coming soon',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.person_outline),
          title: Text('Account'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
        ListTile(
          leading: Icon(Icons.cloud_off),
          title: Text('Sync'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
        ListTile(
          leading: Icon(Icons.people_outline),
          title: Text('Friends'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
      ],
    );
  }
}
