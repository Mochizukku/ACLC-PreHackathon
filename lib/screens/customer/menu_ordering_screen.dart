import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../data/sample_menu.dart';
import '../../theme/app_theme.dart';
import '../../utils/content_filter.dart';

class MenuOrderingScreen extends StatefulWidget {
  final String customerName;
  final String tableNumber;
  final Function(List<CartItem> cartItems, String orderType)? onProceedToCheckout;
  final VoidCallback onChangeTable;

  const MenuOrderingScreen({
    super.key,
    required this.customerName,
    required this.tableNumber,
    this.onProceedToCheckout,
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
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
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

    for (var group in item.customizationGroups) {
      if (group.isRequired && group.options.isNotEmpty) {
        selectedCustoms.add(SelectedCustomization(groupTitle: group.title, option: group.options.first));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
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
                            color: const Color(0xFF1E1E1E),
                            child: const Icon(Icons.fastfood_rounded, color: Colors.white70),
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
                                color: Colors.white,
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
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const Divider(color: Colors.white12, height: 24),

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
                                    color: Colors.white,
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
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'REQUIRED',
                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                                    activeColor: Colors.white,
                                    checkColor: Colors.black,
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      option.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    subtitle: option.price > 0
                                        ? Text(
                                            '+₱${option.price.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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

                          const Text(
                            'SPECIAL INSTRUCTIONS',
                            style: TextStyle(
                              color: Colors.white,
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
                                        instructions = '';
                                      }
                                    },
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Less ice, extra crispy, sauce on the side...',
                                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                                      filled: true,
                                      fillColor: const Color(0xFF1E1E1E),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: instructionsError != null ? Colors.redAccent : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: instructionsError != null ? Colors.redAccent : Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (instructionsError != null) ...[  
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            instructionsError!,
                                            style: const TextStyle(
                                              color: Colors.redAccent,
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

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
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

                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _addItemToCart(item, selectedCustoms, instructions, quantity);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
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
      backgroundColor: Colors.black,
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
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setCartState(() => _orderType = 'Eat In'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _orderType == 'Eat In' ? Colors.white : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '🍽️ Dine-In (Table)',
                                style: TextStyle(
                                  color: _orderType == 'Eat In' ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
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
                              color: _orderType == 'Take Out' ? Colors.white : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '🛍️ Take-Out',
                                style: TextStyle(
                                  color: _orderType == 'Take Out' ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white12, height: 24),

                  if (_cart.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Your cart is empty. Browse items to add!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cart.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 16),
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
                                    color: const Color(0xFF1E1E1E),
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
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    Text(
                                      '₱${cartItem.unitPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
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
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
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
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
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
                          if (widget.onProceedToCheckout != null) {
                            widget.onProceedToCheckout!(_cart, _orderType);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Customer & Table Info Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: const Color(0xFF141414),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: const Icon(Icons.person, color: Colors.white),
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
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onChangeTable,
                    child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Search Bar
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
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
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
                      selectedColor: Colors.white,
                      backgroundColor: const Color(0xFF1E1E1E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
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
                        style: TextStyle(color: Colors.grey),
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
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
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
                                          color: const Color(0xFF1E1E1E),
                                          child: const Icon(Icons.fastfood, color: Colors.white30, size: 40),
                                        ),
                                      ),
                                    ),
                                    if (!item.isAvailable)
                                      Container(
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'SOLD OUT',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₱${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add, size: 16, color: Colors.black),
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
          ],
        ),
      ),

      // Floating Cart Bottom Bar
      bottomNavigationBar: _cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF141414),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _openCartModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_cartTotalCount',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'VIEW CART ORDER',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            ),
    );
  }
}
