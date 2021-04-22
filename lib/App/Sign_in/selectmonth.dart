import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'Homepage1.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page2.dart';

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
    // {
    //   "dates":[{"year":2021,"month":[""]}]
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Select Month and year",
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
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
                  Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Please select month & "
                            "year to enter current  report",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20.0),
                              child: DropdownButton(
                                value: _selectedYearValue,
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
                                hint: Text(
                                  "Select Year",
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              padding: EdgeInsets.all(20.0),
                              child: DropdownButton(
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
                                      fontWeight: FontWeight.bold,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homepage(
                                          selectedMonth: _selectedMonthValue,
                                          selectedYear: _selectedYearValue,
                                        )));
                          },
                          child: Visibility(
                            visible: _selectedMonthValue != null &&
                                _selectedYearValue != null,
                            child: PrimaryButton(
                              btnText: "Ok",
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage2(
                                        // selectedMonth: _selectedMonthValue,
                                        // selectedYear: _selectedYearValue,
                                        )));
                          },
                          child: Text(
                            "select media",
                          ),
                        ),
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

// class DateMonthDropDown {
//   String year;
//   List<String> month;
//
//   DateMonthDropDown({this.year, this.month});
//
//   DateMonthDropDown.fromJson(Map<String, dynamic> json) {
//     year = json['year'];
//     month = json['month'].cast<String>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['year'] = this.year;
//     data['month'] = this.month;
//     return data;
//   }
// }
