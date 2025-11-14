import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlist = {};

  bool contains(String productId) => _wishlist.contains(productId);

  void add(String productId) {
    _wishlist.add(productId);
    notifyListeners();
  }

  void remove(String productId) {
    _wishlist.remove(productId);
    notifyListeners();
  }

  void toggle(String productId) {
    if (contains(productId)) {
      remove(productId);
    } else {
      add(productId);
    }
  }

  List<String> get items => _wishlist.toList();
}
