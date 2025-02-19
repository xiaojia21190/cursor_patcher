import 'package:cusor_patcher/provider/cursor_provider.dart';
import 'package:cusor_patcher/widgets/logs_viewe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CursorView extends ConsumerWidget {
  const CursorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Cursor 替换日志"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: LogsViewer(
                  output: ref.watch(cursorProvider).output,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
