import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/selectmonth.dart';
import 'package:flutter_app/App/Sign_in/selectpage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
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
          var appDropDownMList =
              datavalue[0]['fieldData']['App_month_list_drop'];
          var appDropDownYList =
              datavalue[0]['fieldData']['App_year_list_drop'];
          print("AppMoth...$Appmonth");
          print("Appyear....$Appyear");
          print("contact...$contact");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('AppMonth', Appmonth);
          await prefs.setString("AppYear", Appyear);
          await prefs.setString("contact", contact);
          await prefs.setString('stringValue', rec);
          await prefs.setString('app_dropdown_m_list', appDropDownMList);
          await prefs.setString('app_dropdown_y_list', appDropDownYList);
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
        title: Text('OTP verification page'),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Login To Continue..',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  child: new TextField(
                    controller: _appMobileNumbercontroller,
                    decoration: new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      hintText: 'Enter OTP..',
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
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
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

                    /*  setState(() {
                      _user = user;
                    }); */
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












// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
// import 'selectpage.dart';
// void main() => runApp(Otppage());
//
// class Otppage extends StatefulWidget {
//   @override
//   _OtppageState createState() => _OtppageState();
// }
//
// class _OtppageState extends State<Otppage> {
//   int _otpCodeLength = 4;
//   bool _isLoadingButton = false;
//   bool _enableButton = false;
//   String _otpCode = "";
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _getSignatureCode();
//   }
//
//   /// get signature code
//   _getSignatureCode() async {
//     String signature = await SmsRetrieved.getAppSignature();
//     print("signature $signature");
//   }
//
//   _onSubmitOtp() {
//     setState(() {
//       _isLoadingButton = !_isLoadingButton;
//       _verifyOtpCode();
//     });
//   }
//
//   _onOtpCallBack(String otpCode, bool isAutofill) {
//     setState(() {
//       this._otpCode = otpCode;
//       if (otpCode.length == _otpCodeLength && isAutofill) {
//         _enableButton = false;
//         _isLoadingButton = true;
//         _verifyOtpCode();
//       } else if (otpCode.length == _otpCodeLength && !isAutofill) {
//         _enableButton = true;
//         _isLoadingButton = false;
//       } else {
//         _enableButton = false;
//       }
//     });
//   }
//
//   _verifyOtpCode() {
//     FocusScope.of(context).requestFocus(new FocusNode());
//     Timer(Duration(milliseconds: 4000), () {
//       setState(() {
//         _isLoadingButton = false;
//         _enableButton = false;
//       });
//
//       _scaffoldKey.currentState.showSnackBar(
//           SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
//     });
//     Navigator.push(context,
//         MaterialPageRoute(builder: (context)=>selectpage())
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: const Text('OTP verification'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 TextFieldPin(
//                   filled: true,
//                   filledColor: Colors.grey,
//                   codeLength: _otpCodeLength,
//                   boxSize: 46,
//                   filledAfterTextChange: false,
//                   textStyle: TextStyle(fontSize: 16),
//                   borderStyle: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(34)),
//                   onOtpCallback: (code, isAutofill) =>
//                       _onOtpCallBack(code, isAutofill),
//                 ),
//                 SizedBox(
//                   height: 32,
//                 ),
//                 Container(
//                   width: double.maxFinite,
//                   child: MaterialButton(
//                     onPressed: _enableButton ? _onSubmitOtp : null,
//                     child: _setUpButtonChild(),
//                     color: Colors.blue,
//                     disabledColor: Colors.blue[100],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _setUpButtonChild() {
//     if (_isLoadingButton) {
//       return Container(
//         width: 19,
//         height: 19,
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     } else {
//       return Text(
//         "Verify",
//         style: TextStyle(color: Colors.white),
//       );
//     }
//   }
// }











// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
// import 'selectpage.dart';
// void main() => runApp(Otppage());
//
// class Otppage extends StatefulWidget {
//   @override
//   _OtppageState createState() => _OtppageState();
// }
//
// class _OtppageState extends State<Otppage> {
//   int _otpCodeLength = 4;
//   bool _isLoadingButton = false;
//   bool _enableButton = false;
//   String _otpCode = "";
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _getSignatureCode();
//   }
//
//   /// get signature code
//   _getSignatureCode() async {
//     String signature = await SmsRetrieved.getAppSignature();
//     print("signature $signature");
//   }
//
//   _onSubmitOtp() {
//     setState(() {
//       _isLoadingButton = !_isLoadingButton;
//       _verifyOtpCode();
//     });
//   }
//
//   _onOtpCallBack(String otpCode, bool isAutofill) {
//     setState(() {
//       this._otpCode = otpCode;
//       if (otpCode.length == _otpCodeLength && isAutofill) {
//         _enableButton = false;
//         _isLoadingButton = true;
//         _verifyOtpCode();
//       } else if (otpCode.length == _otpCodeLength && !isAutofill) {
//         _enableButton = true;
//         _isLoadingButton = false;
//       } else {
//         _enableButton = false;
//       }
//     });
//   }
//
//   _verifyOtpCode() {
//     FocusScope.of(context).requestFocus(new FocusNode());
//     Timer(Duration(milliseconds: 4000), () {
//       setState(() {
//         _isLoadingButton = false;
//         _enableButton = false;
//       });
//
//       _scaffoldKey.currentState.showSnackBar(
//           SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
//     });
//     Navigator.push(context,
//         MaterialPageRoute(builder: (context)=>selectpage())
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: const Text('OTP verification'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 TextFieldPin(
//                   filled: true,
//                   filledColor: Colors.grey,
//                   codeLength: _otpCodeLength,
//                   boxSize: 46,
//                   filledAfterTextChange: false,
//                   textStyle: TextStyle(fontSize: 16),
//                   borderStyle: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(34)),
//                   onOtpCallback: (code, isAutofill) =>
//                       _onOtpCallBack(code, isAutofill),
//                 ),
//                 SizedBox(
//                   height: 32,
//                 ),
//                 Container(
//                   width: double.maxFinite,
//                   child: MaterialButton(
//                     onPressed: _enableButton ? _onSubmitOtp : null,
//                     child: _setUpButtonChild(),
//                     color: Colors.blue,
//                     disabledColor: Colors.blue[100],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _setUpButtonChild() {
//     if (_isLoadingButton) {
//       return Container(
//         width: 19,
//         height: 19,
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     } else {
//       return Text(
//         "Verify",
//         style: TextStyle(color: Colors.white),
//       );
//     }
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_app/App/Sign_in/Pinpage.dart';
// import 'package:flutter_app/App/Sign_in/passcodepage.dart';
// import 'package:flutter_app/App/Sign_in/selectpage.dart';
// import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:developer';
// import 'dart:convert';
// import 'dart:async';

// import 'package:toast/toast.dart';

// Album albumFromJson(String str) => Album.fromJson(json.decode(str));

// String albumToJson(Album data) => json.encode(data.toJson());

// Future<bool> fetchAlbum(String otpFromField) async {
//   try {
//     log('testing......');
//     final http.Response token = await http.post(
//       'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
//       },
//     );
//     log('token...:$token');

//     Map<String, dynamic> responsetoke = jsonDecode(token.body);
//     var result = responsetoke['response'];
//     var tokenresult = result['token'];

//     log('result...in field:$tokenresult');

//     var headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $tokenresult'
//     };

//     var raw = jsonEncode({
//       "query": [
//         {"App_otp": otpFromField}
//       ]
//     });
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Monthly_dis_app/_find'));
//     request.body = raw;
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       var res = await response.stream.bytesToString();
//       var result = jsonDecode(res);
//       var responses = result['response'];
//       var datavalue = responses['data'];
//       print(datavalue);
//       var rec = datavalue[0]['fieldData']['App_otp'];
//       var appmonth = datavalue[0]['fieldData']['App_month_list'];
//       var appyear = datavalue[0]['fieldData']['App_year_list'];
//       var contact = datavalue[0]['fieldData']['Contact_Primary_key'];
//       var appDropDownMList = datavalue[0]['fieldData']['App_month_list_drop'];
//       var appDropDownYList = datavalue[0]['fieldData']['App_year_list_drop'];
//       print("AppMoth...$appmonth");
//       print("appyear....$appyear");
//       print("contact...$contact");
//       var prefs = await SharedPreferences.getInstance();
//       prefs.setString('appmonth', appmonth);
//       prefs.setString("appyear", appyear);
//       prefs.setString("contact", contact);
//       prefs.setString('stringValue', rec);
//       prefs.setString('app_dropdown_m_list', appDropDownMList);
//       prefs.setString('app_dropdown_y_list', appDropDownYList);
//       print("data recotp ....:$rec");

//       print(await response.stream.bytesToString());
//       return true;
//     } else {
//       print(response.reasonPhrase);
//       return false;
//     }
//   } catch (e) {
//     print(e);
//     return false;
//   }
// }

// class Album {
//   Album({
//     this.dataInfo,
//     this.data,
//   });

//   DataInfo dataInfo;
//   List<Datum> data;

//   factory Album.fromJson(Map<String, dynamic> json) => Album(
//         dataInfo: DataInfo.fromJson(json["dataInfo"]),
//         data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "dataInfo": dataInfo.toJson(),
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//       };
// }

// class Datum {
//   Datum({
//     this.fieldData,
//     this.portalData,
//     this.recordId,
//     this.modId,
//   });

//   FieldData fieldData;
//   PortalData portalData;
//   String recordId;
//   String modId;

//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         fieldData: FieldData.fromJson(json["fieldData"]),
//         portalData: PortalData.fromJson(json["portalData"]),
//         recordId: json["recordId"],
//         modId: json["modId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "fieldData": fieldData.toJson(),
//         "portalData": portalData.toJson(),
//         "recordId": recordId,
//         "modId": modId,
//       };
// }

// class FieldData {
//   FieldData({
//     this.contactPrimaryKey,
//     this.contactPhoto,
//     this.appUserName,
//     this.appPassword,
//     this.appMobileNumber,
//     this.appMobileImeiNumber,
//     this.mobile,
//   });

//   String contactPrimaryKey;
//   String contactPhoto;
//   String appUserName;
//   String appPassword;
//   String appMobileNumber;
//   String appMobileImeiNumber;
//   int mobile;

//   factory FieldData.fromJson(Map<String, dynamic> json) => FieldData(
//         contactPrimaryKey: json["Contact_Primary_key"],
//         contactPhoto: json["Contact_Photo"],
//         appUserName: json["App_user_name"],
//         appPassword: json["App_password"],
//         appMobileNumber: json["App_mobile_number"],
//         appMobileImeiNumber: json["App_mobile_imei_number"],
//         mobile: json["Mobile"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Contact_Primary_key": contactPrimaryKey,
//         "Contact_Photo": contactPhoto,
//         "App_user_name": appUserName,
//         "App_password": appPassword,
//         "App_mobile_number": appMobileNumber,
//         "App_mobile_imei_number": appMobileImeiNumber,
//         "Mobile": mobile,
//       };
// }

// class PortalData {
//   PortalData();

//   factory PortalData.fromJson(Map<String, dynamic> json) => PortalData();

//   Map<String, dynamic> toJson() => {};
// }

// class DataInfo {
//   DataInfo({
//     this.database,
//     this.layout,
//     this.table,
//     this.totalRecordCount,
//     this.foundCount,
//     this.returnedCount,
//   });

//   String database;
//   String layout;
//   String table;
//   int totalRecordCount;
//   int foundCount;
//   int returnedCount;

//   factory DataInfo.fromJson(Map<String, dynamic> json) => DataInfo(
//         database: json["database"],
//         layout: json["layout"],
//         table: json["table"],
//         totalRecordCount: json["totalRecordCount"],
//         foundCount: json["foundCount"],
//         returnedCount: json["returnedCount"],
//       );

//   Map<String, dynamic> toJson() => {
//         "database": database,
//         "layout": layout,
//         "table": table,
//         "totalRecordCount": totalRecordCount,
//         "foundCount": foundCount,
//         "returnedCount": returnedCount,
//       };
// }

// class Otppage extends StatefulWidget {
//   @override
//   _OtppageState createState() => _OtppageState();
// }

// class _OtppageState extends State<Otppage> {
//   Album _user;
//   Future<Album> futureAlbum;
//   String otpValue;
//   final _key = GlobalKey<FormBuilderState>();
//   @override
//   void initState() {
//     // TODO: implement initState
//     getOtp();
//     super.initState();
//     //futureAlbum = fetchAlbum();
//   }

//   getOtp() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     setState(() {
//       otpValue = prefs.getString("otp");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     onSubmit() async {
//       if (_key.currentState.saveAndValidate()) {
//         var value = _key.currentState.value;
//         /*  if (otpValue == value['otp']) {
//           Navigator.of(context).pushReplacement(MaterialPageRoute(
//             builder: (context) => selectpage(),
//           ));
//         } else {
//           Toast.show("OTP NOT MATCH", context);
//         } */
//         var x = await fetchAlbum(value["otp"]);
//         if (x) {
//           /*     Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => selectpage())); */
//           Toast.show("OK ogot it", context);
//         } else {
//           Toast.show("OTP NOT MATCH", context);
//         }
//       }
//     }

//     return Scaffold(
//         appBar: AppBar(title: Text('OTP verification page')),
//         body: Container(
//           color: Colors.blueGrey,
//           child: FormBuilder(
//             key: _key,
//             child: Column(
//               children: <Widget>[
//                 Container(
//                   margin: EdgeInsets.all(20),
//                   child: Text(
//                     'Login To Continue..',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 25.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   child: new FormBuilderTextField(
//                     name: "otp",
//                     maxLength: 4,
//                     keyboardType: TextInputType.number,
//                     // controller: _appMobileNumbercontroller,
//                     decoration: new InputDecoration(
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.all(Radius.circular(20)),
//                       ),
//                       hintText: 'Enter OTP..',
//                     ),
//                     validator: FormBuilderValidators.compose([
//                       FormBuilderValidators.required(context),
//                       FormBuilderValidators.maxLength(context, 4),
//                       FormBuilderValidators.minLength(context, 4)
//                     ]),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 RaisedButton(
//                   onPressed: onSubmit,
//                   child: Text("SUBMIT"),
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'dart:async';
// // import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
// // import 'selectpage.dart';
// // void main() => runApp(Otppage());
// //
// // class Otppage extends StatefulWidget {
// //   @override
// //   _OtppageState createState() => _OtppageState();
// // }
// //
// // class _OtppageState extends State<Otppage> {
// //   int _otpCodeLength = 4;
// //   bool _isLoadingButton = false;
// //   bool _enableButton = false;
// //   String _otpCode = "";
// //   final _scaffoldKey = GlobalKey<ScaffoldState>();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getSignatureCode();
// //   }
// //
// //   /// get signature code
// //   _getSignatureCode() async {
// //     String signature = await SmsRetrieved.getAppSignature();
// //     print("signature $signature");
// //   }
// //
// //   _onSubmitOtp() {
// //     setState(() {
// //       _isLoadingButton = !_isLoadingButton;
// //       _verifyOtpCode();
// //     });
// //   }
// //
// //   _onOtpCallBack(String otpCode, bool isAutofill) {
// //     setState(() {
// //       this._otpCode = otpCode;
// //       if (otpCode.length == _otpCodeLength && isAutofill) {
// //         _enableButton = false;
// //         _isLoadingButton = true;
// //         _verifyOtpCode();
// //       } else if (otpCode.length == _otpCodeLength && !isAutofill) {
// //         _enableButton = true;
// //         _isLoadingButton = false;
// //       } else {
// //         _enableButton = false;
// //       }
// //     });
// //   }
// //
// //   _verifyOtpCode() {
// //     FocusScope.of(context).requestFocus(new FocusNode());
// //     Timer(Duration(milliseconds: 4000), () {
// //       setState(() {
// //         _isLoadingButton = false;
// //         _enableButton = false;
// //       });
// //
// //       _scaffoldKey.currentState.showSnackBar(
// //           SnackBar(content: Text("Verification OTP Code $_otpCode Success")));
// //     });
// //     Navigator.push(context,
// //         MaterialPageRoute(builder: (context)=>selectpage())
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         key: _scaffoldKey,
// //         appBar: AppBar(
// //           title: const Text('OTP verification'),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Center(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: <Widget>[
// //                 TextFieldPin(
// //                   filled: true,
// //                   filledColor: Colors.grey,
// //                   codeLength: _otpCodeLength,
// //                   boxSize: 46,
// //                   filledAfterTextChange: false,
// //                   textStyle: TextStyle(fontSize: 16),
// //                   borderStyle: OutlineInputBorder(
// //                       borderSide: BorderSide.none,
// //                       borderRadius: BorderRadius.circular(34)),
// //                   onOtpCallback: (code, isAutofill) =>
// //                       _onOtpCallBack(code, isAutofill),
// //                 ),
// //                 SizedBox(
// //                   height: 32,
// //                 ),
// //                 Container(
// //                   width: double.maxFinite,
// //                   child: MaterialButton(
// //                     onPressed: _enableButton ? _onSubmitOtp : null,
// //                     child: _setUpButtonChild(),
// //                     color: Colors.blue,
// //                     disabledColor: Colors.blue[100],
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //
