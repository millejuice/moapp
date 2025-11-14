import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final data = product.toFirestore();
      // Ensure likes and likedBy are present for new documents
      data['likes'] = data['likes'] ?? 0;
      data['likedBy'] = data['likedBy'] ?? [];
      final docRef = await productsCollection.add(data);
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
    final productRef = productsCollection.doc(productId);
    try {
      return await _firestore.runTransaction<bool>((tx) async {
        final snapshot = await tx.get(productRef);
        if (!snapshot.exists) {
          print('likeProduct: product doc does not exist: $productId');
          return false;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        print('likeProduct: before snapshot data for $productId: $data');

        if (likedBy.contains(userId)) {
          print('likeProduct: user $userId already in likedBy');
          return false; // Already liked
        }

        final updateMap = {
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        };

        // Compute a concrete simulated final document (what request.resource would look like)
        final int currentLikes = (data['likes'] is int) ? data['likes'] as int : 0;
        final int likesFinal = currentLikes + 1;
        final List<dynamic> currentLikedBy = List<dynamic>.from(data['likedBy'] ?? []);
        final List<dynamic> likedByFinal = [...currentLikedBy, userId];

        print('likeProduct: applying updateMap: $updateMap (userId: $userId)');
        print('likeProduct: simulated request.resource (concrete) => likes: $likesFinal, likedBy: $likedByFinal');

        // Perform the update
        tx.update(productRef, updateMap);
        return true;
      });
    } on FirebaseException catch (fe) {
      print('FirebaseException liking product: ${fe.code} ${fe.message}');
      // Extra debug hint: print current user and rules context not available here, but we can at least advise
      print('likeProduct: firebase exception while updating product $productId for user $userId');
      if (fe.code == 'permission-denied') rethrow;
      return false;
    } catch (e) {
      print('Error liking product (transaction): $e');
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

  /// Create a user document (named by uid) if it doesn't exist.
  Future<void> createUserIfNotExists(User user) async {
    try {
      final usersRef = _firestore.collection('users').doc(user.uid);
      final doc = await usersRef.get();
      if (!doc.exists) {
        // Default honor code pledge
        const pledge = 'I promise to take the test honestly before GOD.';
        if (user.isAnonymous) {
          await usersRef.set({
            'uid': user.uid,
            'status_message': pledge,
          });
        } else {
          await usersRef.set({
            'name': user.displayName ?? 'User',
            'email': user.email ?? 'Anonymous',
            'uid': user.uid,
            'status_message': pledge,
          });
        }
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Get user document data
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data() as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user document fields
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
}

