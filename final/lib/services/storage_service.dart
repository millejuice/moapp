import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image
  Future<String?> uploadImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get default image URL
  Future<String?> getDefaultImageUrl() async {
    try {
      // Download default image and upload to storage
      const defaultImageUrl = 'http://handong.edu/site/handong/res/img/logo.png';
      final response = await http.get(Uri.parse(defaultImageUrl));
      
      if (response.statusCode == 200) {
        // Upload to Firebase Storage
        final ref = _storage.ref().child('default/product_default.jpg');
        await ref.putData(response.bodyBytes);
        return await ref.getDownloadURL();
      }
      return defaultImageUrl; // Fallback to original URL
    } catch (e) {
      print('Error getting default image: $e');
      return 'http://handong.edu/site/handong/res/img/logo.png';
    }
  }

  // Delete image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.contains('firebasestorage')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}

