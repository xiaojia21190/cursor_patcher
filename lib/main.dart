import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:cusor_patcher/provider/settings_provider.dart';
import 'package:cusor_patcher/theme.dart';
import 'package:cusor_patcher/utils/init.dart';
import 'package:cusor_patcher/utils/native/tray_helper.dart';
import 'package:cusor_patcher/utils/native/tray_manager.dart';
import 'package:cusor_patcher/utils/native/window_watcher.dart';
import 'package:cusor_patcher/widgets/pages/first_lanuch.dart';
import 'package:cusor_patcher/widgets/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> main(List<String> args) async {
  final persistenceService = await preInit(args);

  runApp(ProviderScope(overrides: [
    persistenceProvider.overrideWithValue(persistenceService),
    // appArgumentsProvider.overrideWith((ref) => args),
  ], child: TranslationProvider(child: const MyApp())));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const FirstLaunchPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const Home();
          },
        ),
      ],
    ),
  ],
);

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
        child: MaterialApp.router(
          title: 'Cursor Patcher',
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: settings.themeMode,
          theme: CursorPatcherTheme(settings.themeColor).lightThemeData,
          darkTheme: CursorPatcherTheme(settings.themeColor).darkThemeData,
          routerConfig: _router,
        ),
      ),
    );
  }
}
