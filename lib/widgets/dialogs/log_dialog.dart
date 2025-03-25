import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:cusor_patcher/widgets/logs_viewe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogDialog extends ConsumerWidget {
  const LogDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
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
            Consumer(builder: (context, ref, child) {
              final output = ref.watch(cursorProvider.select((state) => state.output));
              return Expanded(
                child: LogsViewer(
                  output: output,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
