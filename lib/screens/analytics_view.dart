import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 40),
      Text('Insights', style: AppTheme.h1),
      const SizedBox(height: 24),
      GlassCard(
        height: 220,
        child: Column(children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('WEEKLY FOCUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)), Text('29.5 Hours', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))]),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
            _bar(40), _bar(60), _bar(30), _bar(90, active: true), _bar(50), _bar(20), _bar(15)
          ]),
        ]),
      ),
      const SizedBox(height: 32),
      _pRow('Deep Focus', 0.8),
      _pRow('Learning', 0.4),
      _pRow('Administrative', 0.2),
    ],
  );
  
  static Widget _bar(double h, {bool active = false}) => Container(width: 25, height: h * 1.5, decoration: BoxDecoration(color: active ? AppTheme.primary : AppTheme.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(8)));
  
  static Widget _pRow(String l, double v) => Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: AppTheme.h2), Text('${(v*100).toInt()}%')]),
    const SizedBox(height: 8),
    LinearProgressIndicator(value: v, color: AppTheme.primary, backgroundColor: Colors.white, minHeight: 8, borderRadius: BorderRadius.circular(10)),
  ]));
}
