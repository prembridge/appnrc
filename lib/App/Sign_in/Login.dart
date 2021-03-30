import 'package:flutter/material.dart';
//import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Forgotpassword.dart';
import 'Otppage.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'Login.dart';
import 'dart:convert';
import 'dart:async';
import 'package:toast/toast.dart';

class Loginpage extends StatefulWidget {
  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool _isHidden = true;
  Future<Album> futureAlbum;
  bool isSending = false;
  Album _user;
  final TextEditingController _appMobileNumbercontroller =
      TextEditingController();
  final TextEditingController _appPasswordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    Future<bool> checkUserInDatabase(Map<String, dynamic> value) async {
      setState(() {
        isSending = true;
      });
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var imei = prefs.getString('imei');
        var raw = jsonEncode({
          "query": [
            {
              "App_mobile_number": value['phone'],
              "App_password": value['password'],
              "App_mobile_imei_number": imei
            }
          ],
          "script": "apites",
          "script.param": "${value['phone']},${value['password']},$imei"
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
          var rec = datavalue[0]['fieldData']['Rec_id'];
          var otp = datavalue[0]['fieldData']['App_otp'];
          var remobile = datavalue[0]['fieldData']['Mobile'];
          var respass = datavalue[0]['fieldData']['App_password'];

          print("otp ....:$otp");
          print("remobile rec....:$remobile");
          print("respass rec....:$respass");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('getvalue', remobile);
          await prefs.setString('pass', respass);
          await prefs.setString("otp", otp);

          await prefs.setBool("isloging", true);

          setState(() {
            isSending = false;
          });
          var isShown = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                    title: new Image.asset('assets/images/sus.png'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("OK"),
                      )
                    ],
                  ));
          if (isShown)
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Otppage()));
        } else {
          print(response.reasonPhrase);
          Toast.show("Check your Credentials", context, duration: 3);
          setState(() {
            isSending = false;
          });
        }
        return true;
      } catch (e) {
        setState(() {
          isSending = false;
        });
        return false;
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Login page'),
        ),
        body: Container(
          color: Colors.white,
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  " Continue To login",
                  style: TextStyle(fontSize: 30.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilderTextField(
                    keyboardType: TextInputType.phone,
                    name: "phone",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Mobile No.",
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
                  width: width / 2,
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: !isSending
                        ? () async {
                            if (_formKey.currentState.saveAndValidate()) {
                              var _value = _formKey.currentState.value;
                              var x = await checkUserInDatabase(_value);
                              print(x);
                            } else {
                              Toast.show("Vlidation failed", context);
                            }
                          }
                        : null,
                    child:
                        isSending ? CircularProgressIndicator() : Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
