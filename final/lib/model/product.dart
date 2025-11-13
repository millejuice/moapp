import 'package:cloud_firestore/cloud_firestore.dart';

enum Category {
  all,
  accessories,
  clothing,
  home,
}

class Product {
  final String? id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String creatorUid;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final int likes;
  final List<String> likedBy;
  final Category category;
  final bool isFeatured;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.description = '',
    required this.imageUrl,
    required this.creatorUid,
    this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.likedBy = const [],
    this.category = Category.all,
    this.isFeatured = false,
  });

  // Create from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      category: _parseCategory(data['category']),
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore({bool isUpdate = false}) {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'creatorUid': creatorUid,
      'updatedAt': FieldValue.serverTimestamp(),
      'likes': likes,
      'likedBy': likedBy,
      'category': category.toString().split('.').last,
      'isFeatured': isFeatured,
    };
    
    // Only set createdAt when creating new document
    if (!isUpdate) {
      map['createdAt'] = createdAt ?? FieldValue.serverTimestamp();
    }
    
    return map;
  }

  // Copy with method for updates
  Product copyWith({
    String? name,
    int? price,
    String? description,
    String? imageUrl,
    int? likes,
    List<String>? likedBy,
    Timestamp? updatedAt,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorUid: creatorUid,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      category: category,
      isFeatured: isFeatured,
    );
  }

  static Category _parseCategory(dynamic categoryData) {
    if (categoryData == null) return Category.all;
    final categoryStr = categoryData.toString().toLowerCase();
    switch (categoryStr) {
      case 'accessories':
        return Category.accessories;
      case 'clothing':
        return Category.clothing;
      case 'home':
        return Category.home;
      default:
        return Category.all;
    }
  }

  @override
  String toString() => "$name (id=$id)";
}
