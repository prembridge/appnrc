import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = new FlutterSecureStorage();

class NoNetworkService {
  Future<void> storeFailedPostRequestData(
      String formData, String postUrl) async {
    await _storage.write(key: '$postUrl----${DateTime.now()}', value: formData);
  }

  Future<Map<String, String>> readAllData() async {
    return await _storage.readAll();
  }

  Future<void> clean() {
    _storage.deleteAll();
  }
}
