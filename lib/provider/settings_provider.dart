import 'package:cursor_patcher/i18n/strings.g.dart';
import 'package:cursor_patcher/utils/native/auto_start_helper.dart';
import 'package:flutter/material.dart';
import 'package:cursor_patcher/model/settings_state.dart';
import 'package:cursor_patcher/provider/persistence_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late PersistenceService _persistenceService;

  @override
  SettingsState build() {
    _persistenceService = ref.watch(persistenceProvider);
    return SettingsState(
      locale: _persistenceService.getLocale(),
      minimizeToTray: _persistenceService.isMinimizeToTray(),
      autoStartLaunchMinimized: _persistenceService.isAutoStartLaunchMinimized(),
      autoStart: _persistenceService.isAutoStart(),
      workingDirectory: _persistenceService.getWorkingDirectory(),
      rcloneDirectory: _persistenceService.getRcloneDirectory(),
      themeMode: _persistenceService.getThemeMode(),
      themeColor: _persistenceService.getThemeColor(),
      saveWindowPlacement: _persistenceService.getSaveWindowPlacement(),
      proxy: _persistenceService.getProxy(),
      isFirstRun: _persistenceService.isFirstRun(),
      webdavAccount: _persistenceService.getWebdavAccount(),
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

  Future<void> setAutoStartLaunchMinimized(bool value) async {
    await _persistenceService.setAutoStartLaunchMinimized(value);
    state = state.copyWith(autoStartLaunchMinimized: value);
  }

  Future<void> setAutoStart(bool value) async {
    await _persistenceService.setAutoStart(value);
    initAutoStartAndOpenSettings(value);
    state = state.copyWith(autoStart: value);
  }

  Future<void> setWorkingDirectory(String value) async {
    await _persistenceService.setWorkingDirectory(value);
    state = state.copyWith(workingDirectory: value);
  }

  Future<void> setRcloneDirectory(String value) async {
    await _persistenceService.setRcloneDirectory(value);
    state = state.copyWith(rcloneDirectory: value);
  }

  Future<void> setSaveWindowPlacement(bool value) async {
    await _persistenceService.setSaveWindowPlacement(value);
    state = state.copyWith(saveWindowPlacement: value);
  }
}
