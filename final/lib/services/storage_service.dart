import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class StorageService {
  // Use explicit bucket provided by user to ensure uploads go to the correct Storage
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://moappfinal-e52a2.firebasestorage.app',
  );

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
      // Try to reuse already uploaded default image in storage
      final ref = _storage.ref().child('default/product_default.jpg');
      try {
        final existing = await ref.getDownloadURL();
        return existing;
      } catch (_) {
        // Not found: download external default image and upload it
      }

      const defaultImageUrl = 'http://handong.edu/site/handong/res/img/logo.png';
      final response = await http.get(Uri.parse(defaultImageUrl));

      if (response.statusCode == 200) {
        // Upload to Firebase Storage
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

