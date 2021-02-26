import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'menu_screen/MenuScreenState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: MyHomePage(title: 'Vidzeme University'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MenuScreenState createState() => MenuScreenState();
}