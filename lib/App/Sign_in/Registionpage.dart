import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:permission_handler/permission_handler.dart' as per;
import 'dart:developer';
import 'Login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:splashscreen/splashscreen.dart';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());
String platformImei;
String idunique;

Future<void> initPlatformState() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    platformImei =
        await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    List<String> multiImei = await ImeiPlugin.getImeiMulti();
    Map<per.Permission, per.PermissionStatus> statuses = await [
      per.Permission.location,
      per.Permission.storage,
      per.Permission.camera,
      per.Permission.phone,
      per.Permission.mediaLibrary
    ].request();
    log(statuses.toString());
  } on PlatformException {
    platformImei = 'Failed to get platform version.';
  }
}

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
  dynamic appPassword;
  dynamic appMobileNumber;
  String appMobileImeiNumber;
  dynamic mobile;

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

class Registionpage extends StatefulWidget {
  @override
  _RegistionpageState createState() => _RegistionpageState();
}

class _RegistionpageState extends State<Registionpage> {
  Album _user;
  bool _isHidden = true;
  final TextEditingController _appMobileNumbercontroller =
      TextEditingController();
  final TextEditingController _appPasswordcontroller = TextEditingController();
  Future<Album> futureAlbum;
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  void initState() {
    super.initState();
    initPlatformState();
    // futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    Future<bool> checkUserInDatabase(Map<String, dynamic> value) async {
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
            {
              "App_mobile_number": value['phone'],
              "App_password": value['password']
            }
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

          var rec = datavalue[0]['fieldData']['Rec_id'];
          var remobile = datavalue[0]['fieldData']['Mobile'];
          var respass = datavalue[0]['fieldData']['App_password'];

          print("data recotp ....:$rec");
          print("remobile rec....:$remobile");
          print("respass rec....:$respass");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('getvalue', remobile);
          await prefs.setString('pass', respass);

          var headerss = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenresult'
          };

          var raww = jsonEncode({
            "fieldData": {"App_mobile_imei_number": platformImei}
          });
          await prefs.setString('imei', platformImei);
          var requestimei = http.Request(
              'PATCH',
              Uri.parse(
                  'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Monthly_dis_app/records/$rec'));
          requestimei.body = raww;
          requestimei.headers.addAll(headerss);
          http.StreamedResponse responseimei = await requestimei.send();
          if (responseimei.statusCode == 200) {
            print(await responseimei.stream.bytesToString());
          } else {
            print(responseimei.reasonPhrase);
          }
          // return albumFromJson(request.body);

          await prefs.setBool("isFirstime", true);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => Container(
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
                    child: SplashScreen(
                      seconds: 4,

                      navigateAfterSeconds: Loginpage(),

                      title: new Text(
                        'Registration successful',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            // textAlign:TextAlign.center,
                            // height: 20,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      image: new Image.asset(
                        'assets/images/sus.png',
                        width: 180,
                      ),
                      //backgroundColor: Color(0xFF9798CB),
                      gradientBackground: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        // stops:12,
                        colors: [
                          Color(0xFF9798CB),
                          Color(0xFFDDACD3),
                          Color(0xFFF48F9F),
                        ],
                      ),
                      styleTextUnderTheLoader: new TextStyle(),
                      photoSize: 200.0,
                      loaderColor: Colors.brown,
                    ),
                  )));
        } else {
          print(response.reasonPhrase);
          showDialog(
              context: context,
              builder: (context) => Dialog(
                    child: Container(
                      height: height / 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Check Credentials",
                              style: TextStyle(fontSize: width / 20),
                            ),
                          ),
                          Container(
                            width: width / 2,
                            child: Image.asset(
                              'assets/images/fail.png',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("CLOSE"),
                          )
                        ],
                      ),
                    ),
                  ));
        }
        return true;
      } catch (e) {
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9798CB),
        title: Center(
          child: Text(
            'Registration ',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
          // color: Colors.white,

          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   "  Register..",
                //   style: TextStyle(fontSize: 30.0),
                // ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilderTextField(
                    keyboardType: TextInputType.phone,
                    name: "phone",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Mobile No.",
                      labelStyle: TextStyle(fontSize: 20),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                      FormBuilderValidators.numeric(context),
                      FormBuilderValidators.maxLength(context, 10),
                      FormBuilderValidators.minLength(context, 10),
                    ]),
                    maxLength: 10,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilderTextField(
                    obscureText: _isHidden,
                    name: "password",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      labelStyle: TextStyle(fontSize: 20),
                      suffix: InkWell(
                        onTap: _togglePasswordView,
                        child: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                    ]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  height: height / 10,
                  width: width / 2.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.black12, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.saveAndValidate()) {
                        var _value = _formKey.currentState.value;
                        var x = await checkUserInDatabase(_value);
                        print(x);
                      } else {
                        Toast.show("Vlidation failed", context);
                      }
                    },
                    child: Text(
                      "Register",
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}

class RegisterSplashScreen extends StatelessWidget {
  const RegisterSplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
