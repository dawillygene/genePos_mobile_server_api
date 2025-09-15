import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/reporting_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ReportingService _reportingService = ReportingService();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _reportingService.getDashboardOverview();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Welcome back, ${user?.name ?? 'User'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Role: ${_getRoleDisplayName(user?.role)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Key Metrics Cards
                    if (_dashboardData != null) ...[
                      _buildMetricsSection(),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Low Stock Alerts
                      if (_dashboardData!['low_stock_alerts'].isNotEmpty) ...[
                        _buildLowStockSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                      ],

                      // Recent Transactions
                      _buildRecentTransactionsSection(),
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],

                    // Quick Actions
                    _buildQuickActionsSection(user),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsSection() {
    final todaySales = _dashboardData!['today_sales'];
    final weekSales = _dashboardData!['week_sales'];
    final monthSales = _dashboardData!['month_sales'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Today',
                '\$${todaySales['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
                '${todaySales['transaction_count'] ?? 0} transactions',
                Colors.green,
                Icons.today,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: _buildMetricCard(
                'This Week',
                '\$${weekSales['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
                '${weekSales['transaction_count'] ?? 0} transactions',
                Colors.blue,
                Icons.calendar_view_week,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'This Month',
                '\$${monthSales['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
                '${monthSales['transaction_count'] ?? 0} transactions',
                Colors.orange,
                Icons.calendar_month,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: _buildMetricCard(
                'Avg Transaction',
                '\$${_calculateAverageTransaction()}',
                'Average sale',
                Colors.purple,
                Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection() {
    final lowStockProducts = _dashboardData!['low_stock_alerts'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              'Low Stock Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              return Card(
                color: Colors.red.shade50,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'SKU: ${product['sku'] ?? ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product['stock_quantity'] ?? 0} left',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recentTransactions = _dashboardData!['recent_transactions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.transactions),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        ...recentTransactions.take(3).map((transaction) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.receipt, color: Colors.green),
            ),
            title: Text('#${transaction['transaction_number']}'),
            subtitle: Text(
              '${transaction['timestamp'] ?? ''}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              '\$${transaction['total']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildQuickActionsSection(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
            if (user?.role == UserRole.owner) ...[
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
      ],
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateAverageTransaction() {
    final todaySales = _dashboardData!['today_sales'];
    final transactionCount = todaySales['transaction_count'] ?? 0;
    final totalSales = todaySales['total_sales'] ?? 0.0;

    if (transactionCount == 0) return '0.00';

    return (totalSales / transactionCount).toStringAsFixed(2);
  }

  String _getRoleDisplayName(UserRole? role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.salesPerson:
        return 'Sales Person';
      default:
        return 'Unknown';
    }
  }
}
