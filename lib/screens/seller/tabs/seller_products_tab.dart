import 'package:flutter/material.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF606060);
const _tileBackground = Color(0xFFD9D9D9);

class SellerProductsTab extends StatefulWidget {
  const SellerProductsTab({super.key});

  @override
  State<SellerProductsTab> createState() => _SellerProductsTabState();
}

class _SellerProductsTabState extends State<SellerProductsTab> {
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Siomai',
      'stock': '15',
      'icon': Icons.lunch_dining_outlined,
      'color': Color(0xFFF5A65B),
    },
    {
      'name': 'Chicken Cutlet',
      'stock': '10',
      'icon': Icons.fastfood_outlined,
      'color': Color(0xFFE7B36B),
    },
    {
      'name': 'Siopao Asado',
      'stock': '20',
      'icon': Icons.bakery_dining_outlined,
      'color': Color(0xFFD99A6C),
    },
    {
      'name': 'Bagnet',
      'stock': '5',
      'icon': Icons.ramen_dining_outlined,
      'color': Color(0xFFD0A57D),
    },
    {
      'name': 'Gyoza',
      'stock': '8',
      'icon': Icons.dinner_dining_outlined,
      'color': Color(0xFFE2C69D),
    },
    {
      'name': 'Bicol Express',
      'stock': '12',
      'icon': Icons.rice_bowl_outlined,
      'color': Color(0xFFE4A26F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Add Product',
                  child: IconButton(
                    onPressed: _showAddProductDialog,
                    tooltip: 'Add Product',
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _ink,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final product = _products[index];
              return _ProductTile(
                name: product['name'] as String,
                stock: product['stock'] as String,
                icon: product['icon'] as IconData,
                color: product['color'] as Color,
                onEdit: () => _editProduct(index),
                onDelete: () => _confirmDelete(index),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
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
                if (name.isNotEmpty) {
                  setState(() {
                    _products.add({
                      'name': name,
                      'stock': stockController.text.trim().isEmpty
                          ? '0'
                          : stockController.text.trim(),
                      'icon': Icons.inventory_2_outlined,
                      'color': const Color(0xFFB7C6C2),
                    });
                  });
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      stockController.dispose();
    });
  }

  void _editProduct(int index) {
    final product = _products[index];
    final nameController = TextEditingController(
      text: product['name'] as String,
    );
    final stockController = TextEditingController(
      text: product['stock'] as String,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
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
                setState(() {
                  _products[index]['name'] = nameController.text.trim().isEmpty
                      ? product['name']
                      : nameController.text.trim();
                  _products[index]['stock'] =
                      stockController.text.trim().isEmpty
                      ? product['stock']
                      : stockController.text.trim();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      stockController.dispose();
    });
  }

  void _confirmDelete(int index) {
    final productName = _products[index]['name'] as String;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete $productName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _products.removeAt(index);
                });
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0202),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  final String stock;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.name,
    required this.stock,
    required this.icon,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _tileBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 42,
                  color: _ink.withValues(alpha: 0.72),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stock,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    iconSize: 18,
                    icon: const Icon(Icons.more_vert, color: _muted),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
