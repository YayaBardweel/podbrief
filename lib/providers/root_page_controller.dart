// lib/providers/root_page_controller.dart
import 'package:flutter/material.dart';

class RootPageController with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void navigateToTab(int index) {
    if (_currentIndex != index) { // Only notify if index actually changes
      _currentIndex = index;
      notifyListeners();
    }
  }
}