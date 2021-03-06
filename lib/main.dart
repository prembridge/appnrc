import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Login.dart';
import 'package:flutter_app/App/Sign_in/Pinpage.dart';
import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './App/Sign_in/Registionpage.dart';
import 'App/Sign_in/selectpage.dart';
import 'App/Sign_in/sign_in page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isRegistred;
  @override
  void initState() {
    super.initState();
    getAppStaate();
  }

  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isRegistred = prefs.getBool("isRegistered");
    });
    /* Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Loginpage(),
        ),
      );
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isRegistred == null || !isRegistred
            ? Registionpage()
            : selectpage(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Splash screen"),
    );
  }
}
