import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "",
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "",
  );

  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;

  CloudinaryService._internal();

  Future<String> uploadImage(String filePath) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
