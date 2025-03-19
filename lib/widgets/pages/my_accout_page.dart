import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:cusor_patcher/widgets/dialogs/log_dialog.dart';
import 'package:cusor_patcher/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAccoutPage extends ConsumerStatefulWidget {
  const MyAccoutPage({super.key, required this.sizingInformation});
  final SizingInformation sizingInformation;

  @override
  ConsumerState<MyAccoutPage> createState() => _MyAccoutPageState();
}

class _MyAccoutPageState extends ConsumerState<MyAccoutPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: '邮箱地址',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tokenController,
                      label: 'Token',
                      icon: Icons.token,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _replaceAccountInfo(context),
                            icon: const Icon(Icons.sync),
                            label: const Text('替换账户信息'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 24),
                        SizedBox(width: 8),
                        Text('使用说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    Text('1. 填写完整的Cursor账户信息，包括邮箱、Token和设备ID'),
                    SizedBox(height: 4),
                    Text('2. 点击"替换账户信息"按钮执行替换操作'),
                    SizedBox(height: 4),
                    Text('3. 替换前请确保已关闭所有Cursor进程'),
                    SizedBox(height: 4),
                    Text('4. 替换完成后重新启动Cursor即可使用新账户'),
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
    if (_emailController.text.isEmpty || _tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少填写邮箱和Token字段')),
      );
      return;
    }

    try {
      _showLogsDialog(context);

      await ref.read(cursorProvider.notifier).replaceCustomAccountInfo(
            email: _emailController.text,
            token: _tokenController.text,
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

  void _showLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogDialog(),
    );
  }
}
