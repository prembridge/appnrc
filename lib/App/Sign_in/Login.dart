import 'package:flutter/material.dart';
//import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
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
              builder: (context) => Container(
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
                    )
                ),
                child: SplashScreen(
                  seconds: 4,
                  navigateAfterSeconds: new Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Otppage() ,
                  ),
                  title: new Text('Login successful',style: GoogleFonts.montserrat(
                    textStyle: TextStyle(color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,),
                  ),),
                  image: new Image.asset('assets/images/sus.png'),
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

                  //     title: new Image.asset('assets/images/sus.png'),
                  // content:Center(child: Text("Login successful ")),
                  //     actions: [
                  //       TextButton(
                  //         onPressed: () => Navigator.of(context).pop(true),
                  //         child: Text("OK"),
                  //       )
                  //     ],
                    ),
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
          title: Text('Login page',
            style: GoogleFonts.montserrat(
            textStyle: TextStyle(color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,),
        ),),
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
              )
          ),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  " Continue to login",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,),
                  ),
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
                  height: height/9,
                  width: width / 2,
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      side: BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
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
                        isSending ? CircularProgressIndicator() : Text("Login" , style: GoogleFonts.montserrat(
                          textStyle: TextStyle(color: Colors.white,
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold,),
                        ),),
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
