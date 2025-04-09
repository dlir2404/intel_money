import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intel_money/core/models/scan_receipt_response.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/models/category.dart';
import '../controller/transaction_controller.dart';

class TakePictureScreen extends StatefulWidget {
  final Function(CroppedFile image)? processImage;

  const TakePictureScreen({super.key, this.processImage});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
      return;
    }

    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile photo = await _cameraController!.takePicture();
      await _processImage(File(photo.path));
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isProcessing = true;
      });
      await _processImage(File(image.path));
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile == null) return;

      TakePictureResponse response;
      if (widget.processImage != null) {
        response = await widget.processImage!(croppedFile);
      } else {
        response = TakePictureResponse(receiptImage: File(croppedFile.path));
      }

      if (mounted) {
        Navigator.pop(context, response);
      }
    } catch (e) {
      print('Error during image cropping: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentZoomLevel = 1.0;
    double maxZoomLevel = 3.0;
    double baseZoomLevel = 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview with zoom functionality
          if (_isCameraInitialized)
            GestureDetector(
              onScaleStart: (ScaleStartDetails details) {
                baseZoomLevel =
                    currentZoomLevel; // Store the initial zoom level
              },
              onScaleUpdate: (ScaleUpdateDetails details) async {
                if (_cameraController != null) {
                  // Adjust zoom level incrementally
                  currentZoomLevel = (baseZoomLevel * details.scale).clamp(
                    1.0,
                    maxZoomLevel,
                  );
                  await _cameraController!.setZoomLevel(currentZoomLevel);
                }
              },
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Bottom Buttons
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isProcessing ? null : _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  iconSize: 32,
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _takePicture,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                //this sized box is used to center the button
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
