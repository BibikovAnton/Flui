import 'package:Flui/services/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
      // theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
