import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageKitService {
  static final ImageKitService _instance = ImageKitService._();
  factory ImageKitService() => _instance;
  ImageKitService._();

  String? _privateKey;
  String? _urlEndpoint;

  void init() {
    _privateKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'];
    _urlEndpoint = dotenv.env['IMAGEKIT_URL_ENDPOINT'];
  }

  bool get isConfigured =>
    _privateKey != null &&
    _privateKey!.isNotEmpty &&
    _urlEndpoint != null &&
    _urlEndpoint!.isNotEmpty;

  Future<String?> uploadImage({
    required String filePath,
    required String fileName,
    String folder = '/properties',
  }) async {
    if (!isConfigured) return null;

    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);

      final auth = base64Encode(utf8.encode('$_privateKey:'));

      final response = await http.post(
        Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64File,
          'fileName': fileName,
          'folder': folder,
          'useUniqueFileName': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String?;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
