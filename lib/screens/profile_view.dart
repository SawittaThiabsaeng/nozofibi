import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ProfileView extends StatelessWidget {
  final VoidCallback onLogout; 
  final VoidCallback onGoPremium;
  final VoidCallback onGoSettings;

  const ProfileView({
    super.key, 
    required this.onLogout, 
    required this.onGoPremium,
    required this.onGoSettings,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
    children: [
      Center(child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          CircleAvatar(
            radius: 60, 
            backgroundColor: Colors.white, 
            child: Padding(
              padding: const EdgeInsets.all(4), 
              child: ClipOval(child: Image.network('https://api.dicebear.com/7.x/avataaars/svg?seed=Alex'))
            )
          ),
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle), 
            child: const Icon(Icons.bolt, color: Colors.white, size: 18)
          ),
        ]),
        const SizedBox(height: 16),
        Text('Alex Thompson', style: AppTheme.h1),
        const Text('LEVEL 24 • MASTER', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
      ])),
      const SizedBox(height: 40),
      GlassCard(
        onTap: onGoPremium,
        color: AppTheme.primary,
        child: const Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nozofibi Elite', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            Text('Unlock advanced stats & themes.', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
      const SizedBox(height: 24),
      GlassCard(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          _tile(Icons.settings_outlined, 'Account Settings', tap: onGoSettings),
          _tile(Icons.notifications_none, 'Notification Center'),
          _tile(Icons.shield_outlined, 'Privacy & Vault'),
          _tile(Icons.logout, 'End Session', isLast: true, color: Colors.redAccent, tap: onLogout),
        ]),
      )
    ],
  );

  Widget _tile(IconData i, String t, {bool isLast = false, Color? color, VoidCallback? tap}) => ListTile(
    onTap: tap, 
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: (color ?? AppTheme.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(i, color: color ?? AppTheme.primary, size: 20)
    ), 
    title: Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppTheme.textDark)), 
    trailing: const Icon(Icons.chevron_right, size: 18), 
    shape: isLast ? null : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05)))
  );
}
