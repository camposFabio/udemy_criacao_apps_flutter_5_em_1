import 'package:flutter/material.dart';

import './ui/homepage.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Buscador de GIF',
      home: HomePage(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}
