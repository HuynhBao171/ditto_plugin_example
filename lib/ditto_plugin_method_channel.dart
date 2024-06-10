import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ditto_plugin_platform_interface.dart';

/// An implementation of [DittoPluginPlatform] that uses method channels.
class MethodChannelDittoPlugin extends DittoPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ditto_plugin');

  @override
  Future<void> initializeDitto(String appId, String token) async {
    try {
      await methodChannel
          .invokeMethod('initializeDitto', {'appId': appId, 'token': token});
      print("Ditto initialized successfully with appId: $appId, token: $token");
    } on PlatformException catch (e) {
      print("Error initializing Ditto: ${e.message}");
    }
  }

  @override
  Future<void> save(
      {String? documentId,
      required String body,
      required bool isCompleted}) async {
    try {
      await methodChannel.invokeMethod('save', {
        'documentId': documentId,
        'body': body,
        'isCompleted': isCompleted,
      });
      print(
          "Task saved successfully: documentId: $documentId, body: $body, isCompleted: $isCompleted");
    } on PlatformException catch (e) {
      print("Error saving task: ${e.message}");
    }
  }

  @override
  Future<bool> delete(String documentId) async {
    try {
      await methodChannel.invokeMethod('delete', {'documentId': documentId});
      print("Task deleted successfully: documentId: $documentId");
      return true;
    } on PlatformException catch (e) {
      print("Error deleting task: ${e.message}");
      return false;
    }
  }

  @override
  Future<List<dynamic>> getAllTasks() async {
    try {
      final result = await methodChannel.invokeMethod('getAllTasks');
      print("Tasks retrieved successfully: $result");
      return result as List<dynamic>;
    } on PlatformException catch (e) {
      print("Error retrieving tasks: ${e.message}");
      return [];
    }
  }
}
