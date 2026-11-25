import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/cloudinary_constants.dart';

class CloudinaryService {
  /// Uploads an image file directly to Cloudinary using the unsigned preset
  /// Returns the secure URL of the uploaded image
  static Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      final uri = Uri.parse(CloudinaryConstants.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = CloudinaryConstants.uploadPreset;
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
