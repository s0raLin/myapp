//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audiotags/audiotags_plugin_c_api.h>
#include <file_selector_windows/file_selector_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudiotagsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudiotagsPluginCApi"));
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
}
