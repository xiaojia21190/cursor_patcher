import 'dart:io';
import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:tray_manager/tray_manager.dart' as tm;
import 'package:window_manager/window_manager.dart';

enum TrayEntry {
  open,
  quit,
  hide,
}

Future<void> initTray() async {
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    return;
  }
  String iconPath = Platform.isWindows ? 'assets/cursor.ico' : 'assets/cursor.png';
  await tm.trayManager.setIcon(iconPath);

  final items = [
    tm.MenuItem(key: TrayEntry.open.name, label: t.tray.open),
    tm.MenuItem(key: TrayEntry.hide.name, label: t.tray.hide),
    tm.MenuItem(key: TrayEntry.quit.name, label: t.tray.quit),
  ];
  await tm.trayManager.setContextMenu(tm.Menu(items: items));
  await tm.trayManager.setToolTip(t.tray.tooltip);
}

Future<void> hideToTray() async {
  await windowManager.hide();
  if (Platform.isMacOS) {
    // This will crash on Windows
    // https://github.com/localsend/localsend/issues/32
    await windowManager.setSkipTaskbar(true);
  }
}

Future<void> showFromTray() async {
  await windowManager.show();
  await windowManager.focus();
  if (Platform.isMacOS) {
    // This will crash on Windows
    // https://github.com/localsend/localsend/issues/32
    await windowManager.setSkipTaskbar(false);
  }
}
