import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ditto_plugin/ditto_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDittoPlugin platform = MethodChannelDittoPlugin();
  const MethodChannel channel = MethodChannel('ditto_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
