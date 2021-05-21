import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/selectmonth.dart';
import 'package:flutter_app/App/Sign_in/selectpage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'dart:async';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());

class Album {
  Album({
    this.dataInfo,
    this.data,
  });

  DataInfo dataInfo;
  List<Datum> data;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        dataInfo: DataInfo.fromJson(json["dataInfo"]),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dataInfo": dataInfo.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.fieldData,
    this.portalData,
    this.recordId,
    this.modId,
  });

  FieldData fieldData;
  PortalData portalData;
  String recordId;
  String modId;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        fieldData: FieldData.fromJson(json["fieldData"]),
        portalData: PortalData.fromJson(json["portalData"]),
        recordId: json["recordId"],
        modId: json["modId"],
      );

  Map<String, dynamic> toJson() => {
        "fieldData": fieldData.toJson(),
        "portalData": portalData.toJson(),
        "recordId": recordId,
        "modId": modId,
      };
}

class FieldData {
  FieldData({
    this.contactPrimaryKey,
    this.contactPhoto,
    this.appUserName,
    this.appPassword,
    this.appMobileNumber,
    this.appMobileImeiNumber,
    this.mobile,
  });

  String contactPrimaryKey;
  String contactPhoto;
  String appUserName;
  String appPassword;
  String appMobileNumber;
  String appMobileImeiNumber;
  int mobile;

  factory FieldData.fromJson(Map<String, dynamic> json) => FieldData(
        contactPrimaryKey: json["Contact_Primary_key"],
        contactPhoto: json["Contact_Photo"],
        appUserName: json["App_user_name"],
        appPassword: json["App_password"],
        appMobileNumber: json["App_mobile_number"],
        appMobileImeiNumber: json["App_mobile_imei_number"],
        mobile: json["Mobile"],
      );

  Map<String, dynamic> toJson() => {
        "Contact_Primary_key": contactPrimaryKey,
        "Contact_Photo": contactPhoto,
        "App_user_name": appUserName,
        "App_password": appPassword,
        "App_mobile_number": appMobileNumber,
        "App_mobile_imei_number": appMobileImeiNumber,
        "Mobile": mobile,
      };
}

class PortalData {
  PortalData();

  factory PortalData.fromJson(Map<String, dynamic> json) => PortalData();

  Map<String, dynamic> toJson() => {};
}

class DataInfo {
  DataInfo({
    this.database,
    this.layout,
    this.table,
    this.totalRecordCount,
    this.foundCount,
    this.returnedCount,
  });

  String database;
  String layout;
  String table;
  int totalRecordCount;
  int foundCount;
  int returnedCount;

  factory DataInfo.fromJson(Map<String, dynamic> json) => DataInfo(
        database: json["database"],
        layout: json["layout"],
        table: json["table"],
        totalRecordCount: json["totalRecordCount"],
        foundCount: json["foundCount"],
        returnedCount: json["returnedCount"],
      );

  Map<String, dynamic> toJson() => {
        "database": database,
        "layout": layout,
        "table": table,
        "totalRecordCount": totalRecordCount,
        "foundCount": foundCount,
        "returnedCount": returnedCount,
      };
}

class Otppage extends StatefulWidget {
  @override
  _OtppageState createState() => _OtppageState();
}

class _OtppageState extends State<Otppage> {
  Album _user;
  bool isFirstime;
  bool isOTPCorrect = false;
  Future<Album> futureAlbum;
  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isFirstime = prefs.getBool("isFirstime");
    });
  }

  final TextEditingController _appMobileNumbercontroller =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    getAppStaate();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    Future<bool> fetchAlbum(String appMobileNumber) async {
      try {
        log('testing......');
        final http.Response token = await http.post(
          'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
          },
        );
        log('token...:$token');

        Map<String, dynamic> responsetoke = jsonDecode(token.body);
        var result = responsetoke['response'];
        var tokenresult = result['token'];

        log('result...in field:$tokenresult');

        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenresult'
        };

        var raw = jsonEncode({
          "query": [
            {"App_otp": appMobileNumber}
          ]
        });
        var request = http.Request(
            'POST',
            Uri.parse(
                'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Monthly_dis_app/_find'));
        request.body = raw;
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var res = await response.stream.bytesToString();
          var result = jsonDecode(res);
          var responses = result['response'];
          var datavalue = responses['data'];
          print(datavalue);
          var rec = datavalue[0]['fieldData']['App_otp'];
          var Appmonth = datavalue[0]['fieldData']['App_month_list'];
          var Appyear = datavalue[0]['fieldData']['App_year_list'];
          var contact = datavalue[0]['fieldData']['Contact_Primary_key'];
          /*  var appDropDownMList =
              datavalue[0]['fieldData']['App_month_list_drop'];
          var appDropDownYList =
              datavalue[0]['fieldData']['App_year_list_drop']; */
          var monthyearList = datavalue[0]['fieldData']['Month_year_list'];
          print("AppMoth...$Appmonth");
          print("Appyear....$Appyear");
          print("contact...$contact");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('AppMonth', Appmonth);
          await prefs.setString("AppYear", Appyear);
          await prefs.setString("contact", contact);
          await prefs.setString('stringValue', rec);
          await prefs.setString('Month_year_list', monthyearList);
          /*    await prefs.setString('app_dropdown_y_list', appDropDownYList); */
          print("data recotp ....:$rec");

          // print(await response.stream.bytesToString());
          return true;
        } else {
          print(response.reasonPhrase);
          return false;
        }
      } catch (e) {
        log(e);
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Verification',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
               // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF9798CB),
      ),
      body: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Verify your OTP',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                       // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilderTextField(
                    keyboardType: TextInputType.phone,
                    controller: _appMobileNumbercontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter OTP",
                      labelStyle: TextStyle(fontSize: 20),

                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: height /15,
              width: width /2.82,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black12, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  final String appMobileNumber =
                      _appMobileNumbercontroller.text;
                  print('appMobileNumber:$appMobileNumber');
                  final bool user = await fetchAlbum(appMobileNumber);
                  if (user) {
                    return Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            isFirstime ? selectpage() : Selectmonth(),
                      ),
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) => new AlertDialog(
                        title: new Text("please enrter Vaild OTP.."),
                        actions: [
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  "Submit",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
