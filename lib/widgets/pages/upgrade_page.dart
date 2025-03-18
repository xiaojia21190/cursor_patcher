import 'dart:io';

import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:cusor_patcher/model/settings_state.dart';
import 'package:cusor_patcher/provider/settings_provider.dart';
import 'package:cusor_patcher/utils/textutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class UpgradePage extends ConsumerStatefulWidget {
  const UpgradePage({super.key});

  @override
  ConsumerState<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends ConsumerState<UpgradePage> {
  late PackageInfo _packageInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadPath;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      await ref.read(settingsProvider.notifier).fetchLatestVersion();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadUpdate(String url, String fileName) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      _downloadPath = path.join(tempDir.path, fileName);

      await dio.download(
        url,
        _downloadPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = '下载失败: ${e.toString()}';
      });
    }
  }

  Future<void> _installUpdate() async {
    if (_downloadPath == null) return;

    if (Platform.isWindows) {
      await Process.start(_downloadPath!, [], runInShell: true);
      exit(0);
    } else if (Platform.isMacOS) {
      await Process.start('open', [_downloadPath!]);
      exit(0);
    } else if (Platform.isLinux) {
      await Process.start('chmod', ['+x', _downloadPath!]);
      await Process.start(_downloadPath!, []);
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.others.checkForUpdates),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('错误: $_errorMessage'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('当前版本', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(_packageInfo.version),
                              const SizedBox(height: 16),
                              Text('最新版本', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(settings.latestVersion.replaceAll('v', '')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (TextUtils.isNewVersion(_packageInfo.version, settings.latestVersion.replaceAll('v', '')))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('发现新版本!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
                            const SizedBox(height: 16),
                            if (_isDownloading)
                              Column(
                                children: [
                                  LinearProgressIndicator(value: _downloadProgress),
                                  const SizedBox(height: 8),
                                  Text('下载中... ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                                ],
                              )
                            else if (_downloadPath != null)
                              ElevatedButton(
                                onPressed: _installUpdate,
                                child: Text('安装更新'),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('请选择下载方式:'),
                                  const SizedBox(height: 16),
                                  ..._buildDownloadOptions(settings),
                                ],
                              ),
                          ],
                        )
                      else
                        Text('您已经使用最新版本', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildDownloadOptions(SettingsState settings) {
    List<Widget> widgets = [];

    for (final asset in settings.newReleaseAssets) {
      final assetName = asset['name'] as String;
      final downloadUrl = asset['browser_download_url'] as String;

      widgets.add(
        Card(
          child: ListTile(
            title: Text(assetName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadUpdate(downloadUrl, assetName),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () => launchUrl(Uri.parse(downloadUrl)),
                ),
              ],
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }
}
