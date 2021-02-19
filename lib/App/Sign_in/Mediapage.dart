import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
class Mediapage extends StatefulWidget {


  @override
  _MediapageState createState() => _MediapageState();
}


class _MediapageState extends State<Mediapage> {
  File _image;
  Future getImage(bool isCamera) async{
    File image;
    if(isCamera){
      image =  await ImagePicker.pickImage(source: ImageSource.camera);
    } else{
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _image=image;
    });
  }
  uploadimage() async {

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
      var request = http.MultipartRequest('POST', Uri.parse('https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app_dis/records/359245/containers/App_container_field1'));
      request.files.add(await http.MultipartFile.fromPath('upload', '/C:/Users/jacob/OneDrive/Desktop/Book1.csv'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      }
      else {
        print(response.reasonPhrase);
      }

  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    uploadimage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Mediapage'),

      ),
      body:Container(
        padding: EdgeInsets.all(10),
        child: GridView(
          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          children: <Widget>[

            Card(
              elevation: 10,
              color: Colors.blue,
              child: Container(
                child: new Column(
                  children: <Widget>[
                    new IconButton(icon: Icon(Icons.add_a_photo_outlined ,size: 40,color: Colors.black,),
                        onPressed:(){
                          getImage(true);
                        }),
                    new Text('Leaders'),
                    _image==null?Container():Image.file(_image,height: 100,width: 100,),
                  ],
                ),


                  //child: [Text("YOUR TEXT")],
              ),


            ),
            Card(
                elevation: 10,
              color: Colors.deepOrange,
              child: new Column(
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.add_a_photo_outlined ,size: 40,color: Colors.black,),
                      onPressed:(){
                        getImage(true);
                      }),
                  new Text('family'),
                  _image==null?Container():Image.file(_image,height: 100,width: 100,),
                ],
              ),

            ),
            Card(
                elevation: 10,
              color: Colors.deepOrange,
              child: new Column(
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.add_a_photo_outlined ,size: 40,color: Colors.black,),
                      onPressed:(){
                        getImage(true);
                      }),
                  new Text('Community'),
                  _image==null?Container():Image.file(_image,height: 100,width: 100,),
                ],
              ),

            ),
            Card(
                elevation: 10,
              color: Colors.blue,
              child: new Column(
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.add_a_photo_outlined ,size: 40,color: Colors.black,),
                      onPressed:(){
                        getImage(true);
                      }),
                  new Text('Leaders'),
                  _image==null?Container():Image.file(_image,height: 100,width: 100,),
                ],
              ),

            ),
            Container
              (child: new FlatButton(onPressed: () {
              Navigator.pushNamed(context, "YourRoute");
            },
              child: new Text("save"),)),
            // IconButton(icon: Icon(Icons.web,size: 40,color: Colors.black,),
            //     onPressed:(){
            //       getImage(false);
            //     }),
            // IconButton(icon: Icon(Icons.add_a_photo_outlined ,size: 40,color: Colors.black,),
            //     onPressed:(){
            //       getImage(true);
            //     }),
            //_image==null?Container():Image.file(_image,height: 100,width: 100,),
          ],
        ),


      ),
        // child:Container(
        //   child: new FlatButton(
        //     onPressed: () {
        //       /*...*/
        //     },
        //     child: Text(
        //       "Flat Button",
        //     ),
        //   ),
        // )
    );
  }
}