import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_source_sheet.dart';

class TextComposser extends StatefulWidget {
  const TextComposser({Key? key, required this.sendMessage}) : super(key: key);
  final Function({String text, XFile imgFile}) sendMessage;

  @override
  State<TextComposser> createState() => _TextComposserState();
}

class _TextComposserState extends State<TextComposser> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => ImageSourceSheet(
                          onImageSelected: (image) {
                            setState(() {
                              widget.sendMessage(imgFile: image);
                              Navigator.pop(context);
                            });
                          },
                        ));
              },
              icon: const Icon(Icons.photo_camera)),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar uma mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    _reset();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
