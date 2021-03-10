import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/passcodesetpage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pinpage.dart';
import 'passcodepage.dart';

class selectpage extends StatefulWidget {
  @override
  _selectpageState createState() => _selectpageState();
}

class _selectpageState extends State<selectpage> {
  bool isPinSet;
  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isPinSet = prefs.getBool("isPinSet");
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
        title: Text('select page'),
      ),
      body: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  ' Login To Continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
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
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => passcodepage(),
                    ),
                  );
                },
                /* isPinSet == null || isPinSet
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => passcodepage(),
                          ),
                        );
                      }
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => passcodsetepage(),
                          ),
                        );
                      }, */
                child: PrimaryButton(
                  btnText: "Select passcode password",
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Pinpage()));
                },
                child: PrimaryButton(
                  btnText: "Select finger print to authenticate",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
