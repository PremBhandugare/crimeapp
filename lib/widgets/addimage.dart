import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class addImage extends StatefulWidget{
  const addImage({super.key,required this.onPickimage});
  final void Function(File img) onPickimage;
  @override
  State<addImage> createState() => _addImageState();
}

class _addImageState extends State<addImage> {
  File? selectedImg ;

  void takepict() async{
    final img  =ImagePicker();
    final pickedImg = await img.pickImage(
                         source: ImageSource.camera,
                         maxWidth: 600);

    if (pickedImg == null) {
      return;
    }
    setState(() {
    selectedImg = File(pickedImg.path);
      
    });
    widget.onPickimage(selectedImg!);

  }

  @override
  Widget build(BuildContext context) {
    Widget ImgContent =ElevatedButton.icon(
        onPressed:takepict, 
        icon:const  Icon(Icons.camera), 
        label:const Text('Add image'), 
        );
    if (selectedImg!=null) {
      ImgContent = InkWell(
        onTap: takepict,
        child: Image.file(
                   selectedImg!,
                   fit: BoxFit.cover,
                   width: double.infinity,
                   height: double.infinity,
                   ),
        );
    print(selectedImg);
    }    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary
        )
      ),
      height: 245,
      width: double.infinity,
      alignment: Alignment.center,
      child: ImgContent
    );
  }
}