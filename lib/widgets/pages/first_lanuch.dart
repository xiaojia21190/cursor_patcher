import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cursor_patcher/provider/persistence_provider.dart';

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
    if (ref.read(persistenceProvider).getToken().isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
                  const Text(
                    '您需要先获取Cursor Token才能使用本应用。\n'
                    '请访问 https://cursor.ccopilot.org/index.html 获取Token。',
                    textAlign: TextAlign.center,
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
        Navigator.of(context).pushReplacementNamed('/home');
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
