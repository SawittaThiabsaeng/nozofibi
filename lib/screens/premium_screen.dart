import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, Color(0xFF6D28D9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
          )
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: onBack, icon: const Icon(Icons.close, color: Colors.white, size: 28))),
              const Spacer(),
              const Icon(Icons.workspace_premium_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text('Nozofibi Elite', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text('Unleash your productivity potential with deep analytics and themes.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(32),
                child: GlassCard(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: Column(
                    children: [
                      const Text('\$4.99 / MONTH', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                          child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
}
