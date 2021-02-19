/* import 'package:flutter/material.dart';
import 'package:flutter_app/App/models/response_model.dart' as resm;

import 'Mediapage.dart';
import 'Savepage.dart';
import 'Addnewpage.dart';
import 'package:http/http.dart'as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter_swiper/flutter_swiper.dart';

int _count ;
Future<resm.FieldData> fetchAlbum() async {

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
    var raw = jsonEncode({"query":[{"Reporting_Month":prefs.getString('AppMonth'), "Reporting_Year":prefs.getString('AppYear'), "fk_Contact_Id":prefs.getString('contact')}]});
    var request = http.Request('POST', Uri.parse(
        'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app_dis/_find'));
    request.body =raw;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
     // var result = jsonDecode(res);
      var responses = result['response'];
      var x=resm.welcomeFromJson(res);
     // print(x.response.data[0].fieldData.district);
      var datainfo =responses['dataInfo'];
       var count = datainfo['foundCount'];
       prefs.setInt('count', count);
      // print("count:$count");
      // print("responses:$responses");
      List datavalue =responses['data'];
//datavalue.forEach((element) { Album.fromJson(element);});
      for (int i = 0; i < x.response.data.length; i++) {
        //log(datavalue.length);
      // log("i values:$i");
       // String type = datavalue[i]['fieldData'][ 'Gathering_Status'];
       // log("type...$type");
       // print(datavalue);

        //return Album.fromJson(datavalue[i]);
        return x.response.data[i].fieldData;
            }
    // return (count);
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

// _loadCounter() async {
//    //Album count = await fetchAlbum();
//   //
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//
//    //print("count....$count");
//   setState(() {
//
//     _count = (prefs.getInt('count'));
//   });
// }

void setState(Null Function() param0) {
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
        child: Text('${widgetStructure.id} ${widgetStructure.text}')
    );
  }
}
class Album {
  final int Bel_Added;
  final int New_BPT;
  final String Full_Name;
  final String State;
  final String District;
  final String Block;
  final String Village;
  final String Habitation;
  final String Gathering_Status;
  final int Year_of_Start;
  final String Un_Habitation;
  final int Pin;
  Album({this.Bel_Added, this.New_BPT, this.Full_Name,this.State,this.District,this.Block,this.Village,this.Habitation,this.Gathering_Status,this.Year_of_Start,this.Un_Habitation,this.Pin});

  factory Album.fromJson(Map<String, dynamic> json) {
   // var name = json['fieldData']['Reporting_Year'];
    log('json.........:$json');
    return Album(
        Bel_Added: json['Bel_Added'],
        New_BPT: json['New_BPT'],
        Full_Name: json['fieldData']['Full_Name'],
        State:json['fieldData']['State'],
        District:json['fieldData']['District'],
        Block:json['fieldData']['Block'],
        Village:json['fieldData']['Village'],
        Habitation:json['fieldData']['Habitation'],
        Gathering_Status: json['fieldData']['Gathering_Status'],
        Year_of_Start:json['fieldData']['Year_of_Start'],
        Un_Habitation:json['fieldData'][' Un_Habitation'],
        Pin:json['fieldData']['Pin']
    );
  }
}



class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>  {

   SharedPreferences preferences;

   int pomodoro = 0;
  resm.FieldData futureAlbum;
  //SwiperController controller;
  PageController controller;
int pageChanged =0;
 // List<bool> autoplayes;

  // List<SwiperController> controllers;
  // List<MyStructure> widgetList = [];

// var _dropvalue=['Gath','Hc','Mc','PC','Av'];
// var _currentItemSelected='Gath';




  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    // controller = new SwiperController();
    // autoplayes = new List()

init();
    super.initState();
  }
void init()async{
  futureAlbum = await fetchAlbum();




}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('homepage'),
        actions: [
          IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
            controller.animateToPage(--pageChanged, duration:Duration(microseconds: 250), curve: Curves.bounceOut);
          }),
          IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed:(){
            controller.animateToPage(++pageChanged, duration:Duration(microseconds: 250), curve: Curves.bounceOut);
          })
        ],
        ),
        body: futureAlbum!=null?Container(
            color: Colors.blueGrey,
            width: 750,

            child: PageView(
              pageSnapping: true,
                controller: controller,
                onPageChanged:(index){
                setState(() => pageChanged=index);

                },
                children: <Widget>[

                  for (var i = 0; i < preferences.getInt('count'); i++)
                    Text("page $i"),
                          Container(
                            child: new Column(
                              children: <Widget>[
                                Column(
                                  children: [

                                    Column(
                                      children: [
                                        Container(
                                          color: Colors.blueGrey,
                                          width: 750,
                                          height: 130,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: <Widget>[

                                              Column(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage: AssetImage(
                                                        'assets/images/cp.png'),
                                                    radius: 40,

                                                  ),
                                                ],
                                              ),

                                              new Text('ID 123..',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (
                                                                    context) =>
                                                                    Addnewpage())
                                                        );
                                                      },
                                                      child: new Text('Add New',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),


                                            ],

                                          ),


                                        ),


                                      ],

                                    ),

                                    Column(

                                      children: <Widget>[

                                        // new Swiper(
                                        //
                                        //  // controller: controllers[index],
                                        //  // pagination: new SwiperPagination(),
                                        //   //itemCount: widgetList.length,
                                        //   //itemBuilder: (BuildContext context, int index) {
                                        //     return MyWidget(widgetList[index]);
                                        //   },
                                        //   //autoplay: autoplayes[index],
                                        // ),
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: PageView(children: <Widget>[
                                        //     Container(child: Text('Page 1')),
                                        //     Container(child: Text('Page 2')),
                                        //     Text('Page 3'),
                                        //   ]),
                                        // ),

                                        Container(

                                            color: Colors.grey,

                                            height: 450,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Row(
                                                  children: [
                                                    new FutureBuilder<resm.FieldData>(
                                                      builder: (context,
                                                          snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                            "Type:${snapshot.data
                                                                .gatheringStatus}",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              color: Colors.black,
                                                            ),);
                                                        } else
                                                        if (snapshot.hasError) {
                                                          return Text(
                                                              "${snapshot
                                                                  .error}");
                                                        }

                                                        // By default, show a loading spinner.
                                                        return CircularProgressIndicator();
                                                      },
                                                    ),
                                                    SizedBox(width: 30),
                                                    // new RaisedButton(onPressed: null,
                                                    //
                                                    //     child:Text('Name',
                                                    //       style: TextStyle(
                                                    //         fontSize: 20,
                                                    //         color: Colors.white,
                                                    //       ),
                                                    //     )),
                                                    new FutureBuilder<resm.FieldData>(

                                                      builder: (context,
                                                          snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                            " Name:${snapshot.data
                                                                .fullName}",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              color: Colors.black,
                                                            ),);
                                                        } else
                                                        if (snapshot.hasError) {
                                                          return Text(
                                                              "${snapshot
                                                                  .error}");
                                                        }

                                                        // By default, show a loading spinner.
                                                        return CircularProgressIndicator();
                                                      },
                                                    ),

                                                    SizedBox(width: 30),
                                                    new FutureBuilder<resm.FieldData>(
                                                      future: futureAlbum,
                                                      builder: (context,
                                                          snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                            "Year of Start:${snapshot
                                                                .data.yearOfStart}",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              color: Colors.black,
                                                            ),);
                                                        } else
                                                        if (snapshot.hasError) {
                                                          return Text(
                                                              "${snapshot
                                                                  .error}");
                                                        }

                                                        // By default, show a loading spinner.
                                                        return CircularProgressIndicator();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                // DropdownButton<String>(
                                                //     items:  _dropvalue.map((String dropDownStringItem) {
                                                //      return DropdownMenuItem<String>(
                                                //        value: dropDownStringItem,
                                                //
                                                //          child: Text(dropDownStringItem),
                                                //      );
                                                //     }).toList(),
                                                //   onChanged:(String newValueSelected){
                                                // setState(() {
                                                //   this._currentItemSelected =newValueSelected;
                                                //     });
                                                //   },
                                                //   value: _currentItemSelected,
                                                // ),
                                                SizedBox(
                                                  height: 20,
                                                ),

                                                Container(

                                                  child: Column(
                                                    //mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[


                                                        Container(

                                                          child: new FutureBuilder<resm.FieldData>
                                                              (
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  " State:${snapshot
                                                                      .data
                                                                      .state},",
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),

                                                        Container(

                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  " District:${snapshot
                                                                      .data
                                                                      .district}",
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                );
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 150,
                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  " Block:${snapshot
                                                                      .data
                                                                      .block}",
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 150,
                                                          child: new Text(
                                                            'Colony:',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                            ),

                                                          ),
                                                        ),
                                                        Container(
                                                          width: 350,
                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  " Village:${snapshot
                                                                      .data
                                                                      .village
                                                                  }"
                                                                  ,
                                                                  textAlign: TextAlign
                                                                      .center,
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 150,
                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  " Habitation:${snapshot
                                                                      .data
                                                                  .habitation}",
                                                                  textAlign: TextAlign
                                                                      .center,

                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                        Container(

                                                          width: 150,
                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  "UnHabitation:${snapshot
                                                                      .data
                                                                      .unHabitation}",
                                                                  textAlign: TextAlign
                                                                      .center,

                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                        Container(

                                                          width: 150,
                                                          child: new FutureBuilder<
                                                              resm.FieldData>(
                                                            future: futureAlbum,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return Text(
                                                                  "Pin:${snapshot
                                                                      .data
                                                                      .pin}",
                                                                  textAlign: TextAlign
                                                                      .center,

                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),);
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "${snapshot
                                                                        .error}");
                                                              }

                                                              // By default, show a loading spinner.
                                                              return CircularProgressIndicator();
                                                            },
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),

                                                Container(

                                                  child: Row(
                                                    children: [
                                                      new Text('18'
                                                      ),
                                                      SizedBox(width: 150),
                                                      new Text('18'
                                                      ),
                                                      SizedBox(width: 150),
                                                      new Text('18'
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Container(

                                                  // padding: const EdgeInsets.only(bottom:150),
                                                  child: Row(

                                                    children: [

                                                      Container(

                                                        width: 130.0,
                                                        child: new TextField(
                                                          autocorrect: true,
                                                          keyboardType: TextInputType
                                                              .number,
                                                          decoration: new InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius: BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      20)),


                                                            ),

                                                            hintText: 'Total Believers',

                                                          ),

                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Container(

                                                        width: 130.0,
                                                        child: new TextField(
                                                          autocorrect: true,
                                                          keyboardType: TextInputType
                                                              .number,
                                                          decoration: new InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius: BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      20)),


                                                            ),

                                                            hintText: 'Total Baptism',

                                                          ),

                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Container(

                                                        width: 130.0,
                                                        child: new TextField(
                                                          autocorrect: true,
                                                          keyboardType: TextInputType
                                                              .number,
                                                          decoration: new InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius: BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      20)),


                                                            ),

                                                            hintText: 'Avg Attadance',

                                                          ),

                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                    Container(

                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,

                                        children: <Widget>[
                                          GestureDetector(

                                            child: new Text('Save',
                                                style: new TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,)),
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Savepage())
                                              );
                                            },
                                          ),
                                          SizedBox(width: 50),
                                          GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Mediapage())
                                                );
                                              },
                                              child: new Text(
                                                'Media.',
                                                style: new TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,),
                                              )),
                                          SizedBox(width: 50),
                                          // GestureDetector(
                                          //     onTap: (){
                                          //       Navigator.push(context,
                                          //           MaterialPageRoute(builder: (context)=>Addnewpage())
                                          //       );
                                          //     },
                                          //     child: new Text(
                                          //       'AddNew.',
                                          //       style: new TextStyle(
                                          //         color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20,),
                                          //     ))
                                        ],
                                      ),

                                    ),
                                    //   Container(
                                    //      child: Text("data")
                                    // )
                                  ],


                                ),

                              ]),
                          )]))):Conatainer();
                    //  })
                //])));
    //   ],
    // )

    // child: new Swiper(
    //     loop: true,
    //     itemCount: 10,
    //     controller: controller,
    //     pagination: new SwiperPagination(),
    //     itemBuilder: (BuildContext context, int index) {
    //       return new Column(
    //           children: <Widget>[
    //             Column(
    //               children: [
    //
    //                 Column(
    //                   children: [
    //                     Container(
    //                       color: Colors.blueGrey,
    //                       width: 750,
    //                       height: 130,
    //                       child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: <Widget>[
    //
    //
    //                           Column(
    //                             children: [
    //                               CircleAvatar(
    //                                 backgroundImage: AssetImage(
    //                                     'assets/images/cp.png'),
    //                                 radius: 40,
    //
    //                               ),
    //                             ],
    //                           ),
    //
    //                           new Text('ID 123..',
    //                             style: TextStyle(
    //                               fontSize: 15,
    //                             ),
    //                           ),
    //                           Container(
    //                             child: Row(
    //                               children: [
    //                                 GestureDetector(
    //                                   onTap: () {
    //                                     Navigator.push(context,
    //                                         MaterialPageRoute(
    //                                             builder: (context) =>
    //                                                 Addnewpage())
    //                                     );
    //                                   },
    //                                   child: new Text('Add New',
    //                                     style: TextStyle(
    //                                       fontSize: 15,
    //                                       color: Colors.red,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                   ),
    //                                 ),
    //
    //                               ],
    //                             ),
    //                           ),
    //
    //
    //                         ],
    //
    //                       ),
    //
    //
    //                     ),
    //
    //
    //                   ],
    //
    //                 ),
    //
    //                 Column(
    //
    //                   children: <Widget>[
    //
    //                     // new Swiper(
    //                     //
    //                     //  // controller: controllers[index],
    //                     //  // pagination: new SwiperPagination(),
    //                     //   //itemCount: widgetList.length,
    //                     //   //itemBuilder: (BuildContext context, int index) {
    //                     //     return MyWidget(widgetList[index]);
    //                     //   },
    //                     //   //autoplay: autoplayes[index],
    //                     // ),
    //                     // Expanded(
    //                     //   flex: 1,
    //                     //   child: PageView(children: <Widget>[
    //                     //     Container(child: Text('Page 1')),
    //                     //     Container(child: Text('Page 2')),
    //                     //     Text('Page 3'),
    //                     //   ]),
    //                     // ),
    //
    //                     Container(
    //
    //                         color: Colors.grey,
    //
    //                         height: 450,
    //                         child: Column(
    //                           mainAxisAlignment: MainAxisAlignment
    //                               .center,
    //                           children: [
    //                             Row(
    //                               children: [
    //                                 new FutureBuilder<Album>(
    //                                   future: futureAlbum,
    //                                   builder: (context, snapshot) {
    //                                     if (snapshot.hasData) {
    //                                       return Text(
    //                                         "Type:${snapshot.data
    //                                             .Gathering_Status}",
    //                                         style: TextStyle(
    //                                           fontSize: 15,
    //                                           fontWeight: FontWeight
    //                                               .bold,
    //                                           color: Colors.black,
    //                                         ),);
    //                                     } else if (snapshot.hasError) {
    //                                       return Text(
    //                                           "${snapshot.error}");
    //                                     }
    //
    //                                     // By default, show a loading spinner.
    //                                     return CircularProgressIndicator();
    //                                   },
    //                                 ),
    //                                 SizedBox(width: 30),
    //                                 // new RaisedButton(onPressed: null,
    //                                 //
    //                                 //     child:Text('Name',
    //                                 //       style: TextStyle(
    //                                 //         fontSize: 20,
    //                                 //         color: Colors.white,
    //                                 //       ),
    //                                 //     )),
    //                                 new FutureBuilder<Album>(
    //                                   future: futureAlbum,
    //                                   builder: (context, snapshot) {
    //                                     if (snapshot.hasData) {
    //                                       return Text(
    //                                         " Name:${snapshot.data
    //                                             .Full_Name}",
    //                                         style: TextStyle(
    //                                           fontSize: 15,
    //                                           fontWeight: FontWeight
    //                                               .bold,
    //                                           color: Colors.black,
    //                                         ),);
    //                                     } else if (snapshot.hasError) {
    //                                       return Text(
    //                                           "${snapshot.error}");
    //                                     }
    //
    //                                     // By default, show a loading spinner.
    //                                     return CircularProgressIndicator();
    //                                   },
    //                                 ),
    //
    //                                 SizedBox(width: 30),
    //                                 new FutureBuilder<Album>(
    //                                   future: futureAlbum,
    //                                   builder: (context, snapshot) {
    //                                     if (snapshot.hasData) {
    //                                       return Text(
    //                                         "Year of Start:${snapshot
    //                                             .data.Year_of_Start}",
    //                                         style: TextStyle(
    //                                           fontSize: 15,
    //                                           fontWeight: FontWeight
    //                                               .bold,
    //                                           color: Colors.black,
    //                                         ),);
    //                                     } else if (snapshot.hasError) {
    //                                       return Text(
    //                                           "${snapshot.error}");
    //                                     }
    //
    //                                     // By default, show a loading spinner.
    //                                     return CircularProgressIndicator();
    //                                   },
    //                                 ),
    //                               ],
    //                             ),
    //                             // DropdownButton<String>(
    //                             //     items:  _dropvalue.map((String dropDownStringItem) {
    //                             //      return DropdownMenuItem<String>(
    //                             //        value: dropDownStringItem,
    //                             //
    //                             //          child: Text(dropDownStringItem),
    //                             //      );
    //                             //     }).toList(),
    //                             //   onChanged:(String newValueSelected){
    //                             // setState(() {
    //                             //   this._currentItemSelected =newValueSelected;
    //                             //     });
    //                             //   },
    //                             //   value: _currentItemSelected,
    //                             // ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //
    //                             Container(
    //
    //                               child: Column(
    //                                 //mainAxisAlignment: MainAxisAlignment.center,
    //                                   children: <Widget>[
    //
    //
    //                                     Container(
    //
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               " State:${snapshot
    //                                                   .data.State},",
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //
    //                                     Container(
    //
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               " District:${snapshot
    //                                                   .data.District}",
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),
    //                                             );
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Container(
    //                                       width: 150,
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               " Block:${snapshot
    //                                                   .data.Block}",
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Container(
    //                                       width: 150,
    //                                       child: new Text('Colony:',
    //                                         style: TextStyle(
    //                                           fontSize: 15,
    //                                         ),
    //
    //                                       ),
    //                                     ),
    //                                     Container(
    //                                       width: 350,
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               " Village:${snapshot
    //                                                   .data.Village}"
    //                                               , textAlign: TextAlign
    //                                                 .center,
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Container(
    //                                       width: 150,
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               " Habitation:${snapshot
    //                                                   .data
    //                                                   .Habitation}",
    //                                               textAlign: TextAlign
    //                                                   .center,
    //
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Container(
    //
    //                                       width: 150,
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               "UnHabitation:${snapshot
    //                                                   .data
    //                                                   .Un_Habitation}",
    //                                               textAlign: TextAlign
    //                                                   .center,
    //
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Container(
    //
    //                                       width: 150,
    //                                       child: new FutureBuilder<
    //                                           Album>(
    //                                         future: futureAlbum,
    //                                         builder: (context,
    //                                             snapshot) {
    //                                           if (snapshot.hasData) {
    //                                             return Text(
    //                                               "Pin:${snapshot.data
    //                                                   .Pin}",
    //                                               textAlign: TextAlign
    //                                                   .center,
    //
    //                                               style: TextStyle(
    //                                                 fontSize: 15,
    //                                                 fontWeight: FontWeight
    //                                                     .bold,
    //                                                 color: Colors.black,
    //                                               ),);
    //                                           } else
    //                                           if (snapshot.hasError) {
    //                                             return Text("${snapshot
    //                                                 .error}");
    //                                           }
    //
    //                                           // By default, show a loading spinner.
    //                                           return CircularProgressIndicator();
    //                                         },
    //                                       ),
    //                                     ),
    //                                     ]
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //
    //                             Container(
    //
    //                               child: Row(
    //                                 children: [
    //                                   new Text('18'
    //                                   ),
    //                                   SizedBox(width: 150),
    //                                   new Text('18'
    //                                   ),
    //                                   SizedBox(width: 150),
    //                                   new Text('18'
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //
    //                             Container(
    //
    //                               // padding: const EdgeInsets.only(bottom:150),
    //                               child: Row(
    //
    //                                 children: [
    //
    //                                   Container(
    //
    //                                     width: 130.0,
    //                                     child: new TextField(
    //                                       autocorrect: true,
    //                                       keyboardType: TextInputType.number,
    //                                       decoration: new InputDecoration(
    //                                         enabledBorder: OutlineInputBorder(
    //                                           borderSide: BorderSide(
    //                                               color: Colors.white),
    //                                           borderRadius: BorderRadius
    //                                               .all(
    //                                               Radius.circular(20)),
    //
    //
    //                                         ),
    //
    //                                         hintText: 'Total Believers',
    //
    //                                       ),
    //
    //                                     ),
    //                                   ),
    //                                   SizedBox(width: 10),
    //                                   Container(
    //
    //                                     width: 130.0,
    //                                     child: new TextField(
    //                                       autocorrect: true,
    //                                       keyboardType: TextInputType.number,
    //                                       decoration: new InputDecoration(
    //                                         enabledBorder: OutlineInputBorder(
    //                                           borderSide: BorderSide(
    //                                               color: Colors.white),
    //                                           borderRadius: BorderRadius
    //                                               .all(
    //                                               Radius.circular(20)),
    //
    //
    //                                         ),
    //
    //                                         hintText: 'Total Baptism',
    //
    //                                       ),
    //
    //                                     ),
    //                                   ),
    //                                   SizedBox(width: 10),
    //                                   Container(
    //
    //                                     width: 130.0,
    //                                     child: new TextField(
    //                                       autocorrect: true,
    //                                       keyboardType: TextInputType.number,
    //                                       decoration: new InputDecoration(
    //                                         enabledBorder: OutlineInputBorder(
    //                                           borderSide: BorderSide(
    //                                               color: Colors.white),
    //                                           borderRadius: BorderRadius
    //                                               .all(
    //                                               Radius.circular(20)),
    //
    //
    //                                         ),
    //
    //                                         hintText: 'Avg Attadance',
    //
    //                                       ),
    //
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         )
    //                     ),
    //                   ],
    //                 ),
    //                 Container(
    //
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //
    //                     children: <Widget>[
    //                       GestureDetector(
    //
    //                         child: new Text('Save',
    //                             style: new TextStyle(color: Colors.red,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 20,)),
    //                         onTap: () {
    //                           Navigator.push(context,
    //                               MaterialPageRoute(
    //                                   builder: (context) => Savepage())
    //                           );
    //                         },
    //                       ),
    //                       SizedBox(width: 50),
    //                       GestureDetector(
    //                           onTap: () {
    //                             Navigator.push(context,
    //                                 MaterialPageRoute(
    //                                     builder: (context) =>
    //                                         Mediapage())
    //                             );
    //                           },
    //                           child: new Text(
    //                             'Media.',
    //                             style: new TextStyle(
    //                               color: Colors.red,
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 20,),
    //                           )),
    //                       SizedBox(width: 50),
    //                       // GestureDetector(
    //                       //     onTap: (){
    //                       //       Navigator.push(context,
    //                       //           MaterialPageRoute(builder: (context)=>Addnewpage())
    //                       //       );
    //                       //     },
    //                       //     child: new Text(
    //                       //       'AddNew.',
    //                       //       style: new TextStyle(
    //                       //         color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20,),
    //                       //     ))
    //                     ],
    //                   ),
    //
    //                 ),
    //               ],
    //
    //
    //             ),
    //
    //           ]);
    //     })));
    // ));}

  }} */
