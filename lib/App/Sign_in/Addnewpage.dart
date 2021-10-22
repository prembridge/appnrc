import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Homepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:flutter_app/App/services/nonetwork_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Addnewpage extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;

  const Addnewpage({Key key, this.selectedMonth, this.selectedYear})
      : super(key: key);

  @override
  _AddnewpageState createState() => _AddnewpageState();
}

class _AddnewpageState extends State<Addnewpage> {
  String dropdownValue = 'MC';
  //Album _user;

  final TextEditingController _yearOfStartcontroller = TextEditingController();
  final TextEditingController _monthOfStartcontroller = TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>();
  //Future<Album> futureAlbum;
  String selMonth;
  String selYear;
  @override
  void initState() {
    super.initState();
    //futureAlbum = fetchAlbum();
    //futureAlbum = fetchAlbum();
    getYearMonth();
  }

  void getYearMonth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selMonth = prefs.getString('selMonth');
      selYear = prefs.getString('selYear');
    });
    _yearOfStartcontroller.text = selYear;
    _monthOfStartcontroller.text = selMonth;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    Future<bool> showDialogOfSuccess(String msg) async {
      return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("$msg"),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("OK"))
          ],
        ),
      );
    }

    Future<void> postForm() async {
      if (_formKey.currentState.saveAndValidate()) {
        final prefs = await SharedPreferences.getInstance();
        var contact = prefs.getString('contact');
        String postUrl =
            "https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records";
        final formData = _formKey.currentState.value;
        var raw = jsonEncode({
          "fieldData": {
            "State": formData['state'],
            "District": formData['district'],
            "Block": formData['block'],
            "Colony": formData['colony'],
            "Village": formData['village'],
            "Gathering_Status": dropdownValue,
            "New_BPT": formData['newBst'],
            "Bel_Added": formData['BelAded'],
            "Reporting_Month": widget.selectedMonth?.trim(),
            "Reporting_Year": widget.selectedYear,
            "Un_Habitation": formData['unhabitation'],
            "Average_Attendance": formData['averageAttendance'],
            "Year_of_Start": formData['yearOfStart'],
            "Pin": formData['pin'],
            "Habitation": formData['habitation'],
            "Town": "",
            "Full_Name": formData['Full_Name'],
            "fk_Contact_Id": contact,
          }
        });
        log(raw);
        try {
          log('testing......');
          final http.Response token = await http.post(
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
            },
          );
          log('token...:$token');

          Map<String, dynamic> responsetoke = jsonDecode(token.body);
          var result = responsetoke['response'];
          var tokenresult = result['token'];

          log('result...in field:$tokenresult');

          var headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenresult'
          };

          // await prefs.setString('AppMonth', Appmonth);
          //await prefs.setString("AppYear", Appyear);

          log("get cant,,,,$contact");

          var request = http.Request('POST', Uri.parse('$postUrl'));

          /*   request.body = '''{\n"fieldData": {\n  
              "State": "ODISHA88",\n 
              "District": "Sonapur",\n 
              "Block": "Tarbha",\n 
              "Village": "Baghiamunda",
              \n "Gathering_Status": "MC",
              \n "New_BPT": 8,\n 
               "Reporting_Month": "January",\n
                  "Reporting_Year": 2020,\n  
                  "Un_Habitation": "",\n 
                  "Average_Attendance": 14,\n  
                   "Year_of_Start": 2016,\n 
                   "Pin": 767016,\n
                    "Habitation": "Harijan Pada",\n 
                    "Town": "",\n 
                    "Full_Name": "Bhagaban Patra",\n 
                     "fk_Contact_Id": "9726E1502"\n  
                     }}'''; */
          request.body = raw;
          request.headers.addAll(headers);
          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var res = await response.stream.bytesToString();
            print(res);

            await showDialogOfSuccess("Successfully uploaded");
            _formKey.currentState.reset();
          } else {
            print(response.reasonPhrase);
          }
        } on SocketException catch (e) {
          var noNetwork = NoNetworkService();
          noNetwork.storeFailedPostRequestData(raw, postUrl);
          log("Save to local device");

          _formKey.currentState.reset();
          await showDialogOfSuccess("Successfully stored Locally");
          Navigator.of(context).pop();
          print(e);
        }
      }
    }

    return Scaffold(
//resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Center(child: Text('Add New')),
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
            child: selMonth != null && selYear != null
                ? Scrollbar(
                    child: Container(
                      height: height * 120,
                      child: SingleChildScrollView(
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    alignment: Alignment.bottomLeft,
                                    child: DropdownButton<String>(
                                      value: dropdownValue,
                                      underline: Container(),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          dropdownValue = newValue;
                                        });
                                      },
                                      items: <String>[
                                        'MC',
                                        'PC',
                                        'HC',
                                        'AV',
                                        'AC'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    )
                                    // child: new FormBuilderTextField(
                                    //   controller: _typecontroller,
                                    //   validator:
                                    //       FormBuilderValidators.required(context),
                                    //   decoration: InputDecoration(
                                    //     border: OutlineInputBorder(),
                                    //     labelText: "Type",
                                    //   ),
                                    //
                                    //   //hintText: 'Type',
                                    // ),
                                    ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    name: "Full_Name",
                                    validator:
                                        FormBuilderValidators.required(context),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Full Name",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    controller: _yearOfStartcontroller,
                                    name: 'yearOfStart',
                                    //readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Year of Start",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    // readOnly: true,
                                    enabled: false,
                                    controller: _monthOfStartcontroller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Month of Start",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    name: 'state',
                                    validator:
                                        FormBuilderValidators.required(context),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "State",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "district",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "District",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "block",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Block",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "colony",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Colony",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "village",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Village",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "habitation",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Habitation",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "unhabitation",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "UnHabitation",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "pin",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "PIN",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "BelAded",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Total Believers",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "averageAttendance",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "AverageAttendance",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: new FormBuilderTextField(
                                    validator:
                                        FormBuilderValidators.required(context),
                                    name: "newBst",
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Total Baptism",
                                    ),
                                  ),
                                ),
                              ),
                              /*   _user == null
                                  ? Container()
                                  : Text("The user ${_user.fieldData.state}"), */
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                width: width / 2,
                                height: height / 9,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await postForm();
                                  },
                                  child: Text(
                                    "Save",
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )));
  }
}
