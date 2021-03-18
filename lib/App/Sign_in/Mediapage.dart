import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/App/models/response_model.dart';
import 'package:exif/exif.dart';
import 'package:location_permissions/location_permissions.dart';

class Mediapage extends StatefulWidget {
  /// Constructs a [LocationPermitionScreen] for the supplied [Permission].
  // const Mediapage({this.permission, this.onTaped});

  final Datum data;

  const Mediapage({Key key, this.data}) : super(key: key);
  @override
  _MediapageState createState() => _MediapageState();
}

class _MediapageState extends State<Mediapage> {
  ServiceStatus serviceStatus;
  bool locationServiceon = false;
  String latitudeData = "";
  String longtitudeData = "";
  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    serviceStatus = await LocationPermissions().checkServiceStatus();
    log(serviceStatus.index.toString());
    setState(() {});
  }

  File _leaderImage;
  File _familyImage;
  File _communityImage;
  File _gatheringImage;
  Future getImage(bool isCamera, String type) async {
    var _image = ImagePicker();
    String convertDegreesToDD(int degrees, int minutes, int nu, int de) {
      return (degrees + (minutes / 60) + ((nu / de) / 3600))
          .toStringAsPrecision(8);
    }

    Future<File> selectCameraOrGalerry(File image) async {
      if (isCamera) {
        var x = await _image.getImage(source: ImageSource.camera);
        var bytes = await x.readAsBytes();
        var tags = await readExifFromBytes(bytes);
        List<dynamic> gpsLat = tags['GPS GPSLatitude'].values;
        List<dynamic> gpsLon = tags['GPS GPSLongitude'].values;
        latitudeData = convertDegreesToDD(gpsLat[0].numerator,
            gpsLat[1].numerator, gpsLat[2].numerator, gpsLat[2].denominator);
        longtitudeData = convertDegreesToDD(gpsLon[0].numerator,
            gpsLon[1].numerator, gpsLon[2].numerator, gpsLon[2].denominator);
        return File(x.path);
      } else {
        var x = await _image.getImage(source: ImageSource.gallery);
        var bytes = await x.readAsBytes();
        var tags = await readExifFromBytes(bytes);
        /*  tags.forEach((key, value) {
          print('$key  ${value.printable}');
        }); */
        List<dynamic> gpsLat = tags['GPS GPSLatitude'].values;
        List<dynamic> gpsLon = tags['GPS GPSLongitude'].values;
        latitudeData = convertDegreesToDD(gpsLat[0].numerator,
            gpsLat[1].numerator, gpsLat[2].numerator, gpsLat[2].denominator);
        longtitudeData = convertDegreesToDD(gpsLon[0].numerator,
            gpsLon[1].numerator, gpsLon[2].numerator, gpsLon[2].denominator);

        return File(x.path);
      }
    }

    switch (type) {
      case 'leaders':
        var x = await selectCameraOrGalerry(_leaderImage);
        setState(() {
          _leaderImage = x;
        });
        break;
      case 'family':
        var x = await selectCameraOrGalerry(_familyImage);
        setState(() {
          _familyImage = x;
        });
        break;
      case 'community':
        var x = await selectCameraOrGalerry(_communityImage);
        setState(() {
          _communityImage = x;
        });
        break;
      case 'gathering':
        var x = await selectCameraOrGalerry(_gatheringImage);
        setState(() {
          _gatheringImage = x;
        });
        break;
      default:
    }
  }

  Future<void> uploadimage(String type, File file) async {
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
    /*   final prefs = await SharedPreferences.getInstance(); */
    final path = file.absolute.path;
    final prefs = await SharedPreferences.getInstance();
    final recordId = prefs.getString('recordId');
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_report_app/records/$recordId/containers/$type'));
    request.files.add(await http.MultipartFile.fromPath('upload', path));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> saveLatitudeLogitude() async {
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
    final recordId = prefs.getString('recordId');
    var raw = jsonEncode({
      "fieldData": {"lat": latitudeData, "log": longtitudeData}
    });

    log(raw);
    var request = http.Request(
        'PATCH',
        Uri.parse(
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/General_Report_app/records/$recordId'));
    request.body = raw;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Mediapage'),
      ),
      body: serviceStatus?.index == 2
          ? Container(
              padding: EdgeInsets.all(10),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Card(
                    elevation: 10,
                    color: Colors.lightGreenAccent,
                    child: Container(
                      child: new Column(
                        children: <Widget>[
                          Row(
                            children: [
                              new IconButton(
                                  icon: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                  onPressed: () async {
                                    await getImage(true, 'leaders');
                                  }),
                              new IconButton(
                                  icon: Icon(
                                    Icons.photo,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                  onPressed: () async {
                                    await getImage(false, 'leaders');
                                  }),
                            ],
                          ),
                          new Text('Leaders'),
                          _leaderImage == null
                              ? Container()
                              : Image.file(
                                  _leaderImage,
                                  height: 100,
                                  width: 100,
                                ),
                        ],
                      ),

                      //child: [Text("YOUR TEXT")],
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.lightGreen,
                    child: new Column(
                      children: <Widget>[
                        Row(
                          children: [
                            new IconButton(
                                icon: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(true, 'family');
                                }),
                            new IconButton(
                                icon: Icon(
                                  Icons.photo,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(false, 'family');
                                }),
                          ],
                        ),
                        new Text('family'),
                        _familyImage == null
                            ? Container()
                            : Image.file(
                                _familyImage,
                                height: 100,
                                width: 100,
                              ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.tealAccent,
                    child: new Column(
                      children: <Widget>[
                        Row(
                          children: [
                            new IconButton(
                                icon: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(true, 'community');
                                }),
                            new IconButton(
                                icon: Icon(
                                  Icons.photo,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(false, 'community');
                                }),
                          ],
                        ),
                        new Text('Community'),
                        _communityImage == null
                            ? Container()
                            : Image.file(
                                _communityImage,
                                height: 100,
                                width: 100,
                              ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.teal,
                    child: new Column(
                      children: <Widget>[
                        Row(
                          children: [
                            new IconButton(
                                icon: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(true, 'gathering');
                                }),
                            new IconButton(
                                icon: Icon(
                                  Icons.photo,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await getImage(false, 'gathering');
                                }),
                          ],
                        ),
                        new Text('Gathering'),
                        _gatheringImage == null
                            ? Container()
                            : Image.file(
                                _gatheringImage,
                                height: 100,
                                width: 100,
                              ),
                      ],
                    ),
                  ),
                  Container(
                      child: new FlatButton(
                    onPressed: () async {
                      _communityImage != null
                          ? await uploadimage(
                              'Image_community', _communityImage)
                          : null;
                      _familyImage != null
                          ? await uploadimage('Image_family', _familyImage)
                          : null;
                      _leaderImage != null
                          ? await uploadimage('Image_leader', _leaderImage)
                          : null;
                      _gatheringImage != null
                          ? await uploadimage(
                              'Image_gathering', _gatheringImage)
                          : null;
                      await saveLatitudeLogitude();
                    },
                    child: new Text(
                      "save",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  )),
                ],
              ),
            )
          : Container(
              child: Center(
                child: Text("Please Switch On your Location "),
              ),
            ),
    );
  }
}
