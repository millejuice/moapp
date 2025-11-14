import 'package:flutter/foundation.dart';
import 'package:shrine/services/firestore_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  Map<String, dynamic>? _data;
  bool _isEditing = false;

  Map<String, dynamic>? get data => _data;
  bool get isEditing => _isEditing;

  Future<void> load(String uid) async {
    _data = await _service.getUser(uid);
    notifyListeners();
  }

  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  void stopEditing() {
    _isEditing = false;
    notifyListeners();
  }

  Future<bool> save(String uid, String statusMessage) async {
    final success = await _service.updateUser(uid, {'status_message': statusMessage});
    if (success) {
      _data?['status_message'] = statusMessage;
      _isEditing = false;
      notifyListeners();
    }
    return success;
  }
}
