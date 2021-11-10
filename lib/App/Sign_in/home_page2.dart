import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Mediapage2.dart';
import 'package:flutter_app/App/models/home2_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as se;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class HomePage2 extends StatefulWidget {
  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  List<FieldDataModel> fieldData;
  Future<List<FieldDataModel>> fetchfieldData() async {
    var dio = Dio();
    dio.interceptors.add(DioCacheManager(
      CacheConfig(
        baseUrl: "http://nrcoperations.co.in",
        defaultMaxStale: Duration(days: 10),
      ),
    ).interceptor);
    try {
      log('testing......');

      final token = await dio.post(
          'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
          options: buildCacheOptions(Duration(days: 7),
              maxStale: Duration(days: 2),
              forceRefresh: true,
              options: Options(
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
                },
              )));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.data['response']['token']}'
      };
      var raw = jsonEncode({
        "query": [
          {
            "Fk_unique_id": prefs.getString('contact'),
          }
        ],
        "script": "to_check_id_there_r_new_loc",
        "script.param": prefs.getString('contact')
      });
      var request = await dio.post(
          'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Media_storage_monthly_report/_find',
          options: buildCacheOptions(Duration(days: 7),
              maxStale: Duration(days: 2),
              options: Options(headers: headers),
              forceRefresh: true),
          data: raw);

      if (request.statusCode == 200) {
        var res = await request.data;

        //  var x = json.decode(res);
        var y = List.from(res['response']['data']);
        // var recordid = List.from(y['fieldData']['recordId']);

        // print(recordid);
        var fields = y.map((e) => FieldDataModel.fromJson(e)).toList();
        for (var item in fields) {
          // log("${item.fieldData.locationId} =======>> ${item.fieldData.familyImage} ");
          log("${item.fieldData.toJson()} ");
        }
        return fields;
        // return fields;
      } else {
        // print(request.reasonPhrase);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  void initState() {
    getFieldData();

    super.initState();
  }

  getFieldData() async {
    var x = await fetchfieldData();
    setState(() {
      fieldData = x;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = (constraints.maxHeight) * 0.1;
        final width = (constraints.maxWidth) * 0.1;
        return Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  'Media',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              backgroundColor: Color(0xFF9798CB),
            ),
            body: fieldData != null
                ? Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      // stops:12,
                      colors: [
                        Color(0xFF9798CB),
                        Color(0xFFDDACD3),
                        Color(0xFFF48F9F),
                      ],
                    )),
                    child: ListView.builder(
                      itemCount: fieldData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: height * 2,
                          width: width * 100,
                          child: FieldsCard(
                            fieldData: fieldData[index].fieldData,
                            recordId: fieldData[index].recordId,
                            index: (index + 1),
                            height: height,
                            width: width,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  maintainState: true,
                                  builder: (context) =>
                                      /*  LifecycleWatcher(
                                    afterCoorectPin: */
                                      Mediapage2(
                                    fieldData: fieldData[index].fieldData,
                                    recordId: fieldData[index].recordId,
                                    // ),
                                  ), /* */
                                ),
                              );
                              setState(() {
                                fieldData = null;
                              });
                              fieldData = await fetchfieldData();
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ))
                : Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class FieldsCard extends StatefulWidget {
  final FieldData fieldData;
  final String recordId;
  final double height;
  final double width;
  final int index;
  final Function onTap;
  const FieldsCard(
      {Key key,
      this.fieldData,
      this.height,
      this.width,
      this.index,
      this.recordId,
      this.onTap})
      : super(key: key);

  @override
  _FieldsCardState createState() => _FieldsCardState();
}

class _FieldsCardState extends State<FieldsCard> {
  int imageCount = 0;
  void getImageCOunt() {
    if (widget.fieldData.communityImage != "") {
      imageCount = imageCount + 1;
    }
    if (widget.fieldData.familyImage != "") {
      imageCount = imageCount + 1;
    }
    if (widget.fieldData.gatheringImage != "") {
      imageCount = imageCount + 1;
    }
    if (widget.fieldData.leaderImage != "") {
      imageCount = imageCount + 1;
    }
    setState(() {});
  }

  @override
  void initState() {
    getImageCOunt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget fields(String title, String subtitle) {
      return Container(
        height: widget.height * 2,
        width: widget.width * 4,
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      );
    }

    return Stack(
      children: [
        Card(
          elevation: 10.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  // stops:12,
                  colors: [
                    Color(0xFF9798CB),
                    Color(0xFFDDACD3),
                    Color(0xFFF48F9F),
                  ],
                )),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    fields("Gathering", widget.fieldData.gathering),
                    fields("Full Name", widget.fieldData.fullName),
                    fields("State", widget.fieldData.state),
                    fields("District", widget.fieldData.district),
                    fields("Village", widget.fieldData.village),
                    fields("Block", widget.fieldData.block),
                    fields("Colony", widget.fieldData.colony),
                    fields("Un-Habitation ", widget.fieldData.unHabbitation)
                  ],
                )),
          ),
        ),
        CircleAvatar(
            radius: widget.width * 0.4, child: Text(widget.index.toString())),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: widget.width * 4,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: widget.onTap, child: Text("Add Media")),
                    Spacer(),
                    Text("$imageCount /4"),
                    Spacer(),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
