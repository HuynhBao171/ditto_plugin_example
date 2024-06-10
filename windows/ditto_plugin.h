#ifndef FLUTTER_PLUGIN_DITTO_PLUGIN_H_
#define FLUTTER_PLUGIN_DITTO_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ditto_plugin {

class DittoPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DittoPlugin();

  virtual ~DittoPlugin();

  // Disallow copy and assign.
  DittoPlugin(const DittoPlugin&) = delete;
  DittoPlugin& operator=(const DittoPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ditto_plugin

#endif  // FLUTTER_PLUGIN_DITTO_PLUGIN_H_
