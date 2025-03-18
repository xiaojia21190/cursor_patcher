import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class CursorVersionNewDialog extends ConsumerStatefulWidget {
  const CursorVersionNewDialog({super.key});

  @override
  ConsumerState<CursorVersionNewDialog> createState() => _CursorVersionNewDialogState();
}

class _CursorVersionNewDialogState extends ConsumerState<CursorVersionNewDialog> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cursorProviderNotifier = ref.watch(cursorProvider.notifier);
    cursorProviderNotifier.getNewVersion();
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
              onChanged: (value) async {
                await ref.watch(cursorProvider.notifier).getFilterVersion(value);
              },
            ),

            const SizedBox(height: 16),
            const Divider(),

            // 版本列表
            Consumer(builder: (context, ref, child) {
              final cursor = ref.watch(cursorProvider);
              return cursor.filterCursorVersion.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: cursor.filterCursorVersion.length,
                        itemBuilder: (context, index) {
                          final version = cursor.filterCursorVersion[index];
                          final buildid = version.split("_")[1];
                          final lastVersion = version.split("_")[0];
                          return ExpansionTile(
                            title: Text('版本 $lastVersion', style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              // Windows 下载区域
                              _buildSystemSection(context, 'Windows', Icons.window, [
                                _DownloadOption('Windows x64', 'https://downloads.cursor.com/production/$buildid/win32/x64/user-setup/CursorUserSetup-x64-$lastVersion.exe', 'AWS下载'),
                                _DownloadOption('Windows ARM64', 'https://downloads.cursor.com/production/$buildid/win32/arm64/user-setup/CursorUserSetup-arm64-$lastVersion.exe', 'AWS下载'),
                              ]),

                              const SizedBox(height: 8),

                              // macOS 下载区域
                              _buildSystemSection(context, 'macOS', Icons.laptop_mac, [
                                _DownloadOption('Universal', 'https://downloads.cursor.com/production/$buildid/darwin/universal/Cursor-darwin-universal.dmg', 'AWS下载'),
                                _DownloadOption('Apple Silicon', 'https://downloads.cursor.com/production/$buildid/darwin/arm64/Cursor-darwin-arm64.dmg', 'AWS下载'),
                                _DownloadOption('Intel', 'https://downloads.cursor.com/production/$buildid/darwin/x64/Cursor-darwin-x64.dmg', 'AWS下载'),
                              ]),

                              const SizedBox(height: 8),

                              // Linux 下载区域
                              _buildSystemSection(context, 'Linux', Icons.computer, [
                                _DownloadOption('x86_64', 'https://downloads.cursor.com/production/client/linux/x64/appimage/Cursor-$version.deb.glibc2.25-x86_64.AppImage', 'AWS下载'),
                                _DownloadOption('ARM64', 'https://downloads.cursor.com/production/client/linux-arm64/appimage/Cursor-$version.deb.glibc2.28-aarch64.AppImage', 'AWS下载'),
                              ]),
                            ],
                          );
                        },
                      ),
                    )
                  : Expanded(child: const Center(child: CircularProgressIndicator()));
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
  final String officialText;

  _DownloadOption(this.name, this.url, this.officialText);
}
