import 'dart:convert';

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
  Stream<List<Map<String, dynamic>>> streamAllMessages() {
    const EventChannel eventChannel = EventChannel('ditto_plugin/chat');
    print("Stream all tasks");
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      print("Event: $event");
      final jsonData = event.replaceAll('"_id"', '"id"') as String;
      final List<dynamic> tasksData = jsonDecode(jsonData);
      final List<Map<String, dynamic>> tasks =
          tasksData.cast<Map<String, dynamic>>().toList();

      return tasks;
    });
  }

  @override
  Future<void> sendMessage(
      {String? messageId,
      required String content,
      required String createdAt,
      required String senderName}) async {
    try {
      await methodChannel.invokeMethod('sendMessage', {
        'messageId': messageId,
        'content': content,
        'createdAt': createdAt,
        'senderName': senderName,
      });
    } on PlatformException catch (e) {
      print("Failed to send message: ${e.message}");
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) {
    return DittoPluginPlatform.instance.deleteMessage(messageId);
  }
}
