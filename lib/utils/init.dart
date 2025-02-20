import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:cusor_patcher/provider/window_dimensions_provider.dart';
import 'package:cusor_patcher/utils/native/tray_helper.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Pre-initializes the app.
/// Reads the command line arguments and initializes the [PersistenceService].
/// Initializes the tray and the window manager.
Future<PersistenceService> preInit(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 确保PersistenceService完全初始化
  final persistenceService = await PersistenceService.initialize();
  // if (persistenceService) {
  //   throw Exception('Failed to initialize PersistenceService');
  // }

  // Register default plural resolver
  for (final locale in AppLocale.values) {
    if ([AppLocale.en].contains(locale)) {
      continue;
    }

    LocaleSettings.setPluralResolver(
      locale: locale,
      cardinalResolver: (n, {zero, one, two, few, many, other}) {
        if (n == 0) {
          return zero ?? other ?? n.toString();
        }
        if (n == 1) {
          return one ?? other ?? n.toString();
        }
        return other ?? n.toString();
      },
      ordinalResolver: (n, {zero, one, two, few, many, other}) {
        return other ?? n.toString();
      },
    );
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Check if this app is already open and let it "show up".
    // If this is the case, then exit the current instance.
    // initialize tray AFTER i18n has been initialized
    try {
      await initTray();
    } catch (e) {
      debugPrint('Initializing tray failed: $e');
    }

    // initialize size and position
    await WindowManager.instance.ensureInitialized();
    await WindowDimensionsController(persistenceService).initDimensionsConfiguration();

    // WindowOptions windowOptions = WindowOptions(
    //   center: true,
    //   backgroundColor: Colors.white, // 尝试一个非透明的颜色
    //   skipTaskbar: false,
    //   title: "My Flutter App", // 设置标题
    // );

    // windowManager.waitUntilReadyToShow(windowOptions, () async {
    //   try {
    await WindowManager.instance.show();
    await WindowManager.instance.focus();
    //   } catch (e) {
    //     print('Error showing/focusing window: $e');
    //   }
    // });
  }
  return persistenceService;
}
