import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sale.dart';
import '../colors.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final ApiService _apiService = ApiService();
  List<Sale> _sales = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sales = await _apiService.getSales(
        startDate: _startDate,
        endDate: _endDate,
        perPage: 50,
      );

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // For demo purposes, add some sample sales
        _sales = _getSampleSales();
      });
    }
  }

  List<Sale> _getSampleSales() {
    return [
      Sale(
        id: '1',
        items: [],
        subtotal: 150.00,
        tax: 15.00,
        discount: 0.00,
        total: 165.00,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        cashierId: '1',
        cashierName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        customerName: 'Alice Smith',
      ),
      Sale(
        id: '2',
        items: [],
        subtotal: 75.50,
        tax: 7.55,
        discount: 5.00,
        total: 78.05,
        paymentMethod: PaymentMethod.card,
        status: SaleStatus.completed,
        cashierId: '1',
        cashierName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Sale(
        id: '3',
        items: [],
        subtotal: 299.99,
        tax: 30.00,
        discount: 20.00,
        total: 309.99,
        paymentMethod: PaymentMethod.mobile,
        status: SaleStatus.completed,
        cashierId: '2',
        cashierName: 'Jane Wilson',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        customerName: 'Bob Johnson',
        customerPhone: '+1234567890',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header with filters
          _buildHeader(),
          const SizedBox(height: 16),

          // Sales list
          Expanded(child: _buildSalesContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Text(
                  'Sales History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _loadSales,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date filters
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _startDate?.toString().substring(0, 10) ??
                            'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _endDate?.toString().substring(0, 10) ?? 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _loadSales();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesContent() {
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

    if (_sales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sales found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _sales.length,
      itemBuilder: (context, index) {
        final sale = _sales[index];
        return _SaleCard(sale: sale, onTap: () => _showSaleDetails(sale));
      },
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadSales();
    }
  }

  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sale #${sale.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${sale.createdAt.toString().substring(0, 16)}'),
              Text('Cashier: ${sale.cashierName}'),
              if (sale.customerName != null)
                Text('Customer: ${sale.customerName}'),
              if (sale.customerPhone != null)
                Text('Phone: ${sale.customerPhone}'),
              Text('Payment: ${_getPaymentMethodName(sale.paymentMethod)}'),
              Text('Status: ${sale.status.name.toUpperCase()}'),
              const SizedBox(height: 16),
              Text('Subtotal: \$${sale.subtotal.toStringAsFixed(2)}'),
              Text('Tax: \$${sale.tax.toStringAsFixed(2)}'),
              Text('Discount: \$${sale.discount.toStringAsFixed(2)}'),
              const Divider(),
              Text(
                'Total: \$${sale.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (sale.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes: ${sale.notes}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (sale.status == SaleStatus.completed)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _printReceipt(sale);
              },
              child: const Text('Print Receipt'),
            ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobile:
        return 'Mobile Payment';
      case PaymentMethod.mixed:
        return 'Mixed Payment';
    }
  }

  void _printReceipt(Sale sale) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt printing feature coming soon!')),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;

  const _SaleCard({required this.sale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(sale.status),
          child: Icon(
            _getStatusIcon(sale.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              'Sale #${sale.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '\$${sale.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(sale.createdAt.toString().substring(0, 16)),
                const Spacer(),
                Text('Cashier: ${sale.cashierName}'),
              ],
            ),
            if (sale.customerName != null)
              Text('Customer: ${sale.customerName}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(sale.paymentMethod),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPaymentMethodName(sale.paymentMethod),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(sale.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sale.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.pending:
        return Colors.orange;
      case SaleStatus.completed:
        return Colors.green;
      case SaleStatus.cancelled:
        return Colors.red;
      case SaleStatus.refunded:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(SaleStatus status) {
    switch (status) {
      case SaleStatus.pending:
        return Icons.pending;
      case SaleStatus.completed:
        return Icons.check_circle;
      case SaleStatus.cancelled:
        return Icons.cancel;
      case SaleStatus.refunded:
        return Icons.undo;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.mobile:
        return Colors.purple;
      case PaymentMethod.mixed:
        return Colors.orange;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobile:
        return 'Mobile';
      case PaymentMethod.mixed:
        return 'Mixed';
    }
  }
}
