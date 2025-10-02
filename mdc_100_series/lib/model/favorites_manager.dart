// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import 'product.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final List<Product> _favoriteHotels = [];

  List<Product> get favoriteHotels => List.unmodifiable(_favoriteHotels);

  bool isFavorite(Product product) {
    return _favoriteHotels.any((hotel) => hotel.id == product.id);
  }

  void addToFavorites(Product product) {
    if (!isFavorite(product)) {
      _favoriteHotels.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(Product product) {
    _favoriteHotels.removeWhere((hotel) => hotel.id == product.id);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      removeFromFavorites(product);
    } else {
      addToFavorites(product);
    }
  }

  int get favoriteCount => _favoriteHotels.length;
}