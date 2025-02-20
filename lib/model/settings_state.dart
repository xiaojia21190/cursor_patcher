import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required bool minimizeToTray,
    required bool autoStartLaunchMinimized,
    required bool saveWindowPlacement,
    required ThemeMode themeMode,
    required Color themeColor,
    required AppLocale? locale,
    required String? proxy,
    required bool isFirstRun,
    required String webdavAccount,
    @Default('v0.0.0') String currentVersion,
    @Default('v0.0.0') String latestVersion,
    @Default([]) List<Map> newReleaseAssets,
  }) = _SettingsState;
}
