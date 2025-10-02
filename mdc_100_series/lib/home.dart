import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'detail.dart';
import 'model/product.dart';
import 'model/products_repository.dart';
import 'model/favorites_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> _isSelected = [false, true]; // [ListView, GridView] - GridView selected by default
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try with different mode
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch URL: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

// TODO: Make a collection of cards (102)

// Replace this entire method
  List<Card> _buildGridCards(BuildContext context) {
    List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return products.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Hotel Image (Top)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Hero(
                tag: 'hotel-image-${product.id}',
                child: Image.asset(
                  product.assetName,
                  package: product.assetPackage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Hotel Info (Bottom)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Stars Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(height: 2.0),
                  // Hotel Name
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 12,
                      ),
                      const SizedBox(width: 2.0),
                      Expanded(
                        child: Text(
                          product.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // More Button (bottom right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(product: product),
                            ),
                          );
                        },
                        child: const Text(
                          'more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Method to build list view cards
  List<Widget> _buildListCards(BuildContext context) {
    List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (products.isEmpty) {
      return const <Widget>[];
    }

    final ThemeData theme = Theme.of(context);

    return products.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Hotel Image (Left)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Hero(
                    tag: 'hotel-image-${product.id}',
                    child: Image.asset(
                      product.assetName,
                      package: product.assetPackage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              // Hotel Info (Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stars Rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < product.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 4.0),
                    // Hotel Name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    // Location with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 14,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            product.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // More Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(product: product),
                              ),
                            );
                          },
                          child: const Text(
                            'more',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Drawer widget for navigation menu
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Pages',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home,color: Colors.lightBlueAccent,),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search,color: Colors.lightBlueAccent,),
            title: const Text('Search'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/search');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city,color: Colors.lightBlueAccent,),
            title: const Text('Favorite Hotels'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/favorite-hotels');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person,color: Colors.lightBlueAccent,),
            title: const Text('My Page'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/my-page');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout,color: Colors.lightBlueAccent,),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // TODO: Add a variable for Category (104)
  @override
  Widget build(BuildContext context) {
    // TODO: Return an AsymmetricView (104)
    // TODO: Pass Category variable to AsymmetricView (104)
    return Scaffold(
      // TODO: Add app bar (102)
      // TODO: Add a grid view (102)
      appBar: AppBar(
        title: const Text('Main'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        // TODO: Add buttons and title (102)
        // TODO: Add trailing buttons (102)
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  semanticLabel: 'favorites',
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/favorite-hotels');
                },
              ),
              if (_favoritesManager.favoriteCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_favoritesManager.favoriteCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.language,
              semanticLabel: 'language',
            ),
            onPressed: () {
              _launchURL('https://www.handong.edu/');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Toggle Button for switching between ListView and GridView
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButtons(
                  isSelected: _isSelected,
                  selectedColor: Colors.blue,
                  color: Colors.grey,
                  fillColor: Colors.transparent,
                  borderColor: Colors.grey,
                  selectedBorderColor: Colors.blue,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                        if (buttonIndex == index) {
                          _isSelected[buttonIndex] = true;
                        } else {
                          _isSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  children: const <Widget>[
                    Icon(Icons.list),
                    Icon(Icons.grid_view),
                  ],
                ),
              ],
            ),
          ),
          // Content area - ListView or GridView based on selection
          Expanded(
            child: _isSelected[0] 
                ? ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: _buildListCards(context),
                  )
                : OrientationBuilder(
                    builder: (context, orientation) {
                      return GridView.count(
                        crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                        padding: const EdgeInsets.all(8.0),
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                        children: _buildGridCards(context),
                      );
                    },
                  ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
