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
  final txn_service.TransactionService _transactionService =
      txn_service.TransactionService();

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
        isCredit:
            _selectedCustomer != null && _selectedCustomer!.creditLimit > 0,
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

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _showAddCustomer = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final customers = await _customerService.getAllCustomers();

      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading customers: $e')));
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone?.toLowerCase().contains(query) == true ||
            customer.email?.toLowerCase().contains(query) == true;
      }).toList();
    });
  }

  Future<void> _addCustomer(Customer customer) async {
    try {
      await _customerService.createCustomer(customer);
      await _loadData(); // Refresh the list
      setState(() => _showAddCustomer = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding customer: $e')));
      }
    }
  }

  Future<void> _updateCustomer(Customer customer) async {
    try {
      await _customerService.updateCustomer(customer);
      await _loadData(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating customer: $e')));
      }
    }
  }

  Future<void> _deleteCustomer(int customerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _customerService.deleteCustomer(customerId);
        await _loadData(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting customer: $e')),
          );
        }
      }
    }
  }

  void _showCustomerDetails(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomerDetailsSheet(
        customer: customer,
        onUpdate: _updateCustomer,
        onDelete: () => _deleteCustomer(customer.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showAddCustomer = true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  color: Colors.grey.shade50,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Customer Count
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        'Total Customers',
                        _customers.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),

                // Customer List
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? const Center(child: Text('No customers found'))
                      : ListView.builder(
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingMedium,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    customer.name.isNotEmpty
                                        ? customer.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer.phone ?? 'No phone'),
                                    if (customer.email != null)
                                      Text(
                                        customer.email!,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (customer.creditLimit > 0)
                                      Row(
                                        children: [
                                          Text(
                                            'Credit: \$${customer.outstandingBalance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: customer.outstandingBalance >
                                                      customer.creditLimit * 0.8
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' / \$${customer.creditLimit.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view':
                                        _showCustomerDetails(customer);
                                        break;
                                      case 'edit':
                                        // TODO: Implement edit customer
                                        break;
                                      case 'delete':
                                        _deleteCustomer(customer.id!);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Text('View Details'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                                onTap: () => _showCustomerDetails(customer),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      // Add Customer FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddCustomer = true),
        child: const Icon(Icons.add),
      ),

      // Add Customer Bottom Sheet
      bottomSheet: _showAddCustomer
          ? AddCustomerSheet(
              onSave: _addCustomer,
              onCancel: () => setState(() => _showAddCustomer = false),
            )
          : null,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AddCustomerSheet extends StatefulWidget {
  final Function(Customer) onSave;
  final VoidCallback onCancel;

  const AddCustomerSheet({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _creditLimitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      creditLimit: double.tryParse(_creditLimitController.text) ?? 0.0,
      outstandingBalance: 0.0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Customer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Credit Limit Field
            TextFormField(
              controller: _creditLimitController,
              decoration: const InputDecoration(
                labelText: 'Credit Limit (Optional)',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Customer'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),
          ],
        ),
      ),
    );
  }
}

class CustomerDetailsSheet extends StatelessWidget {
  final Customer customer;
  final Function(Customer) onUpdate;
  final VoidCallback onDelete;

  const CustomerDetailsSheet({
    super.key,
    required this.customer,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Customer Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Phone', customer.phone ?? 'Not provided'),
                  if (customer.email != null)
                    _buildInfoRow('Email', customer.email!),
                  _buildInfoRow(
                    'Status',
                    customer.isActive ? 'Active' : 'Inactive',
                  ),
                  _buildInfoRow(
                    'Member since',
                    _formatDate(customer.createdAt),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Credit Information
          if (customer.creditLimit > 0)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    _buildInfoRow(
                      'Credit Limit',
                      '\$${customer.creditLimit.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Outstanding Balance',
                      '\$${customer.outstandingBalance.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Available Credit',
                      '\$${(customer.creditLimit - customer.outstandingBalance).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to customer transaction history
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text('Transaction History'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit customer
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Customer'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Delete Customer',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
