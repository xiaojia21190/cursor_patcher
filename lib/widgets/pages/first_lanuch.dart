import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cursor_patcher/provider/persistence_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class FirstLaunchPage extends ConsumerStatefulWidget {
  const FirstLaunchPage({super.key});

  @override
  ConsumerState<FirstLaunchPage> createState() => _FirstLaunchPageState();
}

class _FirstLaunchPageState extends ConsumerState<FirstLaunchPage> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final token = ref.read(persistenceProvider).getToken();
      debugPrint('token: $token');
      if (token.isNotEmpty && mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final persistence = ref.read(persistenceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎使用'),
      ),
      body: persistence.getToken().isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '请输入您的Cursor Token',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        //删除下划线
                        const TextSpan(text: '您需要先获取cursor.ccopilot的token才能使用本应用。\n请访问 ', style: TextStyle(fontSize: 16, decoration: TextDecoration.none)),
                        TextSpan(
                          text: 'https://cursor.ccopilot.org/index.html',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(
                                  Uri.parse('https://cursor.ccopilot.org/index.html'),
                                ),
                        ),
                        const TextSpan(text: ' 在localStorage中获取token。', style: TextStyle(fontSize: 16, decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Token',
                      border: OutlineInputBorder(),
                      hintText: '请输入您的Token',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    onPressed: _isLoading ? null : _saveToken,
                    child: _isLoading ? const CircularProgressIndicator() : const Text('确认'),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text('Cursor Patcher 已启动'),
            ),
    );
  }

  Future<void> _saveToken() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入Token')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final persistence = ref.read(persistenceProvider);

      // 保存token到持久化存储
      await persistence.saveToken(_tokenController.text);

      // 导航到主页面
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存Token失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}
