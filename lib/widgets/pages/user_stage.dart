import 'package:cusor_patcher/provider/userStage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStagePage extends ConsumerWidget {
  const UserStagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStage = ref.watch(userStageHelperProvider);

    return Scaffold(
      body: switch (userStage) {
        AsyncData(:final value) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        color: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Basic Information',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow('Name', value.name ?? ''),
                              const SizedBox(height: 12),
                              _buildInfoRow('Email', value.email ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(value.picture ?? ''),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Usage',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Usage (Last 30 days)',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        _buildUsageBar(
                          'Premium models',
                          value.maxRequestUsage ?? 0,
                          value.maxRequestUsage ?? 0,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => const CircularProgressIndicator(),
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageBar(String label, int used, int? total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text('$used / ${total ?? "∞"}'),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 8),
        if (total != null)
          LinearProgressIndicator(
            value: used / total,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        const SizedBox(height: 4),
        Text(
          'You\'ve used $used requests out of your ${total ?? "unlimited"} fast requests quota.',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
