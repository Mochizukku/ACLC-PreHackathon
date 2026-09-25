import 'package:flutter/material.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF606060);
const _border = Color(0xFFDFDFDF);
const _rowBackground = Color(0xFFD9D9D9);
const _alertRed = Color(0xFFFF0202);

class SellerOrdersTab extends StatefulWidget {
  const SellerOrdersTab({super.key});

  @override
  State<SellerOrdersTab> createState() => _SellerOrdersTabState();
}

class _SellerOrdersTabState extends State<SellerOrdersTab> {
  String _selectedCategory = 'Finished';

  final List<Map<String, dynamic>> _orders = [
    {
      'customerId': 'CUST001',
      'date': '2024-06-15 14:30',
      'total': '₱150.00',
      'items': 2,
    },
    {
      'customerId': 'CUST002',
      'date': '2024-06-15 13:45',
      'total': '₱200.00',
      'items': 1,
    },
    {
      'customerId': 'CUST003',
      'date': '2024-06-15 12:15',
      'total': '₱350.00',
      'items': 3,
    },
    {
      'customerId': 'CUST004',
      'date': '2024-06-15 11:00',
      'total': '₱100.00',
      'items': 1,
    },
    {
      'customerId': 'CUST005',
      'date': '2024-06-15 10:30',
      'total': '₱275.00',
      'items': 4,
    },
    {
      'customerId': 'CUST006',
      'date': '2024-06-15 09:45',
      'total': '₱180.00',
      'items': 2,
    },
    {
      'customerId': 'CUST007',
      'date': '2024-06-15 09:00',
      'total': '₱225.00',
      'items': 3,
    },
  ];

  final List<Map<String, dynamic>> _statusCards = [
    {'title': 'INCOMING\nORDERS', 'count': 2, 'color': _alertRed},
    {'title': 'PENDING\nORDERS', 'count': 1, 'color': const Color(0xFFFF8A00)},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(36, 10, 36, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Orders',
              style: const TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              for (var index = 0; index < _statusCards.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                Expanded(
                  child: _OrderStatusCard(
                    title: _statusCards[index]['title'] as String,
                    count: _statusCards[index]['count'] as int,
                    color: _statusCards[index]['color'] as Color,
                    isSelected:
                        _selectedCategory ==
                        _statusCards[index]['title'].toString().replaceAll(
                          '\n',
                          ' ',
                        ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = _statusCards[index]['title']
                            .toString()
                            .replaceAll('\n', ' ');
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Finished Orders',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          ..._orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OrderRow(
                order: order,
                onTap: () => _showOrderDetails(order),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Order Details',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(
                  label: 'Customer ID',
                  value: order['customerId'] as String,
                ),
                _DetailRow(label: 'Date', value: order['date'] as String),
                _DetailRow(label: 'Items', value: '${order['items']}'),
                _DetailRow(label: 'Total', value: order['total'] as String),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderStatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $count orders',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 106,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _ink : _border,
                  width: 1.2,
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            Positioned(
              top: -7,
              right: -7,
              child: Semantics(
                label: '$count',
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const _OrderRow({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Order for ${order['customerId']}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _rowBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order for ${order['customerId']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order['date'] as String),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: _ink, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    final parts = value.split(' ');
    if (parts.length != 2) {
      return value;
    }
    return '${parts[0]} • ${parts[1]}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
