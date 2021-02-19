import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/Homepage.dart';
import 'package:flutter_app/App/Sign_in/sign_in%20page.dart';
import 'package:http/http.dart'as http;
import 'dart:developer';
import 'Login.dart';
import 'dart:convert';
Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());


Future<Album> fetchAlbum(String state,String district, String block, String colony,String village,String fullName,String yearOfStart, String belAdded,String habitation,String unHabitation,String pin) async {
  try {
    log('testing......');
    final http.Response token =
    await http.post(
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
    var raw =jsonEncode({"fieldData":{"State": state, "District": district,"Block": block,"Colony":colony, "Village": village, "Gathering_Status": "MC","New_BPT": 8, "Bel_Added":belAdded,"Reporting_Month": "January", "Reporting_Year": 2020,"Un_Habitation": unHabitation,"Average_Attendance": 14,"Year_of_Start": yearOfStart,"Pin": 767016,"Habitation": habitation,"Town": "","Full_Name": fullName,"fk_Contact_Id": "9726E1502","fk_Report_id_New": "E53C3C8771" }});
    var request = http.Request('POST', Uri.parse('https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records'));
    //request.body = '''{\n"fieldData": {\n  "State": "ODISHA88",\n "District": "Sonapur",\n "Block": "Tarbha",\n "Village": "Baghiamunda",\n "Gathering_Status": "MC",\n "New_BPT": 8,\n  "Reporting_Month": "January",\n   "Reporting_Year": 2020,\n  "Un_Habitation": "",\n "Average_Attendance": 14,\n   "Year_of_Start": 2016,\n "Pin": 767016,\n "Habitation": "Harijan Pada",\n "Town": "",\n "Full_Name": "Bhagaban Patra",\n  "fk_Contact_Id": "9726E1502",\n  "fk_Report_id_New": "E53C3C8771"\n  \n   }\n}''';
    request.body=raw;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200){
      var res = await response.stream.bytesToString();
      print(res);
      return albumFromJson(request.body);
    }

    else {
      print(response.reasonPhrase);
    }
  }
  catch (e) {
    print(e);
    return null;
  }
}
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

  String state;
  String district;
  String block;
  String colony;
  String village;
  String gatheringStatus;
  int newBpt;
  String reportingMonth;
  int reportingYear;
  String unHabitation;
  int averageAttendance;
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
    colony:json["Colony"],
    village: json["Village"],
    gatheringStatus: json["Gathering_Status"],
    newBpt: json["New_BPT"],
    belAdded:json["Bel_Added"],
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
    "Colony":colony,
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
  Album  _user;

  final TextEditingController _Statecontroller = TextEditingController();
  final TextEditingController _districtcontroller = TextEditingController();
  final TextEditingController _blockcontroller = TextEditingController();
  final TextEditingController _villagecontroller = TextEditingController();
  final TextEditingController _Fullnamecontroller = TextEditingController();
  final TextEditingController _yearOfStartcontroller = TextEditingController();
  final TextEditingController _colonycontroller = TextEditingController();
  final TextEditingController _belAddedcontroller = TextEditingController();
  final TextEditingController _habitationcontroller = TextEditingController();
  final TextEditingController _unhabitationcontroller = TextEditingController();
  final TextEditingController _pincontroller = TextEditingController();
  Future<Album> futureAlbum;
  @override
  void initState() {
    super.initState();
    //futureAlbum = fetchAlbum();
    //futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Add New'),

        ),
        body: Container(

            color: Colors.blueGrey,
            child:Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: new TextField(
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Type',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _Fullnamecontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Name',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _yearOfStartcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Year of start',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(

                      child: new TextField(
                        controller: _Statecontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'State',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _districtcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'District',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _blockcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Block',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _colonycontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Colony',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _villagecontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Village',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _habitationcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Habitation',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _unhabitationcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'UnHabitation',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _pincontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Pin',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        controller: _belAddedcontroller,
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Total Believers',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Avg.Attendance',
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: new TextField(
                        decoration:new InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),

                          hintText: 'Total Baptism',
                        ),
                      ),
                    ),
                    _user == null ? Container() :
                    Text("The user ${_user.fieldData.state}"),

                    GestureDetector(
                      onTap: ()async{
                        final String state = _Statecontroller.text;
                        final String district = _districtcontroller.text;
                        final String block = _blockcontroller.text;
                        final String colony = _colonycontroller.text;
                        final String village = _villagecontroller.text;
                        final String fullname = _Fullnamecontroller.text;
                        final String yearOfStart = _yearOfStartcontroller.text;
                        final String belAdded = _belAddedcontroller.text;
                        final String habitation = _habitationcontroller.text;
                        final String unhabitation = _unhabitationcontroller.text;
                        final String pin = _pincontroller.text;
                        final Album user = await fetchAlbum(state,district,block,colony,village,fullname,yearOfStart,belAdded,habitation,unhabitation,pin);
                        setState(() {
                          _user = user;
                        });

                      },
                      child: PrimaryButton(
                        btnText: "Save",
                      ),
                    ),
                  ],
                ),
              ),
            ) ));
  }
}