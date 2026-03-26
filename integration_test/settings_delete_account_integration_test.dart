import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nozofibi/screens/settings_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete Account flow confirms and invokes callback',
      (tester) async {
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
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

    await tester.tap(find.widgetWithText(ListTile, 'Delete Account'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining('remove your account and local app data'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
  });

  testWidgets('Delete Account flow does not invoke callback when canceled',
      (tester) async {
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
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

    await tester.tap(find.widgetWithText(ListTile, 'Delete Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
