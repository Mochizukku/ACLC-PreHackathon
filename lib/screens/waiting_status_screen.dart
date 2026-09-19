import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';

class WaitingStatusScreen extends StatefulWidget {
  final CustomerOrder order;
  final VoidCallback onOrderCompleted;
  final VoidCallback onCancelRequested;

  const WaitingStatusScreen({
    super.key,
    required this.order,
    required this.onOrderCompleted,
    required this.onCancelRequested,
  });

  @override
  State<WaitingStatusScreen> createState() => _WaitingStatusScreenState();
}

class _WaitingStatusScreenState extends State<WaitingStatusScreen> {
  Timer? _autoAdvanceTimer;
  bool _isAutoSimulating = false;
  int _prepSecondsRemaining = 300; // 5 minute countdown
  Timer? _prepCountdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _prepCountdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _prepCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prepSecondsRemaining > 0 && widget.order.status == OrderStatus.preparing) {
        setState(() {
          _prepSecondsRemaining--;
        });
      }
    });
  }

  void _advanceOrderStatus() {
    setState(() {
      switch (widget.order.status) {
        case OrderStatus.pendingPayment:
          widget.order.status = OrderStatus.paid;
          break;
        case OrderStatus.paid:
          widget.order.status = OrderStatus.preparing;
          break;
        case OrderStatus.preparing:
          widget.order.status = OrderStatus.readyForPickup;
          _showReadyNotificationSnackbar();
          break;
        case OrderStatus.readyForPickup:
          widget.order.status = OrderStatus.completed;
          _autoAdvanceTimer?.cancel();
          widget.onOrderCompleted();
          break;
        case OrderStatus.completed:
        case OrderStatus.cancelled:
          break;
      }
    });
  }

  void _toggleAutoSimulation(bool enable) {
    setState(() {
      _isAutoSimulating = enable;
    });
    _autoAdvanceTimer?.cancel();
    if (enable) {
      _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (widget.order.status == OrderStatus.readyForPickup) {
          timer.cancel();
          _advanceOrderStatus();
        } else if (widget.order.status == OrderStatus.completed || widget.order.status == OrderStatus.cancelled) {
          timer.cancel();
        } else {
          _advanceOrderStatus();
        }
      });
    }
  }

  void _showReadyNotificationSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.statusGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Colors.black, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '🔔 ORDER READY! Please present your ticket at Counter #1 for pickup.',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Live Order Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppTheme.primaryOrange),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardBgElevated,
                  title: const Text('Counter Ordering Help', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    '1. Pay at counter with cash or QR.\n2. Once vendor receives payment, status turns to "Preparing".\n3. Wait for "Ready for Pickup!" callout.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: AppTheme.primaryOrange)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vendor Simulator Control Banner for evaluation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF2E1A05),
              child: Row(
                children: [
                  const Icon(Icons.science_rounded, color: AppTheme.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SELLER SIMULATOR:',
                      style: TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Auto-Advance', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Switch(
                        value: _isAutoSimulating,
                        activeColor: AppTheme.primaryOrange,
                        onChanged: _toggleAutoSimulation,
                      ),
                    ],
                  ),
                  if (status != OrderStatus.completed && status != OrderStatus.cancelled)
                    ElevatedButton(
                      onPressed: _advanceOrderStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _getSimulatorButtonLabel(status),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Big Ticket Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'TABLE ${widget.order.tableNumber} • ${widget.order.orderType.toUpperCase()}',
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'ORDER #${widget.order.orderId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Customer: ${widget.order.customerName}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status Highlight Card
                    _buildStatusBanner(status),

                    const SizedBox(height: 28),

                    // Step Tracker Timeline
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORDER PROGRESS',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildTimelineStep(
                            stepNumber: 1,
                            title: 'Order Placed (Pending Payment)',
                            description: 'Present Order #${widget.order.orderId} at cashier to pay ₱${widget.order.totalAmount.toStringAsFixed(2)}',
                            isActive: status.stepIndex >= 0,
                            isCompleted: status.stepIndex > 0,
                          ),
                          _buildTimelineStep(
                            stepNumber: 2,
                            title: 'Payment Confirmed',
                            description: 'Payment verified by seller counter',
                            isActive: status.stepIndex >= 1,
                            isCompleted: status.stepIndex > 1,
                          ),
                          _buildTimelineStep(
                            stepNumber: 3,
                            title: 'Preparing in Kitchen',
                            description: 'Chefs are grilling & assembling your order',
                            isActive: status.stepIndex >= 2,
                            isCompleted: status.stepIndex > 2,
                          ),
                          _buildTimelineStep(
                            stepNumber: 4,
                            title: 'Ready for Pickup!',
                            description: 'Collect your meal at Pickup Counter #1',
                            isActive: status.stepIndex >= 3,
                            isCompleted: status.stepIndex > 3,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Order Items Summary Accordion
                    ExpansionTile(
                      backgroundColor: AppTheme.cardBg,
                      collapsedBackgroundColor: AppTheme.cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryOrange),
                      title: Text(
                        'View Order Details (${widget.order.items.length} items)',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              for (var item in widget.order.items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item.quantity}x ${item.item.name}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      Text('₱${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Customer Cancel Action Notice (Must request vendor to cancel after placement)
                    if (status == OrderStatus.pendingPayment)
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardBgElevated,
                              title: const Text('Cancel Order?', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                'As per policy, confirmed orders cannot be directly cancelled by customers. Please inform the cashier if you wish to cancel before payment.',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK', style: TextStyle(color: AppTheme.primaryOrange)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.textMuted),
                        label: const Text('Request Order Cancellation', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ),

                    if (status == OrderStatus.readyForPickup)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.onOrderCompleted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.statusGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 22),
                              SizedBox(width: 8),
                              Text('COLLECT MEAL & VIEW RECEIPT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSimulatorButtonLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingPayment:
        return 'Simulate Paid ▶';
      case OrderStatus.paid:
        return 'Start Cooking ▶';
      case OrderStatus.preparing:
        return 'Mark Ready ▶';
      case OrderStatus.readyForPickup:
        return 'Complete Order ▶';
      default:
        return 'Done';
    }
  }

  Widget _buildStatusBanner(OrderStatus status) {
    Color bg;
    IconData icon;
    String title;
    String sub;

    switch (status) {
      case OrderStatus.pendingPayment:
        bg = AppTheme.statusAmber;
        icon = Icons.access_time_filled_rounded;
        title = 'Awaiting Counter Payment';
        sub = 'Please head to Counter #1 and show Order #${widget.order.orderId}';
        break;
      case OrderStatus.paid:
        bg = AppTheme.accentTeal;
        icon = Icons.check_circle_rounded;
        title = 'Payment Received!';
        sub = 'Order dispatched to kitchen queue.';
        break;
      case OrderStatus.preparing:
        bg = AppTheme.primaryOrange;
        icon = Icons.soup_kitchen_rounded;
        title = 'Preparing in Kitchen...';
        sub = 'Estimated prep time: ${_prepSecondsRemaining ~/ 60}m ${_prepSecondsRemaining % 60}s';
        break;
      case OrderStatus.readyForPickup:
        bg = AppTheme.statusGreen;
        icon = Icons.notifications_active_rounded;
        title = 'Order Ready for Pickup! 🎉';
        sub = 'Please proceed to Pickup Counter #1 to collect your meal.';
        break;
      case OrderStatus.completed:
        bg = AppTheme.statusGreen;
        icon = Icons.task_alt_rounded;
        title = 'Order Completed!';
        sub = 'Enjoy your food!';
        break;
      case OrderStatus.cancelled:
        bg = AppTheme.statusRed;
        icon = Icons.error_rounded;
        title = 'Order Cancelled';
        sub = widget.order.cancellationReason ?? 'Cancelled by store management.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: bg, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isActive,
    required bool isCompleted,
    bool isLast = false,
  }) {
    Color stepColor = isCompleted
        ? AppTheme.statusGreen
        : isActive
            ? AppTheme.primaryOrange
            : Colors.white24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.statusGreen : (isActive ? AppTheme.primaryOrange : AppTheme.cardBgElevated),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Colors.black)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isActive ? Colors.white : AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppTheme.statusGreen : Colors.white10,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
