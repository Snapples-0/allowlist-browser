import 'package:flutter/material.dart';
import 'browser_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AllowlistBrowserApp());
}

class AllowlistBrowserApp extends StatelessWidget {
  const AllowlistBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allowlist Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BrowserScreen(),
    );
  }
}
