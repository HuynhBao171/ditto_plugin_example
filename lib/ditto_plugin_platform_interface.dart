import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ditto_plugin_method_channel.dart';

abstract class DittoPluginPlatform extends PlatformInterface {
  /// Constructs a DittoPluginPlatform.
  DittoPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static DittoPluginPlatform _instance = MethodChannelDittoPlugin();

  /// The default instance of [DittoPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelDittoPlugin].
  static DittoPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DittoPluginPlatform] when
  /// they register themselves.
  static set instance(DittoPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initializeDitto(String appId, String token);

  Future<void> save(
      {String? documentId, required String body, required bool isCompleted});

  Future<bool> delete(String documentId);

  Future<List<dynamic>> getAllTasks();

  Stream<List<dynamic>> streamAllTasks();

  // Các phương thức cho Live Query
  Future<void> startLiveQuery(String collectionName, String query);
  Future<void> stopLiveQuery(String collectionName);
  Stream<List<dynamic>> liveQueryStream(String collectionName);

  // // Các phương thức cho Bluetooth
  // Future<void> startBluetoothDataTransfer(String deviceId);
  // Future<void> stopBluetoothDataTransfer();
  // Stream<dynamic> bluetoothDataStream();
}
