import 'package:cursor_patcher/i18n/strings.g.dart';
import 'package:cursor_patcher/provider/settings_provider.dart';
import 'package:cursor_patcher/widgets/button_card.dart';
// import 'package:cursor_patcher/widgets/pages/first_launch_page.dart';
import 'package:cursor_patcher/widgets/logs_viewer.dart';
import 'package:cursor_patcher/widgets/responsive_builder.dart';
import 'package:cursor_patcher/widgets/sponsor_btn.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class CursorPatcherPage extends ConsumerWidget {
  final SizingInformation sizingInformation;

  const CursorPatcherPage({super.key, required this.sizingInformation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (settings.isFirstRun == true) {
      // return FirstLaunchPage(sizingInformation: sizingInformation);
    }
    return Scaffold(
        appBar: (sizingInformation.isDesktop
            ? null
            : AppBar(
                title: const Text('Cursor Patcher', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
        body: Center(
            child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security, size: 24),
                          const SizedBox(width: 8),
                          Text('授权码信息', style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              // TODO: 实现刷新功能
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text('以下数据显示您的Token获取限制和使用情况'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUsageInfo(
                            icon: Icons.access_time,
                            title: '今日剩余',
                            value: '10',
                            color: Colors.green,
                          ),
                          _buildUsageInfo(
                            icon: Icons.calendar_today,
                            title: '每日上限',
                            value: '10',
                            color: Colors.blue,
                          ),
                          _buildUsageInfo(
                            icon: Icons.bar_chart,
                            title: '累计使用',
                            value: '1',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('您的专属授权码'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("" ?? '未获取授权码'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on),
                          const SizedBox(width: 8),
                          Text('快捷操作', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('下载最新脚本'),
                      onTap: () {
                        // TODO: 实现下载功能
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.token),
                      title: const Text('提交Token'),
                      onTap: () {
                        // TODO: 实现Token提交功能
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('加入TG群组'),
                      onTap: () => launchUrl(Uri.parse('https://t.me/cursor_chat')),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Cursor 历史版本下载'),
                      onTap: () {
                        // TODO: 实现历史版本下载
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SponsorBtn(),
              ListTile(
                title: Text(t.home.logs, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              ),
              Expanded(
                child: Card(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: LogsViewer(
                      output: ["test"],
                    )),
              ),
            ],
          ),
        )));
  }

  Widget _buildUsageInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
