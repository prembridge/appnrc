import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app/App/services/nonetwork_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'network_provider.dart';

class PostNotifier extends StateNotifier<AsyncValue<LocalRecords>> {
  final ProviderReference ref;
  PostNotifier({this.ref}) : super(AsyncLoading()) {
    postData();
  }
  Future<void> postData() async {
    var x = ref.watch(netProvider);
    int uploadedRecords = 1;
    if (x.data.value != ConnectivityResult.none) {
      final noNet = NoNetworkService();
      var storedData = await noNet.readAllData();
      state = AsyncData(
        LocalRecords(
          totalRecord: storedData.entries.length,
          uploadedREcords: 0,
        ),
      );
      for (var post in storedData.entries) {
        // log(post.value);
        if (await postDataToServer(post.key, post.value)) {
          uploadedRecords = uploadedRecords + 1;
          state = AsyncData(LocalRecords(
            totalRecord: storedData.entries.length,
            uploadedREcords: uploadedRecords,
          ));
        }
      }
    }
    state = AsyncError("online state");
  }

  bool isFIleType(String type) {
    var x = type.split(",").last;
    if (x == "1") {
      return true;
    }
    return false;
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

      if (isFIleType(postUrl.toString())) {
        var url = postUrl
            .toString()
            .split('-')[0]
            .replaceAll(",0", "")
            .replaceAll(",1", "");

        var request = http.MultipartRequest('POST', Uri.parse('$url'));
        request.files.add(await http.MultipartFile.fromPath('upload', body));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var res = await response.stream.bytesToString();
          var x = json.decode(res);
          var noNetwork = NoNetworkService();
          await noNetwork.cleanEntry(postUrl);
          state = AsyncError("all uploaded");
          log(x.toString());

          return true;
        } else {
          log(response.reasonPhrase);
          return false;
        }
      } else {
        var request = http.Request(
            'POST',
            Uri.parse(
                '${postUrl.toString().split('-')[0].replaceAll(",0", "").replaceAll(",1", "")}'));
        request.body = body;
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          var res = await response.stream.bytesToString();

          var x = json.decode(res);
          var noNetwork = NoNetworkService();
          await noNetwork.cleanEntry(postUrl);
          state = AsyncError("all uploaded");
          log(x.toString());
          return true;
        } else {
          log(response.reasonPhrase);
          return false;
        }
      }
    } on SocketException catch (e) {
      var noNetwork = NoNetworkService();
      noNetwork.storeFailedPostRequestData(postUrl, postUrl);
      state = AsyncData(LocalRecords(totalRecord: 0, uploadedREcords: 0));
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