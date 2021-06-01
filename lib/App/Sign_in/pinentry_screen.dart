import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/App/Sign_in/Homepage1.dart';
import 'package:flutter_app/App/Sign_in/Login.dart';
//import 'package:flutter_app/App/Sign_in/Homepage.dart';

import 'package:flutter_lock_screen/flutter_lock_screen.dart';
//import 'Homepage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'selectmonth.dart';

class PinEntryScreen extends StatefulWidget {
  final Widget afterScreen;
  PinEntryScreen({Key key, this.title, this.afterScreen}) : super(key: key);

  final String title;

  @override
  _passcodepageState createState() => new _passcodepageState();
}

class _passcodepageState extends State<PinEntryScreen> {
  bool isFingerprint;
  bool isFirstime;
  bool isPinSet;
  var myPass;
  @override
  void initState() {
    super.initState();
    getAppStaate();
  }

  Future<void> getAppStaate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pin = prefs.getString('pin');
    var pinO = jsonDecode(pin);
    setState(() {
      isFirstime = prefs.getBool("isFirstime");
      myPass = pinO["pin"];
    });
  }

  Future<Null> biometrics() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    if (authenticated) {
      setState(() {
        isFingerprint = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return myPass != null
        ? LockScreen(
            title: " Confirm PIN",
            passLength: myPass.length,
            // fingerPrintImage: "assets/images/fin.png",
            bgImage: "assets/images/Black.png",
            showFingerPass: false,
            //bgImage:false,
            numColor: Colors.blue,
            fingerVerify: false,
            borderColor: Colors.white,
            showWrongPassDialog: true,
            wrongPassContent: "PIN Mismatch Please try again.",
            wrongPassTitle: "Opps!",
            wrongPassCancelButtonText: "Cancel",
            passCodeVerify: (passcode) async {
              for (int i = 0; i < myPass.length; i++) {
                if (passcode[i] != myPass[i]) {
                  return false;
                }
              }

              return true;
            },
            onSuccess: () {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  maintainState: true,
                  builder: (BuildContext context) {
                    return LifecycleWatcher(
                      afterCoorectPin: widget.afterScreen,
                    );
                  }));
            })
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

class LifecycleWatcher extends StatefulWidget {
  final Widget afterCoorectPin;
  LifecycleWatcher({this.afterCoorectPin});
  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  bool wasinactive = false;
  int count = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  Widget build(BuildContext context) {
    log(_lastLifecycleState.toString());
    /*  Widget child = Container();
    if (_lastLifecycleState != null) {
      print(_lastLifecycleState);
      switch (_lastLifecycleState) {
        case AppLifecycleState.resumed:
          child = PinEntryScreen(
            afterScreen: widget.afterCoorectPin,
          );
          break;
        case AppLifecycleState.inactive:
          child = Container(color: Colors.green);
          break;
        case AppLifecycleState.paused:
          child = Container(color: Colors.orange);
          break;
        case AppLifecycleState.detached:
          child = Container(color: Colors.blue);
          break;
      }
      return child;
    } */
    if (_lastLifecycleState == AppLifecycleState.inactive) {
      setState(() {
        wasinactive = true;
      });
    }
    if (_lastLifecycleState == AppLifecycleState.paused) {
      setState(() {
        wasinactive = false;
      });
    }
    if (_lastLifecycleState == AppLifecycleState.resumed && !wasinactive) {
      setState(() {
        wasinactive = false;
        count = count + 1;
      });
      if (count == 1) {
        return PinEntryScreen(
          afterScreen: widget.afterCoorectPin,
        );
      }
      return widget.afterCoorectPin;
    }

    return widget.afterCoorectPin;
  }
}
