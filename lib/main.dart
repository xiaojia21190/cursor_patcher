import 'dart:io';

import 'package:cursor_patcher/i18n/strings.g.dart';
import 'package:cursor_patcher/provider/persistence_provider.dart';
import 'package:cursor_patcher/provider/settings_provider.dart';
import 'package:cursor_patcher/theme.dart';
import 'package:cursor_patcher/utils/init.dart';
import 'package:cursor_patcher/utils/native/tray_helper.dart';
import 'package:cursor_patcher/utils/native/tray_manager.dart';
import 'package:cursor_patcher/utils/native/window_watcher.dart';
import 'package:cursor_patcher/widgets/pages/first_lanuch.dart';
import 'package:cursor_patcher/widgets/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main(List<String> args) async {
  final persistenceService = await preInit(args);

  runApp(ProviderScope(overrides: [
    persistenceProvider.overrideWithValue(persistenceService),
    // appArgumentsProvider.overrideWith((ref) => args),
  ], child: TranslationProvider(child: const MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // final alistNotifier = ref.watch(alistProvider.notifier);
    // final rcloneNotifier = ref.watch(rcloneProvider.notifier);
    return TrayWatcher(
      child: WindowWatcher(
        onClose: () async {
          try {
            if (ref.watch(settingsProvider).minimizeToTray) {
              await hideToTray();
            } else {
              // await alistNotifier.endAlist();
              // await rcloneNotifier.endRclone();
              exit(0);
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        child: MaterialApp(
          title: 'Cursor Patcher',
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: settings.themeMode,
          theme: CursorPatcherTheme(settings.themeColor).lightThemeData,
          darkTheme: CursorPatcherTheme(settings.themeColor).darkThemeData,
          home: const FirstLaunchPage(),
        ),
      ),
    );
  }
}
