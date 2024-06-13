import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'presentation/home_page.dart';

String appId = 'e39d315c-64ff-49bb-8954-a2690cc23f6c';
String token = 'e1896c94-7851-46cc-a4d3-4a04042fbd39';
Logger logger = Logger();
void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _dittoPlugin = DittoPlugin();

  @override
  void initState() {
    super.initState();
    // _initializeDitto();
    // _requestPermissions();
  }

  Future<void> _initializeDitto() async {
    try {
      await _dittoPlugin.initializeDitto(appId, token);
      logger.i('Ditto initialized successfully!');
    } on PlatformException catch (e) {
      logger.e('Failed to initialize Ditto: ${e.message}');
    }
  }

  Future<void> _requestPermissions() async {
    var permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage,
      Permission.nearbyWifiDevices,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }

    statuses.forEach((permission, status) {
      if (status.isGranted) {
        logger.i("$permission granted");
      } else {
        logger.w("$permission denied");

        // Hiển thị dialog giải thích
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permission Request'),
              content: Text(
                  'The app requires $permission permission to function. Please grant the permission in settings.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _initializeDitto(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Xử lý lỗi nếu có
              return Text('Error: ${snapshot.error}');
            } else {
              // Hiển thị HomePage khi khởi tạo thành công
              return const HomePage();
            }
          } else {
            // Hiển thị một widget loading khi đang khởi tạo
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
