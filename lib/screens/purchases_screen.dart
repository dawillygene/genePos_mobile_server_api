import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';
import '../services/supplier_service.dart';
import '../models/supplier_model.dart';
import '../services/auth_service.dart';

class PurchasesScreen extends StatefulWidget {
  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final SupplierService _supplierService = SupplierService();
  final AuthService _authService = AuthService();
  List<Purchase> _purchases = [];
  List<Supplier> _suppliers = [];
  final _formKey = GlobalKey<FormState>();
  int? _selectedSupplierId;
  final _dateController = TextEditingController();
  Purchase? _selectedPurchase;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
    _loadSuppliers();
  }

  Future<void> _loadPurchases() async {
    final purchases = await _purchaseService.getPurchases();
    setState(() {
      _purchases = purchases;
    });
  }

  Future<void> _loadSuppliers() async {
    final suppliers = await _supplierService.getSuppliers();
    setState(() {
      _suppliers = suppliers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchases'),
      ),
      body: ListView.builder(
        itemCount: _purchases.length,
        itemBuilder: (context, index) {
          final purchase = _purchases[index];
          return ListTile(
            title: Text('Purchase #${purchase.id}'),
            subtitle: Text('Supplier ID: ${purchase.supplierId} - Grand Total: ${purchase.grandTotal}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showForm(purchase: purchase);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deletePurchase(purchase.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showForm({Purchase? purchase}) {
    _selectedPurchase = purchase;
    _selectedSupplierId = purchase?.supplierId;
    _dateController.text = purchase?.date ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(purchase == null ? 'Add Purchase' : 'Edit Purchase'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedSupplierId,
                  items: _suppliers.map((supplier) {
                    return DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Supplier'),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a supplier';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _dateController.text = pickedDate.toIso8601String();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submit();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final date = _dateController.text;
      final user = _authService.currentUser;
      if (user == null) {
        // Handle case where user is not logged in
        return;
      }
      final userId = user.id;

      if (_selectedPurchase == null) {
        final newPurchase = Purchase(
          supplierId: _selectedSupplierId!,
          userId: userId!,
          date: date,
          status: 1,
        );
        _purchaseService.insertPurchase(newPurchase).then((_) {
          _loadPurchases();
          Navigator.of(context).pop();
        });
      } else {
        final updatedPurchase = Purchase(
          id: _selectedPurchase!.id,
          supplierId: _selectedSupplierId!,
          userId: userId!,
          date: date,
          status: _selectedPurchase!.status,
        );
        _purchaseService.updatePurchase(updatedPurchase).then((_) {
          _loadPurchases();
          Navigator.of(context).pop();
        });
      }
    }
  }

  void _deletePurchase(int id) {
    _purchaseService.deletePurchase(id).then((_) {
      _loadPurchases();
    });
  }
}
