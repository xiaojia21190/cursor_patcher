import 'package:cursor_patcher/i18n/strings.g.dart';
import 'package:cursor_patcher/provider/settings_provider.dart';
import 'package:cursor_patcher/widgets/alist_args_tile.dart';
import 'package:cursor_patcher/widgets/pages/about_page.dart';
import 'package:cursor_patcher/widgets/pages/language_page.dart';
import 'package:cursor_patcher/widgets/responsive_builder.dart';
import 'package:cursor_patcher/widgets/theme_tile.dart';
import 'package:cursor_patcher/widgets/toggle_tile.dart';
import 'package:cursor_patcher/widgets/working_directory_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.sizingInformation});
  final SizingInformation sizingInformation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (sizingInformation.isDesktop
            ? null
            : AppBar(
                title: Text(t.tabs.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
        body: const SettingsTab());
  }
}

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  @override
  void initState() {
    super.initState();
    //final settings = ref.watch(settingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(children: [
                ListTile(title: Text(t.settings.interfaceSettings.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                ChangeThemeModeTile(),
                ChangeThemeColorTile(),
                ListTile(
                  title: Text(t.settings.interfaceSettings.language),
                  leading: Icon(
                    Icons.language_rounded,
                    color: settings.themeColor,
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguagePage())),
                ),
                Container(height: 10)
              ]),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(children: [
                // ListTile(title: Text(t.settings.cursor_patcherSettings.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                // CustomToggleTile(
                //   value: settings.saveWindowPlacement,
                //   onToggled: (value) => settingsNotifier.setSaveWindowPlacement(value),
                //   title: t.settings.cursor_patcherSettings.saveWindowPlacement.title,
                //   subtitle: t.settings.cursor_patcherSettings.saveWindowPlacement.description,
                // ),
                // CustomToggleTile(
                //   value: settings.minimizeToTray,
                //   onToggled: (value) => settingsNotifier.setMinimizeToTray(value),
                //   title: t.settings.cursor_patcherSettings.minimizeToTray.title,
                //   subtitle: t.settings.cursor_patcherSettings.minimizeToTray.description,
                // ),
                // CustomToggleTile(
                //   value: settings.autoStart,
                //   onToggled: (value) => ref.watch(settingsProvider.notifier).setAutoStart(value),
                //   title: t.settings.cursor_patcherSettings.autoStart.title,
                //   subtitle: t.settings.cursor_patcherSettings.autoStart.description,
                // ),
                // CustomToggleTile(
                //   value: settings.autoStartLaunchMinimized,
                //   onToggled: (value) => settingsNotifier.setAutoStartLaunchMinimized(value),
                //   title: t.settings.cursor_patcherSettings.autoStartLaunchMinimized.title,
                //   subtitle: t.settings.cursor_patcherSettings.autoStartLaunchMinimized.description,
                // ),
                // Container(height: 10)
              ]),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(children: [
                ListTile(title: Text(t.settings.alistSettings.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                CustomToggleTile(
                  value: settings.autoStartAlist,
                  onToggled: (value) => settingsNotifier.setAutoStartAlist(value),
                  title: t.settings.alistSettings.autoStartAlist.title,
                  subtitle: t.settings.alistSettings.autoStartAlist.description,
                ),
                WorkingDirectoryTile(),
                // ProxyTile(),
                AlistArgsTile(),
                Container(height: 10)
              ]),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(children: [
                ListTile(title: Text(t.settings.rcloneSettings.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                CustomToggleTile(
                  value: settings.autoStartRclone,
                  onToggled: (value) => settingsNotifier.setAutoStartRclone(value),
                  title: t.settings.rcloneSettings.autoStartAlist.title,
                  subtitle: t.settings.rcloneSettings.autoStartAlist.description,
                ),
                CustomToggleTile(
                  value: settings.startAfterAlist,
                  onToggled: (value) => settingsNotifier.setStartAfterAlist(value),
                  title: t.settings.rcloneSettings.startAfterAlist.title,
                  subtitle: t.settings.rcloneSettings.startAfterAlist.description,
                ),
                RcloneDirectoryTile(),
                Container(height: 10)
              ]),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(children: [
                ListTile(
                  title: Text(t.settings.others.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                ),
                ListTile(
                  title: Text(t.settings.others.checkForUpdates),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage()));
                  },
                ),
                ListTile(
                  title: Text(t.settings.others.about),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                  },
                ),
                Container(height: 10)
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
