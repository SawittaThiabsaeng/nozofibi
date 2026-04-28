import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'data/app_local_db.dart';
import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'providers/study_session_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Init services ───────────────────────────────────────────────
  await AppLocalDb.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  await TaskProvider.initNotifications();

  // ─── Run app ─────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => StudySessionProvider()),
      ],
      child: const MyAppBootstrap(),
    ),
  );
}