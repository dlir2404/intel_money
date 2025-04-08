import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
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
            toolbarTitle: 'Crop Receipt',
            toolbarColor: Colors.black,
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Receipt'),
        ],
      );

      if (croppedFile == null) return;

      final inputImage = InputImage.fromFilePath(croppedFile.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final extractedData = _extractReceiptData(recognizedText.text);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptConfirmationScreen(
                  receiptImage: File(croppedFile.path),
                  extractedData: extractedData,
                ),
          ),
        );
      }
    } catch (e) {
      print('Error during image cropping: $e');
    }
  }

  Map<String, dynamic> _extractReceiptData(String text) {
    // This is a simple implementation - you'll need to improve this
    // based on the format of receipts you're expecting to scan

    final lines = text.split('\n');
    double? totalAmount;
    DateTime? date;
    String? storeName;

    // Try to find store name (usually at the top)
    if (lines.isNotEmpty) {
      storeName = lines[0];
    }

    // Look for date
    for (final line in lines) {
      // Simple regex for date formats like DD/MM/YYYY or YYYY-MM-DD
      RegExp dateRegex = RegExp(r'(\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4})');
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        try {
          // Try to parse the date - this is simplified
          final dateStr = dateMatch.group(0)!;
          // You'll need more robust date parsing logic based on your locale
          date = DateTime.parse(dateStr);
        } catch (e) {
          // Fallback to current date if parsing fails
          date = DateTime.now();
        }
      }
    }

    // Look for total amount
    for (final line in lines) {
      if (line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('amount') ||
          line.toLowerCase().contains('sum')) {
        // Extract numbers from the line
        RegExp amountRegex = RegExp(r'(\d+[,.]\d+)');
        final amountMatch = amountRegex.firstMatch(line);
        if (amountMatch != null) {
          try {
            String amountStr = amountMatch.group(0)!;
            amountStr = amountStr.replaceAll(',', '.');
            totalAmount = double.parse(amountStr);
          } catch (e) {
            print('Error parsing amount: $e');
          }
        }
      }
    }

    return {
      'store': storeName ?? 'Unknown Store',
      'date': date ?? DateTime.now(),
      'amount': totalAmount ?? 0.0,
      'fullText': text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Receipt Scanner',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _isCameraInitialized
              ? CameraPreview(_cameraController!)
              : const Center(child: CircularProgressIndicator()),

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

                //this size box to make the button centered
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptConfirmationScreen extends StatefulWidget {
  final File receiptImage;
  final Map<String, dynamic> extractedData;

  const ReceiptConfirmationScreen({
    Key? key,
    required this.receiptImage,
    required this.extractedData,
  }) : super(key: key);

  @override
  State<ReceiptConfirmationScreen> createState() =>
      _ReceiptConfirmationScreenState();
}

class _ReceiptConfirmationScreenState extends State<ReceiptConfirmationScreen> {
  late TextEditingController storeController;
  late TextEditingController amountController;
  late DateTime selectedDate;
  late String category;

  @override
  void initState() {
    super.initState();
    storeController = TextEditingController(
      text: widget.extractedData['store'],
    );
    amountController = TextEditingController(
      text: widget.extractedData['amount'].toString(),
    );
    selectedDate = widget.extractedData['date'];
    category = 'Khác'; // Default category
  }

  @override
  void dispose() {
    storeController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Expense'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    widget.receiptImage,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Store Name',
              controller: storeController,
              icon: Icons.store,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Amount',
              controller: amountController,
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CategorySelector(
              onCategorySelected: (value) {
                setState(() {
                  category = value;
                });
              },
              selectedCategory: category,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final expense = {
                    'store': storeController.text,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'date': selectedDate,
                    'category': category,
                    'receiptImage': widget.receiptImage.path,
                  };
                  Navigator.pop(context, expense);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const CategorySelector({
    Key? key,
    required this.onCategorySelected,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Ăn uống',
      'Mua sắm',
      'Di chuyển',
      'Hóa đơn',
      'Giải trí',
      'Sức khỏe',
      'Giáo dục',
      'Khác',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          categories.map((category) {
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.7),
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
    );
  }
}
