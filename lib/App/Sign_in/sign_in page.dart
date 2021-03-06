import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:keyboard_visibility/keyboard_visibility.dart';
//import 'Homepage.dart';
import 'Registionpage.dart';

class SignInpage extends StatefulWidget {
  @override
  _SignInpageState createState() => _SignInpageState();
}

class _SignInpageState extends State<SignInpage> {
  int _pageState = 0;
  var _backgroundcolor = Colors.white;
  double _loginWidth = 0;
  double _loginHight = 0;
  double _regiserHight = 0;
  double _loginYoffset = 0;
  double _loginXoffset = 0;
  double _RegYoffset = 0;
  double windowWidth = 0;
  double windowHight = 0;
  double headingTop = 100;
  double _loginOpacity = 1;
  bool _keyboardVisibility = false;
  @override
  // void initState() {
  //   super.initState();
  //   KeyboardVisibilityNotification().addNewListener(
  //     onChange: (bool visible) {
  //       setState(() {
  //         _keyboardVisibility= visible;
  //       });
  //     },
  //   );

  // }
  @override
  Widget build(BuildContext context) {
    windowHight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    _loginHight = windowHight - 250;
    _regiserHight = windowHight - 250;
    switch (_pageState) {
      case 0:
        _backgroundcolor = Colors.white;
        _loginYoffset = windowHight;
        _loginXoffset = 0;
        _loginWidth = windowWidth;
        _RegYoffset = windowHight;
        _loginOpacity = 1;
        headingTop = 100;
        break;
      case 1:
        _backgroundcolor = Colors.red;
        _loginYoffset = _keyboardVisibility ? 40 : 270;
        _loginHight = _keyboardVisibility ? windowHight : windowHight - 270;
        _loginWidth = windowWidth;
        _loginXoffset = 0;
        _RegYoffset = windowHight;
        _loginOpacity = 1;
        headingTop = 90;
        break;
      case 2:
        _backgroundcolor = Colors.red;
        _loginYoffset = 240;
        _loginWidth = windowWidth - 40;
        _loginXoffset = 20;
        _loginHight = _keyboardVisibility ? windowHight : windowHight - 270;
        _loginYoffset = _keyboardVisibility ? 30 : 240;
        _RegYoffset = _keyboardVisibility ? 55 : 270;
        _regiserHight = _keyboardVisibility ? windowHight : windowHight - 270;
        _loginOpacity = 0.7;
        headingTop = 80;
    }
    return Stack(
      children: [
        AnimatedContainer(
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(milliseconds: 1000),
          color: _backgroundcolor,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _pageState = 0;
                  });
                },
                child: Container(
                  child: Column(children: <Widget>[
                    AnimatedContainer(
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: Duration(milliseconds: 1000),
                      margin: EdgeInsets.only(top: headingTop),
                      child: Text(
                        'N R C',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ]),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                // child: Image.asset('assets/images/cp.png'),
              ),
              Container(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_pageState != 0) {
                        _pageState = 0;
                      } else {
                        _pageState = 1;
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(32),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(50)),
                    child: Center(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Registionpage()));
                            });
                          },
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          padding: EdgeInsets.all(32),
          width: _loginWidth,
          height: _loginHight,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(milliseconds: 1000),
          transform: Matrix4.translationValues(_loginXoffset, _loginYoffset, 1),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(_loginOpacity),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      'Login To Continue ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  inputTextdata(
                    hint: 'MobileNum...',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  inputTextdata(
                    hint: 'Password..',
                  ),
                  inputTextdata(
                    hint: 'OTP',
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  GestureDetector(
                    // onTap: (){
                    //   Navigator.push(context,
                    //       MaterialPageRoute(builder: (context)=>Homepage())
                    //   );
                    // },
                    child: PrimaryButton(
                      btnText: "Ok",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pageState = 2;
                      });
                    },
                    child: Outlinebtn(
                      btnText: "Registration",
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        AnimatedContainer(
          height: _regiserHight,
          padding: EdgeInsets.all(32),
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(milliseconds: 1000),
          transform: Matrix4.translationValues(0, _RegYoffset, 1),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Registration.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  inputTextdata(
                    hint: 'MobileNum...',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  inputTextdata(
                    hint: 'Password.',
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  PrimaryButton(
                    btnText: 'Creat Account',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pageState = 1;
                      });
                    },
                    child: Outlinebtn(
                      btnText: "Back To Login",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class inputTextdata extends StatefulWidget {
  final String hint;
  inputTextdata({this.hint});
  @override
  _inputTextdataState createState() => _inputTextdataState();
}

class _inputTextdataState extends State<inputTextdata> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        children: <Widget>[
          Container(
            width: 80,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: InputBorder.none,
                hintText: widget.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  final String btnText;
  PrimaryButton({this.btnText});
  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueGrey, borderRadius: BorderRadius.circular(50)),
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          widget.btnText,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class Outlinebtn extends StatefulWidget {
  final String btnText;
  Outlinebtn({this.btnText});
  @override
  _OutlinebtnState createState() => _OutlinebtnState();
}

class _OutlinebtnState extends State<Outlinebtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50)),
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          widget.btnText,
          style: TextStyle(color: Colors.blueGrey, fontSize: 20),
        ),
      ),
    );
  }
}
