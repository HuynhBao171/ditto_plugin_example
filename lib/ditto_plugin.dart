import 'package:flutter/services.dart';

import 'ditto_plugin_platform_interface.dart';

class DittoPlugin {
  // Access the platform instance directly for methods
  Future<void> initializeDitto(String appId, String token) {
    return DittoPluginPlatform.instance.initializeDitto(appId, token);
  }

  Future<void> sendMessage({
    String? messageId,
    required String content,
    required String createdAt,
    required String senderName,
  }) async {
    try {
      await DittoPluginPlatform.instance.sendMessage(
        messageId: messageId,
        content: content,
        createdAt: createdAt,
        senderName: senderName,
      );
    } on PlatformException catch (e) {
      print("Failed to send message: ${e.message}");
    }
  }

  Future<bool> deleteMessage(String messageId) {
    return DittoPluginPlatform.instance.deleteMessage(messageId);
  }

  Stream<List<dynamic>> streamAllMessages() {
    return DittoPluginPlatform.instance.streamAllMessages();
  }
}
