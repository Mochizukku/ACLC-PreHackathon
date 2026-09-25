import 'package:flutter/material.dart';

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
  bool _isStoreOpen = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 0,
            width: 0,
            child: Text(
              'Seller Home',
              style: TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 0.01,
              ),
            ),
          ),
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
            isOpen: _isStoreOpen,
            onChanged: (value) {
              setState(() {
                _isStoreOpen = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Orders',
                  count: '4',
                  icon: Icons.inventory_2_outlined,
                  onTap: widget.onNavigateToOrders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Products',
                  count: '15',
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _QuickActionCard(
                    label: 'Create\nProduct',
                    icon: Icons.add_box_outlined,
                    onTap: () => _showActionDialog('Create Product'),
                  );
                }
                if (index == 1) {
                  return _QuickActionCard(
                    label: 'Restock\nItems',
                    icon: Icons.inventory_2_outlined,
                    onTap: () => _showActionDialog('Restock Items'),
                  );
                }
                return _QuickActionCard(
                  label: 'View\nProducts',
                  icon: Icons.storefront_outlined,
                  onTap: widget.onNavigateToProducts,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(String action) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(action),
          content: Text(
            '$action functionality will be integrated with the seller database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK', style: TextStyle(color: _ink)),
            ),
          ],
        );
      },
    );
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
            Text(
              isOpen ? 'Open for orders' : 'Currently closed',
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isOpen ? 'OPEN' : 'CLOSED',
              style: TextStyle(
                color: isOpen ? _openGreen : _muted,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            _StoreToggle(value: isOpen, onChanged: onChanged),
          ],
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
    return Semantics(
      button: true,
      toggled: value,
      label: 'Store status',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 54,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFB9F6CA) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? _openGreen : const Color(0xFF9F9F9F),
                shape: BoxShape.circle,
              ),
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
    return Semantics(
      button: true,
      label: '$title, $count',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 124,
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
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
    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      child: InkWell(
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
      ),
    );
  }
}
