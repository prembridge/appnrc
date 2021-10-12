import 'package:flutter/material.dart';

import 'package:flutter_app/App/models/response_model.dart' as resm;
import 'package:flutter_app/App/models/response_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Homeedit.dart';
import 'Addnewpage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio/dio.dart';

Future<resm.Welcome> fetchAlbum() async {
  var dio = Dio();
  dio.interceptors.add(DioCacheManager(
    CacheConfig(
      baseUrl: "http://nrcoperations.co.in",
      defaultMaxStale: Duration(days: 10),
    ),
  ).interceptor);
  Welcome x;
  try {
    log('testing......');

    final token = await dio.post(
        'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
        options: buildCacheOptions(Duration(days: 7),
            maxStale: Duration(days: 2),
            forceRefresh: true,
            options: Options(
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
              },
            )));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.data['response']['token']}'
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
    var request = await dio.post(
        'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app_dis/_find',
        options: buildCacheOptions(Duration(days: 7),
            maxStale: Duration(days: 2),
            options: Options(headers: headers),
            forceRefresh: true),
        data: raw);
    //request.body = raw;

    if (request.statusCode == 200) {
      var res = await request.data;
      //  print(res.runtimeType);
      x = resm.Welcome.fromJson(res);
      //  x = resm.welcomeFromJson(res);
      //return x;
    } else {
      print(request.statusMessage);
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
    var x = await fetchAlbum();
    setState(() {
      futureAlbum = x;
    });
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
                            ' The report for the month of ${widget.selectedMonth}  ${widget.selectedYear} is uploaded '),
                      )
                    ],
                  ),
                )
              : null,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (isItLastPage) Navigator.of(context).pop();
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
              "Reporting_Month": widget.selectedMonth?.trim(),
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
        return Center(
            child: Center(
          child: Text(
            "${(controller.page + 1).toInt()} of ${futureAlbum.response.dataInfo.foundCount}",
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: width / 18,
              ),
            ),
          ),
        ));
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
            title: Center(),
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
                          height: height * 1.2,
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
                                            // color: Colors.red,
                                            child: Row(
                                              children: [
                                                Spacer(),
                                                Container(
                                                  width: width / 4,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          color: Colors.white,
                                                          width: 1),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                    ),
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
                                                      "New",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: width / 28,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(flex: 8)
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              Expanded(
                                flex: 12,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(18.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              " Previous Report :-",
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: width / 28,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              ('${e.value.fieldData.reportingMonth} ${e.value.fieldData.reportingYear} '),
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: width / 28,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      maintainState: true,
                                                      builder: (context) =>
                                                          /* LifecycleWatcher(
                                    afterCoorectPin: HomePage2(),
                                  ), */
                                                          Homeedit(
                                                        fieldData: futureAlbum
                                                            .response
                                                            .data[e.key]
                                                            .fieldData,
                                                        selectedMonth: widget
                                                            .selectedMonth,
                                                        selectedYear:
                                                            widget.selectedYear,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // color: Colors.red,

                                        child: Center(
                                          child: Text(
                                            "Type :- ${e.value.fieldData.gatheringStatus}",
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: width / 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              width: width * 100,
                                              child: DataTable(
                                                dataRowColor:
                                                    MaterialStateProperty.all(
                                                        Colors.transparent),
                                                headingRowHeight: 0.0,
                                                rows: [
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Name:-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.fullName}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Year of Start :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.yearOfStart}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "State :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.state}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "District :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.district}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Block :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.block}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Colony :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.colony}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Village :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.village}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Habitation :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.habitation}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Un-Habitation :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.unHabitation}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                                  DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        "Pin :-",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${e.value.fieldData.pin}",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width / 28,
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
                                              )))
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.18),
                              FormBuilder(
                                key: _formKey,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextInputWidget(
                                      labeltext: "Total Believers",
                                      name: "Bel_Added",
                                      prevData: "${e.value.fieldData.belAdded}",
                                      height: height,
                                      width: width,
                                    ),
                                    SizedBox(width: 10),
                                    TextInputWidget(
                                      labeltext: "Total Baptism",
                                      name: "New_BPT",
                                      prevData: "${e.value.fieldData.newBpt}",
                                      height: height,
                                      width: width,
                                    ),
                                    SizedBox(width: 10),
                                    TextInputWidget(
                                      labeltext: "Average Attendance",
                                      name: "Average_Attendance",
                                      prevData:
                                          "${e.value.fieldData.averageAttendance}",
                                      height: height,
                                      width: width,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: width,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(2.0),
                                            height: height / 8,
                                            width: width / 4,
                                            //padding: EdgeInsets.all(width / 40),
                                            child: ElevatedButton(
                                              child: Text(
                                                !isLastPage ? 'Next' : 'Save',
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width / 22,
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
          Container(
            height: height / 30,
            child: Text(
              prevData,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
