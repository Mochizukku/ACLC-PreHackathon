import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/store_repository.dart';
import 'seller_edit_product_screen.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF606060);

class SellerProductDetailScreen extends StatefulWidget {
  final SellerProductItem product;

  const SellerProductDetailScreen({super.key, required this.product});

  @override
  State<SellerProductDetailScreen> createState() =>
      _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState
    extends State<SellerProductDetailScreen> {
  late SellerProductItem _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    StoreRepository.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    StoreRepository.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      // Refresh product data from repo in case it was edited
      final updated = StoreRepository.instance.products
          .where((p) => p.id == _product.id)
          .firstOrNull;
      if (updated != null) {
        setState(() => _product = updated);
      }
    }
  }

  void _navigateToEdit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerEditProductScreen(product: _product),
      ),
    );
    // Refresh after edit returns
    _onStoreChanged();
  }

  @override
  Widget build(BuildContext context) {
    final addons = StoreRepository.instance.products
        .where((p) => p.id != _product.id)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              SizedBox(
                width: double.infinity,
                height: 240,
                child: _product.imageBytes != null
                    ? Image.memory(
                        Uint8List.fromList(_product.imageBytes!),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Center(
                            child: Icon(Icons.fastfood_rounded,
                                size: 60, color: Colors.white54),
                          ),
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'P ${_product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            const Text(
                              'per piece',
                              style: TextStyle(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Status badge
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontSize: 13, color: _muted),
                        ),
                        Text(
                          _product.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _product.isAvailable
                                ? const Color(0xFF00C714)
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _product.description.isNotEmpty
                                ? _product.description
                                : 'No description added.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add-ons section
                    if (addons.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Addons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: addons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final addon = addons[index];
                            return _AddonChip(product: addon);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Edit Product Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Edit Product',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete Product Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text(
                                  'Delete "${_product.name}"? This cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    StoreRepository.instance
                                        .deleteProduct(_product.id);
                                    Navigator.of(ctx).pop();
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text(
                          'Delete Product',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddonChip extends StatelessWidget {
  final SellerProductItem product;

  const _AddonChip({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 70,
            height: 60,
            child: product.imageBytes != null
                ? Image.memory(Uint8List.fromList(product.imageBytes!), fit: BoxFit.cover)
                : Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.fastfood_rounded,
                          size: 28, color: Colors.white54),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            product.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: _muted),
          ),
        ),
      ],
    );
  }
}
