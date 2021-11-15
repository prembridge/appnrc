import 'dart:developer';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final _storage = new FlutterSecureStorage();

class NoNetworkService {
  Future<void> storeFailedPostRequestData(
      String formData, String postUrl) async {
    await _storage.write(
        key: '$postUrl----${DateTime.now()},0', value: formData);
  }

  static Future<void> storeFailedFileUploadRequest(
      File imageFile, String postUrl) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = basename(imageFile.path);
    File tempFile = await imageFile.copy("${tempDir.path}/$fileName");

    await _storage.write(
        key: '$postUrl----${DateTime.now()},1', value: tempFile.path);
  }

  Future<Map<String, String>> readAllData() async {
    return await _storage.readAll();
  }

  Future<void> cleanEntry(String key) {
    return _storage.delete(key: key);
  }

  Future<void> clean() {
    return _storage.deleteAll();
  }
}
