import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Homepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'Login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());

class Album {
  Album({
    this.fieldData,
  });

  FieldData fieldData;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        fieldData: FieldData.fromJson(json["fieldData"]),
      );

  Map<String, dynamic> toJson() => {
        "fieldData": fieldData.toJson(),
      };
}

class FieldData {
  FieldData({
    this.type,
    this.state,
    this.district,
    this.block,
    this.colony,
    this.village,
    this.gatheringStatus,
    this.newBpt,
    this.reportingMonth,
    this.reportingYear,
    this.unHabitation,
    this.averageAttendance,
    this.belAdded,
    this.yearOfStart,
    this.pin,
    this.habitation,
    this.town,
    this.fullName,
    this.fkContactId,
    this.fkReportIdNew,
  });
  String type;
  String state;
  String district;
  String block;
  String colony;
  String village;
  String gatheringStatus;
  String newBpt;
  String reportingMonth;
  String reportingYear;
  String unHabitation;
  String averageAttendance;
  String belAdded;
  String yearOfStart;
  String pin;
  String habitation;
  String town;
  String fullName;
  String fkContactId;
  String fkReportIdNew;

  factory FieldData.fromJson(Map<String, dynamic> json) => FieldData(
        state: json["State"],
        district: json["District"],
        block: json["Block"],
        colony: json["Colony"],
        village: json["Village"],
        gatheringStatus: json["Gathering_Status"],
        newBpt: json["New_BPT"],
        belAdded: json["Bel_Added"],
        reportingMonth: json["Reporting_Month"],
        reportingYear: json["Reporting_Year"],
        unHabitation: json["Un_Habitation"],
        averageAttendance: json["Average_Attendance"],
        yearOfStart: json["Year_of_Start"],
        pin: json["Pin"],
        habitation: json["Habitation"],
        town: json["Town"],
        fullName: json["Full_Name"],
        fkContactId: json["fk_Contact_Id"],
        fkReportIdNew: json["fk_Report_id_New"],
      );

  Map<String, dynamic> toJson() => {
        "State": state,
        "District": district,
        "Block": block,
        "Colony": colony,
        "Village": village,
        "Gathering_Status": gatheringStatus,
        "New_BPT": newBpt,
        "Bel_Added": belAdded,
        "Reporting_Month": reportingMonth,
        "Reporting_Year": reportingYear,
        "Un_Habitation": unHabitation,
        "Average_Attendance": averageAttendance,
        "Year_of_Start": yearOfStart,
        "Pin": pin,
        "Habitation": habitation,
        "Town": town,
        "Full_Name": fullName,
        "fk_Contact_Id": fkContactId,
        "fk_Report_id_New": fkReportIdNew,
      };
}

class Addnewpage extends StatefulWidget {
  @override
  _AddnewpageState createState() => _AddnewpageState();
}

class _AddnewpageState extends State<Addnewpage> {
  String dropdownValue = 'MC';
  Album _user;
  final TextEditingController _typecontroller = TextEditingController();
  final TextEditingController _avgcontroller = TextEditingController();
  final TextEditingController _newbptcontroller = TextEditingController();
  final TextEditingController _Statecontroller = TextEditingController();
  final TextEditingController _districtcontroller = TextEditingController();
  final TextEditingController _blockcontroller = TextEditingController();
  final TextEditingController _villagecontroller = TextEditingController();
  final TextEditingController _Fullnamecontroller = TextEditingController();
  final TextEditingController _yearOfStartcontroller = TextEditingController();
  final TextEditingController _monthOfStartcontroller = TextEditingController();
  final TextEditingController _colonycontroller = TextEditingController();
  final TextEditingController _belAddedcontroller = TextEditingController();
  final TextEditingController _habitationcontroller = TextEditingController();
  final TextEditingController _unhabitationcontroller = TextEditingController();
  final TextEditingController _pincontroller = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  Future<Album> futureAlbum;
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
    Future<Album> fetchAlbum(
      String avg,
      String newBpt,
      String type,
      String state,
      String district,
      String block,
      String colony,
      String village,
      String fullName,
      String yearOfStart,
      String belAdded,
      String habitation,
      String monthOfStart,
      String unHabitation,
      String pin,
    ) async {
      if (_formKey.currentState.saveAndValidate()) {
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
          final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('AppMonth', Appmonth);
          //await prefs.setString("AppYear", Appyear);
          var contact = await prefs.getString('contact');
          log("get cant,,,,$contact");
          var raw = jsonEncode({
            "fieldData": {
              "State": state,
              "District": district,
              "Block": block,
              "Colony": colony,
              "Village": village,
              "Gathering_Status": dropdownValue,
              "New_BPT": newBpt,
              "Bel_Added": belAdded,
              "Reporting_Month": monthOfStart,
              "Reporting_Year": yearOfStart,
              "Un_Habitation": unHabitation,
              "Average_Attendance": avg,
              "Year_of_Start": yearOfStart,
              "Pin": pin,
              "Habitation": habitation,
              "Town": "",
              "Full_Name": fullName,
              "fk_Contact_Id": contact,
            }
          });
          var request = http.Request(
              'POST',
              Uri.parse(
                  'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records'));

          //request.body = '''{\n"fieldData": {\n  "State": "ODISHA88",\n "District": "Sonapur",\n "Block": "Tarbha",\n "Village": "Baghiamunda",\n "Gathering_Status": "MC",\n "New_BPT": 8,\n  "Reporting_Month": "January",\n   "Reporting_Year": 2020,\n  "Un_Habitation": "",\n "Average_Attendance": 14,\n   "Year_of_Start": 2016,\n "Pin": 767016,\n "Habitation": "Harijan Pada",\n "Town": "",\n "Full_Name": "Bhagaban Patra",\n  "fk_Contact_Id": "9726E1502",\n  "fk_Report_id_New": "E53C3C8771"\n  \n   }\n}''';
          request.body = raw;
          request.headers.addAll(headers);
          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var res = await response.stream.bytesToString();
            print(res);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text("Form Submitted Successfully !!"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"))
                ],
              ),
            );
            return albumFromJson(request.body);
          } else {
            print(response.reasonPhrase);
          }
        } catch (e) {
          print(e);
          return null;
        }
      }
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                                  validator:
                                      FormBuilderValidators.required(context),
                                  controller: _Fullnamecontroller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Name",
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
                                  controller: _Statecontroller,
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
                                  controller: _districtcontroller,
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
                                  controller: _blockcontroller,
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
                                  controller: _colonycontroller,
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
                                  controller: _villagecontroller,
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
                                  controller: _habitationcontroller,
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
                                  controller: _unhabitationcontroller,
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
                                  controller: _pincontroller,
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
                                  controller: _belAddedcontroller,
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
                                  controller: _avgcontroller,
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
                                  controller: _newbptcontroller,
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
                              width: width / 3.5,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final String newBpt = _newbptcontroller.text;
                                  final String avg = _avgcontroller.text;
                                  final String type = _typecontroller.text;
                                  final String state = _Statecontroller.text;
                                  final String district =
                                      _districtcontroller.text;
                                  final String block = _blockcontroller.text;
                                  final String colony = _colonycontroller.text;
                                  final String village =
                                      _villagecontroller.text;
                                  final String fullname =
                                      _Fullnamecontroller.text;
                                  final String yearOfStart =
                                      _yearOfStartcontroller.text;
                                  final String monthOfStart =
                                      _monthOfStartcontroller.text;
                                  final String belAdded =
                                      _belAddedcontroller.text;
                                  final String habitation =
                                      _habitationcontroller.text;
                                  final String unhabitation =
                                      _unhabitationcontroller.text;
                                  final String pin = _pincontroller.text;
                                  final Album user = await fetchAlbum(
                                      avg,
                                      newBpt,
                                      type,
                                      state,
                                      district,
                                      block,
                                      colony,
                                      village,
                                      fullname,
                                      yearOfStart,
                                      belAdded,
                                      habitation,
                                      monthOfStart,
                                      unhabitation,
                                      pin);
                                  setState(() {
                                    _user = user;
                                  });
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
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )));
  }
}
