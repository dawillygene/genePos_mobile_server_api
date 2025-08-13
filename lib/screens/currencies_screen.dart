import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';

class CurrenciesScreen extends StatefulWidget {
  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<Currency> _currencies = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _symbolController = TextEditingController();
  Currency? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final currencies = await _currencyService.getCurrencies();
    setState(() {
      _currencies = currencies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currencies'),
      ),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          return ListTile(
            title: Text(currency.name),
            subtitle: Text('${currency.code} (${currency.symbol})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showForm(currency: currency);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteCurrency(currency.id!);
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

  void _showForm({Currency? currency}) {
    _selectedCurrency = currency;
    _nameController.text = currency?.name ?? '';
    _codeController.text = currency?.code ?? '';
    _symbolController.text = currency?.symbol ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currency == null ? 'Add Currency' : 'Edit Currency'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _symbolController,
                  decoration: InputDecoration(labelText: 'Symbol'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a symbol';
                    }
                    return null;
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
      final name = _nameController.text;
      final code = _codeController.text;
      final symbol = _symbolController.text;

      if (_selectedCurrency == null) {
        final newCurrency = Currency(name: name, code: code, symbol: symbol);
        _currencyService.insertCurrency(newCurrency).then((_) {
          _loadCurrencies();
          Navigator.of(context).pop();
        });
      } else {
        final updatedCurrency = Currency(
          id: _selectedCurrency!.id,
          name: name,
          code: code,
          symbol: symbol,
        );
        _currencyService.updateCurrency(updatedCurrency).then((_) {
          _loadCurrencies();
          Navigator.of(context).pop();
        });
      }
    }
  }

  void _deleteCurrency(int id) {
    _currencyService.deleteCurrency(id).then((_) {
      _loadCurrencies();
    });
  }
}
