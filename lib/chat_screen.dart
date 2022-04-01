import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<dynamic, dynamic>> list = [];
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser?.displayName != null) return _currentUser;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String? text, XFile? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Não foi possivel fazer o login, tente novamente!"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user?.uid,
      "senderName": user?.displayName,
      "senderPhotoUrl": user?.photoURL,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      File file = File(imgFile.path);
      firebase_storage.UploadTask task = firebase_storage
          .FirebaseStorage.instance
          .ref(_currentUser!.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);
      setState(() {
        _isLoading = true;
      });
      try {
        firebase_storage.TaskSnapshot snapshot = await task;
        String url = await (snapshot).ref.getDownloadURL();
        data['imgUrl'] = url;
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          print(task.snapshot);
        }

        if (e.code == 'permission-denied') {
          if (kDebugMode) {
            print('User does not have permission to upload to this reference.');
          }
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
    if (text != null) data['text'] = text;
    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.displayName != null
            ? "Olá, ${_currentUser?.displayName}"
            : "Chat App"),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Você saiu com sucesso!"),
                      backgroundColor: Colors.red,
                    ));
                  },
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<DocumentSnapshot> lista = [];
                lista = snapshot.data!.docs.reversed.toList();
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return ChatMessage(
                        data: lista[index],
                        mine: lista[index]["uid"] == _currentUser?.uid);
                  },
                );
              },
            ),
          ),
          _isLoading ? const LinearProgressIndicator() : Container(),
          TextComposser(sendMessage: _sendMessage),
        ],
      ),
    );
  }
}
