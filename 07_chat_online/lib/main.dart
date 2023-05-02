import 'package:chat_online/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseFirestore.instance.collection("mensagem").snapshots().listen((event) {
    event.docs.forEach((element) {
      print(element.data());
    });
  });
/*
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("mensagem").get();
  snapshot.docs.forEach((element) {
    print(element.data());
  });
      .doc("msg2")
      .set({"texto": "tudo bem", "from": "fred", "read": false});
*/

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.blue,
          iconTheme: IconThemeData(color: Colors.blue)),
      home: ChatScreen(),
    );
  }
}
