/* import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermitionScreen extends StatefulWidget {
  /// Constructs a [LocationPermitionScreen] for the supplied [Permission].
  const LocationPermitionScreen({this.permission, this.onTaped});

  final Permission permission;
  final Function onTaped;
  @override
  PermissionState createState() => PermissionState(permission);
}

class PermissionState extends State<LocationPermitionScreen> {
  PermissionState(this.permission);

  final Permission permission;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await permission.status;
    setState(() => permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !permissionStatus.isGranted
          ? Center(
              child: ListTile(
              title: Text(
                permission.toString(),
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: Text(
                permissionStatus.toString(),
                style: TextStyle(color: getPermissionColor()),
              ),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    checkServiceStatus(context, permission);
                  }),
              onTap: () {
                requestPermission(permission);
              },
            ))
          : Center(
              child: ElevatedButton(
                  onPressed: widget.onTaped, child: Text("Continue"))),
    );
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.status).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      permissionStatus = status;
      print(permissionStatus);
    });
  }
}
 */