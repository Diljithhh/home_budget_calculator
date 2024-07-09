
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_budget_calculator/firebase_options.dart';
import 'package:home_budget_calculator/view/Home/homePage.dart';
import 'package:home_budget_calculator/view/login/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(  MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}