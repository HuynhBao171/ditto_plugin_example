import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:logger/logger.dart';

import 'presentation/home_page.dart';

String appId = 'e39d315c-64ff-49bb-8954-a2690cc23f6c';
String token = 'e1896c94-7851-46cc-a4d3-4a04042fbd39';
Logger logger = Logger();
void main() {
  runApp(const MyApp());
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
    _initializeDitto();
  }

  Future<void> _initializeDitto() async {
    try {
      await _dittoPlugin.initializeDitto(appId, token);
      logger.i('Ditto initialized successfully!');
    } on PlatformException catch (e) {
      logger.e('Failed to initialize Ditto: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
