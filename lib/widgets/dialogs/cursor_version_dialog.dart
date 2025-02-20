import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class CursorVersionDialog extends ConsumerStatefulWidget {
  const CursorVersionDialog({super.key});

  @override
  ConsumerState<CursorVersionDialog> createState() => _CursorVersionDialogState();
}

class _CursorVersionDialogState extends ConsumerState<CursorVersionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final List<String> _versions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredVersions {
    if (_searchText.isEmpty) {
      return _versions;
    }
    return _versions.where((version) => version.toLowerCase().contains(_searchText.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cursorProviderNotifier = ref.watch(cursorProvider.notifier);
    cursorProviderNotifier.getVersion();
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Cursor 历史版本下载', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索版本...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),

            const SizedBox(height: 16),
            const Divider(),

            // 版本列表
            Consumer(builder: (context, ref, child) {
              final cursor = ref.watch(cursorProvider);
              return cursor.cursorVersion.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: cursor.cursorVersion.length,
                        itemBuilder: (context, index) {
                          final version = cursor.cursorVersion[index];
                          final version1 = version.split(',')[0].toString();
                          final version2 = version.split(',')[1];
                          return ExpansionTile(
                            title: Text('版本 $version1', style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              // Windows 下载区域
                              _buildSystemSection(context, 'Windows', Icons.window, [
                                _DownloadOption('Windows x64', 'https://downloader.cursor.sh/builds/$version2/windows/nsis/x64', 'https://download.todesktop.com/230313mzl4w4u92/Cursor%20Setup%200.45.14%20-%20Build%20$version2-x64.exe', '官网下载', 'ToDesk下载'),
                                _DownloadOption('Windows ARM64', 'https://downloader.cursor.sh/builds/$version2/windows/nsis/arm64', 'https://download.todesktop.com/230313mzl4w4u92/Cursor%20Setup%200.45.14%20-%20Build%20$version2-arm64.exe', '官网下载', 'ToDesk下载'),
                              ]),

                              const SizedBox(height: 8),

                              // macOS 下载区域
                              _buildSystemSection(context, 'macOS', Icons.laptop_mac, [
                                _DownloadOption('Apple Silicon', 'https://downloader.cursor.sh/builds/250219jnihavxsz/mac/installer/arm64', 'https://download.todesktop.com/230313mzl4w4u92/Cursor%200.45.14%20-%20Build%20250219jnihavxsz-arm64.dmg', '官网下载', 'ToDesk下载'),
                                _DownloadOption('Intel', 'https://downloader.cursor.sh/builds/250219jnihavxsz/mac/installer/x64', 'https://download.todesktop.com/230313mzl4w4u92/Cursor%200.45.14%20-%20Build%20250219jnihavxsz-x64.dmg', '官网下载', 'ToDesk下载'),
                              ]),

                              const SizedBox(height: 8),

                              // Linux 下载区域
                              _buildSystemSection(context, 'Linux', Icons.computer, [
                                _DownloadOption('通用版本', 'https://downloader.cursor.sh/builds/250219jnihavxsz/linux/appImage/x64', 'https://download.todesktop.com/230313mzl4w4u92/cursor-0.45.14-build-250219jnihavxsz-x86_64.AppImage', '官网下载', 'ToDesk下载'),
                              ]),
                            ],
                          );
                        },
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSection(BuildContext context, String title, IconData icon, List<_DownloadOption> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...options.map((option) => _buildDownloadOption(context, option)).toList(),
        ],
      ),
    );
  }

  Widget _buildDownloadOption(BuildContext context, _DownloadOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(option.name, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          TextButton(
            onPressed: () => _launchUrl(option.url),
            child: Text(option.todeskText),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _launchUrl(option.url),
            child: Text(option.officialText),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}

class _DownloadOption {
  final String name;
  final String url;
  final String todeskUrl;
  final String todeskText;
  final String officialText;

  _DownloadOption(this.name, this.url, this.todeskUrl, this.todeskText, this.officialText);
}
