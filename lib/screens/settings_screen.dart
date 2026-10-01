import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dark = await SettingsService.isDarkMode();
    final notif = await SettingsService.notificationsEnabled();
    if (mounted) {
      setState(() {
        _darkMode = dark;
        _notifications = notif;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Notification permission denied')));
      }
    }
    await SettingsService.setNotificationsEnabled(value);
    setState(() => _notifications = value);
  }

  Future<void> _sendTest() async {
    await NotificationService.requestPermission();
    await NotificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_notifications
            ? 'Test notification sent'
            : 'Enable notifications first'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            subtitle: const Text('Use dark theme across the app'),
            value: _darkMode,
            onChanged: (v) async {
              await SettingsService.setDarkMode(v);
              setState(() => _darkMode = v);
            },
          ),
          const _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Enable notifications'),
            subtitle: const Text('Receive app updates and alerts'),
            value: _notifications,
            onChanged: _toggleNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Send test notification'),
            subtitle: const Text('Check that notifications work'),
            enabled: _notifications,
            onTap: _sendTest,
          ),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}