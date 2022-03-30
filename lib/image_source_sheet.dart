import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final Function(XFile) onImageSelected;

  const ImageSourceSheet({Key? key, required this.onImageSelected}) : super(key: key);

  void imageSelected(XFile? image){
    if(image != null){
      onImageSelected(image);
    }
  }
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(child: const Text("Câmera"), onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? image = await _picker.pickImage(source: ImageSource.camera);
            imageSelected(image);
          }),
          TextButton(child: const Text("Galeria"), onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
            imageSelected(image);
          }),
        ],
      ),
    );
  }
}
