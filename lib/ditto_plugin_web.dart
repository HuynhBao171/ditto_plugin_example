// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'ditto_plugin_platform_interface.dart';

/// A web implementation of the DittoPluginPlatform of the DittoPlugin plugin.
class DittoPluginWeb extends DittoPluginPlatform {
  /// Constructs a DittoPluginWeb
  DittoPluginWeb();

  static void registerWith(Registrar registrar) {
    DittoPluginPlatform.instance = DittoPluginWeb();
  }

  @override
  Future<void> initializeDitto(String appId, String token) {
    throw UnimplementedError();
  }

  // Loại bỏ setupWithDocument

  @override
  Future<void> save(
      {String? documentId, required String body, required bool isCompleted}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String documentId) {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getAllTasks() {
    throw UnimplementedError();
  }

  @override
  Stream<List> streamAllTasks() {
    throw UnimplementedError();
  }
}
