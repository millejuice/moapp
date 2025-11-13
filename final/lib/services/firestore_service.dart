import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get products collection reference
  CollectionReference get productsCollection =>
      _firestore.collection('products');

  // Get all products
  Stream<List<Product>> getProducts() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // Get products sorted by price
  Stream<List<Product>> getProductsSorted(String sortOrder) {
    Query query = productsCollection;
    
    if (sortOrder == 'ASC') {
      query = query.orderBy('price', descending: false);
    } else {
      query = query.orderBy('price', descending: true);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // Get product by ID
  Future<Product?> getProduct(String id) async {
    try {
      final doc = await productsCollection.doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Add product
  Future<String?> addProduct(Product product) async {
    try {
      final docRef = await productsCollection.add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Update product
  Future<bool> updateProduct(String id, Product product) async {
    try {
      final updateData = product.toFirestore(isUpdate: true);
      // Remove createdAt from update data
      updateData.remove('createdAt');
      await productsCollection.doc(id).update(updateData);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      await productsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Like product
  Future<bool> likeProduct(String productId, String userId) async {
    try {
      final productRef = productsCollection.doc(productId);
      final productDoc = await productRef.get();
      
      if (!productDoc.exists) return false;

      final data = productDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        return false; // Already liked
      }

      likedBy.add(userId);
      await productRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': likedBy,
      });

      return true;
    } catch (e) {
      print('Error liking product: $e');
      return false;
    }
  }

  // Check if user has liked product
  Future<bool> hasUserLiked(String productId, String userId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      return likedBy.contains(userId);
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }
}

