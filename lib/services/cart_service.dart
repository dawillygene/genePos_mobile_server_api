import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/sale.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _taxRate = 0.10; // 10% tax rate
  double _generalDiscount = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  double get taxRate => _taxRate;
  double get generalDiscount => _generalDiscount;

  // Cart calculations
  double get subtotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  double get totalItemDiscount {
    return _items.fold(0.0, (sum, item) => sum + item.discount);
  }

  double get taxableAmount {
    return subtotal - totalItemDiscount - _generalDiscount;
  }

  double get taxAmount {
    return taxableAmount * _taxRate;
  }

  double get total {
    return taxableAmount + taxAmount;
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Cart operations
  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity <= product.stockQuantity) {
        _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        throw Exception(
          'Insufficient stock. Available: ${product.stockQuantity}',
        );
      }
    } else {
      // Add new item
      if (quantity <= product.stockQuantity) {
        final cartItem = CartItem(
          id: const Uuid().v4(),
          product: product,
          quantity: quantity,
          unitPrice: product.price,
        );
        _items.add(cartItem);
      } else {
        throw Exception(
          'Insufficient stock. Available: ${product.stockQuantity}',
        );
      }
    }

    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id.toString() == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id.toString() == productId);

    if (index >= 0) {
      final item = _items[index];

      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else if (newQuantity <= item.product.stockQuantity) {
        _items[index] = item.copyWith(quantity: newQuantity);
      } else {
        throw Exception(
          'Insufficient stock. Available: ${item.product.stockQuantity}',
        );
      }

      notifyListeners();
    }
  }

  void updateItemDiscount(String productId, double discount) {
    final index = _items.indexWhere((item) => item.product.id.toString() == productId);

    if (index >= 0) {
      final item = _items[index];
      final maxDiscount = item.unitPrice * item.quantity;

      if (discount <= maxDiscount && discount >= 0) {
        _items[index] = item.copyWith(discount: discount);
        notifyListeners();
      } else {
        throw Exception('Invalid discount amount');
      }
    }
  }

  void setGeneralDiscount(double discount) {
    if (discount >= 0 && discount <= subtotal) {
      _generalDiscount = discount;
      notifyListeners();
    } else {
      throw Exception('Invalid discount amount');
    }
  }

  void setTaxRate(double rate) {
    if (rate >= 0 && rate <= 1) {
      _taxRate = rate;
      notifyListeners();
    } else {
      throw Exception('Invalid tax rate');
    }
  }

  void clearCart() {
    _items.clear();
    _generalDiscount = 0.0;
    notifyListeners();
  }

  // Convert cart to sale
  Sale createSale({
    required String cashierId,
    required String cashierName,
    required PaymentMethod paymentMethod,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) {
    if (isEmpty) {
      throw Exception('Cannot create sale with empty cart');
    }

    return Sale(
      id: const Uuid().v4(),
      items: List.from(_items),
      subtotal: subtotal,
      tax: taxAmount,
      discount: totalItemDiscount + _generalDiscount,
      total: total,
      paymentMethod: paymentMethod,
      status: SaleStatus.pending,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      cashierId: cashierId,
      cashierName: cashierName,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  // Load cart from sale (for returns/exchanges)
  void loadFromSale(Sale sale) {
    clearCart();
    for (final item in sale.items) {
      _items.add(item);
    }

    // Calculate general discount
    final totalItemDiscount = sale.items.fold(
      0.0,
      (sum, item) => sum + item.discount,
    );
    _generalDiscount = sale.discount - totalItemDiscount;

    notifyListeners();
  }

  // Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'itemDiscount': totalItemDiscount,
      'generalDiscount': _generalDiscount,
      'taxableAmount': taxableAmount,
      'taxAmount': taxAmount,
      'total': total,
    };
  }

  // Search for product in cart
  CartItem? findItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id.toString() == productId);
    } catch (e) {
      return null;
    }
  }

  // Get quantity of specific product in cart
  int getProductQuantity(String productId) {
    final item = findItem(productId);
    return item?.quantity ?? 0;
  }
}
