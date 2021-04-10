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

// try {
//   log('testing......');
//
//   final http.Response token =
//   await http.post(
//     'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
//     },
//
//   );
//   log('token:$token');
//
//   Map<String, dynamic> responsetoken = jsonDecode(token.body);
//   var result = responsetoken['response'];
//   var tokenresult = result['token'];
//
//   log('result...in field:$responsetoken');
//   final prefs = await SharedPreferences.getInstance();
//   //Return String
//   final stringValue = prefs.getString('AppMonth');
//   final appyear =prefs.getString('AppYear');
//   final contact =prefs.getString('contact');
//   print("appyear...$appyear");
//   print("value....:$stringValue");
//   print("contact...$contact");
//
//
//   var headers = {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $tokenresult'
//   };
//   var raw = jsonEncode({"query":[{"Reporting_Month":stringValue, "Reporting_Year":appyear, "fk_Contact_Id":contact}]});
//   var request = http.Request('POST', Uri.parse(
//       'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app_dis/_find'));
//   request.body =raw;
//  // '''{ "query":[{"Reporting_Month":"jan", "Reporting_Year":"2020", "fk_Contact_Id":"9726E1502"}]}''';
//   request.headers.addAll(headers);
//   http.StreamedResponse response = await request.send();
//   if (response.statusCode == 200) {
//     print(await response.stream.bytesToString());
//   }
//   else {
//     print(response.reasonPhrase);
//   }
//
// }
// catch (e) {
//   print(e);
//   return null;
// }

class Selectmonth extends StatefulWidget {
  @override
  _SelectmonthState createState() => _SelectmonthState();
}

class _SelectmonthState extends State<Selectmonth> {
  //Future<Album> futureAlbum;
  //int _value = 1;
  String _email = '';
  String _years = '';
  String _months = '';

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
      _years = (prefs.getString('app_dropdown_y_list'));
      _months = (prefs.getString('app_dropdown_m_list'));
    });
  }

  List<DropdownMenuItem<String>> monthsDropDownItems() {
    if (_months.contains(',')) {
      return _months
          .split(',')
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList();
    } else {
      return [
        DropdownMenuItem(
          value: _months,
          child: Text(_months),
        )
      ];
    }
  }

  List<DropdownMenuItem<String>> yearDropDownItems() {
    if (_years.contains(',')) {
      return _years
          .split(',')
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList();
    } else {
      return [
        DropdownMenuItem(
          value: _years,
          child: Text(_years),
        )
      ];
    }
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
      body: Container(
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
          children: [
            Container(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Please Select Month & "
                      "Year To Enter Current  report",
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
                          value: _selectedMonthValue,
                          items: monthsDropDownItems(),
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
                      SizedBox(
                        width: 40,
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: DropdownButton(
                          value: _selectedYearValue,
                          items: yearDropDownItems(),
                          onChanged: (value) async {
                            setState(() {
                              _selectedYearValue = value;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('selYear', value);
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
                      )
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
          ],
        ),
      ),
    );
  }
}
