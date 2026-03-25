import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'browser_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AllowlistBrowserApp());
}

class AllowlistBrowserApp extends StatelessWidget {
  const AllowlistBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BrowserScreen(),
    );
  }
}
