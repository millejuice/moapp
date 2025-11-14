import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/wishlist_provider.dart';
import 'services/firestore_service.dart';
import 'model/product.dart';
import 'detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wish List'),
      ),
      body: FutureBuilder<List<Product?>>(
        future: Future.wait(wishlist.items.map((id) => service.getProduct(id))),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = (snapshot.data ?? []).whereType<Product>().toList();
          if (products.isEmpty) {
            return const Center(child: Text('Wishlist is empty'));
          }
          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                    : const Icon(Icons.image),
                title: Text(product.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    wishlist.remove(product.id!);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage(productId: product.id!)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
