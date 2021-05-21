import 'package:flutter/material.dart';
import 'package:flutter_app/App/Sign_in/selectmonth.dart';
import 'package:flutter_app/App/models/response_model.dart' as resm;
import 'package:flutter_app/App/models/response_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Mediapage.dart';
import 'Savepage.dart';
import 'Addnewpage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter_swiper/flutter_swiper.dart';

int _count;

Future<resm.Welcome> fetchAlbum() async {
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
}

class MyStructure {
  final int id;
  final String text;
  MyStructure({this.id, this.text});
}

class MyWidget extends StatelessWidget {
  final MyStructure widgetStructure;
  MyWidget(this.widgetStructure);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green,
        child: Text('${widgetStructure.id} ${widgetStructure.text}'));
  }
}

class Homepage extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;

  const Homepage({Key key, this.selectedMonth, this.selectedYear})
      : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool viewVisible = false;
  bool showNext = false;
  SharedPreferences preferences;
  final _formKey = GlobalKey<FormBuilderState>();

  int pomodoro = 0;
  Welcome futureAlbum;

  PageController controller = PageController();
  int pageChanged = 0;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstime", false);

    futureAlbum = await fetchAlbum();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    void showDialogOfSuccess(bool isItLastPage) async {
      setState(() {
        showNext = true;
      });
      return await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Successfully Saved"),
          content: isItLastPage
              ? Container(
                  height: height / 10,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                            ' The report for the month of ${widget.selectedMonth}  ${widget.selectedYear} is uploaded '
                        ),
                      )
                    ],
                  ),
                )
              : null,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.nextPage(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.bounceIn);
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    }

    Future<void> postForm(Datum prevData, bool isItLastPage) async {
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
        git init
        if (_formKey.currentState.saveAndValidate()) {
          var x = _formKey.currentState.value;

          var request = http.Request(
              'POST',
              Uri.parse(
                  'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records'));
          var raw = jsonEncode({
            "fieldData": {
              "State": prevData.fieldData.state,
              "District": prevData.fieldData.district,
              "Block": prevData.fieldData.block,
              "Colony": prevData.fieldData.colony,
              "Village": prevData.fieldData.village,
              "Gathering_Status": prevData.fieldData.gatheringStatus,
              "New_BPT": x['New_BPT'],
              "Bel_Added": x['Bel_Added'],
              "Reporting_Month": widget.selectedMonth.trim(),
              "Reporting_Year": widget.selectedYear,
              "Un_Habitation": prevData.fieldData.unHabitation,
              "Average_Attendance": x['Average_Attendance'],
              "Year_of_Start": prevData.fieldData.yearOfStart,
              "Pin": prevData.fieldData.pin,
              "Habitation": prevData.fieldData.habitation,
              "Town": "",
              "Full_Name": prevData.fieldData.fullName,
              "fk_Contact_Id": prevData.fieldData.fkContactId,
              "fk_Report_id_New": ""
            }
          });
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
            showDialogOfSuccess(isItLastPage);
            _formKey.currentState.reset();
            setState(() {
              viewVisible = true;
            });
          } else {
            print(response.reasonPhrase);
          }
        }
      } catch (e) {
        print(e);
      }
    }

    Widget pageIndex() {
      if (controller.hasClients) {
        return Text(
            "${(controller.page + 1).toInt()} Of ${futureAlbum.response.dataInfo.foundCount}");
      }
      return Container(
        child: futureAlbum != null
            ? Text("1/${futureAlbum.response.dataInfo.foundCount}")
            : Container(),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      return (Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Center(
              // child: Text(
              //   'Homepage',
              //   style: GoogleFonts.montserrat(
              //     textStyle: TextStyle(
              //       color: Colors.white,
              //       fontSize: 25.0,
              //     ),
              //   ),
              // ),
            ),
            backgroundColor: Color(0xFF9798CB),
            actions: [
              IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    controller.previousPage(
                        curve: Curves.bounceOut,
                        duration: Duration(microseconds: 250));
                  }),
              Center(child: pageIndex()),
              IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: showNext
                      ? () {
                          print(pageChanged);

                          controller.jumpToPage(pageChanged);
                          controller.nextPage(
                              curve: Curves.bounceOut,
                              duration: Duration(microseconds: 250));
                        }
                      : null)
            ],
          ),
          body: futureAlbum != null
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
                  //color: Colors.blueGrey,
                  child: PageView(
                    pageSnapping: true,
                    controller: controller,
                    physics: showNext ? null : NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        pageChanged = index;
                        viewVisible = false;
                        showNext = false;
                      });
                    },
                    children:
                        futureAlbum.response.data.asMap().entries.map((e) {
                      bool isLastPage = futureAlbum.response.data
                              .indexOf(futureAlbum.response.data.last) ==
                          e.key;
                      return SingleChildScrollView(
                        child: Container(
                          height: height,
                          width: width,
                          child: Column(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'assets/images/pro.png'),
                                                radius: 40,
                                              ),
                                            )),
                                        Expanded(
                                          child: Container(
                                            width: width,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width: width / 4,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                Addnewpage(),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        "Add New",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 35,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      " Previous Report :-",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: width / 25,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  //SizedBox(width:5),
                                                  Text(
                                                    ('${e.value.fieldData.reportingMonth} ${e.value.fieldData.reportingYear} '),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 25,
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 9,
                                  child: Container(
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
                                      children: [
                                        Expanded(
                                            child: Container(
                                          padding: EdgeInsets.all(20.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Type :- ${e.value.fieldData.gatheringStatus}",
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: width / 28,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                "Name :- ${e.value.fieldData.fullName}",
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: width / 28,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                "Year Of Start :- ${e.value.fieldData.yearOfStart}",
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: width / 28,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                        Expanded(
                                            flex: 6,
                                            child: Container(
                                              // width: width,
                                              padding:
                                                  EdgeInsets.all(width / 25),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "State :- ${e.value.fieldData.state}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "District :- ${e.value.fieldData.district}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Block :- ${e.value.fieldData.block}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Colony :- ${e.value.fieldData.colony}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Village :- ${e.value.fieldData.village}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Habitation :- ${e.value.fieldData.habitation}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Un.Habitation :- ${e.value.fieldData.unHabitation}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "PIN :- ${e.value.fieldData.pin.toString()}",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width / 28,
                                                      ),
                                                    ),
                                                  ),
                                                  FormBuilder(
                                                    key: _formKey,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        TextInputWidget(
                                                          labeltext:
                                                              "Total Believers",
                                                          name: "Bel_Added",
                                                          prevData:
                                                              "${e.value.fieldData.belAdded}",
                                                          height: height,
                                                          width: width,
                                                        ),
                                                        SizedBox(width: 10),
                                                        TextInputWidget(
                                                          labeltext:
                                                              "Total Baptism",
                                                          name: "New_BPT",
                                                          prevData:
                                                              "${e.value.fieldData.newBpt}",
                                                          height: height,
                                                          width: width,
                                                        ),
                                                        SizedBox(width: 10),
                                                        TextInputWidget(
                                                          labeltext:
                                                              "Average Attendance",
                                                          name:
                                                              "Average_Attendance",
                                                          prevData:
                                                              "${e.value.fieldData.averageAttendance}",
                                                          height: height,
                                                          width: width,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: width,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            height: height /11,
                                            width: width /3,
                                            //padding: EdgeInsets.all(width / 40),
                                            child: ElevatedButton(
                                              child: Text(
                                                !isLastPage ? 'Next' : 'Save',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: width /25,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                postForm(e.value, isLastPage);
                                                // showDialogOfSuccess(true);
                                                //controller.jumpToPage(15);
                                              },
                                            ),
                                          ),
                                          // Visibility(
                                          //   visible: viewVisible,
                                          //   child: Container(
                                          //     padding: EdgeInsets.all(
                                          //         width / 40),
                                          //     child: ElevatedButton(
                                          //       onPressed: () {
                                          //         Navigator.push(
                                          //             context,
                                          //             MaterialPageRoute(
                                          //                 builder:
                                          //                     (context) =>
                                          //                         Mediapage()));
                                          //       },
                                          //       child: new Text(
                                          //         "MEDIA",
                                          //         style: GoogleFonts
                                          //             .montserrat(
                                          //           textStyle: TextStyle(
                                          //             color: Colors.black,
                                          //             fontSize:
                                          //                 width / 25,
                                          //
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // )
                                        ]),
                                  ))
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ))
              : Container(child: Center(child: CircularProgressIndicator()))));
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
