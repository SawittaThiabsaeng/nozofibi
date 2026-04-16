import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/screens/settings_view.dart';

Widget _buildSettingsView({
  required VoidCallback onBack,
  required ValueChanged<bool> onThemeChanged,
  required ValueChanged<String> onLanguageChanged,
  required Future<void> Function() onDeleteMyData,
  required Future<void> Function() onDeleteAccount,
}) => MaterialApp(
    home: SettingsView(
      onBack: onBack,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onDeleteMyData: onDeleteMyData,
      onDeleteAccount: onDeleteAccount,
    ),
  );

void main() {
  testWidgets('Delete My Local Data calls callback when confirmed',
      (tester) async {
    var localDeleteCalled = false;

    await tester.pumpWidget(
      _buildSettingsView(
        onBack: () {},
        onThemeChanged: (_) {},
        onLanguageChanged: (_) {},
        onDeleteMyData: () async {
          localDeleteCalled = true;
        },
        onDeleteAccount: () async {},
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Delete My Local Data'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Delete Local Data'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(localDeleteCalled, isTrue);
  });

  testWidgets('Delete My Local Data does not call callback when canceled',
      (tester) async {
    var localDeleteCalled = false;

    await tester.pumpWidget(
      _buildSettingsView(
        onBack: () {},
        onThemeChanged: (_) {},
        onLanguageChanged: (_) {},
        onDeleteMyData: () async {
          localDeleteCalled = true;
        },
        onDeleteAccount: () async {},
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Delete My Local Data'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(localDeleteCalled, isFalse);
  });

  testWidgets('Dark Mode switch calls onThemeChanged callback', (tester) async {
    var latestThemeValue = false;

    await tester.pumpWidget(
      _buildSettingsView(
        onBack: () {},
        onThemeChanged: (value) {
          latestThemeValue = value;
        },
        onLanguageChanged: (_) {},
        onDeleteMyData: () async {},
        onDeleteAccount: () async {},
      ),
    );

    await tester.tap(find.byType(Switch).at(1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(latestThemeValue, isTrue);
  });

  testWidgets('Legal dialogs open and close correctly', (tester) async {
    await tester.pumpWidget(
      _buildSettingsView(
        onBack: () {},
        onThemeChanged: (_) {},
        onLanguageChanged: (_) {},
        onDeleteMyData: () async {},
        onDeleteAccount: () async {},
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(ListTile, 'Terms of Service'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Terms of Service'), findsNWidgets(2));
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);

    // Scroll down to find Privacy Policy ListTile
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(ListTile, 'Privacy Policy'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Privacy Policy'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);
  });
}
