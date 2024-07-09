import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'package:workmanager/workmanager.dart';
import 'background_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
  );

  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: 150),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSM Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GSM Data Example'),
    );
  }
}
