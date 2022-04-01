import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, required this.data, required this.mine}) : super(key: key);
  final DocumentSnapshot<dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    if (data.data()["uid"] != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            !mine?
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data.data()["senderPhotoUrl"]),
              ),
            ) : Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: mine? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  data.data()["imgUrl"] != null
                      ? Image.network(data.data()["imgUrl"], width: 250,)
                      : Text(
                    data.data()["text"],
                          textAlign: mine? TextAlign.end : TextAlign.start,
                          style: const TextStyle(fontSize: 16),
                        ),
                  Text(
                    data.data()["senderName"],
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            mine?
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data.data()["senderPhotoUrl"]),
              ),
            ) : Container(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
