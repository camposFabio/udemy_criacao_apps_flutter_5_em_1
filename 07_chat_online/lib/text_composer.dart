import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;

  File imgFile;
  final _picker = ImagePicker();

  final TextEditingController controller = TextEditingController();

  void reset() {
    widget.sendMessage(text: controller.text);
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final PickedFile pickedFile =
                  await _picker.getImage(source: ImageSource.camera);
              if (pickedFile != null) {
                imgFile = File(pickedFile.path);
                widget.sendMessage(imgFile: imgFile);
              } else {
                print('No image selected.');
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration:
                  InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    reset();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
