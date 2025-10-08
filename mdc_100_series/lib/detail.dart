// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'model/product.dart';
import 'model/favorites_manager.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'hotel-image-${widget.product.id}',
                  flightShuttleBuilder: (context, animation, flightDirection, fromHeroContext, toHeroContext) {
                    return Material(
                      child: toHeroContext.widget,
                    );
                  },
                  child: InkWell(
                    onDoubleTap: () {
                      setState(() {
                        _favoritesManager.toggleFavorite(widget.product);
                      });
                      final bool isFavorite = _favoritesManager.isFavorite(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite 
                              ? 'Added ${widget.product.name} to favorites!' 
                              : 'Removed ${widget.product.name} from favorites!'
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      child: widget.product.imageUrl != null
                          ? Image.network(
                              widget.product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.hotel,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              widget.product.assetName,
                              package: widget.product.assetPackage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.hotel,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoritesManager.toggleFavorite(widget.product);
                      });
                      final bool isFavorite = _favoritesManager.isFavorite(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite 
                              ? 'Added ${widget.product.name} to favorites!' 
                              : 'Removed ${widget.product.name} from favorites!'
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      _favoritesManager.isFavorite(widget.product) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stars Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.product.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 12.0),
                  
                  // Animated Hotel Name
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        widget.product.name,
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 1000),
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Location with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          widget.product.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  
                  // Phone number with icon
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.product.phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  
                  // Description
                  Text(
                    widget.product.description ?? 'Experience luxury and comfort at this beautiful hotel with world-class amenities and exceptional service.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  
                  // Book Now Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: Text('Booking \${widget.product.name}...'),
                  //           duration: const Duration(seconds: 2),
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blue,
                  //       foregroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Book Now',
                  //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
