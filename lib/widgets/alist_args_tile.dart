import 'package:cursor_patcher/i18n/strings.g.dart';
import 'package:cursor_patcher/model/settings_state.dart';
import 'package:cursor_patcher/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlistArgsTile extends ConsumerWidget {
  const AlistArgsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // final alistNotifier = ref.read(alistProvider.notifier);

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      title: Text(
        t.settings.alistSettings.argumentsList.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(settings.alistArgs.join(', ')),
      trailing: FilledButton.tonal(
        onPressed: () async {
          final args = await showDialog<List<String>>(
            context: context,
            builder: (context) => _AlistArgsDialog(
              initialArgs: settings.alistArgs,
            ),
          );
          if (args != null) {
            if (args.isEmpty) {
              args.add('');
            }
            // alistNotifier.endAlist();
            // alistNotifier.setAlistArgs(args);
          }
        },
        child: Text(t.button.edit),
      ),
    );
  }
}

class _AlistArgsDialog extends StatefulWidget {
  const _AlistArgsDialog({required this.initialArgs});

  final List<String> initialArgs;

  @override
  __AlistArgsDialogState createState() => __AlistArgsDialogState();
}

class __AlistArgsDialogState extends State<_AlistArgsDialog> {
  late List<String> args;

  @override
  void initState() {
    super.initState();
    args = List.from(widget.initialArgs);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(t.settings.alistSettings.argumentsList.title),
        subtitle: Text(t.settings.alistSettings.argumentsList.description),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < args.length; i++)
              Row(
                key: UniqueKey(),
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: args[i],
                      onChanged: (value) => args[i] = value,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        args.removeAt(i);
                        if (args.isEmpty) {
                          args.add('');
                        }
                      });
                    },
                    tooltip: t.settings.alistSettings.argumentsList.remove,
                    icon: const Icon(Icons.delete_forever_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        args.insert(i + 1, '');
                      });
                    },
                    tooltip: t.settings.alistSettings.argumentsList.addArgument,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.button.cancel),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(args),
          child: Text(t.button.save),
        ),
      ],
    );
  }
}
