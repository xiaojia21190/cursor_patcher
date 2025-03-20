import 'dart:convert';
import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:cusor_patcher/model/settings_state.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cusor_patcher/utils/textutils.dart';
import 'package:cusor_patcher/widgets/pages/upgrade_page.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late PersistenceService _persistenceService;
  bool _hasCheckedForUpdates = false;

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
      currentVersion: _persistenceService.getCursorPatcherVersion(),
    );
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
    try {
      // 从JSON文件获取版本信息，这里使用一个静态URL
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/xiaojia21190/cursor_patcher/main/version.json'));

      if (response.statusCode != 200) {
        throw Exception('获取版本信息失败，状态码: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      String latest = json['version'];
      List assets = json['assets'] ?? [];

      // 确定当前平台
      String platformKey = Platform.isWindows ? 'windows' : (Platform.isMacOS ? 'macos' : 'linux');

      // 过滤当前平台的资源
      List<Map> assetsForSpecificPlatform = [];
      for (var asset in assets) {
        if (asset is Map && asset['name'].toString().contains(platformKey)) {
          assetsForSpecificPlatform.add(asset);
        }
      }

      state = state.copyWith(latestVersion: latest, newReleaseAssets: assetsForSpecificPlatform);
    } catch (e) {
      debugPrint('获取版本信息失败: $e');
      throw Exception('获取版本信息失败: $e');
    }
  }

  Future<bool> checkForUpdatesIfNeeded() async {
    if (_hasCheckedForUpdates) return false;

    try {
      _hasCheckedForUpdates = true;
      await fetchLatestVersion();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final latestVersion = state.latestVersion.replaceAll('v', '');

      return TextUtils.isNewVersion(currentVersion, latestVersion);
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return false;
    }
  }

  void startPeriodicUpdateCheck(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () async {
      final hasUpdate = await checkForUpdatesIfNeeded();
      if (hasUpdate && context.mounted) {
        _showUpdateNotification(context);
      }
    });
  }

  void _showUpdateNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: const Text('有新版本可用，是否前往更新页面？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.button.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePage()));
            },
            child: Text(t.button.ok),
          ),
        ],
      ),
    );
  }
}
