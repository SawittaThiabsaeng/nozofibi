import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsView extends StatefulWidget {
  final VoidCallback onBack;
  const SettingsView({super.key, required this.onBack});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: Text('Settings', style: AppTheme.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: widget.onBack),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section('PREFERENCES'),
          _switchTile('Push Notifications', _notifications, (v) => setState(() => _notifications = v)),
          _switchTile('Dark Mode (Beta)', _darkMode, (v) => setState(() => _darkMode = v)),
          const SizedBox(height: 32),
          _section('LEGAL'),
          _tile('Terms of Service'),
          _tile('Privacy Policy'),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Text(t, style: AppTheme.caption));
  
  Widget _switchTile(String t, bool v, Function(bool) c) => ListTile(
    title: Text(t, style: AppTheme.bodyBold),
    trailing: Switch(value: v, onChanged: c, activeColor: AppTheme.primary),
  );

  Widget _tile(String t) => ListTile(
    title: Text(t, style: AppTheme.bodyBold),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {},
  );
}
