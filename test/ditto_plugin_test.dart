import 'package:flutter_test/flutter_test.dart';
import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:ditto_plugin/ditto_plugin_platform_interface.dart';
import 'package:ditto_plugin/ditto_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDittoPluginPlatform
    with MockPlatformInterfaceMixin
    implements DittoPluginPlatform {
  Future<String?> getPlatformVersion() => Future.value('42');

  Future<void> createDocument(
      String collectionName, Map<String, dynamic> data) {
    // TODO: implement createDocument
    throw UnimplementedError();
  }

  Future<void> deleteDocument(String collectionName, String documentId) {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

  Future<void> initializeDitto(String appId, String token) {
    // TODO: implement initializeDitto
    throw UnimplementedError();
  }

  Future<bool> delete(String documentId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  Future<List> getAllTasks() {
    // TODO: implement getAllTasks
    throw UnimplementedError();
  }

  Future<void> save(
      {String? documentId, required String body, required bool isCompleted}) {
    // TODO: implement save
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
