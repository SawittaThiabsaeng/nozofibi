import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/screens/settings_view.dart';

void main() {
  testWidgets('delete account asks confirmation and calls action when confirmed',
      (tester) async {
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('th')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsView(
          onBack: () {},
          onThemeChanged: (_) {},
          onLanguageChanged: (_) {},
          onDeleteMyData: () async {},
          onDeleteAccount: () async {
            deleteCalled = true;
          },
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ListTile, 'Delete Account'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Delete Account'), findsNWidgets(2));
    expect(
      find.textContaining('remove your account and local app data'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(deleteCalled, isTrue);
  });

  testWidgets('delete account does not call action when canceled',
      (tester) async {
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('th')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsView(
          onBack: () {},
          onThemeChanged: (_) {},
          onLanguageChanged: (_) {},
          onDeleteMyData: () async {},
          onDeleteAccount: () async {
            deleteCalled = true;
          },
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ListTile, 'Delete Account'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(deleteCalled, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
