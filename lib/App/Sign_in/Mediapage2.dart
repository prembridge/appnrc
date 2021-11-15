import 'package:flutter/material.dart';
import 'package:flutter_app/App/models/home2_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:async';
import '../services/nonetwork_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exif/exif.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/post_provider.dart';

class Mediapage2 extends StatefulWidget {
  final FieldData fieldData;
  final String recordId;
  const Mediapage2({Key key, this.fieldData, this.recordId}) : super(key: key);
  @override
  _Mediapage2State createState() => _Mediapage2State();
}

class _Mediapage2State extends State<Mediapage2> {
  ServiceStatus serviceStatus;
  bool locationServiceon = false;
  String latitudeData = "";
  String longtitudeData = "";
  bool isUploading = false;
  bool isOneImageSelected = false;
  int noOfImagesUploadeed = 0;
  @override
  void initState() {
    super.initState();
    print(widget.recordId);
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    serviceStatus = await LocationPermissions().checkServiceStatus();
    var gpsLocation = await _determinePosition();

    setState(() {
      latitudeData = gpsLocation.altitude.toString();
      longtitudeData = gpsLocation.longitude.toString();
    });
    log('GPS Latitude: $latitudeData  GPS Longitude: $longtitudeData');
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
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
        if (x != null) {
          var gpsLocation = await _determinePosition();
          setState(() {
            latitudeData = gpsLocation.altitude.toString();
            longtitudeData = gpsLocation.longitude.toString();
          });
          return File(x.path);
        } else {
          return null;
        }
      } else {
        var x = await _image.getImage(source: ImageSource.gallery);
        var bytes = await x.readAsBytes();
        var tags = await readExifFromBytes(bytes);

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
      case 'Leader_image':
        var x = await selectCameraOrGalerry(_leaderImage);

        setState(() {
          _leaderImage = x;
        });

        break;
      case 'Family_image':
        var x = await selectCameraOrGalerry(_familyImage);
        setState(() {
          _familyImage = x;
        });
        break;
      case 'Community_image':
        var x = await selectCameraOrGalerry(_communityImage);
        setState(() {
          _communityImage = x;
        });
        break;
      case 'Gathering_image':
        var x = await selectCameraOrGalerry(_gatheringImage);
        setState(() {
          _gatheringImage = x;
        });
        break;
      default:
    }
    if (_communityImage != null ||
        _familyImage != null ||
        _gatheringImage != null ||
        _leaderImage != null) {
      setState(() {
        isOneImageSelected = true;
      });
    }
  }

  Future<http.Response> getAuthToken() async {
    log('testing......');
    return await http.post(
      'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/sessions',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Basic c3VzaGlsOkphY29iNw==',
      },
    );
  }

  Future showSuccess(String msg) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$msg"),
            //content: Text("Successfully  Uploaded Images"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        });
  }

  Future<bool> uploadimage(String type, File file) async {
    String postUrl =
        "https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Media_storage_monthly_report/records/${widget.recordId}/containers/$type";
    ////"https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Media_storage_monthly_report/records/31065/containers/Leader_image----2021-11-15 17:59:00.839846,1"
    try {
      final token = await getAuthToken();
      log('token...:$token');

      Map<String, dynamic> responsetoke = jsonDecode(token.body);
      var result = responsetoke['response'];
      var tokenresult = result['token'];

      log('result...in field:$tokenresult');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenresult'
      };

      final path = file.absolute.path;

      var request = http.MultipartRequest('POST', Uri.parse('$postUrl'));
      request.files.add(await http.MultipartFile.fromPath('upload', path));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        noOfImagesUploadeed = noOfImagesUploadeed + 1;
        return true;
      } else {
        print(response.statusCode);
        print("========================");
        print(response.reasonPhrase);
        return false;
      }
    } on SocketException catch (e) {
      int selectedImages = 0;
      await NoNetworkService.storeFailedFileUploadRequest(file, postUrl);
      noOfImagesUploadeed = noOfImagesUploadeed + 1;
      if (_gatheringImage != null) {
        selectedImages = selectedImages + 1;
      }
      if (_familyImage != null) {
        selectedImages = selectedImages + 1;
      }
      if (_communityImage != null) {
        selectedImages = selectedImages + 1;
      }
      if (_leaderImage != null) {
        selectedImages = selectedImages + 1;
      }
      if (noOfImagesUploadeed == selectedImages) {
        await showSuccess("Stored Locally");
        Navigator.of(context).pop();
      }
      return false;
    }
  }

  Future<bool> saveLatitudeLogitude() async {
    log('GPS Latitude: $latitudeData  GPS Longitude: $longtitudeData');
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
      "fieldData": {"Latitude": latitudeData, "Longitude": longtitudeData}
    });

    log(raw);
    var request = http.Request(
        'PATCH',
        Uri.parse(
            'https://nrcoperations.co.in/fmi/data/vLatest/databases/OA_Master/layouts/Media_storage_monthly_report/records/${widget.recordId}'));

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
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      Widget imageWidget(String imgurl, File img) {
        if (imgurl == "" && img == null) {
          return Container(child: Text("Add an image"));
        }
        if (img != null) {
          return Image.file(
            img,
            height: 100,
            width: 100,
          );
        }

        return Image.network(
          imgurl,
          errorBuilder: (context, error, stackTrace) =>
              Text("Image unavailable currently"),
          loadingBuilder: (context, child, loadingProgress) {
            var x = loadingProgress;
            if (x?.cumulativeBytesLoaded != x?.expectedTotalBytes) {
              return CircularProgressIndicator();
            }
            return child;
          },
          height: 100,
          width: 100,
        );
      }

      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(noOfImagesUploadeed);
              },
            ),
            title: Center(child: Text('Add Media')),
          ),
          body: serviceStatus?.index == 2
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
                  child: Column(children: [
                    Expanded(
                      flex: 10,
                      child: GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                        ),
                        children: <Widget>[
                          Card(
                              elevation: 10,
                              color: Colors.deepPurple.shade100,
                              child: Container(
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          'Leaders',
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: width / 18,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                                icon: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  size: 40,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () async {
                                                  await getImage(
                                                      true, 'Leader_image');
                                                }),
                                            Text("Camera")
                                          ],
                                        ),
                                      ],
                                    ),
                                    imageWidget(widget.fieldData.leaderImage,
                                        _leaderImage)
                                  ],
                                ),

                                //child: [Text("YOUR TEXT")],
                              )),
                          Card(
                            elevation: 10,
                            color: Colors.deepPurple.shade200,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    new Text(
                                      'Family',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: width / 18,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              await getImage(
                                                  true, 'Family_image');
                                            }),
                                        Text("Camera")
                                      ],
                                    ),
                                    // Text(
                                    //   "OR",
                                    //   style:
                                    //       TextStyle(fontWeight: FontWeight.bold),
                                    // ),
                                    /*  Column(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.photo,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                          onPressed: () async {
                                            await getImage(
                                                false, 'Family_image');
                                          }),
                                      Text("Gallery")
                                    ],
                                  ), */
                                  ],
                                ),
                                imageWidget(
                                  widget.fieldData.familyImage,
                                  _familyImage,
                                ),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 10,
                            color: Colors.deepPurple.shade200,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    new Text(
                                      'Community',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: width / 18,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              await getImage(
                                                  true, 'Community_image');
                                            }),
                                        Text("Camera")
                                      ],
                                    ),
                                    // Text(
                                    //   "OR",
                                    //   style:
                                    //       TextStyle(fontWeight: FontWeight.bold),
                                    // ),
                                    /*  Column(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.photo,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                          onPressed: () async {
                                            await getImage(
                                                false, 'Community_image');
                                          }),
                                      Text("Gallery")
                                    ],
                                  ), */
                                  ],
                                ),
                                imageWidget(
                                  widget.fieldData.communityImage,
                                  _communityImage,
                                ),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 10,
                            color: Colors.deepPurple.shade100,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    new Text(
                                      'Gathering',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: width / 18,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        new IconButton(
                                            icon: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              await getImage(
                                                  true, 'Gathering_image');
                                            }),
                                        Text("Camera")
                                      ],
                                    ),
                                    // Text(
                                    //   "OR",
                                    //   style:
                                    //       TextStyle(fontWeight: FontWeight.bold),
                                    // ),
                                    /*    Column(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.photo,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                          onPressed: () async {
                                            await getImage(
                                                false, 'Gathering_image');
                                          }),
                                      Text("Gallery")
                                    ],
                                  ), */
                                  ],
                                ),
                                imageWidget(
                                  widget.fieldData.gatheringImage,
                                  _gatheringImage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: isOneImageSelected
                          ? ElevatedButton(
                              onPressed: !isUploading
                                  ? () async {
                                      setState(() {
                                        isUploading = true;
                                      });

                                      _communityImage != null
                                          ? await uploadimage(
                                              'Family_image', _communityImage)
                                          : null;
                                      _familyImage != null
                                          ? await uploadimage(
                                              'Family_image', _familyImage)
                                          : null;
                                      _leaderImage != null
                                          ? await uploadimage(
                                              'Leader_image', _leaderImage)
                                          : null;
                                      _gatheringImage != null
                                          ? await uploadimage('Gathering_image',
                                              _gatheringImage)
                                          : null;
                                      var sent = await saveLatitudeLogitude();
                                      if (sent) {
                                        setState(() {
                                          isUploading = false;
                                        });
                                        showSuccess(
                                            "Successfully  Uploaded Images");
                                        setState(() {
                                          _communityImage = null;
                                          _familyImage = null;
                                          _gatheringImage = null;
                                          _leaderImage = null;

                                          isOneImageSelected = false;
                                        });
                                      }
                                    }
                                  : null,
                              child: !isUploading
                                  ? Text(
                                      "SAVE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  : CircularProgressIndicator(),
                            )
                          : Container(),
                    ),
                  ]),
                )
              : Container(
                  child: Center(
                    child: Text("Please Switch On your Location "),
                  ),
                ));
    });
  }
}
