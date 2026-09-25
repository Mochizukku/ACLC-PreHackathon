import 'package:flutter/material.dart';

class SellerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SellerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    (
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    (
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      label: 'Products',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDFDFDF), width: 1)),
      ),
      child: SizedBox(
        height: 52,
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: item.label,
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E1E1E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        size: 27,
                        color: isSelected
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFA1A1A1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
