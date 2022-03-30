import 'package:chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: 'Chat flutter',
    debugShowCheckedModeBanner: false,
    home: const ChatScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      iconTheme: const IconThemeData(
        color: Colors.blue
      )
    ),
  ));
}