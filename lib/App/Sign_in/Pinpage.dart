import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Login.dart';
import 'package:flutter_app/App/Sign_in/passcodepage.dart';
import 'package:flutter_app/App/Sign_in/selectmonth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pinpage extends StatefulWidget {
  @override
  _PinpageState createState() => _PinpageState();
}

class _PinpageState extends State<Pinpage> {
  LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometric;
  List<BiometricType> _availableBiometric;
  String authorized = "Not authorized";
  bool isFirstime;
  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isFirstime = prefs.getBool("isFirstime");
    });
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometric;
    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      log(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: "Scan your finger print to authenticate",
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      authorized =
          authenticated ? "Autherized success" : "Failed to authenticate";
      print(authorized);
    });
    if (authenticated) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => isFirstime ? Selectmonth() : Loginpage()));
    }
  }

  @override
  void initState() {
    super.initState();
    getAppStaate();
    _checkBiometric();
    _getAvailableBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF3C3E52),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 45),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/fin.png',
                    width: 140,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "FingerPrint Auth",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    width: 150,
                    child: Text(
                      "Authentication using your fingerprint click Authenticate",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, height: 1.5),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.blueGrey,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: _authenticate,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 24.0),
                        child: Text(
                          'Authenticate',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   height: 20,
                  //   child: GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           Navigator.push(context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => passcodepage())
                  //           );
                  //         });
                  //       },
                  //       child:Text("Skip",style: TextStyle(color: Colors.white,fontSize: 20),)
                  //       ),
                  // ),
                  //Text("Skip",style: TextStyle(color: Colors.white,fontSize: 20),)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
