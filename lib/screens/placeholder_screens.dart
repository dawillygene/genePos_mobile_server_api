import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../services/customer_service.dart';
import '../services/transaction_service.dart' as txn_service;
import '../models/product.dart';
import '../models/customer.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart' as txn_model;

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();
  final txn_service.TransactionService _transactionService = txn_service.TransactionService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Customer> _customers = [];
  Customer? _selectedCustomer;

  final List<CartItem> _cartItems = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  bool _isLoading = true;
  bool _showCart = false;
  String _selectedCategory = 'All';
  double _generalDiscount = 0.0;
  double _taxRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final products = await _productService.getAllProducts();
      final customers = await _customerService.getAllCustomers();

      setState(() {
        _products = products.where((p) => p.isActive).toList();
        _filteredProducts = _products;
        _customers = customers.where((c) => c.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            product.name.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query) ||
            (product.barcode?.toLowerCase().contains(query) ?? false);
        final matchesCategory =
            _selectedCategory == 'All' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory && product.isActive;
      }).toList();
    });
  }

  void _addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      setState(() {
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      });
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: 1,
        unitPrice: product.price,
      );
      setState(() {
        _cartItems.add(cartItem);
      });
    }

    if (!_showCart) {
      setState(() => _showCart = true);
    }
  }

  void _updateCartItemQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(item);
      return;
    }

    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index >= 0) {
      setState(() {
        _cartItems[index] = item.copyWith(quantity: newQuantity);
      });
    }
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cartItems.removeWhere((cartItem) => cartItem.id == item.id);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _selectedCustomer = null;
      _generalDiscount = 0.0;
      _discountController.clear();
    });
  }

  double get _subtotal => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.unitPrice * item.quantity),
  );

  double get _totalDiscount =>
      _cartItems.fold(0.0, (sum, item) => sum + item.discount) +
      _generalDiscount;

  double get _taxableAmount => _subtotal - _totalDiscount;
  double get _taxAmount => _taxableAmount * _taxRate;
  double get _total => _taxableAmount + _taxAmount;

  Future<void> _processPayment(String paymentMethod) async {
    if (_cartItems.isEmpty) return;

    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      await _transactionService.processTransaction(
        userId: authState.user!.id,
        cartItems: _cartItems,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: _totalDiscount,
        total: _total,
        paymentMethod: _getPaymentMethod(paymentMethod),
        customerId: _selectedCustomer?.id,
        isCredit: _selectedCustomer != null && _selectedCustomer!.creditLimit > 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearCart();
        setState(() => _showCart = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Transaction failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: Icon(
              _showCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
            ),
            onPressed: () => setState(() => _showCart = !_showCart),
          ),
          if (_cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _cartItems.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Product Catalog
                Expanded(
                  flex: _showCart ? 2 : 1,
                  child: Column(
                    children: [
                      // Search and Filter Bar
                      Container(
                        padding: const EdgeInsets.all(
                          AppConstants.paddingMedium,
                        ),
                        color: Colors.grey.shade50,
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search products...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            // Category Filter
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('All'),
                                    selected: _selectedCategory == 'All',
                                    onSelected: (selected) {
                                      setState(() => _selectedCategory = 'All');
                                      _filterProducts();
                                    },
                                  ),
                                  ..._products
                                      .map((p) => p.category)
                                      .toSet()
                                      .map(
                                        (category) => FilterChip(
                                          label: Text(category),
                                          selected:
                                              _selectedCategory == category,
                                          onSelected: (selected) {
                                            setState(
                                              () =>
                                                  _selectedCategory = category,
                                            );
                                            _filterProducts();
                                          },
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Product Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: AppConstants.paddingMedium,
                                mainAxisSpacing: AppConstants.paddingMedium,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Card(
                              elevation: 2,
                              child: InkWell(
                                onTap: () => _addToCart(product),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.paddingSmall,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: product.imageUrl != null
                                              ? Image.network(
                                                  product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Icons.inventory,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: AppConstants.paddingSmall,
                                      ),

                                      // Product Info
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      Text(
                                        'SKU: ${product.sku}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),

                                      const Spacer(),

                                      // Price and Stock
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            '${product.stockQuantity}',
                                            style: TextStyle(
                                              color: product.stockQuantity < 5
                                                  ? Colors.red
                                                  : Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Panel
                if (_showCart)
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Cart Header
                        Container(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          color: Colors.grey.shade100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearCart,
                              ),
                            ],
                          ),
                        ),

                        // Customer Selection
                        Container(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          child: DropdownButtonFormField<Customer>(
                            decoration: const InputDecoration(
                              labelText: 'Customer (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedCustomer,
                            items: [
                              const DropdownMenuItem<Customer>(
                                value: null,
                                child: Text('Walk-in Customer'),
                              ),
                              ..._customers.map(
                                (customer) => DropdownMenuItem(
                                  value: customer,
                                  child: Text(
                                    '${customer.name} (${customer.phone})',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (customer) {
                              setState(() => _selectedCustomer = customer);
                            },
                          ),
                        ),

                        // Cart Items
                        Expanded(
                          child: _cartItems.isEmpty
                              ? const Center(child: Text('Cart is empty'))
                              : ListView.builder(
                                  itemCount: _cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _cartItems[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.paddingSmall,
                                        vertical: 4,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppConstants.paddingSmall,
                                        ),
                                        child: Row(
                                          children: [
                                            // Product Image
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child:
                                                  item.product.imageUrl != null
                                                  ? Image.network(
                                                      item.product.imageUrl!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(Icons.inventory),
                                            ),

                                            const SizedBox(
                                              width: AppConstants.paddingSmall,
                                            ),

                                            // Product Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '\$${item.unitPrice.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Quantity Controls
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                  ),
                                                  onPressed: () =>
                                                      _updateCartItemQuantity(
                                                        item,
                                                        item.quantity - 1,
                                                      ),
                                                ),
                                                Text(
                                                  item.quantity.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () =>
                                                      _updateCartItemQuantity(
                                                        item,
                                                        item.quantity + 1,
                                                      ),
                                                ),
                                              ],
                                            ),

                                            // Subtotal
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Remove Button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _removeFromCart(item),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Cart Summary and Payment
                        Container(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Discount Input
                              TextField(
                                controller: _discountController,
                                decoration: const InputDecoration(
                                  labelText: 'General Discount',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _generalDiscount =
                                        double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),

                              const SizedBox(
                                height: AppConstants.paddingMedium,
                              ),

                              // Summary
                              _buildSummaryRow('Subtotal', _subtotal),
                              if (_totalDiscount > 0)
                                _buildSummaryRow('Discount', -_totalDiscount),
                              _buildSummaryRow('Tax', _taxAmount),
                              const Divider(),
                              _buildSummaryRow('Total', _total, isTotal: true),

                              const SizedBox(
                                height: AppConstants.paddingMedium,
                              ),

                              // Payment Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _cartItems.isNotEmpty
                                          ? () => _processPayment('cash')
                                          : null,
                                      icon: const Icon(Icons.money),
                                      label: const Text('Cash'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppConstants.paddingSmall,
                                  ),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _cartItems.isNotEmpty
                                          ? () => _processPayment('card')
                                          : null,
                                      icon: const Icon(Icons.credit_card),
                                      label: const Text('Card'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppConstants.paddingSmall),

                              ElevatedButton.icon(
                                onPressed: _cartItems.isNotEmpty
                                    ? () => _processPayment('mobile')
                                    : null,
                                icon: const Icon(Icons.phone_android),
                                label: const Text('Mobile Payment'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  txn_model.PaymentMethod _getPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return txn_model.PaymentMethod.cash;
      case 'card':
        return txn_model.PaymentMethod.card;
      case 'mobile':
        return txn_model.PaymentMethod.transfer; // Using transfer for mobile
      default:
        return txn_model.PaymentMethod.cash;
    }
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Products Screen - Coming Soon')),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const Center(child: Text('Categories Screen - Coming Soon')),
    );
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: const Center(child: Text('Customers Screen - Coming Soon')),
    );
  }
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const Center(child: Text('Transactions Screen - Coming Soon')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen - Coming Soon')),
    );
  }
}
