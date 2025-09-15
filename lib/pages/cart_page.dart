import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../colors.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        if (cart.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add some products to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Cart items list
            Expanded(flex: 2, child: _buildCartItems(cart)),

            const VerticalDivider(),

            // Checkout panel
            Expanded(flex: 1, child: _buildCheckoutPanel(cart)),
          ],
        );
      },
    );
  }

  Widget _buildCartItems(CartService cart) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              const Text(
                'Cart Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  _showClearCartDialog(cart);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Cart'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),

        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item.product.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${item.unitPrice.toStringAsFixed(2)} each',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),

                      // Quantity controls
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (item.quantity > 1) {
                                cart.updateQuantity(
                                  item.product.id.toString(),
                                  item.quantity - 1,
                                );
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            width: 40,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              try {
                                cart.updateQuantity(
                                  item.product.id.toString(),
                                  item.quantity + 1,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),

                      // Subtotal and remove
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              cart.removeProduct(item.product.id.toString());
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildCheckoutPanel(CartService cart) {
    final summary = cart.getCartSummary();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Checkout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Order summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow('Items', '${summary['itemCount']}'),
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${summary['subtotal'].toStringAsFixed(2)}',
                  ),
                  if (summary['itemDiscount'] > 0)
                    _buildSummaryRow(
                      'Item Discount',
                      '-\$${summary['itemDiscount'].toStringAsFixed(2)}',
                    ),
                  if (summary['generalDiscount'] > 0)
                    _buildSummaryRow(
                      'General Discount',
                      '-\$${summary['generalDiscount'].toStringAsFixed(2)}',
                    ),
                  _buildSummaryRow(
                    'Tax',
                    '\$${summary['taxAmount'].toStringAsFixed(2)}',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    '\$${summary['total'].toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment method
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PaymentMethod>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: PaymentMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(_getPaymentMethodName(method)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Customer details
          const Text(
            'Customer Details (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customerPhoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),

          const Spacer(),

          // Checkout button
          ElevatedButton(
            onPressed: _isProcessing ? null : () => _processCheckout(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Complete Sale (\$${summary['total'].toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primaryBlue : null,
            ),
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

  void _showClearCartDialog(CartService cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from the cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(CartService cart) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get current user (you'll need to pass this from the parent widget)
      final User currentUser = User(
        id: 1,
        email: 'cashier@example.com',
        name: 'Sample Cashier',
        role: UserRole.salesPerson,
        createdAt: DateTime.now(),
      );

      final sale = cart.createSale(
        cashierId: currentUser.id.toString(),
        cashierName: currentUser.name,
        paymentMethod: _selectedPaymentMethod,
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
        customerPhone: _customerPhoneController.text.isEmpty
            ? null
            : _customerPhoneController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Submit sale to API
      await _apiService.createSale(sale);

      // Clear cart and form
      cart.clearCart();
      _customerNameController.clear();
      _customerPhoneController.clear();
      _notesController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
