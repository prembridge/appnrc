import 'package:flutter/material.dart';

import 'App/Sign_in/sign_in page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: SignInpage(),
        ),
      ),

    );
  }
}
