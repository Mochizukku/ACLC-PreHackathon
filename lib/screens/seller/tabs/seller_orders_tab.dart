import 'package:flutter/material.dart';
import '../../../models/menu_item.dart';
import '../../../services/store_repository.dart';
import '../seller_incoming_orders_screen.dart';

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

  void _navigateToIncomingOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SellerIncomingOrdersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = StoreRepository.instance;
    final incomingCount = repo.incomingOrders.length;
    final pendingCount = repo.pendingOrders.length;
    final finishedList = repo.finishedOrders;

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

          // Cards Row (Matching Image 3)
          Row(
            children: [
              Expanded(
                child: _OrderStatusCard(
                  title: 'INCOMING\nORDERS',
                  count: incomingCount,
                  color: _alertRed,
                  onTap: _navigateToIncomingOrders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrderStatusCard(
                  title: 'PENDING\nORDERS',
                  count: pendingCount,
                  color: const Color(0xFFFF8A00),
                  onTap: _navigateToIncomingOrders,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Finished Orders Section (Image 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Finished Orders',
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              Icon(Icons.format_list_bulleted_rounded, color: _ink, size: 22),
            ],
          ),
          const SizedBox(height: 16),

          if (finishedList.isEmpty)
            _buildSampleFinishedOrders()
          else
            ...finishedList.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OrderRow(
                  customerLabel: order.customerName,
                  dateLabel: _formatTime(order.orderTime),
                  onTap: () => _showOrderDetails(order),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSampleFinishedOrders() {
    final sampleRows = [
      {'id': 'Customer ID', 'date': 'Date'},
      {'id': 'Customer ID', 'date': 'Date'},
      {'id': 'Customer ID', 'date': 'Date'},
      {'id': 'Customer ID', 'date': 'Date'},
      {'id': 'Customer ID', 'date': 'Date'},
    ];

    return Column(
      children: sampleRows.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OrderRow(
            customerLabel: item['id']!,
            dateLabel: item['date']!,
            onTap: () {},
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetails(CustomerOrder order) {
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
                  'Order #${order.orderId}',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(label: 'Customer Name', value: order.customerName),
                _DetailRow(label: 'Table Number', value: order.tableNumber),
                _DetailRow(label: 'Order Type', value: order.orderType),
                _DetailRow(label: 'Status', value: order.status.displayName),
                _DetailRow(label: 'Total Amount', value: '₱${order.totalAmount.toStringAsFixed(2)}'),
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
  final VoidCallback onTap;

  const _OrderStatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              border: Border.all(color: _border, width: 1.2),
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
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: count > 0
                  ? Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox(width: 10, height: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String customerLabel;
  final String dateLabel;
  final VoidCallback onTap;

  const _OrderRow({
    required this.customerLabel,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _rowBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              customerLabel,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateLabel,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
