import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _apiService.getDashboardData();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // For demo purposes, use sample data
        _dashboardData = _getSampleDashboardData();
      });
    }
  }

  Map<String, dynamic> _getSampleDashboardData() {
    return {
      'todaySales': 1250.75,
      'todayTransactions': 28,
      'weekSales': 8750.50,
      'monthSales': 35200.25,
      'topProducts': [
        {'name': 'Laptop Computer', 'sales': 15, 'revenue': 14999.85},
        {'name': 'Wireless Mouse', 'sales': 45, 'revenue': 1799.55},
        {'name': 'Coffee Mug', 'sales': 32, 'revenue': 415.68},
        {'name': 'T-Shirt', 'sales': 28, 'revenue': 699.72},
        {'name': 'Energy Bar', 'sales': 89, 'revenue': 355.11},
      ],
      'dailySales': [
        {'day': 'Mon', 'sales': 850.0},
        {'day': 'Tue', 'sales': 1200.0},
        {'day': 'Wed', 'sales': 950.0},
        {'day': 'Thu', 'sales': 1400.0},
        {'day': 'Fri', 'sales': 1650.0},
        {'day': 'Sat', 'sales': 2200.0},
        {'day': 'Sun', 'sales': 1500.0},
      ],
      'paymentMethods': [
        {'method': 'Cash', 'percentage': 45.0},
        {'method': 'Card', 'percentage': 35.0},
        {'method': 'Mobile', 'percentage': 20.0},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Using sample data (API connection failed)',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.dashboard, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats cards
          _buildStatsCards(),
          const SizedBox(height: 24),

          // Charts row
          Row(
            children: [
              Expanded(child: _buildSalesChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildPaymentMethodChart()),
            ],
          ),
          const SizedBox(height: 24),

          // Top products
          _buildTopProducts(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final data = _dashboardData!;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today\'s Sales',
            '\$${data['todaySales'].toStringAsFixed(2)}',
            Icons.today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Transactions',
            '${data['todayTransactions']}',
            Icons.receipt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Week Sales',
            '\$${data['weekSales'].toStringAsFixed(2)}',
            Icons.date_range,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Month Sales',
            '\$${data['monthSales'].toStringAsFixed(2)}',
            Icons.calendar_month,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    final List<dynamic> dailySales = _dashboardData!['dailySales'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales (This Week)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      dailySales
                          .map<double>((e) => e['sales'] as double)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dailySales.length) {
                            return Text(dailySales[value.toInt()]['day']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: dailySales.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['sales'],
                          color: AppColors.primaryBlue,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    final List<dynamic> paymentMethods = _dashboardData!['paymentMethods'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: paymentMethods.asMap().entries.map((entry) {
                    final colors = [Colors.green, Colors.blue, Colors.purple];
                    return PieChartSectionData(
                      value: entry.value['percentage'],
                      title: '${entry.value['percentage'].toStringAsFixed(0)}%',
                      color: colors[entry.key % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...paymentMethods.asMap().entries.map((entry) {
              final colors = [Colors.green, Colors.blue, Colors.purple];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value['method']} (${entry.value['percentage']}%)',
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final List<dynamic> topProducts = _dashboardData!['topProducts'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = topProducts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${product['sales']} units sold'),
                  trailing: Text(
                    '\$${product['revenue'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
