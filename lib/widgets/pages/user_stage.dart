import 'package:cusor_patcher/provider/userStage_provider.dart';
import 'package:cusor_patcher/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStagePage extends ConsumerWidget {
  final SizingInformation sizingInformation;
  const UserStagePage({super.key, required this.sizingInformation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStageHelper = ref.watch(userStageHelperProvider.notifier);
    userStageHelper.getCursorAccountInfo();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cursor 用户信息',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Consumer(builder: (context, ref, child) {
                    final userStage = ref.watch(userStageHelperProvider);
                    if (userStage.totalUsed == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('加载中...'),
                          ],
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          context,
                          title: '使用情况',
                          icon: Icons.analytics,
                          children: [
                            _buildInfoTile(
                              context,
                              icon: Icons.timer,
                              label: '已使用',
                              value: '${userStage.totalUsed}',
                            ),
                            _buildInfoTile(
                              context,
                              icon: Icons.access_time_filled,
                              label: '剩余',
                              value: '${userStage.totalAvailable}',
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoSection(
                          context,
                          title: '账户信息',
                          icon: Icons.person,
                          children: [
                            _buildInfoTile(
                              context,
                              icon: Icons.email,
                              label: '邮箱',
                              value: userStage.email ?? '未设置',
                            ),
                            _buildInfoTile(
                              context,
                              icon: Icons.star,
                              label: '贡献者',
                              value: userStage.contributor ?? '否',
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoSection(
                          context,
                          title: '账户状态',
                          icon: Icons.security,
                          children: [
                            _buildInfoTile(
                              context,
                              icon: Icons.info,
                              label: '状态',
                              value: userStage.status.toString() == '1' ? '正常' : '禁用',
                              valueColor: userStage.status.toString() == '1' ? Colors.green : Colors.red,
                            ),
                            if (userStage.disableReason?.isNotEmpty == true)
                              _buildInfoTile(
                                context,
                                icon: Icons.warning,
                                label: '禁用原因',
                                value: userStage.disableReason!,
                                valueColor: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
