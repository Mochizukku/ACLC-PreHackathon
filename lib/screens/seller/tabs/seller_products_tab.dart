import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../services/store_repository.dart';
import '../seller_product_detail_screen.dart';

const _ink = Color(0xFF1E1E1E);

class SellerProductsTab extends StatefulWidget {
  const SellerProductsTab({super.key});

  @override
  State<SellerProductsTab> createState() => _SellerProductsTabState();
}

class _SellerProductsTabState extends State<SellerProductsTab> {
  @override
  void initState() {
    super.initState();
    StoreRepository.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    StoreRepository.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _navigateToDetail(SellerProductItem product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerProductDetailScreen(product: product),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final priceController = TextEditingController(text: '7.00');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Lumpia Shanghai',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price per piece (₱)',
                  hintText: 'e.g. 7.00',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock (pieces)',
                  hintText: 'e.g. 25',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final stock = int.tryParse(stockController.text.trim()) ?? 0;
                final price = double.tryParse(priceController.text.trim()) ?? 7.00;
                if (name.isNotEmpty) {
                  StoreRepository.instance.addProduct(name, stock);
                  // Update price on freshly added product
                  final added = StoreRepository.instance.products.last;
                  added.price = price;
                  StoreRepository.instance.notifyAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "$name" (${stock} pcs)')),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add Product'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      stockController.dispose();
      priceController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = StoreRepository.instance;
    final products = repo.products;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Products" + Add "+" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  color: _ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                onPressed: _showAddProductDialog,
                icon: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2-Column Grid — tap opens Product Detail Screen
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductTile(
                product: product,
                onTap: () => _navigateToDetail(product),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final SellerProductItem product;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.onTap,
  });

  Widget _image() {
    if (product.imageBytes != null) {
      return Image.memory(
        Uint8List.fromList(product.imageBytes!),
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF262626),
        child: const Center(
          child: Icon(Icons.fastfood_rounded, color: Colors.white54, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                ),
              ),
            ),

            // Text overlay: "Name N pcs."
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                '${product.name} ${product.stock} pcs.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
