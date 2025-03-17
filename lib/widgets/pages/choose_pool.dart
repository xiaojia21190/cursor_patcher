import 'package:cusor_patcher/provider/persistence_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChoosePool extends ConsumerStatefulWidget {
  const ChoosePool({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChoosePoolState();
}

class _ChoosePoolState extends ConsumerState<ChoosePool> {
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择池'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 60),
              ),
              onPressed: () => {context.go("/cursorPool")},
              child: const Text('cursor pool '),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 60),
              ),
              onPressed: () => {context.go("/myAccount")},
              child: const Text('自己账号切换'),
            )
          ],
        ),
      ),
    );
  }
}
