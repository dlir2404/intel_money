import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intel_money/features/transaction/widgets/transaction_image.dart';

import '../../../core/models/scan_receipt_response.dart';
import '../screens/take_picture_screen.dart';

class InputImage extends StatefulWidget {
  final dynamic image;
  final Function(File image) onImageSelected;
  final Function() onImageRemoved;

  const InputImage({
    super.key,
    required this.image,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  State<StatefulWidget> createState() {
    return _InputImageState();
  }
}

class _InputImageState extends State<InputImage> {
  dynamic _image;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }

  @override
  void didUpdateWidget(covariant InputImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      setState(() {
        _image = widget.image;
      });
    }
  }

  Future<void> _takePicture() async {
    final TakePictureResponse result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TakePictureScreen()),
    );

    setState(() {
      _image = result.receiptImage;
    });

    widget.onImageSelected(_image!);
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);

      setState(() {
        _image = file;
      });

      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _image != null
        ? TransactionImage(
          image: _image!,
          onImageRemoved: () {
            setState(() {
              _image = null;
            });
            widget.onImageRemoved();
          },
        )
        : Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () => _pickImageFromGallery(),
                  icon: Icon(Icons.photo_library, color: Colors.grey[400]),
                ),
              ),
              Container(width: 1, color: Colors.grey, height: 48),
              Expanded(
                child: IconButton(
                  onPressed: () => _takePicture(),
                  icon: Icon(Icons.camera_alt, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        );
  }
}
