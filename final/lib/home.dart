import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/product.dart';
import 'services/firestore_service.dart';
import 'detail_page.dart';
import 'add_product_page.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import 'services/wishlist_provider.dart';
import 'wishlist_page.dart';
import 'package:shrine/services/login_provider.dart';
import 'package:shrine/services/dropdown_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LoginProvider>(
          builder: (context, loginProv, _) {
            return Text(loginProv.appBarTitle);
          },
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown for sorting
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<DropDownProvider>(
              builder: (BuildContext context, DropDownProvider dd, _) {
                return DropdownButton<String>(
                  value: dd.value,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'ASC', child: Text('ASC')),
                    DropdownMenuItem(value: 'DESC', child: Text('DESC')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) dd.setValue(newValue);
                  },
                );
              },
            ),
          ),

          // Product grid
          Expanded(
            child: Consumer<DropDownProvider>(
              builder: (BuildContext context, DropDownProvider dd, _) {
                return StreamBuilder<List<Product>>(
                  stream: _firestoreService.getProductsSorted(dd.value),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('오류: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('상품이 없습니다.'));
                    }

                    return _buildGridCards(context, snapshot.data!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCards(BuildContext context, List<Product> products) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Consumer<WishlistProvider>(
          builder: (context, wishlist, _) {
            final inWishlist = product.id != null && wishlist.contains(product.id!);
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Image area with optional wishlist badge
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.image, size: 50));
                                },
                              )
                            : const Center(child: Icon(Icons.image, size: 50)),
                        if (inWishlist)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.check, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Text/Action area
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(product.price),
                            style: theme.textTheme.titleSmall,
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: product.id != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPage(productId: product.id!),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text('more'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
