import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:cusor_patcher/widgets/logs_viewe.dart';
import 'package:cusor_patcher/widgets/responsive_builder.dart';
import 'package:cusor_patcher/widgets/dialogs/cursor_version_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CursorPatcherPage extends ConsumerStatefulWidget {
  final SizingInformation sizingInformation;

  const CursorPatcherPage({super.key, required this.sizingInformation});

  @override
  ConsumerState<CursorPatcherPage> createState() => _CursorPatcherPageState();
}

class _CursorPatcherPageState extends ConsumerState<CursorPatcherPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final settings = ref.watch(settingsProvider);

    final cursorProviderNotifier = ref.watch(cursorProvider.notifier);
    cursorProviderNotifier.getCursorHelper();
    return Scaffold(
        appBar: (widget.sizingInformation.isDesktop
            ? null
            : AppBar(
                title: const Text('Cursor Patcher', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
        body: SingleChildScrollView(child: Container(
            // constraints: const BoxConstraints(maxWidth: 800),
            child: Consumer(
          builder: (context, ref, child) {
            final cursor = ref.watch(cursorProvider);
            return cursor.authCode != null
                ? Column(
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
                                    onPressed: () async {
                                      await cursorProviderNotifier.refreshAuthCode();
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
                                    value: cursor.todayRemaining.toString(),
                                    color: Colors.green,
                                  ),
                                  _buildUsageInfo(
                                    icon: Icons.calendar_today,
                                    title: '每日上限',
                                    value: cursor.maxDailyLimit.toString(),
                                    color: Colors.blue,
                                  ),
                                  _buildUsageInfo(
                                    icon: Icons.bar_chart,
                                    title: '累计使用',
                                    value: cursor.totalUsed.toString(),
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
                                    //click
                                    child: GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: cursor.authCode ?? ''));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Copied ${cursor.authCode} to clipboard!'),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(cursor.authCode ?? '未获取授权码'),
                                      ),
                                    ),
                                  ),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.flash_on),
                                      const SizedBox(width: 8),
                                      Text('快捷操作', style: Theme.of(context).textTheme.titleLarge),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.refresh),
                              title: const Text('切换账号'),
                              onTap: () async {
                                try {
                                  await ref.watch(persistenceProvider).saveToken("");
                                  await cursorProviderNotifier.replaceAuthToken();
                                  context.go('/');
                                } catch (e) {
                                  CherryToast.error(
                                    title: Text("切换账号失败", style: TextStyle(color: Colors.black)),
                                    animationType: AnimationType.fromRight,
                                    animationDuration: Duration(milliseconds: 1000),
                                    autoDismiss: true,
                                  ).show(context);
                                }
                              },
                            ),
                            //一键替换
                            ListTile(
                              leading: const Icon(Icons.flash_on),
                              title: const Text('一键替换'),
                              onTap: () async {
                                try {
                                  await cursorProviderNotifier.replaceToken(cursor.authCode ?? '');
                                  _showLogsDialog(context, ref);
                                } catch (e) {
                                  CherryToast.error(
                                    title: Text("替换失败", style: TextStyle(color: Colors.black)),
                                    animationType: AnimationType.fromRight,
                                    animationDuration: Duration(milliseconds: 1000),
                                    autoDismiss: true,
                                  ).show(context);
                                }
                              },
                            ),
                            //重制授权码
                            ListTile(
                              leading: const Icon(Icons.refresh),
                              title: const Text('重置授权码'),
                              onTap: () async {
                                try {
                                  await cursorProviderNotifier.resetAuthCode();
                                } catch (e) {
                                  CherryToast.error(
                                    title: Text("授权码重置失败", style: TextStyle(color: Colors.black)),
                                    animationType: AnimationType.fromRight,
                                    animationDuration: Duration(milliseconds: 1000),
                                    autoDismiss: true,
                                  ).show(context);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: const Text('Cursor 历史版本下载'),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const CursorVersionDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ))));
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

  // 添加显示日志弹窗的方法
  void _showLogsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('操作日志', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: LogsViewer(
                  output: ref.watch(cursorProvider).output,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
