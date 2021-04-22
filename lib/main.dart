import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Login.dart';
import 'package:flutter_app/App/Sign_in/Pinpage.dart';
import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './App/Sign_in/Registionpage.dart';
import 'App/Sign_in/locationPermitionScreen.dart';
import 'App/Sign_in/selectpage.dart';
import 'App/Sign_in/sign_in page.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static Map<int, Color> color = {
    50: Color.fromRGBO(151, 152, 203, .1),
    100: Color.fromRGBO(151, 152, 203, .2),
    200: Color.fromRGBO(151, 152, 203, .3),
    300: Color.fromRGBO(151, 152, 203, .4),
    400: Color.fromRGBO(151, 152, 203, .5),
    500: Color.fromRGBO(151, 152, 203, .6),
    600: Color.fromRGBO(151, 152, 203, .7),
    700: Color.fromRGBO(151, 152, 203, .8),
    800: Color.fromRGBO(151, 152, 203, .9),
    900: Color.fromRGBO(151, 152, 203, 1),
  };
  MaterialColor primeColor = MaterialColor(0xFF9798CB, color);

  bool isFirstime;
  @override
  void initState() {
    super.initState();
    getAppStaate();
  }

  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isFirstime = prefs.getBool("isFirstime");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: primeColor),
      home: Container(
        child: SplashScreen(
          seconds: 4,
          navigateAfterSeconds: new Scaffold(
            resizeToAvoidBottomInset: false,
            body: isFirstime == null || isFirstime
                ? Registionpage()
                : selectpage(),
          ),
          title: new Text(
            'NRC',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
          image: new Image.asset('assets/images/Logo.png' ),
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
      ),
    );

    /* SplashScreen(
        seconds: 4,
        navigateAfterSeconds: new Scaffold(
          resizeToAvoidBottomInset: false,
          body:
              isFirstime == null || isFirstime ? Registionpage() : selectpage(),
        ),
        title: new Text('Welcome In SplashScreen'),
        image: new Image.asset('assets/images/village.jpg'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 200.0,
        loaderColor: Colors.brown,
      ), */
  }
}
