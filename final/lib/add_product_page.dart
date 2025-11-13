import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/product.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;
  String? _defaultImageUrl;

  @override
  void initState() {
    super.initState();
    _loadDefaultImage();
  }

  Future<void> _loadDefaultImage() async {
    final url = await _storageService.getDefaultImageUrl();
    setState(() {
      _defaultImageUrl = url;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _defaultImageUrl ?? 
          'http://handong.edu/site/handong/res/img/logo.png';

      // Create product first to get ID
      final product = Product(
        name: _nameController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl, // Temporary, will update after upload
        creatorUid: user.uid,
      );

      // Add product to get document ID
      final productId = await _firestoreService.addProduct(product);
      if (productId == null) {
        throw Exception('상품 추가 실패');
      }

      // Upload image if selected
      if (_selectedImage != null) {
        final uploadedUrl = await _storageService.uploadImage(
          _selectedImage!,
          productId,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
          // Update product with image URL
          final updatedProduct = product.copyWith(imageUrl: imageUrl);
          await _firestoreService.updateProduct(productId, updatedProduct);
        }
      } else {
        // Use default image URL
        final updatedProduct = product.copyWith(imageUrl: imageUrl);
        await _firestoreService.updateProduct(productId, updatedProduct);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품이 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _defaultImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _defaultImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.image, size: 80),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image, size: 80),
                          ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                onPressed: _pickImage,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 24),
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '상품명을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '가격을 입력하세요';
                }
                if (int.tryParse(value.trim()) == null) {
                  return '올바른 숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: UnderlineInputBorder(),
              ),
              maxLines: 3,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

