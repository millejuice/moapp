import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'model/product.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'add_product_page.dart';

class DetailPage extends StatefulWidget {
  final String productId;

  const DetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  
  Product? _product;
  bool _isLoading = false;
  bool _hasLiked = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _firestoreService.getProduct(widget.productId);
    if (product != null) {
      setState(() {
        _product = product;
      });
      _checkLikeStatus();
    }
  }

  Future<void> _checkLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _product != null) {
      final hasLiked = await _firestoreService.hasUserLiked(
        widget.productId,
        user.uid,
      );
      setState(() {
        _hasLiked = hasLiked;
      });
    }
  }

  Future<void> _likeProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_hasLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only do it once !!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _firestoreService.likeProduct(
      widget.productId,
      user.uid,
    );

    if (success) {
      setState(() {
        _hasLiked = true;
      });
      _loadProduct(); // Reload to get updated like count
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('I LIKE IT!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only do it once !!')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _product == null) return;

    if (_product!.creatorUid != user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 권한이 없습니다.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      // Delete image from storage
      if (_product!.imageUrl.contains('firebasestorage')) {
        await _storageService.deleteImage(_product!.imageUrl);
      }
      final success = await _firestoreService.deleteProduct(widget.productId);
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품이 삭제되었습니다.')),
        );
      }
    }
  }

  void _startEdit() {
    // Open the edit page immediately instead of toggling an inline edit state.
    if (_product == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: _product!),
      ),
    ).then((_) {
      // Reload product after returning from edit page
      _loadProduct();
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadProduct(); // Reload original data
  }

  Future<void> _saveEdit() async {
    // Navigate to edit page (reuse AddProductPage)
    if (_product != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductPage(product: _product!),
        ),
      );
      _loadProduct();
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final canEdit = user != null && _product!.creatorUid == user.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail'),
        actions: [
          // Edit icon always visible; enabled only for the author
          IconButton(
            icon: const Icon(Icons.create),
            onPressed: !_isEditing
                ? (canEdit
                    ? _startEdit
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('수정 권한이 없습니다.')),
                        );
                      })
                : null,
            tooltip: canEdit ? 'Edit' : 'No permission',
          ),

          // Delete icon always visible; enabled only for the author
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: !_isEditing
                ? (canEdit
                    ? _deleteProduct
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('삭제 권한이 없습니다.')),
                        );
                      })
                : null,
            tooltip: canEdit ? 'Delete' : 'No permission',
          ),

          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEdit,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: _saveEdit,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image (clipped to avoid overflow/overlap)
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: _product!.imageUrl.isNotEmpty
                          ? Image.network(
                              _product!.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.image, size: 80),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(Icons.image, size: 80),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          _product!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Price and Like
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$ ${_product!.price}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: _hasLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: _isLoading ? null : _likeProduct,
                                ),
                                Text(
                                  '${_product!.likes}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          _product!.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Metadata
                        const Divider(),
                        Text(
                          'creator: ${_product!.creatorUid}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (_product!.createdAt != null)
                          Text(
                            '${_formatTimestamp(_product!.createdAt!)} Created',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (_product!.updatedAt != null)
                          Text(
                            '${_formatTimestamp(_product!.updatedAt!)} Modified',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yy.MM.dd HH:mm:ss').format(date);
  }
}

// Edit Product Page (reuses AddProductPage structure)
class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
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
    
    if (widget.product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 ID가 없습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.product.imageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final uploadedUrl = await _storageService.uploadImage(
          _selectedImage!,
          widget.product.id!,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final updatedProduct = widget.product.copyWith(
        name: _nameController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        updatedAt: Timestamp.now(),
      );

      final success = await _firestoreService.updateProduct(
        widget.product.id!,
        updatedProduct,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품이 수정되었습니다.')),
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
        title: const Text('Edit'),
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
            // Image
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
                    : widget.product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product.imageUrl,
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
            // Image pick button (use IconButton instead of FAB to avoid overlaying image)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                tooltip: 'Pick Image',
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

