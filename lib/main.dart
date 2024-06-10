import 'package:flutter/material.dart';
// import 'package:realm_local_db/ui/homepage.ui.dart';
import 'package:realm_local_db/ui/hompage_2.ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Realm Home Page'),
    );
  }
}
