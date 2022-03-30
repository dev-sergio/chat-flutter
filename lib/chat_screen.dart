import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<dynamic, dynamic>> list = [];


  void _sendMessage({String? text, XFile? imgFile}) async {
    Map<String, dynamic> data = {};

    if (imgFile != null) {
      File file = File(imgFile.path);
      firebase_storage.UploadTask task = firebase_storage
          .FirebaseStorage.instance
          .ref(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);

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
    }
    if (text != null) data['text'] = text;
    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Olá"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ){
                    return const Center(
                      child: CircularProgressIndicator(),
                    ) ;
                  }

                  List<DocumentSnapshot> lista = snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: Text(lista[index]['text']),
                      );
                    },

                  );
                },

              ),
          ),
          TextComposser(sendMessage: _sendMessage),
        ],
      ),
    );
  }
}
