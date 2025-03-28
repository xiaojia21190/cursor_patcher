import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:cusor_patcher/provider/settings_provider.dart';
import 'package:cusor_patcher/theme.dart';
import 'package:cusor_patcher/utils/init.dart';
import 'package:cusor_patcher/utils/native/tray_helper.dart';
import 'package:cusor_patcher/utils/native/tray_manager.dart';
import 'package:cusor_patcher/utils/native/window_watcher.dart';
import 'package:cusor_patcher/widgets/pages/choose_pool.dart';
import 'package:cusor_patcher/widgets/pages/cursor_pool_page.dart';
import 'package:cusor_patcher/widgets/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> main(List<String> args) async {
  final persistenceService = await preInit(args);

  runApp(ProviderScope(overrides: [
    persistenceProvider.overrideWithValue(persistenceService),
  ], child: TranslationProvider(child: const MyApp())));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const ChoosePool();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'cursorPool',
          builder: (BuildContext context, GoRouterState state) {
            return const CursorPoolPage();
          },
        ),
        GoRoute(
          path: 'home/:isAccount',
          builder: (BuildContext context, GoRouterState state) {
            final query = state.pathParameters['isAccount'];
            return Home(isAccount: query == '1');
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
    // 启动后检查更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).startPeriodicUpdateCheck(context);
    });

    final settings = ref.watch(settingsProvider);
    //删除provider
    // final per = ref.read(persistenceProvider);
    // per.clearStorage();
    return TrayWatcher(
      child: WindowWatcher(
        onClose: () async {
          try {
            if (ref.watch(settingsProvider).minimizeToTray) {
              await hideToTray();
            } else {
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
