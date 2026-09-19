import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../data/sample_menu.dart';
import '../theme/app_theme.dart';
import '../utils/content_filter.dart';

class MenuOrderingScreen extends StatefulWidget {
  final String customerName;
  final String tableNumber;
  final Function(List<CartItem> cartItems, String orderType) onProceedToCheckout;
  final VoidCallback onChangeTable;

  const MenuOrderingScreen({
    super.key,
    required this.customerName,
    required this.tableNumber,
    required this.onProceedToCheckout,
    required this.onChangeTable,
  });

  @override
  State<MenuOrderingScreen> createState() => _MenuOrderingScreenState();
}

class _MenuOrderingScreenState extends State<MenuOrderingScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<CartItem> _cart = [];
  String _orderType = 'Eat In'; // 'Eat In' or 'Take Out'

  List<MenuItem> get _filteredItems {
    return SampleMenuData.items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get _cartSubtotal {
    double total = 0.0;
    for (var item in _cart) {
      total += item.totalPrice;
    }
    return total;
  }

  int get _cartTotalCount {
    int count = 0;
    for (var item in _cart) {
      count += item.quantity;
    }
    return count;
  }

  void _addItemToCart(MenuItem item, List<SelectedCustomization> customs, String notes, int qty) {
    setState(() {
      _cart.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        item: item,
        quantity: qty,
        selectedCustomizations: customs,
        specialInstructions: notes,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cardBgElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.statusGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${item.name} to your order!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomizationSheet(MenuItem item) {
    List<SelectedCustomization> selectedCustoms = [];
    String instructions = '';
    String? instructionsError;
    int quantity = 1;

    // Set defaults for required groups
    for (var group in item.customizationGroups) {
      if (group.isRequired && group.options.isNotEmpty) {
        selectedCustoms.add(SelectedCustomization(groupTitle: group.title, option: group.options.first));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            double calculateSheetUnitPrice() {
              double base = item.price;
              for (var c in selectedCustoms) {
                base += c.option.price;
              }
              return base * quantity;
            }

            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Modal Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          item.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.cardBgElevated,
                            child: const Icon(Icons.fastfood_rounded, color: AppTheme.primaryOrange),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),

                  const Divider(color: Colors.white10, height: 24),

                  // Customization options list
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var group in item.customizationGroups) ...[
                            Row(
                              children: [
                                Text(
                                  group.title.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.primaryGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (group.isRequired) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryOrange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'REQUIRED',
                                      style: TextStyle(color: AppTheme.primaryOrange, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (var option in group.options) ...[
                              Builder(
                                builder: (context) {
                                  final isSelected = selectedCustoms.any(
                                    (c) => c.groupTitle == group.title && c.option.id == option.id,
                                  );
                                  return CheckboxListTile(
                                    activeColor: AppTheme.primaryOrange,
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      option.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    subtitle: option.price > 0
                                        ? Text(
                                            '+₱${option.price.toStringAsFixed(2)}',
                                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                          )
                                        : null,
                                    value: isSelected,
                                    onChanged: (bool? checked) {
                                      setSheetState(() {
                                        if (group.allowMultiple) {
                                          if (checked == true) {
                                            selectedCustoms.add(SelectedCustomization(groupTitle: group.title, option: option));
                                          } else {
                                            selectedCustoms.removeWhere((c) => c.groupTitle == group.title && c.option.id == option.id);
                                          }
                                        } else {
                                          // Single choice radio behavior
                                          selectedCustoms.removeWhere((c) => c.groupTitle == group.title);
                                          if (checked == true) {
                                            selectedCustoms.add(SelectedCustomization(groupTitle: group.title, option: option));
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 12),
                          ],

                          // Special Instructions field
                          const Text(
                            'SPECIAL INSTRUCTIONS',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatefulBuilder(
                            builder: (context, setFieldState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    onChanged: (val) {
                                      final error = ContentFilter.validate(val, isName: false);
                                      setFieldState(() {
                                        instructionsError = error;
                                      });
                                      if (error == null) {
                                        instructions = val;
                                      } else {
                                        // Keep previous clean value; don't overwrite with flagged content
                                        instructions = '';
                                      }
                                    },
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Less ice, extra crispy, sauce on the side...',
                                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                                      filled: true,
                                      fillColor: AppTheme.cardBgElevated,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: instructionsError != null
                                              ? AppTheme.statusRed
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: instructionsError != null
                                              ? AppTheme.statusRed
                                              : AppTheme.primaryOrange,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (instructionsError != null) ...[  
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded,
                                            size: 14, color: AppTheme.statusRed),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            instructionsError!,
                                            style: const TextStyle(
                                              color: AppTheme.statusRed,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity Selector & Add to Cart Button
                  Row(
                    children: [
                      // Qty Counter
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgElevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setSheetState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove, color: Colors.white),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => setSheetState(() => quantity++),
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Add Button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _addItemToCart(item, selectedCustoms, instructions, quantity);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ADD TO ORDER',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  '₱${calculateSheetUnitPrice().toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setCartState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Order Cart',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_cart.length} item(s)',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Eat In / Take Out Switcher
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setCartState(() => _orderType = 'Eat In'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _orderType == 'Eat In' ? AppTheme.primaryOrange : AppTheme.cardBgElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '🍽️ Dine-In (Table)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setCartState(() => _orderType = 'Take Out'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _orderType == 'Take Out' ? AppTheme.primaryOrange : AppTheme.cardBgElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '🛍️ Take-Out',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white10, height: 24),

                  if (_cart.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Your cart is empty. Browse items to add!',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cart.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 16),
                        itemBuilder: (context, index) {
                          final cartItem = _cart[index];
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  cartItem.item.imageUrl,
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 54,
                                    height: 54,
                                    color: AppTheme.cardBgElevated,
                                    child: const Icon(Icons.fastfood, color: Colors.white54),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.item.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    if (cartItem.selectedCustomizations.isNotEmpty)
                                      Text(
                                        cartItem.selectedCustomizations.map((c) => c.option.name).join(', '),
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                    Text(
                                      '₱${cartItem.unitPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textMuted, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (cartItem.quantity > 1) {
                                          cartItem.quantity--;
                                        } else {
                                          _cart.removeAt(index);
                                        }
                                      });
                                      setCartState(() {});
                                    },
                                  ),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryOrange, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        cartItem.quantity++;
                                      });
                                      setCartState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (_cart.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '₱${_cartSubtotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onProceedToCheckout(_cart, _orderType);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'CONFIRM & PROCEED TO CHECKOUT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Customer & Table Info Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppTheme.cardBg,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                    child: const Icon(Icons.person, color: AppTheme.primaryOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customerName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Active Table: ${widget.tableNumber}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onChangeTable,
                    child: const Text('Change', style: TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Search Bar & Categories
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search crispy chicken, burgers, drinks...',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryOrange),
                  filled: true,
                  fillColor: AppTheme.cardBgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category Chips Bar
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: SampleMenuData.categories.length,
                itemBuilder: (context, index) {
                  final cat = SampleMenuData.categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryOrange,
                      backgroundColor: AppTheme.cardBgElevated,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Food Items Grid
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching meals found',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return GestureDetector(
                          onTap: () => _openCustomizationSheet(item),
                          child: Container(
                            decoration: AppTheme.cardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.network(
                                        item.imageUrl,
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 110,
                                          color: AppTheme.cardBgElevated,
                                          child: const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
                                        ),
                                      ),
                                    ),
                                    if (item.isBestseller)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGold,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'BESTSELLER',
                                            style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                    if (item.isSpicy)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppTheme.statusRed,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₱${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryGold,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryOrange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add, size: 14, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Sticky Bottom Cart Bar
            if (_cart.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgElevated,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, -4)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _openCartModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_cartTotalCount items',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'VIEW CART',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          '₱${_cartSubtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
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
