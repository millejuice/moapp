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

import 'product.dart';

class ProductsRepository {
  static List<Product> loadProducts(Category category) {
    const allProducts = <Product>[
      Product(
        category: Category.accessories,
        id: 0,
        isFeatured: true,
        name: 'Grand Luxury Hotel',
        price: 250,
        rating: 5,
        location: '123 5th Avenue, New York, NY 10001',
        description: 'Experience luxury at its finest with stunning city views, world-class amenities, and exceptional service in the heart of Manhattan. Our hotel features spacious suites, fine dining restaurants, spa facilities, and 24-hour room service.',
        phoneNumber: '+1 212 555 0123',
      ),
      Product(
        category: Category.accessories,
        id: 1,
        isFeatured: true,
        name: 'Ocean View Resort',
        price: 180,
        rating: 4,
        location: '21050 Pacific Coast Hwy, Malibu, CA 90265',
        description: 'A beautiful beachfront resort offering pristine ocean views, spa services, and direct beach access for the perfect getaway. Enjoy our infinity pool, beachside bar, and world-class wellness center.',
        phoneNumber: '+1 310 555 0456',
      ),
      Product(
        category: Category.accessories,
        id: 2,
        isFeatured: false,
        name: 'Mountain Lodge',
        price: 120,
        rating: 4,
        location: '675 Lionshead Pl, Vail, CO 81657',
        description: 'Cozy mountain retreat surrounded by nature with hiking trails, fireplace rooms, and stunning mountain vistas. Perfect for winter skiing and summer hiking adventures.',
        phoneNumber: '+1 970 555 0789',
      ),
      Product(
        category: Category.accessories,
        id: 3,
        isFeatured: true,
        name: 'City Center Hotel',
        price: 160,
        rating: 5,
        location: '900 W Olympic Blvd, Los Angeles, CA 90015',
        description: 'Modern hotel in the heart of LA with rooftop pool, fitness center, and easy access to major attractions. Features contemporary design and premium amenities.',
        phoneNumber: '+1 213 555 0321',
      ),
      Product(
        category: Category.accessories,
        id: 4,
        isFeatured: false,
        name: 'Boutique Inn',
        price: 95,
        rating: 4,
        location: '444 Presidio Ave, San Francisco, CA 94115',
        description: 'Charming boutique hotel with unique décor, personalized service, and prime location near Union Square. Experience intimate luxury with artisanal amenities.',
        phoneNumber: '+1 415 555 0654',
      ),
      Product(
        category: Category.accessories,
        id: 5,
        isFeatured: false,
        name: 'Business Hotel',
        price: 140,
        rating: 4,
        location: '320 N Dearborn St, Chicago, IL 60654',
        description: 'Modern business hotel with conference facilities, executive lounge, and convenient airport shuttle service. Perfect for corporate travelers.',
        phoneNumber: '+1 312 555 0987',
      ),
      Product(
        category: Category.accessories,
        id: 6,
        isFeatured: false,
        name: 'Riverside Resort',
        price: 200,
        rating: 5,
        location: '1510 SW Harbor Way, Portland, OR 97201',
        description: 'Peaceful riverside resort offering kayaking, fishing, spa treatments, and farm-to-table dining experiences. Surrounded by nature and tranquility.',
        phoneNumber: '+1 503 555 0147',
      ),
      Product(
        category: Category.accessories,
        id: 7,
        isFeatured: true,
        name: 'Historic Hotel',
        price: 175,
        rating: 5,
        location: '60 School St, Boston, MA 02108',
        description: 'Elegant historic hotel with classic architecture, fine dining restaurant, and rich cultural heritage. Located in the heart of historic Boston.',
        phoneNumber: '+1 617 555 0258',
      ),
      Product(
        category: Category.accessories,
        id: 8,
        isFeatured: true,
        name: 'Desert Oasis',
        price: 220,
        rating: 4,
        location: '5594 E Camelback Rd, Phoenix, AZ 85018',
        description: 'Luxury desert resort featuring golf course, multiple pools, spa services, and stunning desert landscapes. Experience the beauty of the Sonoran Desert.',
        phoneNumber: '+1 602 555 0369',
      ),
      Product(
        category: Category.home,
        id: 9,
        isFeatured: true,
        name: 'Gilt desk trio',
        price: 58,
      ),
      Product(
        category: Category.home,
        id: 10,
        isFeatured: false,
        name: 'Copper wire rack',
        price: 18,
      ),
      Product(
        category: Category.home,
        id: 11,
        isFeatured: false,
        name: 'Soothe ceramic set',
        price: 28,
      ),
      Product(
        category: Category.home,
        id: 12,
        isFeatured: false,
        name: 'Hurrahs tea set',
        price: 34,
      ),
      Product(
        category: Category.home,
        id: 13,
        isFeatured: true,
        name: 'Blue stone mug',
        price: 18,
      ),
      Product(
        category: Category.home,
        id: 14,
        isFeatured: true,
        name: 'Rainwater tray',
        price: 27,
      ),
      Product(
        category: Category.home,
        id: 15,
        isFeatured: true,
        name: 'Chambray napkins',
        price: 16,
      ),
      Product(
        category: Category.home,
        id: 16,
        isFeatured: true,
        name: 'Succulent planters',
        price: 16,
      ),
      Product(
        category: Category.home,
        id: 17,
        isFeatured: false,
        name: 'Quartet table',
        price: 175,
      ),
      Product(
        category: Category.home,
        id: 18,
        isFeatured: true,
        name: 'Kitchen quattro',
        price: 129,
      ),
      Product(
        category: Category.clothing,
        id: 19,
        isFeatured: false,
        name: 'Clay sweater',
        price: 48,
      ),
      Product(
        category: Category.clothing,
        id: 20,
        isFeatured: false,
        name: 'Sea tunic',
        price: 45,
      ),
      Product(
        category: Category.clothing,
        id: 21,
        isFeatured: false,
        name: 'Plaster tunic',
        price: 38,
      ),
      Product(
        category: Category.clothing,
        id: 22,
        isFeatured: false,
        name: 'White pinstripe shirt',
        price: 70,
      ),
      Product(
        category: Category.clothing,
        id: 23,
        isFeatured: false,
        name: 'Chambray shirt',
        price: 70,
      ),
      Product(
        category: Category.clothing,
        id: 24,
        isFeatured: true,
        name: 'Seabreeze sweater',
        price: 60,
      ),
      Product(
        category: Category.clothing,
        id: 25,
        isFeatured: false,
        name: 'Gentry jacket',
        price: 178,
      ),
      Product(
        category: Category.clothing,
        id: 26,
        isFeatured: false,
        name: 'Navy trousers',
        price: 74,
      ),
      Product(
        category: Category.clothing,
        id: 27,
        isFeatured: true,
        name: 'Walter henley (white)',
        price: 38,
      ),
      Product(
        category: Category.clothing,
        id: 28,
        isFeatured: true,
        name: 'Surf and perf shirt',
        price: 48,
      ),
      Product(
        category: Category.clothing,
        id: 29,
        isFeatured: true,
        name: 'Ginger scarf',
        price: 98,
      ),
      Product(
        category: Category.clothing,
        id: 30,
        isFeatured: true,
        name: 'Ramona crossover',
        price: 68,
      ),
      Product(
        category: Category.clothing,
        id: 31,
        isFeatured: false,
        name: 'Chambray shirt',
        price: 38,
      ),
      Product(
        category: Category.clothing,
        id: 32,
        isFeatured: false,
        name: 'Classic white collar',
        price: 58,
      ),
      Product(
        category: Category.clothing,
        id: 33,
        isFeatured: true,
        name: 'Cerise scallop tee',
        price: 42,
      ),
      Product(
        category: Category.clothing,
        id: 34,
        isFeatured: false,
        name: 'Shoulder rolls tee',
        price: 27,
      ),
      Product(
        category: Category.clothing,
        id: 35,
        isFeatured: false,
        name: 'Grey slouch tank',
        price: 24,
      ),
      Product(
        category: Category.clothing,
        id: 36,
        isFeatured: false,
        name: 'Sunshirt dress',
        price: 58,
      ),
      Product(
        category: Category.clothing,
        id: 37,
        isFeatured: true,
        name: 'Fine lines tee',
        price: 58,
      ),
    ];
    if (category == Category.all) {
      return allProducts;
    } else {
      return allProducts.where((Product p) {
        return p.category == category;
      }).toList();
    }
  }
}
