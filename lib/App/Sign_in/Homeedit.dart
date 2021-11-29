import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/App/models/response_model.dart' as resm;
import 'package:flutter_app/App/models/response_model.dart';
import 'package:flutter_app/App/services/nonetwork_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

/* Future<resm.Welcome> fetchAlbum() async {
  Welcome x;
  try {
    log('testing......');

    final http.Response token = await http.post(
      'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
      },
    );
    log('token:$token');

    Map<String, dynamic> responsetoken = jsonDecode(token.body);
    var result = responsetoken['response'];
    var tokenresult = result['token'];

    log('result...in field:$responsetoken');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tokenresult'
    };
    var raw = jsonEncode({
      "query": [
        {
          "Reporting_Month": prefs.getString('AppMonth'),
          "Reporting_Year": prefs.getString('AppYear'),
          "fk_Contact_Id": prefs.getString('contact')
        }
      ]
    });
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app_dis/_find'));
    request.body = raw;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      print(res);
      // return resm.Welcome.fromJson(json.decode(res));
      x = resm.welcomeFromJson(res);
      //return x;
    } else {
      print(response.reasonPhrase);
    }
    return x;
  } catch (e) {
    print(e);
    return null;
  }
} */

class Homeedit extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;
  final resm.FieldData fieldData;

  const Homeedit(
      {Key key,
      @required this.selectedMonth,
      this.selectedYear,
      @required @required this.fieldData})
      : super(key: key);
  @override
  _HomeeditState createState() => _HomeeditState();
}

class _HomeeditState extends State<Homeedit> {
  String dropdownValue;

  SharedPreferences preferences;
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  void initState() {
    super.initState();
    print(widget.fieldData.team);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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

    Future<bool> postForm() async {
      if (_formKey.currentState.saveAndValidate()) {
        String postUrl =
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records';
        var formData = _formKey.currentState.value;
        var raw = jsonEncode({
          "fieldData": {
            "State": formData['state'],
            "District": formData['district'],
            "Block": formData['block'],
            "Colony": formData['colony'],
            "Village": formData['village'],
            "Gathering_Status": formData['gatering_status'],
            "New_BPT": widget.fieldData.newBpt,
            "Bel_Added": widget.fieldData.belAdded,
            "Reporting_Month": widget.selectedMonth?.trim(),
            "Reporting_Year": widget.selectedYear,
            "Un_Habitation": formData['unHabitation'],
            "Average_Attendance": widget.fieldData.averageAttendance,
            "Year_of_Start": formData['yearOfStart'],
            "Pin": formData['pin'],
            "Habitation": formData['habitation'],
            "Town": "",
            "Full_Name": formData['name'],
            "fk_Contact_Id": widget.fieldData.fkContactId,
            "fk_Report_id_New": "",
            "Team": widget.fieldData.team
          }
        });
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
          var request = http.Request('POST', Uri.parse('$postUrl'));

          log(raw);
          request.body = raw;
          request.headers.addAll(headers);
          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var res = await response.stream.bytesToString();
            //var responses =res
            // print(responses);
            var x = json.decode(res);
            print(x);
            final prefs = await SharedPreferences.getInstance();
            final String recordId = x['response']['recordId'];
            prefs.setString('recordId', recordId);
            print("Sent");

            await showDialogOfSuccess("Successfully Updated");
            Navigator.of(context).pop();
          } else {
            print(response.reasonPhrase);
            // await showDialogOfSuccess("Successfully Updated");

          }
        } on SocketException catch (e) {
          var noNetwork = NoNetworkService();
          noNetwork.storeFailedPostRequestData(raw, postUrl);
          log("Save to local device");

          _formKey.currentState.reset();
          await showDialogOfSuccess("Successfully stored ");
          Navigator.of(context).pop();
          print(e);
        }
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      return (Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor: Color(0xFF9798CB)),
        body: SingleChildScrollView(
          child: Container(
            height: height * 1.4,
            width: width,
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
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: height * 0.01),
                  Container(
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/pro.png'),
                      radius: 40,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Container(
                    width: width * 0.2,
                    padding: EdgeInsets.all(0.1),
                    child: FormBuilderDropdown<String>(
                      name: "gatering_status",
                      initialValue: "${widget.fieldData.gatheringStatus}",
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['MC', 'PC', 'HC', 'AV', 'AC', 'Closed']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                      child: DataTable(
                    dataRowColor: MaterialStateProperty.all(Colors.transparent),
                    headingRowHeight: 0.0,
                    dataRowHeight: height * 0.09,
                    rows: [
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Name:-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: "name",
                            validator: FormBuilderValidators.required(context),
                            initialValue: "${widget.fieldData.fullName}",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Year of Start :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: "yearOfStart",
                            validator: FormBuilderValidators.required(context),
                            initialValue: "${widget.fieldData.yearOfStart}",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "State :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'state',
                            validator: FormBuilderValidators.required(context),
                            initialValue: "${widget.fieldData.state}",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "District :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'district',
                            initialValue: "${widget.fieldData.district}",
                            validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Block :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'block',
                            initialValue: "    ${widget.fieldData.block}",
                            validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Colony :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'colony',
                            //validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            initialValue: "${widget.fieldData.colony}",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Village :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'village',
                            // validator: FormBuilderValidators.required(context),
                            initialValue: "${widget.fieldData.village}",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Habitation :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'habitation',
                            initialValue: "${widget.fieldData.habitation}",
                            // validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Un-Habitation :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'unHabitation',
                            //validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            initialValue: "${widget.fieldData.unHabitation}",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            "Pin :-",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FormBuilderTextField(
                            name: 'pin',
                            validator: FormBuilderValidators.required(context),
                            initialValue: "${widget.fieldData.pin}",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: width / 28,
                              ),
                            ),
                          ),
                        ),
                      ])
                    ],
                    columns: [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text(""))
                    ],
                  )),
                  SizedBox(height: height * 0.01),
                  // Container(
                  //   //  height: height * 6,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       TextInputWidget(
                  //         labeltext: "Total Believers",
                  //         name: "Bel_Added",
                  //         prevData: "${widget.fieldData.belAdded}",
                  //         height: height,
                  //         width: width,
                  //       ),
                  //       SizedBox(width: 10),
                  //       TextInputWidget(
                  //         labeltext: "Total Baptism",
                  //         name: "New_BPT",
                  //         prevData: "${widget.fieldData.newBpt}",
                  //         height: height,
                  //         width: width,
                  //       ),
                  //       SizedBox(width: 10),
                  //       TextInputWidget(
                  //         labeltext: "Average Attendance",
                  //         name: "Average_Attendance",
                  //         prevData: "${widget.fieldData.averageAttendance}",
                  //         height: height,
                  //         width: width,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    child: ElevatedButton(
                        child: Text(
                          'Save',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: width / 22,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await postForm();
                        }
                        //controller.jumpToPage(15);

                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ));
    });
  }
}

class TextInputWidget extends StatelessWidget {
  final String prevData;

  final String labeltext;
  final String name;
  final double height;
  final double width;
  const TextInputWidget({
    Key key,
    this.prevData,
    this.labeltext,
    this.name,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            prevData,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            width: width / 4,
            height: height / 15,
            child: new FormBuilderTextField(
              name: name,
              autocorrect: true,
              validator: FormBuilderValidators.required(context),
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: width / 35),
                labelText: labeltext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
