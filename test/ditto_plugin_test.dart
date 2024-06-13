import 'package:flutter_test/flutter_test.dart';
import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:ditto_plugin/ditto_plugin_platform_interface.dart';
import 'package:ditto_plugin/ditto_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDittoPluginPlatform
    with MockPlatformInterfaceMixin
    implements DittoPluginPlatform {
  @override
  Future<bool> deleteMessage(String messageId) {
    throw UnimplementedError();
  }

  @override
  Future<void> initializeDitto(String appId, String token) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendMessage(
      {String? messageId,
      required String content,
      required String createdAt,
      required String senderName}) {
    throw UnimplementedError();
  }

  @override
  Stream<List> streamAllMessages() {
    throw UnimplementedError();
  }
}

void main() {
  final DittoPluginPlatform initialPlatform = DittoPluginPlatform.instance;

  test('$MethodChannelDittoPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDittoPlugin>());
  });

  test('getPlatformVersion', () async {
    DittoPlugin dittoPlugin = DittoPlugin();
    MockDittoPluginPlatform fakePlatform = MockDittoPluginPlatform();
    DittoPluginPlatform.instance = fakePlatform;
  });
}
