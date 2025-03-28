import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
// import 'package:cusor_patcher/model/token_data.dart';
import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:cusor_patcher/widgets/dialogs/cursor_version_new_dialog.dart';
import 'package:cusor_patcher/widgets/dialogs/log_dialog.dart';
import 'package:cusor_patcher/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({super.key, required this.sizingInformation});
  final SizingInformation sizingInformation;

  @override
  ConsumerState<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cursorProviderNotifier = ref.read(cursorProvider.notifier);
    return Scaffold(
      appBar: (widget.sizingInformation.isDesktop
          ? null
          : AppBar(
              title: const Text('我的账户', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer(builder: (context, ref, child) {
                  final cursor = ref.watch(cursorProvider.select((state) => state.tokenData));
                  return cursor.email != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_circle, size: 24),
                                const SizedBox(width: 8),
                                Text('Cursor账户配置', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text('请填写Cursor账户信息，配置文件将使用这些信息进行替换'),
                            //sub
                            const SizedBox(height: 16),
                            Text("用户ID: ${cursor.userId}"),
                            const SizedBox(height: 16),
                            Text("邮箱地址：${cursor.email}"),
                            const SizedBox(height: 16),
                            Text("Token：${cursor.token}"),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Consumer(builder: (context, ref, child) {
                                  ref.watch(cursorProvider);
                                  return Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => {cursorProviderNotifier.emptyToken()},
                                      icon: const Icon(Icons.sync),
                                      label: const Text('切换账户'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_circle, size: 24),
                                const SizedBox(width: 8),
                                Text('Cursor账户配置', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text('请填写Cursor账户信息，配置文件将使用这些信息进行替换'),
                            //sub
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _userIdController,
                              label: '用户ID',
                              icon: Icons.person,
                              hintText: '请输入用户ID-user_01JPREZG***',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              label: '邮箱地址',
                              icon: Icons.email,
                              hintText: '请输入邮箱地址-user@example.com',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _tokenController,
                              label: 'Token',
                              icon: Icons.token,
                              hintText: '请输入Token-eyJhbGciOi***',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Consumer(builder: (context, ref, child) {
                                  ref.watch(cursorProvider);
                                  return Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _replaceAccountInfo(context),
                                      icon: const Icon(Icons.sync),
                                      label: const Text('替换账户信息'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        );
                }),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 30,
                      children: [
                        Expanded(
                          flex: 1,
                          //禁用更新
                          child: FilledButton.icon(
                            onPressed: () {
                              _showLogsDialog(context);
                              cursorProviderNotifier.disableAutoUpdate();
                            },
                            label: const Text('禁用更新'),
                            icon: const Icon(Icons.update_disabled),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          //禁用更新
                          child: FilledButton.icon(
                            onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (context) => const CursorVersionNewDialog(),
                              )
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Cursor 历史版本下载(0.45.14以后)'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 24),
                        SizedBox(width: 8),
                        Text('使用说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('1. 填写完整的Cursor账户信息，包括邮箱、Token和设备ID'),
                    const SizedBox(height: 4),
                    const Text('2. 点击"替换账户信息"按钮执行替换操作'),
                    const SizedBox(height: 4),
                    const Text('3. 替换前请确保已关闭所有Cursor进程'),
                    const SizedBox(height: 4),
                    const Text('4. 替换完成后重新启动Cursor即可使用新账户'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String hintText = '',
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: controller.text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已复制$label')),
            );
          },
        ),
      ),
      maxLines: maxLines,
    );
  }

  void _replaceAccountInfo(BuildContext context) async {
    if (_emailController.text.isEmpty || _tokenController.text.isEmpty || _userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少填写邮箱、Token和用户ID字段')),
      );
      return;
    }

    try {
      _showLogsDialog(context);

      await ref.read(cursorProvider.notifier).replaceCustomAccountInfo(
            email: _emailController.text,
            token: _tokenController.text,
            userId: _userIdController.text,
          );
    } catch (e) {
      if (context.mounted) {
        CherryToast.error(
          title: Text("替换账户信息失败: $e", style: const TextStyle(color: Colors.black)),
          animationType: AnimationType.fromRight,
          animationDuration: const Duration(milliseconds: 1000),
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  // 添加显示日志弹窗的方法
  void _showLogsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => LogDialog());
  }
}
