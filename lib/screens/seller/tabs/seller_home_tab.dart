import 'package:flutter/material.dart';
import '../../../services/store_repository.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF606060);
const _border = Color(0xFFDFDFDF);
const _openGreen = Color(0xFF00C714);
const _actionBackground = Color(0xFF262626);

class SellerHomeTab extends StatefulWidget {
  final VoidCallback onNavigateToOrders;
  final VoidCallback onNavigateToProducts;

  const SellerHomeTab({
    super.key,
    required this.onNavigateToOrders,
    required this.onNavigateToProducts,
  });

  @override
  State<SellerHomeTab> createState() => _SellerHomeTabState();
}

class _SellerHomeTabState extends State<SellerHomeTab> {
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

  @override
  Widget build(BuildContext context) {
    final repo = StoreRepository.instance;
    final isStoreOpen = repo.isStoreOpen;
    final ordersCount = repo.allOrders.isEmpty ? 4 : repo.allOrders.length;
    final productsCount = repo.products.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Name',
            style: TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Store address',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.2),
          ),
          const SizedBox(height: 24),
          _StoreStatus(
            isOpen: isStoreOpen,
            onChanged: (value) {
              repo.toggleStoreStatus(value);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Orders',
                  count: '$ordersCount',
                  icon: Icons.inventory_2_outlined,
                  onTap: widget.onNavigateToOrders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Products',
                  count: '$productsCount',
                  icon: Icons.shopping_bag_outlined,
                  onTap: widget.onNavigateToProducts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickActionCard(
                  label: 'Create\nProduct',
                  icon: Icons.add_box_outlined,
                  onTap: _showCreateProductDialog,
                ),
                const SizedBox(width: 12),
                _QuickActionCard(
                  label: 'Restock\nItems',
                  icon: Icons.inventory_2_outlined,
                  onTap: _showRestockDialog,
                ),
                const SizedBox(width: 12),
                _QuickActionCard(
                  label: 'View\nProducts',
                  icon: Icons.storefront_outlined,
                  onTap: widget.onNavigateToProducts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProductDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Pork Tonkatsu',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock (pieces)',
                  hintText: 'e.g. 20',
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
                if (name.isNotEmpty) {
                  StoreRepository.instance.addProduct(name, stock);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added product "$name" ($stock pcs)')),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      stockController.dispose();
    });
  }

  void _showRestockDialog() {
    final repo = StoreRepository.instance;
    if (repo.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available to restock.')),
      );
      return;
    }

    String selectedId = repo.products.first.id;
    final addQtyController = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Restock Items'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Product:'),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedId,
                    items: repo.products.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text('${p.name} (Current: ${p.stock} pcs)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to Add',
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
                    final qty = int.tryParse(addQtyController.text.trim()) ?? 0;
                    if (qty > 0) {
                      repo.restockProduct(selectedId, qty);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restocked $qty pieces!')),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Restock'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      addQtyController.dispose();
    });
  }
}

class _StoreStatus extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onChanged;

  const _StoreStatus({required this.isOpen, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Store Status',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOpen ? _openGreen : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOpen ? 'Toggle to close' : 'Toggle to open',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOpen ? 'OPEN' : 'CLOSED',
                style: TextStyle(
                  color: isOpen ? _openGreen : Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              _StoreToggle(value: isOpen, onChanged: onChanged),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 1, color: _border),
      ],
    );
  }
}

class _StoreToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StoreToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 58,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? _openGreen : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 124,
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 21, color: _muted),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: _muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 124,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _actionBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFD9D9D9)),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
