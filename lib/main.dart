import 'package:chatty/firebase_options.dart';
import 'package:chatty/pages/drawing_board_page.dart';
import 'package:chatty/services/auth/auth.dart';
import 'package:chatty/services/auth/login_or_register.dart';
import 'package:chatty/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
