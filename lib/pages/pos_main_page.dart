import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/google_signin_service.dart';
import '../models/user.dart';
import '../colors.dart';
import 'product_grid_page.dart';
import 'cart_page.dart';
import 'sales_history_page.dart';
import 'dashboard_page.dart';
import 'shop_management_page.dart';

class POSMainPage extends StatefulWidget {
  final User user;

  const POSMainPage({super.key, required this.user});

  @override
  State<POSMainPage> createState() => _POSMainPageState();
}

class _POSMainPageState extends State<POSMainPage> {
  int _selectedIndex = 0;
  late final CartService _cartService;
  late final GoogleSignInService _googleSignInService;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _googleSignInService = GoogleSignInService();

    _pages = [
      const ProductGridPage(),
      const CartPage(),
      const SalesHistoryPage(),
      const DashboardPage(),
      ShopManagementPage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cartService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'GenePos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          actions: [
            // Cart items count
            Consumer<CartService>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1; // Go to cart page
                        });
                      },
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // User menu
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.user.name.isNotEmpty
                      ? widget.user.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    _showProfileDialog();
                    break;
                  case 'settings':
                    _showSettingsDialog();
                    break;
                  case 'logout':
                    await _handleLogout();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Text('Profile (${widget.user.name})'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings),
                      const SizedBox(width: 8),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Row(
          children: [
            // Sidebar Navigation
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.grey[100],
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.store),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Cart'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('Sales'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business),
                  label: Text('Shop'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        floatingActionButton:
            _selectedIndex ==
                0 // Show only on products page
            ? FloatingActionButton.extended(
                onPressed: _showAddProductDialog,
                backgroundColor: AppColors.primaryBlue,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Product',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.user.name}'),
            const SizedBox(height: 8),
            Text('Email: ${widget.user.email}'),
            const SizedBox(height: 8),
            Text('Role: ${widget.user.role.name.toUpperCase()}'),
            if (widget.user.phone != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${widget.user.phone}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.print),
              title: Text('Printer Settings'),
              subtitle: Text('Configure receipt printer'),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment Methods'),
              subtitle: Text('Configure payment options'),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Tax Settings'),
              subtitle: Text('Configure tax rates'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    // This would open a dialog or navigate to add product page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Product feature coming soon!')),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _googleSignInService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
        }
      }
    }
  }
}
