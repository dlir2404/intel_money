import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionImage extends StatelessWidget {
  final dynamic image; // Can be File or String (URL)
  final Function()? onImageRemoved;

  const TransactionImage({super.key, required this.image, this.onImageRemoved});

  Future<void> _handleImageTap(BuildContext context) async {
    if (image is File) {
      // For local files, always use custom preview to avoid platform channel issues
      _showImagePreview(context);
    } else if (image is String) {
      final imageUrl = image as String;
      if (imageUrl.startsWith('http')) {
        // Try to launch URL, fallback to preview on error
        try {
          final url = Uri.parse(imageUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            _showImagePreview(context);
          }
        } on PlatformException catch (e) {
          // Handle platform channel errors gracefully
          print('Platform error launching URL: $e');
          _showImagePreview(context);
        } catch (e) {
          print('Error launching URL: $e');
          _showImagePreview(context);
        }
      } else {
        // Local path as string, use preview
        _showImagePreview(context);
      }
    }
  }

  void _showImagePreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(image: image),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImage(context)),
        if (onImageRemoved != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onImageRemoved,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (image is File) {
      return InkWell(
        onTap: () => _handleImageTap(context),
        child: Image.file(
          image as File,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Lỗi tải ảnh', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      );
    } else if (image is String) {
      return InkWell(
          onTap: () => _handleImageTap(context),
          child: Image.network(
            image as String,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Lỗi tải ảnh', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          )
      );
    } else {
      // Fallback for null or unsupported types
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Không hỗ trợ định dạng', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }
}

class ImagePreviewPage extends StatelessWidget {
  final dynamic image;

  const ImagePreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Xem ảnh',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: _buildImageWidget(context),
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    if (image is File) {
      return Image.file(
        image as File,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'Không thể tải ảnh',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          );
        },
      );
    } else if (image is String) {
      return Image.network(
        image as String,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đang tải ảnh...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'Không thể tải ảnh từ server',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          );
        },
      );
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Định dạng ảnh không được hỗ trợ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    }
  }
}