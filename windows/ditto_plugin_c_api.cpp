#include "include/ditto_plugin/ditto_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ditto_plugin.h"

void DittoPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ditto_plugin::DittoPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
