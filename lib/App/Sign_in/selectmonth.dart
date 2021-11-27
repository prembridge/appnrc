import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/App/Sign_in/pinentry_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'Homepage1.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page2.dart';
import './pinentry_screen.dart';

class Selectmonth extends StatefulWidget {
  @override
  _SelectmonthState createState() => _SelectmonthState();
}

class _SelectmonthState extends State<Selectmonth> {
  //Future<Album> futureAlbum;
  //int _value = 1;
  String _email = '';
  String _monthYear = '';
  Map<String, dynamic> ym;
  List<String> months = [];
  List<String> years = [];
  String _selectedMonthValue;
  String _selectedYearValue;
  @override
  void initState() {
    // TODO: implement initState
    _loadCounter();
    super.initState();
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //var value = prefs.getString('AppMonth');
    //print("Appmonth..$value");

    await prefs.setBool("isFirstime", false);
    setState(() {
      _email = (prefs.getString('AppMonth'));

      _monthYear = (prefs.getString('Month_year_list'));
      print("month$_monthYear");
    });
    splitYearsAndMonths();
  }

  void splitYearsAndMonths() {
    var x = _monthYear.split(",");
    List<String> m = [];
    List<String> y = [];
    x.forEach((e) {
      m.add(e.split("||").last);
      y.add(e.split("||").first);
    });
    ym = Map.fromIterables(y, m);
    years.addAll(y);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // {
    //   "dates":[{"year":2021,"month":[""]}]
    // }
    return Scaffold(
      appBar: AppBar(
        //leading: Container(),
        centerTitle: true,
        title: Text(
          " Add Report",
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
        backgroundColor: Color(0xFF9798CB),
      ),
      body: years.isNotEmpty
          ? Container(
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: height / 5),
                  Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            " Select Month & " "Year ",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(width / 30.0),
                              margin: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 10.0),
                              color: Colors.white,
                              child: DropdownButton(
                                value: _selectedYearValue,
                                isDense: true,
                                items: years
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (val) async {
                                  setState(() {
                                    months = [];
                                    _selectedMonthValue = null;
                                  });
                                  String xx;
                                  ym.forEach((k, v) {
                                    if (val == k) {
                                      xx = v;
                                    }
                                  });
                                  months = xx.split("|");
                                  _selectedYearValue = val;
                                  setState(() {});

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('selYear', val);
                                },
                                hint: Center(
                                  child: Text(
                                    "Select Year",
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //SizedBox(width: 5),
                            Container(
                              padding: EdgeInsets.all(width / 30.0),
                              margin: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 10.0),
                              color: Colors.white,
                              child: DropdownButton(
                                isDense: true,
                                value: _selectedMonthValue,
                                items: months
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  setState(() {
                                    _selectedMonthValue = value;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('selMonth', value);
                                },
                                hint: Text(
                                  "Select Month",
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
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
                  Container(
                    child: Column(
                      children: [
                        Visibility(
                          visible: _selectedMonthValue != null &&
                              _selectedYearValue != null,
                          child: Container(
                            height: height / 11,
                            // width: width / 3.8,
                            //color: Color(0xFF9798CB),
                            padding: EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              // style: ElevatedButton.styleFrom(
                              //   side:
                              //       BorderSide(color: Colors.black12, width: 1),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(30),
                              //   ),
                              // ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    maintainState: true,
                                    builder: (context) =>
                                        /* LifecycleWatcher(
                                      afterCoorectPin:  */
                                        Homepage(
                                      selectedMonth: _selectedMonthValue,
                                      selectedYear: _selectedYearValue,
                                      // ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Submit",
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: width / 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          width: width / 5,
                          height: width / 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(width / 60),
                              primary: Color(0xFFDDACD3).withOpacity(0.8),
                              elevation: 0.0,
                            ),
                            child: Image.asset(
                              'assets/images/im.png',
                              fit: BoxFit.fill,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    maintainState: true,
                                    builder: (context) =>
                                        /* LifecycleWatcher(
                                    afterCoorectPin: HomePage2(),
                                  ), */
                                        HomePage2()),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: height / 70),
                        Text(
                          "Add Media",
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
