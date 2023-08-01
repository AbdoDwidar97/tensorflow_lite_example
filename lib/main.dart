import 'package:flutter/material.dart';
import 'package:tflite_example/main_screen.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}

