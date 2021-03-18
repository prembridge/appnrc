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

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SplashScreen(
        seconds: 4,
        navigateAfterSeconds: new Scaffold(
          resizeToAvoidBottomInset: false,
          body:
              isFirstime == null || isFirstime ? Registionpage() : selectpage(),
        ),
        title: new Text('Welcome TO NRCApp'),
        image: new Image.asset('assets/images/cp.jpg'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 200.0,
        loaderColor: Colors.brown,
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
