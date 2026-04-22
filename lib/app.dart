import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme.dart';

class EncuestasYetiApp extends StatelessWidget {
  const EncuestasYetiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casa del Yeti',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WelcomeScreen(),
    );
  }
}
