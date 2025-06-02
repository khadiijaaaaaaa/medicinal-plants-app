// bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF499265),
      selectedItemColor: const Color(0xFFF2E7D3),
      unselectedItemColor: const Color(0xFFF2E7D3).withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Identify',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.spa),
          label: 'Remedies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}