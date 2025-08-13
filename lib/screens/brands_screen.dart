import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';
import 'package:gene_pos/models/brand_model.dart';
import 'package:gene_pos/services/brand_service.dart';

class BrandsScreen extends StatefulWidget {
  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> with TickerProviderStateMixin {
  final BrandService _brandService = BrandService();
  late Future<List<Brand>> _brandsFuture;
  late AnimationController _backgroundController;
  late Animation<Color?> _colorAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: kPrimaryColor.withOpacity(0.8),
      end: kAccentColor.withOpacity(0.8),
    ).animate(_backgroundController);

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _loadBrands();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _loadBrands() {
    setState(() {
      _brandsFuture = _brandService.getBrands();
      _listAnimationController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Brand Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGradientStart, _colorAnimation.value ?? kPrimaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: FutureBuilder<List<Brand>>(
            future: _brandsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kWhiteColor));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: kWhiteColor)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No brands found. Add one to get started!', style: TextStyle(color: kWhiteColor, fontSize: 18)));
              }

              final brands = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  return _buildBrandListItem(brand, index);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBrandDialog(),
        backgroundColor: kAccentColor,
        icon: const Icon(Icons.add, color: kWhiteColor),
        label: const Text('Add Brand', style: TextStyle(color: kWhiteColor)),
        tooltip: 'Add a new brand',
      ),
    );
  }

  Widget _buildBrandListItem(Brand brand, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Interval(
          (0.1 * index) / 2,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: kWhiteColor.withOpacity(0.15),
        elevation: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: kSecondaryColor,
            child: Text(
              brand.name.substring(0, 1),
              style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            brand.name,
            style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: brand.description != null && brand.description!.isNotEmpty
              ? Text(
                  brand.description!,
                  style: TextStyle(color: kWhiteColor.withOpacity(0.7)),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note, color: kSecondaryColor, size: 28),
                onPressed: () => _showBrandDialog(brand: brand),
                tooltip: 'Edit ${brand.name}',
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
                onPressed: () => _confirmDelete(brand),
                tooltip: 'Delete ${brand.name}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBrandDialog({Brand? brand}) {
    final nameController = TextEditingController(text: brand?.name ?? '');
    final descriptionController = TextEditingController(text: brand?.description ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 350,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kDarkBlue.withOpacity(0.95),
                    kPrimaryColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: kGlassBorder.withOpacity(0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kAccentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            brand == null ? Icons.add_box_rounded : Icons.edit_rounded,
                            size: 40,
                            color: kSecondaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            brand == null ? 'Create New Brand' : 'Update Brand',
                            style: const TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (brand != null)
                            Text(
                              '"${brand.name}"',
                              style: TextStyle(
                                color: kSecondaryColor,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildDialogTextField(nameController, 'Brand Name', Icons.label_important),
                    const SizedBox(height: 20),
                    _buildDialogTextField(descriptionController, 'Description (Optional)', Icons.description),
                    
                    const SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: kWhiteColor.withOpacity(0.3)),
                              ),
                            ),
                            icon: const Icon(Icons.cancel, color: kWhiteColor, size: 20),
                            label: const Text(
                              'CANCEL',
                              style: TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final name = nameController.text.trim();
                              final description = descriptionController.text.trim();

                              if (name.isNotEmpty) {
                                if (brand == null) {
                                  _addBrand(Brand(name: name, description: description));
                                } else {
                                  _updateBrand(brand.copyWith(name: name, description: description));
                                }
                                Navigator.pop(context);
                              } else {
                                _showSnackBar('Brand name is required.', Colors.orange);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccentColor,
                              foregroundColor: kWhiteColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            icon: Icon(
                              brand == null ? Icons.add_circle : Icons.check_circle,
                              color: kWhiteColor,
                              size: 20,
                            ),
                            label: Text(
                              brand == null ? 'CREATE' : 'UPDATE',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: kWhiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: kSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Enter ${label.toLowerCase()}',
          hintStyle: TextStyle(
            color: kWhiteColor.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kSecondaryColor, size: 22),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: kWhiteColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: kSecondaryColor,
              width: 3,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: kWhiteColor.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  void _confirmDelete(Brand brand) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 350),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kDarkBlue.withOpacity(0.95),
                  Colors.red.shade900.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Confirm Deletion',
                    style: TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: kWhiteColor,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Are you sure you want to delete\n'),
                        TextSpan(
                          text: '"${brand.name}"',
                          style: const TextStyle(
                            color: kSecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const TextSpan(text: '?\n\nThis action cannot be undone.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: kWhiteColor.withOpacity(0.3)),
                            ),
                          ),
                          icon: const Icon(Icons.cancel, color: kWhiteColor, size: 18),
                          label: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteBrand(brand.id!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: kWhiteColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          icon: const Icon(Icons.delete_forever, color: kWhiteColor, size: 18),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addBrand(Brand brand) async {
    await _brandService.addBrand(brand);
    _loadBrands();
    _showSnackBar('Brand added successfully!', Colors.green.shade600);
  }

  void _updateBrand(Brand brand) async {
    await _brandService.updateBrand(brand);
    _loadBrands();
    _showSnackBar('Brand updated successfully!', Colors.blue.shade600);
  }

  void _deleteBrand(int id) async {
    await _brandService.deleteBrand(id);
    _loadBrands();
    _showSnackBar('Brand deleted successfully!', Colors.red.shade700);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 10,
      ),
    );
  }
}
