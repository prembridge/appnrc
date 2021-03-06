import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/App/Sign_in/Login.dart';
import 'package:flutter_app/App/Sign_in/passcodesetpage.dart';
import 'package:flutter_app/App/Sign_in/selectmonth.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pinpage.dart';
import 'passcodepage.dart';

class selectpage extends StatefulWidget {
  @override
  _selectpageState createState() => _selectpageState();
}

class _selectpageState extends State<selectpage> {
  bool isPinSet;
  bool isFirstime;
  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isPinSet = prefs.getBool("isPinSet") ?? false;
      isFirstime = prefs.getBool("isFirstime") ?? true;
    });
  }

  @override
  void initState() {
    getAppStaate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Login Options',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF9798CB),
      ),
      body: Container(
        width: 550,
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
              // mainAxisAlignment: Main,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    ' Choose an option',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // inputTextdata(
                //   hint: 'MobileNum...',
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                // inputTextdata(
                //   hint: 'Password..',
                // ),
                // SizedBox(
                //   height: 20,
                // ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: isFirstime || !isPinSet

                        ///
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => passcodsetepage(),
                              ),
                            );
                          }
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => passcodepage(),
                              ),
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Color(0xFF9798CB),
                          side: BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            isFirstime || !isPinSet
                                ? "Setup passcode"
                                : "Use Passcode",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "OR",
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    LocalAuthentication auth = LocalAuthentication();
                    bool authenticated = false;
                    try {
                      authenticated = await auth.authenticateWithBiometrics(
                          localizedReason:
                              "Scan your finger print to authenticate",
                          useErrorDialogs: true,
                          stickyAuth: false);
                    } on PlatformException catch (e) {
                      print(e);
                    }
                    if (!mounted) return;

                    setState(() {});
                    if (authenticated) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) =>
                              isFirstime ? Selectmonth() : Loginpage()));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Color(0xFF9798CB),
                        side: BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          "Use fingerprint ",
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
