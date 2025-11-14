import 'package:flutter/foundation.dart';

class DropDownProvider extends ChangeNotifier {
  String _value = 'ASC';

  String get value => _value;

  void setValue(String newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }
}
