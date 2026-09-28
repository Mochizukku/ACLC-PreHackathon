import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/services/store_repository.dart';
import 'package:q2_app/models/menu_item.dart';
import 'package:q2_app/utils/content_filter.dart';

void main() {
  setUp(() {
    StoreRepository.instance.clearSession();
    StoreRepository.instance.resetBanState();
  });

  test('ContentFilter detects profane and inappropriate language correctly', () {
    expect(ContentFilter.validate('Valid store reason'), isNull);
    expect(ContentFilter.validate('fuck this app'), isNotNull);
    expect(ContentFilter.validate('skibidi toilet brainrot'), isNotNull);
  });

  test('StoreRepository tracks 3 inappropriate attempts and flags/bans user', () {
    final repo = StoreRepository.instance;
    expect(repo.inappropriateCount, 0);
    expect(repo.isBanned, false);

    repo.recordInappropriateAttempt();
    expect(repo.inappropriateCount, 1);
    expect(repo.isBanned, false);

    repo.recordInappropriateAttempt();
    expect(repo.inappropriateCount, 2);
    expect(repo.isBanned, false);

    repo.recordInappropriateAttempt();
    expect(repo.inappropriateCount, 3);
    expect(repo.isBanned, true);
  });

  test('Adding customer order reflects in incoming orders and updates stock on PAID', () {
    final repo = StoreRepository.instance;

    // Add a Siomai product since StoreRepository no longer pre-loads default products
    repo.addProduct('Siomai', 30,
        'https://images.unsplash.com/photo-1496116218417-1a781b1c416c');
    final initialSiomaiStock =
        repo.products.firstWhere((p) => p.name == 'Siomai').stock;

    final testOrder = CustomerOrder(
      orderId: '999',
      customerName: 'Juan Dela Cruz',
      tableNumber: 'Table 4',
      items: [
        CartItem(
          id: 'ci_test_1',
          item: MenuItem(
            id: 'm1',
            name: 'Siomai',
            description: 'Pork Siomai',
            price: 50.0,
            category: 'Snacks',
            imageUrl: '',
          ),
          quantity: 2,
        ),
      ],
      subtotal: 100.0,
      taxAndFee: 0.0,
      totalAmount: 100.0,
      orderTime: DateTime.now(),
      orderType: 'Dine In',
      status: OrderStatus.pendingPayment,
    );

    // Add customer order
    repo.addOrder(testOrder);
    expect(repo.incomingOrders.length, 1);
    expect(repo.incomingOrders.first.customerName, 'Juan Dela Cruz');

    // Mark order as PAID
    repo.updateOrderStatus('999', OrderStatus.paid);
    expect(repo.incomingOrders.isEmpty, true);

    // Verify stock is deducted by 2 pieces
    final updatedSiomaiStock =
        repo.products.firstWhere((p) => p.name == 'Siomai').stock;
    expect(updatedSiomaiStock, initialSiomaiStock - 2);
  });
}
