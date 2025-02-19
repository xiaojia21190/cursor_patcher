import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:cusor_patcher/model/settings_state.dart';
import 'package:cusor_patcher/provider/settings_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeThemeModeTile extends ConsumerWidget {
  const ChangeThemeModeTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsState settings = ref.watch(settingsProvider);
    final SettingsNotifier settingsNotifier = ref.read(settingsProvider.notifier);
    return ListTile(
      leading: Icon(Icons.dark_mode, color: settings.themeColor),
      title: Text(t.settings.interfaceSettings.themeMode),
      trailing: FilledButton.tonal(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(t.settings.interfaceSettings.themeMode),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    title: Text(t.settings.theme.system),
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      settingsNotifier.setThemeMode(value!);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile(
                    title: Text(t.settings.theme.light),
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      settingsNotifier.setThemeMode(value!);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile(
                    title: Text(t.settings.theme.dark),
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      settingsNotifier.setThemeMode(value!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Text(settings.themeMode == ThemeMode.system
            ? t.settings.theme.system
            : settings.themeMode == ThemeMode.light
                ? t.settings.theme.light
                : t.settings.theme.dark),
      ),
    );
  }
}

class ChangeThemeColorTile extends ConsumerWidget {
  const ChangeThemeColorTile({super.key});

  static const themeColors = <String, Color>{
    "Crimson": Color.fromARGB(255, 220, 20, 60),
    "Orange": Colors.orange,
    "Chrome": Color.fromARGB(255, 230, 184, 0),
    "Grass": Colors.lightGreen,
    "Teal": Colors.teal,
    "Cyan": Colors.cyan,
    "Sea Foam": Color.fromARGB(255, 112, 193, 207),
    "Ice": Color.fromARGB(255, 115, 155, 208),
    "Blue": Colors.blue,
    "Indigo": Colors.indigo,
    "Violet": Colors.deepPurple,
    "Orchid": Color.fromARGB(255, 218, 112, 214),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsState settings = ref.watch(settingsProvider);
    final SettingsNotifier settingsNotifier = ref.read(settingsProvider.notifier);
    return ListTile(
        leading: Icon(Icons.color_lens_rounded, color: settings.themeColor),
        title: Text(t.settings.interfaceSettings.themeColor),
        trailing: FilledButton.tonal(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.settings.interfaceSettings.themeColor),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: themeColors.entries
                        .map((entry) => RadioListTile(
                              activeColor: entry.value,
                              title: Text(entry.key),
                              value: entry.value,
                              groupValue: settings.themeColor,
                              onChanged: (value) {
                                settingsNotifier.setThemeColor(value!);
                                Navigator.pop(context);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            );
          },
          child: Text(t.button.select),
        ));
  }
}
