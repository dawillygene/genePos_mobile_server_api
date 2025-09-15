import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome back, ${user?.displayName ?? 'User'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Role: ${user?.roleDisplayName ?? 'Unknown'}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Quick actions grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMedium,
                mainAxisSpacing: AppConstants.paddingMedium,
                children: [
                  _buildActionCard(
                    context,
                    'POS',
                    Icons.point_of_sale,
                    Colors.green,
                    () => Navigator.pushNamed(context, AppRoutes.pos),
                  ),
                  _buildActionCard(
                    context,
                    'Products',
                    Icons.inventory,
                    Colors.blue,
                    () => Navigator.pushNamed(context, AppRoutes.products),
                  ),
                  _buildActionCard(
                    context,
                    'Customers',
                    Icons.people,
                    Colors.orange,
                    () => Navigator.pushNamed(context, AppRoutes.customers),
                  ),
                  _buildActionCard(
                    context,
                    'Transactions',
                    Icons.receipt,
                    Colors.purple,
                    () => Navigator.pushNamed(context, AppRoutes.transactions),
                  ),
                  if (user?.isAdmin ?? false) ...[
                    _buildActionCard(
                      context,
                      'Categories',
                      Icons.category,
                      Colors.teal,
                      () => Navigator.pushNamed(context, AppRoutes.categories),
                    ),
                    _buildActionCard(
                      context,
                      'Settings',
                      Icons.settings,
                      Colors.grey,
                      () => Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
