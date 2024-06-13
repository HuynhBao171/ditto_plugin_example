import 'package:flutter/services.dart';

import 'ditto_plugin_platform_interface.dart';

class DittoPlugin {
  // Access the platform instance directly for methods
  Future<void> initializeDitto(String appId, String token) {
    return DittoPluginPlatform.instance.initializeDitto(appId, token);
  }

  Future<void> save(
      {String? documentId,
      required String body,
      required bool isCompleted}) async {
    try {
      await DittoPluginPlatform.instance
          .save(documentId: documentId, body: body, isCompleted: isCompleted);
    } on PlatformException catch (e) {
      print("Failed to save task: ${e.message}");
    }
  }

  Future<bool> delete(String documentId) {
    return DittoPluginPlatform.instance.delete(documentId);
  }

  Future<List<dynamic>> getAllTasks() {
    return DittoPluginPlatform.instance.getAllTasks();
  }

  Stream<List<dynamic>> streamAllTasks() {
    return DittoPluginPlatform.instance.streamAllTasks();
  }
}
