import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/home_feature/screens/home_screen.dart';
import '../features/browse_feature/screens/browse_screen.dart';
import '../features/library_feature/screens/watchlist_screen.dart';
import '../features/profile_feature/screens/profile_screen.dart';

class MainController extends GetxController {
  final RxInt _selectedIndex = 0.obs;

  RxInt get selectedIndex => _selectedIndex;

  List<BottomNavigationBarItem> get navigationItems => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: 'Browse',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border),
      activeIcon: Icon(Icons.bookmark),
      label: 'Watchlist',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  List<Widget> get pages => const [
    HomeScreen(),
    BrowseScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    if (index < 0 || index >= navigationItems.length) {
      return;
    }

    _selectedIndex.value = index;
  }
}
