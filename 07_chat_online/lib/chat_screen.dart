import 'dart:io';

import 'package:chat_online/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User _currentUser;

  bool uploading = false;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final User user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possivel fazer o login. Tente Novamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now()
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid)
          .child(
            DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .putFile(imgFile);

      setState(() {
        uploading = true;
      });
      StorageTaskSnapshot taskSnapshot = await task.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();

      data['imgUrl'] = url;
      setState(() {
        uploading = false;
      });
    }
    if (text != null) {
      data['text'] = text;
    }
    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_currentUser != null
            ? 'Olá ${_currentUser.displayName}'
            : 'Ola App'),
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().signOut();
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Você saiu com sucesso'),
                      ),
                    );
                  },
                )
              : Container(),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("messages")
                .orderBy('time')
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data.docs.reversed.toList();
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return ChatMessage(documents[index].data(),
                          documents[index].data()['uid'] == _currentUser?.uid);
                    },
                    itemCount: documents.length,
                    reverse: true,
                  );
              }
            },
          ),
        ),
        uploading ? LinearProgressIndicator() : Container(),
        TextComposer(_sendMessage)
      ]),
    );
  }
}
