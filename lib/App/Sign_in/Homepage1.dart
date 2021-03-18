import 'package:flutter/material.dart';
import 'package:flutter_app/App/models/response_model.dart' as resm;
import 'package:flutter_app/App/models/response_model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
    void showDialogOfSuccess() async {
      setState(() {
        showNext = true;
      });
      return await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Successfully Saved"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            )
          ],
        ),
      );
    }

    Future<void> postForm(Datum prevData) async {
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
            showDialogOfSuccess();
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
            "${(controller.page + 1).toInt()}/${futureAlbum.response.dataInfo.foundCount}");
      }
      return Container(
        child: futureAlbum != null
            ? Text("1/${futureAlbum.response.dataInfo.foundCount}")
            : Container(),
      );
    }

    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('homepage'),
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
                color: Colors.blueGrey,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
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
                  children: futureAlbum.response.data
                      .map((e) => SingleChildScrollView(
                            child: Container(
                              color: Colors.blueGrey,
                              // width: MediaQuery.of(context).size.width,
                              // height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                /// crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/images/pro.png'),
                                        radius: 40,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 45),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Last Enter Month & year Report:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          (e.fieldData.reportingMonth),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          (e.fieldData.reportingYear)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ]),
                                  SizedBox(height: 10),
                                  new Container(
                                      child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Addnewpage()));
                                        },
                                        child: new Text('Add New',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  )),
                                  new Container(
                                    color: Colors.white,
                                    height: 450,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("Type:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            SizedBox(width: 8),
                                            Text(
                                              e.fieldData.gatheringStatus,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(width: 15),
                                            Text("Name:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            SizedBox(width: 8),
                                            Text(
                                              e.fieldData.fullName,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(width: 15),
                                            Text("Year of Start:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            SizedBox(width: 8),
                                            Text(
                                              (e.fieldData.yearOfStart)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Center(
                                            child: Container(
                                          //mainAxisAlignment: MainAxisAlignment.center,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("State:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.state,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          height: 15,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              Text("District:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.district,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Block:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.block,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              Text("Colony:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.colony,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Village:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.village,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              Text("Habitation:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.habitation,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("UN.Habitation:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                e.fieldData.unHabitation,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 8),
                                        Center(
                                            child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              Text("PIN:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              SizedBox(width: 8),
                                              Text(
                                                (e.fieldData.pin).toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )),
                                        SizedBox(height: 30),
                                        Container(
                                          child: Row(
                                            children: [
                                              new Text(
                                                (e.fieldData.belAdded)
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 150),
                                              new Text(
                                                (e.fieldData.newBpt).toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 150),
                                              new Text(
                                                (e.fieldData.averageAttendance)
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          // padding: const EdgeInsets.only(bottom:150),
                                          child: FormBuilder(
                                            key: _formKey,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 130.0,
                                                  child:
                                                      new FormBuilderTextField(
                                                    name: "Bel_Added",
                                                    autocorrect: true,
                                                    validator:
                                                        FormBuilderValidators
                                                            .required(context),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        new InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20)),
                                                      ),
                                                      labelText:
                                                          'Total Believers',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 130.0,
                                                  child:
                                                      new FormBuilderTextField(
                                                    validator:
                                                        FormBuilderValidators
                                                            .required(context),
                                                    name: "New_BPT",
                                                    autocorrect: true,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        new InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20)),
                                                      ),
                                                      labelText:
                                                          'Total Baptism',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 130.0,
                                                  child:
                                                      new FormBuilderTextField(
                                                    name: "Average_Attendance",
                                                    autocorrect: true,
                                                    validator:
                                                        FormBuilderValidators
                                                            .required(context),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        new InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20)),
                                                      ),
                                                      labelText:
                                                          'Avg Attadance',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: new Text('Save',
                                                style: new TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                )),
                                            onTap: () {
                                              postForm(e);
                                            },
                                          ),
                                          SizedBox(width: 50),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Mediapage(
                                                            data: e,
                                                          )));
                                            },
                                            child: Visibility(
                                                visible: viewVisible,
                                                child: new Text(
                                                  'Media.',
                                                  style: new TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                )),
                                          )
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ))
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ));
  }
}
