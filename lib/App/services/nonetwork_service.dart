import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final _storage = new FlutterSecureStorage();

class NoNetworkService {
  Future<void> storeFailedPostRequestData(
      String formData, String postUrl) async {
    await _storage.write(key: '$postUrl----${DateTime.now()}', value: formData);
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
