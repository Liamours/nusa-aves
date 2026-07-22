import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const BirdFeApp());
}

class BirdFeApp extends StatelessWidget {
  const BirdFeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirdFe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainPage(),
    );
  }
}
