import 'package:flutter/material.dart';
//import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
//import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Forgotpassword.dart';
import 'Otppage.dart';
import 'package:http/http.dart'as http;
import 'dart:developer';
import 'Login.dart';
import 'dart:convert';
import 'dart:async';


Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());


Future<Album> fetchAlbum(String appMobileNumber, String appPassword) async {
  try {
    log('testing......');
    final http.Response token =
    await http.post(
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

    var raw = jsonEncode({"query":[{"App_mobile_number":appMobileNumber,"App_password":appPassword}],"script":"apites"});
    var request = http.Request('POST', Uri.parse('https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Monthly_dis_app/_find'));
    request.body = raw;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var result = jsonDecode(res);
      var responses = result['response'];
      var datavalue =responses['data'];
      print(datavalue);
      var rec =datavalue[0]['fieldData']['App_otp'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('getvalue', rec);
      print("data recotp ....:$rec");

    }
    else {
      print(response.reasonPhrase);
    }
  }

  catch (e) {
    print(e);
    return null;
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
  String appPassword;
  String appMobileNumber;
  String appMobileImeiNumber;
  int mobile;

  factory FieldData.fromJson(Map<String, dynamic> json) =>  FieldData(

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

  factory PortalData.fromJson(Map<String, dynamic> json) => PortalData(
  );

  Map<String, dynamic> toJson() => {
  };
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





class Loginpage extends StatefulWidget {
  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  Future<Album> futureAlbum;
  Album  _user;
  final TextEditingController _appMobileNumbercontroller = TextEditingController();
  final TextEditingController _appPasswordcontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //futureAlbum = fetchAlbum();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login page'),

      ),
      body: Container(
        color: Colors.blueGrey,
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin:EdgeInsets.only(bottom: 20),
                  child: Text('Login To Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  child:new TextField(
                    controller: _appMobileNumbercontroller,
                    decoration:new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),

                      hintText: 'Mobilenumber',
                    ),
                  ),

                ),

                SizedBox(
                  height: 20,
                ),

                Container(
                  child:new TextField(
                    controller: _appPasswordcontroller,
                    decoration:new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),

                      hintText: 'Password',
                    ),
                  ),

                ),

                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>Forgotpassword())
                        );
                      },
                      child: new Text("Forgot Password",style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final String appMobileNumber = _appMobileNumbercontroller.text;
                    final String appPassword = _appPasswordcontroller.text;
                    // String signature = await SmsRetrieved.getAppSignature();
                    // print("signature in loging $signature");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>Otppage())
                    );
                    final Album user = await fetchAlbum(appMobileNumber, appPassword);
                    setState(() {
                      _user = user;

                    });
                  },

                  child: PrimaryButton(
                    btnText: "Ok",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }
}