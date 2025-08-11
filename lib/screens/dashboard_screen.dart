import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';
import 'package:gene_pos/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kGradientStart,
                  kGradientMiddle.withOpacity(0.8),
                  kGradientEnd.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  0.5 + 0.3 * math.sin(_backgroundAnimation.value),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(8, (index) {
                  return Positioned(
                    left:
                        (screenSize.width * (index / 8) +
                            40 * math.cos(_backgroundAnimation.value + index)) %
                        screenSize.width,
                    top:
                        (screenSize.height * (index / 8) +
                            30 * math.sin(_backgroundAnimation.value + index)) %
                        screenSize.height,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kWhiteColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      _buildAnimatedHeader(currentUser?.displayName ?? 'User'),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),

                              // Sales & Orders Section
                              _buildSectionHeader(
                                '💰 Sales & Orders',
                                kSecondaryColor,
                              ),
                              SizedBox(height: 12),
                              _buildCardGrid([
                                DashboardItem(
                                  'POS Sales',
                                  Icons.point_of_sale,
                                  kSecondaryColor,
                                  () => _navigateToSales(),
                                ),
                                DashboardItem(
                                  'Orders',
                                  Icons.receipt_long,
                                  kAccentColor,
                                  () => _navigateToOrders(),
                                ),
                                DashboardItem(
                                  'Order Products',
                                  Icons.shopping_basket,
                                  kPrimaryColor,
                                  () => _navigateToOrderProducts(),
                                ),
                                DashboardItem(
                                  'Transactions',
                                  Icons.payment,
                                  kLightBlue,
                                  () => _navigateToTransactions(),
                                ),
                              ]),

                              SizedBox(height: 24),

                              // Product Management Section
                              _buildSectionHeader(
                                '📦 Product Management',
                                kPrimaryColor,
                              ),
                              SizedBox(height: 12),
                              _buildCardGrid([
                                DashboardItem(
                                  'Products',
                                  Icons.inventory_2,
                                  kPrimaryColor,
                                  () => _navigateToProducts(),
                                ),
                                DashboardItem(
                                  'Categories',
                                  Icons.category,
                                  kSecondaryColor,
                                  () => _navigateToCategories(),
                                ),
                                DashboardItem(
                                  'Brands',
                                  Icons.branding_watermark,
                                  kAccentColor,
                                  () => _navigateToBrands(),
                                ),
                                DashboardItem(
                                  'Units',
                                  Icons.straighten,
                                  kLightBlue,
                                  () => _navigateToUnits(),
                                ),
                              ]),

                              SizedBox(height: 24),

                              // Purchase & Supply Section
                              _buildSectionHeader(
                                '🚚 Purchase & Supply',
                                kAccentColor,
                              ),
                              SizedBox(height: 12),
                              _buildCardGrid([
                                DashboardItem(
                                  'Purchases',
                                  Icons.shopping_cart_checkout,
                                  kAccentColor,
                                  () => _navigateToPurchases(),
                                ),
                                DashboardItem(
                                  'Suppliers',
                                  Icons.local_shipping,
                                  kSecondaryColor,
                                  () => _navigateToSuppliers(),
                                ),
                                DashboardItem(
                                  'Purchase Items',
                                  Icons.list_alt,
                                  kPrimaryColor,
                                  () => _navigateToPurchaseItems(),
                                ),
                              ]),

                              SizedBox(height: 24),

                              // Customer & User Management Section
                              _buildSectionHeader(
                                '👥 People Management',
                                kLightBlue,
                              ),
                              SizedBox(height: 12),
                              _buildCardGrid([
                                DashboardItem(
                                  'Customers',
                                  Icons.people,
                                  kLightBlue,
                                  () => _navigateToCustomers(),
                                ),
                                DashboardItem(
                                  'Users',
                                  Icons.supervised_user_circle,
                                  kPrimaryColor,
                                  () => _navigateToUsers(),
                                ),
                              ]),

                              SizedBox(height: 24),

                              // System & Settings Section
                              _buildSectionHeader(
                                '⚙️ System & Settings',
                                kDarkBlue,
                              ),
                              SizedBox(height: 12),
                              _buildCardGrid([
                                DashboardItem(
                                  'Currency',
                                  Icons.monetization_on,
                                  kSecondaryColor,
                                  () => _navigateToCurrency(),
                                ),
                                DashboardItem(
                                  'Settings',
                                  Icons.settings,
                                  kDarkBlue,
                                  () => _navigateToSettings(),
                                ),
                                DashboardItem(
                                  'Reports',
                                  Icons.analytics,
                                  kAccentColor,
                                  () => _navigateToReports(),
                                ),
                                DashboardItem(
                                  'Logout',
                                  Icons.exit_to_app,
                                  Colors.red.shade400,
                                  () => _handleLogout(),
                                ),
                              ]),

                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader(String userName) {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGlassLight, kGlassDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: kGlassBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [kSecondaryColor, kAccentColor],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.store, color: kWhiteColor, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $userName!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kWhiteColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gene POS Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              color: kWhiteColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickStat(
                      'Today Sales',
                      'TSh 450,000',
                      Icons.trending_up,
                    ),
                    _buildQuickStat('Total Products', '1,247', Icons.inventory),
                    _buildQuickStat('Active Orders', '23', Icons.receipt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kSecondaryColor, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kWhiteColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: kWhiteColor.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kWhiteColor,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(List<DashboardItemData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDashboardCard(
          item.title,
          item.icon,
          item.color,
          item.onTap,
        );
      },
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  kWhiteColor.withOpacity(0.2),
                  kWhiteColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: kWhiteColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [color.withOpacity(0.8), color],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 28, color: kWhiteColor),
                      ),
                      SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kWhiteColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Navigation Methods
  void _navigateToSales() {
    print('Navigate to POS Sales');
    // TODO: Navigate to POS sales screen
  }

  void _navigateToOrders() {
    print('Navigate to Orders');
    // TODO: Navigate to orders management screen
  }

  void _navigateToOrderProducts() {
    print('Navigate to Order Products');
    // TODO: Navigate to order products screen
  }

  void _navigateToTransactions() {
    print('Navigate to Transactions');
    // TODO: Navigate to transactions screen
  }

  void _navigateToProducts() {
    print('Navigate to Products');
    // TODO: Navigate to products management screen
  }

  void _navigateToCategories() {
    print('Navigate to Categories');
    // TODO: Navigate to categories management screen
  }

  void _navigateToBrands() {
    print('Navigate to Brands');
    // TODO: Navigate to brands management screen
  }

  void _navigateToUnits() {
    Navigator.pushNamed(context, '/units');
  }

  void _navigateToPurchases() {
    print('Navigate to Purchases');
    // TODO: Navigate to purchases management screen
  }

  void _navigateToSuppliers() {
    print('Navigate to Suppliers');
    // TODO: Navigate to suppliers management screen
  }

  void _navigateToPurchaseItems() {
    print('Navigate to Purchase Items');
    // TODO: Navigate to purchase items screen
  }

  void _navigateToCustomers() {
    print('Navigate to Customers');
    // TODO: Navigate to customers management screen
  }

  void _navigateToUsers() {
    print('Navigate to Users');
    // TODO: Navigate to users management screen
  }

  void _navigateToCurrency() {
    print('Navigate to Currency');
    // TODO: Navigate to currency settings screen
  }

  void _navigateToSettings() {
    print('Navigate to Settings');
    // TODO: Navigate to settings screen
  }

  void _navigateToReports() {
    print('Navigate to Reports');
    // TODO: Navigate to reports screen
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: kWhiteColor,
          title: Text(
            'Confirm Logout',
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: kDarkBlue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: kDarkBlue)),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Logout', style: TextStyle(color: kWhiteColor)),
            ),
          ],
        );
      },
    );
  }
}

// Helper class for dashboard items
class DashboardItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DashboardItemData(this.title, this.icon, this.color, this.onTap);
}

DashboardItemData DashboardItem(
  String title,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return DashboardItemData(title, icon, color, onTap);
}
