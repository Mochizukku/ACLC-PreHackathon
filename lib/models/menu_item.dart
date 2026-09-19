enum OrderStatus {
  pendingPayment,
  paid,
  preparing,
  readyForPickup,
  completed,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.paid:
        return 'Payment Confirmed';
      case OrderStatus.preparing:
        return 'Preparing in Kitchen';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup!';
      case OrderStatus.completed:
        return 'Order Completed';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 0;
      case OrderStatus.paid:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.readyForPickup:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class CustomizationOption {
  final String id;
  final String name;
  final double price;

  CustomizationOption({
    required this.id,
    required this.name,
    required this.price,
  });
}

class CustomizationGroup {
  final String title;
  final bool isRequired;
  final bool allowMultiple;
  final List<CustomizationOption> options;

  CustomizationGroup({
    required this.title,
    this.isRequired = false,
    this.allowMultiple = false,
    required this.options,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isBestseller;
  final bool isSpicy;
  final int prepareTimeMinutes;
  final List<CustomizationGroup> customizationGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isBestseller = false,
    this.isSpicy = false,
    this.prepareTimeMinutes = 5,
    this.customizationGroups = const [],
  });
}

class SelectedCustomization {
  final String groupTitle;
  final CustomizationOption option;

  SelectedCustomization({
    required this.groupTitle,
    required this.option,
  });
}

class CartItem {
  final String id;
  final MenuItem item;
  int quantity;
  final List<SelectedCustomization> selectedCustomizations;
  final String specialInstructions;

  CartItem({
    required this.id,
    required this.item,
    this.quantity = 1,
    this.selectedCustomizations = const [],
    this.specialInstructions = '',
  });

  double get unitPrice {
    double total = item.price;
    for (var custom in selectedCustomizations) {
      total += custom.option.price;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;
}

class CustomerOrder {
  final String orderId;
  final String customerName;
  final String tableNumber;
  final List<CartItem> items;
  final double subtotal;
  final double taxAndFee;
  final double totalAmount;
  final DateTime orderTime;
  final String orderType; // 'Eat In' or 'Take Out'
  OrderStatus status;
  String? cancellationReason;

  CustomerOrder({
    required this.orderId,
    required this.customerName,
    required this.tableNumber,
    required this.items,
    required this.subtotal,
    required this.taxAndFee,
    required this.totalAmount,
    required this.orderTime,
    this.orderType = 'Eat In',
    this.status = OrderStatus.pendingPayment,
    this.cancellationReason,
  });
}
