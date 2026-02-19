import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle))),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 80, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  const Text('Nozofibi', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 2)),
                  const Text('Elevate your focus & life', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 48),
                  GlassCard(
                    child: Column(
                      children: [
                        _loginField('Email', Icons.email_outlined),
                        const SizedBox(height: 16),
                        _loginField('Password', Icons.lock_outline, obscure: true),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                            child: ElevatedButton(
                              onPressed: onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 0,
                              ),
                              child: const Text('Start Focusing', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginField(String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: Icon(icon, color: AppTheme.primary),
        filled: true, fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }
}
