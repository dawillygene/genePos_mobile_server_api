import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class ShopManagementPage extends StatefulWidget {
  final User user;

  const ShopManagementPage({super.key, required this.user});

  @override
  State<ShopManagementPage> createState() => _ShopManagementPageState();
}

class _ShopManagementPageState extends State<ShopManagementPage> {
  List<dynamic> _shops = [];
  List<dynamic> _teamMembers = [];
  bool _isLoading = true;
  Map<String, dynamic>? _shopStats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = context.read<ApiService>();
      
      // Load shops and team members in parallel
      final results = await Future.wait([
        apiService.getShops(),
        apiService.getTeamMembers(),
        if (widget.user.shopId != null) 
          apiService.getShopStatistics(widget.user.shopId!),
      ]);
      
      setState(() {
        _shops = results[0] as List<dynamic>;
        _teamMembers = results[1] as List<dynamic>;
        if (results.length > 2) {
          _shopStats = results[2] as Map<String, dynamic>;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createShop() async {
    if (widget.user.role != UserRole.owner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only shop owners can create shops'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CreateShopDialog(),
    );

    if (result != null) {
      try {
        final apiService = context.read<ApiService>();
        await apiService.createShop(
          name: result['name']!,
          description: result['description'],
          address: result['address'],
          phone: result['phone'],
          email: result['email'],
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create shop: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addTeamMember() async {
    if (widget.user.role != UserRole.owner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only shop owners can add team members'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddTeamMemberDialog(),
    );

    if (result != null) {
      try {
        final apiService = context.read<ApiService>();
        await apiService.addTeamMember(
          name: result['name']!,
          email: result['email']!,
          password: result['password']!,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team member added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add team member: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Management'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Statistics (if user has a shop)
            if (_shopStats != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Statistics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Products',
                              value: '${_shopStats!['total_products'] ?? 0}',
                              icon: Icons.inventory,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Team Members',
                              value: '${_shopStats!['active_team_members'] ?? 0}',
                              icon: Icons.people,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (_shopStats!['total_sales'] != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Sales',
                                value: '\$${_shopStats!['total_sales']}',
                                icon: Icons.trending_up,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: 'Monthly Revenue',
                                value: '\$${_shopStats!['monthly_revenue'] ?? 0}',
                                icon: Icons.monetization_on,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Shops Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shops',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.user.role == UserRole.owner)
                  ElevatedButton.icon(
                    onPressed: _createShop,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Shop'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_shops.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.store, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No shops found'),
                        Text('Create your first shop to get started'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_shops.length, (index) {
                final shop = _shops[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.store),
                    ),
                    title: Text(shop['name'] ?? 'Unnamed Shop'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shop['description'] != null)
                          Text(shop['description']),
                        if (shop['address'] != null)
                          Text(shop['address']),
                      ],
                    ),
                    trailing: widget.user.role == UserRole.owner
                        ? PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              }),

            const SizedBox(height: 32),

            // Team Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Members',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.user.role == UserRole.owner)
                  ElevatedButton.icon(
                    onPressed: _addTeamMember,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_teamMembers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No team members found'),
                        Text('Add team members to help manage your shop'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_teamMembers.length, (index) {
                final member = _teamMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(member['name']?[0]?.toString().toUpperCase() ?? '?'),
                    ),
                    title: Text(member['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['email'] ?? ''),
                        Text(
                          member['role']?.toString().toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            color: member['role'] == 'owner' ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: member['is_active'] == true ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.user.role == UserRole.owner)
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(member['is_active'] == true ? Icons.block : Icons.check_circle),
                                    const SizedBox(width: 8),
                                    Text(member['is_active'] == true ? 'Deactivate' : 'Activate'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'toggle') {
                                try {
                                  await context.read<ApiService>().toggleTeamMemberStatus(member['id']);
                                  _loadData();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update member: $e')),
                                  );
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateShopDialog extends StatefulWidget {
  @override
  State<_CreateShopDialog> createState() => _CreateShopDialogState();
}

class _CreateShopDialogState extends State<_CreateShopDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Shop'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shop Name *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter shop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'description': _descriptionController.text.trim(),
                'address': _addressController.text.trim(),
                'phone': _phoneController.text.trim(),
                'email': _emailController.text.trim(),
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _AddTeamMemberDialog extends StatefulWidget {
  @override
  State<_AddTeamMemberDialog> createState() => _AddTeamMemberDialogState();
}

class _AddTeamMemberDialogState extends State<_AddTeamMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Team Member'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'password': _passwordController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
