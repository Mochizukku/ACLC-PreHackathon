import 'package:flutter/material.dart';

import 'seller_brand_header.dart';

class SellerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationTap;

  const SellerAppBar({super.key, required this.onNotificationTap});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      title: const SellerBrandHeader(logoSize: 40, textWidth: 90),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: 'Account',
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF4B5563),
              size: 19,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: onNotificationTap,
              tooltip: 'Notifications',
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: Color(0xFF1E1E1E),
              ),
            ),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0202),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
