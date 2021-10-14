import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app/App/services/nonetwork_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'network_provider.dart';

class PostNotifier extends StateNotifier<LocalRecords> {
  final ProviderReference ref;
  PostNotifier({this.ref})
      : super(LocalRecords(totalRecord: 0, uploadedREcords: 0)) {
    postData();
  }
  Future<void> postData() async {
    var x = ref.watch(netProvider);
    if (x.data.value != ConnectivityResult.none) {
      final noNet = NoNetworkService();
      var storedData = await noNet.readAllData();
      state = LocalRecords(
          totalRecord: storedData.entries.length, uploadedREcords: 0);
      for (var post in storedData.entries) {
        int uploadedRecords = 0;
        log(post.value);
        if (await postDataToServer(post.key, post.value)) {
          uploadedRecords = uploadedRecords + 1;
          state = LocalRecords(
            totalRecord: storedData.entries.length,
            uploadedREcords: uploadedRecords,
          );
        }
      }
    }
  }

  Future<bool> postDataToServer(String postUrl, String body) async {
    try {
      final http.Response token = await http.post(
        'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
        },
      );

      Map<String, dynamic> responsetoke = jsonDecode(token.body);
      var result = responsetoke['response'];
      var tokenresult = result['token'];

      log('result...in field:$tokenresult');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenresult'
      };

      var request = http.Request(
          'POST', Uri.parse('${postUrl.toString().split('-')[0]}'));

      request.body = body;
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();

        var x = json.decode(res);
        var noNetwork = NoNetworkService();
        await noNetwork.cleanEntry(postUrl);
        log(x.toString());
        return true;
      } else {
        log(response.reasonPhrase);
        return false;
      }
    } on SocketException catch (e) {
      var noNetwork = NoNetworkService();
      noNetwork.storeFailedPostRequestData(postUrl, postUrl);
      return false;
    }
  }
}

final postNotifier = StateNotifierProvider((ref) => PostNotifier(ref: ref));

class LocalRecords {
  final totalRecord;
  final uploadedREcords;
  LocalRecords({this.totalRecord, this.uploadedREcords});
}
