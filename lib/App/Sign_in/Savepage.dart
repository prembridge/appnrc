// import 'package:flutter/material.dart';
// import 'package:http/http.dart'as http;
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer';
// import 'package:flutter_swiper/flutter_swiper.dart';
// Future<Album> fetchAlbum() async {
//
//   final http.Response token =
//       await http.post("https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions",
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
//         },
//
//       );
//
//
//    Map<String, dynamic> responsetoken = jsonDecode(token.body);
// var result = responsetoken['response'];
// var tokenresult =result['token'];
//   log('result...in field:$responsetoken');
//
//   final response =
//   await http.get("https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records",
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $tokenresult'
//     },
//   );
//   Map<String, dynamic > responseJson = jsonDecode(response.body);
//   var res = responseJson['response'];
//   var reresult =res['data'];
//
//
//
//
//   //var fieldData = reresult['[fieldData]'];
// //var fielddata =reresult['fieldData'];
//   log('result...in field:$reresult[0]');
//   return Album.fromJson(reresult[0]);
//
//
//   // if (response.statusCode == 200) {
//   //
//   //   // If the server did return a 200 OK response,
//   //   // then parse the JSON.
//   //   return Album.fromJson(jsonDecode(response.body));
//   //
//   // } else {
//   //
//   //   // If the server did not return a 200 OK response,
//   //   // then throw an exception.
//   //   throw Exception('Failed to load album');
//   // }
// }
// class MyStructure {
//   final int id;
//   final String text;
//   MyStructure({this.id, this.text});
// }
// class MyWidget extends StatelessWidget {
//   final MyStructure widgetStructure;
//   MyWidget(this.widgetStructure);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         color: Colors.green,
//         child: Text('${widgetStructure.id} ${widgetStructure.text}')
//     );
//   }
// }
// class Album {
//   final int Bel_Added;
//   final int New_BPT;
//   final String Full_Name;
//
//   Album({this.Bel_Added, this.New_BPT, this.Full_Name});
//
//   factory Album.fromJson(Map<String, dynamic> json) {
//     // var name = json['fieldData']['Reporting_Year'];
//     // log('json:$name');
//     return Album(
//       Bel_Added: json['Bel_Added'],
//       New_BPT: json['New_BPT'],
//       Full_Name: json['fieldData']['Full_Name']
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> createAlbum(String title) async {

  print('testing......');
  final http.Response token =
  await http.post(
    'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
    },

  );
  print('token...:$token');

  Map<String, dynamic> responsetoke = jsonDecode(token.body);
  var result = responsetoke['response'];
  var tokenresult = result['token'];

  print('result...in field:$tokenresult');

  final http.Response response = await http.post(
    'https://jsonplaceholder.typicode.com/albums',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album.');
  }
}

class Album {
  final int id;
  final String title;

  Album({this.id, this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
    );
  }
}


class Savepage extends StatefulWidget {
  @override
  _SavepageState createState() => _SavepageState();
}

class _SavepageState extends State<Savepage> {
  final TextEditingController _controller = TextEditingController();

  Future<Album> _futureAlbum;

  // SwiperController controller;
  //
  // List<bool> autoplayes;
  //
  // List<SwiperController> controllers;
  // List<MyStructure> widgetList = [];

  @override
  void initState() {
    // controller = new SwiperController();
    // autoplayes = new List()
    //   ..length = 10
    //   ..fillRange(0, 10, false);
    // controllers = new List()
    //   ..length = 10
    //   ..fillRange(0, 10, new SwiperController());
    //
    // for(int i=0;i < 10; i++) {
    //   widgetList.add(MyStructure(id:i,text: ' this is index ${i}'));
    // }

    // TODO: implement initState
    super.initState();
    //_futureAlbum = createAlbum(title);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureAlbum == null)
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Enter Title'),
              ),
              ElevatedButton(
                child: Text('Create Data'),
                onPressed: () {
                  setState(() {
                    _futureAlbum = createAlbum(_controller.text);
                  });
                },
              ),
            ],
          )
              : FutureBuilder<Album>(
            future: _futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.title);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: new Scaffold(
//         body: new Swiper(
//           loop: false,
//           itemCount: widgetList.length,
//           controller: controller,
//           pagination: new SwiperPagination(),
//           itemBuilder: (BuildContext context, int index) {
//             return new Column(
//               children: <Widget>[
//                 new SizedBox(
//                   child: new Swiper(
//                     controller: controllers[index],
//                     pagination: new SwiperPagination(),
//                     itemCount: widgetList.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return MyWidget(widgetList[index]);
//                     },
//                     autoplay: autoplayes[index],
//                   ),
//                   height: 300.0,
//                 ),
//                 // new RaisedButton(
//                 //   onPressed: () {
//                 //     setState(() {
//                 //       autoplayes[index] = true;
//                 //     });
//                 //   },
//                 //   child: new Text("Start autoplay"),
//                 // ),
//                 // new RaisedButton(
//                 //   onPressed: () {
//                 //     setState(() {
//                 //       autoplayes[index] = false;
//                 //     });
//                 //   },
//                 //   child: new Text("End autoplay"),
//                 // ),
//                 // new Text("is autoplay: ${autoplayes[index]}")
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }