import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/main.dart';
import 'package:nozofibi/providers/study_session_provider.dart';
import 'package:nozofibi/providers/task_provider.dart';
import 'package:provider/provider.dart';

class _FakeTaskProvider extends TaskProvider {
  @override
  Future<void> load() async {}
}

class _FakeStudySessionProvider extends StudySessionProvider {
  @override
  Future<void> loadSessions() async {}
}

Widget _buildTestApp({
  required Future<void> Function() onSignOut,
}) => MultiProvider(
    providers: [
      ChangeNotifierProvider<TaskProvider>(create: (_) => _FakeTaskProvider()),
      ChangeNotifierProvider<StudySessionProvider>(
        create: (_) => _FakeStudySessionProvider(),
      ),
    ],
    child: MaterialApp(
      home: MainNavigation(
        userName: 'Tester',
        onToggleDarkMode: (_) {},
        onLanguageChanged: (_) {},
        onSignOut: onSignOut,
      ),
    ),
  );

void main() {
  testWidgets('Cancel does not sign out', (tester) async {
    var signOutCalls = 0;

    await tester.pumpWidget(
      _buildTestApp(
        onSignOut: () async {
          signOutCalls++;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.widgetWithText(ListTile, 'Sign Out'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.widgetWithText(ListTile, 'Sign Out'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(signOutCalls, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Confirm sign out triggers sign out callback', (tester) async {
    var signOutCalls = 0;

    await tester.pumpWidget(
      _buildTestApp(
        onSignOut: () async {
          signOutCalls++;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.widgetWithText(ListTile, 'Sign Out'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.widgetWithText(ListTile, 'Sign Out'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Sign Out'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(signOutCalls, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
