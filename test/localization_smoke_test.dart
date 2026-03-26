import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/l10n/app_strings.dart';
import 'package:nozofibi/screens/schedule_view.dart';
import 'package:nozofibi/screens/settings_view.dart';
import 'package:nozofibi/providers/study_session_provider.dart';
import 'package:nozofibi/screens/analytics_view.dart';
import 'package:provider/provider.dart';

Widget _buildLocalizedApp({
  required Locale locale,
  required Widget child,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('th')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

class _StringsProbe extends StatelessWidget {
  const _StringsProbe();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Column(
        children: [
          Text(s.welcomeBack),
          Text(s.settings),
          Text(s.noSavedSessions),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('AppStrings resolves Thai content when locale is th',
      (tester) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        locale: const Locale('th'),
        child: const _StringsProbe(),
      ),
    );

    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
    expect(find.text('การตั้งค่า'), findsOneWidget);
    expect(find.text('ยังไม่มีเซสชันที่บันทึก'), findsOneWidget);
  });

  testWidgets('SettingsView renders Thai labels in th locale', (tester) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        locale: const Locale('th'),
        child: SettingsView(
          onBack: () {},
          onThemeChanged: (_) {},
          onLanguageChanged: (_) {},
          onDeleteMyData: () async {},
          onDeleteAccount: () async {},
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('ลบบัญชี'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('การตั้งค่า'), findsWidgets);
    expect(find.text('ลบบัญชี'), findsOneWidget);
    expect(find.text('ลบข้อมูลในเครื่อง'), findsWidgets);
  });

  testWidgets('ScheduleView renders Thai empty-state labels in th locale',
      (tester) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        locale: const Locale('th'),
        child: ScheduleView(
          tasks: const [],
          onAddTask: (_) {},
          onToggle: (_) {},
          onDelete: (_) {},
        ),
      ),
    );

    expect(find.text('ตารางงาน'), findsOneWidget);
    expect(find.text('วันนี้ยังไม่มีแผน'), findsOneWidget);
  });

  testWidgets('AnalyticsView renders Thai section labels in th locale',
      (tester) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        locale: const Locale('th'),
        child: ChangeNotifierProvider(
          create: (_) => StudySessionProvider(),
          child: const AnalyticsView(
            tasks: [],
            refreshToken: 0,
          ),
        ),
      ),
    );

    expect(find.text('ภาพรวม'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('เซสชันล่าสุด'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('เซสชันล่าสุด'), findsOneWidget);
    expect(find.text('ยังไม่มีเซสชันที่บันทึก'), findsOneWidget);
  });
}
