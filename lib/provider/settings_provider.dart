import 'dart:convert';
import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:cusor_patcher/model/settings_state.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late PersistenceService _persistenceService;

  @override
  SettingsState build() {
    _persistenceService = ref.watch(persistenceProvider);
    return SettingsState(
      locale: _persistenceService.getLocale(),
      minimizeToTray: _persistenceService.isMinimizeToTray(),
      themeMode: _persistenceService.getThemeMode(),
      themeColor: _persistenceService.getThemeColor(),
      saveWindowPlacement: _persistenceService.getSaveWindowPlacement(),
      proxy: _persistenceService.getProxy(),
      isFirstRun: _persistenceService.isFirstRun(),
      webdavAccount: _persistenceService.getWebdavAccount(),
      currentVersion: _persistenceService.getCursorPatcherVersion(),
    );
  }

  Future<void> setWebdavAccount(String value) async {
    await _persistenceService.setWebdavAccount(value);
    state = state.copyWith(webdavAccount: value);
  }

  Future<void> setFirstRun(bool value) async {
    await _persistenceService.setFirstRun(value);
    state = state.copyWith(isFirstRun: value);
  }

  Future<void> setProxy(String? proxy) async {
    await _persistenceService.setProxy(proxy);
    state = state.copyWith(proxy: proxy);
  }

  Future<void> setLocale(AppLocale? locale) async {
    await _persistenceService.setLocale(locale);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeColor(Color value) async {
    await _persistenceService.setThemeColor(value);
    state = state.copyWith(themeColor: value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    await _persistenceService.setThemeMode(value);
    state = state.copyWith(themeMode: value);
  }

  Future<void> setMinimizeToTray(bool value) async {
    await _persistenceService.setMinimizeToTray(value);
    state = state.copyWith(minimizeToTray: value);
  }

  Future<void> setSaveWindowPlacement(bool value) async {
    await _persistenceService.setSaveWindowPlacement(value);
    state = state.copyWith(saveWindowPlacement: value);
  }

  Future<void> fetchLatestVersion() async {
    final response = await http.get(Uri.parse('https://api.github.com/repos/xiaojia21190/cursor_patcher/releases/latest'));
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      String latest = json['tag_name'];
      List assets = json['assets'];
      String platformKey = Platform.isWindows ? 'windows' : (Platform.isMacOS ? 'macos' : 'linux');
      List<Map> assetsForSpecificPlatform = [];
      for (Map asset in assets) {
        if (asset['name'].contains(platformKey)) {
          assetsForSpecificPlatform.add(asset);
        }
      }
      state = state.copyWith(latestVersion: latest, newReleaseAssets: assetsForSpecificPlatform);
    } catch (e) {
      throw Exception('$e\nFailed to get latest version when fetching: ${json.toString()}');
    }
  }
}
