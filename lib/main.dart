import 'package:flutter/material.dart';
import 'package:todo_notes_app/notes&todo.dart';
import 'package:todo_notes_app/sql_helper.dart';

void main() async {
 // ErrorWidget.builder = (FlutterErrorDetails errorDetails) => Material
  WidgetsFlutterBinding.ensureInitialized();
  SqlHelper().getDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesTodo(),
    );
  }
}


