import 'package:flutter/material.dart';
import 'model/product.dart';
import 'model/favorites_manager.dart';
import 'detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Filter options
  bool noKidsZone = false;
  bool petFriendly = false;
  bool freeBreakfast = false;
  bool freeWifi = false;
  bool electricCarCharging = false;
  
  // Date options
  DateTime? checkInDate;
  DateTime? checkOutDate;
  
  // ExpansionPanel states
  bool isFilterExpanded = false;
  bool isDateExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      if (index == 0) {
                        isFilterExpanded = !isFilterExpanded;
                      } else if (index == 1) {
                        isDateExpanded = !isDateExpanded;
                      }
                    });
                  },
                  children: [
                    // Filter Section
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          leading: Icon(Icons.filter_list, color: Colors.blue),
                          title: Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'select filters',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                      body: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('No Kids Zone'),
                            subtitle: const Text('Adults only areas'),
                            value: noKidsZone,
                            onChanged: (bool? value) {
                              setState(() {
                                noKidsZone = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          CheckboxListTile(
                            title: const Text('Pet-Friendly'),
                            subtitle: const Text('Pets allowed'),
                            value: petFriendly,
                            onChanged: (bool? value) {
                              setState(() {
                                petFriendly = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          CheckboxListTile(
                            title: const Text('Free breakfast'),
                            subtitle: const Text('Complimentary morning meal'),
                            value: freeBreakfast,
                            onChanged: (bool? value) {
                              setState(() {
                                freeBreakfast = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          CheckboxListTile(
                            title: const Text('Free Wifi'),
                            subtitle: const Text('Complimentary internet access'),
                            value: freeWifi,
                            onChanged: (bool? value) {
                              setState(() {
                                freeWifi = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          CheckboxListTile(
                            title: const Text('Electric Car Charging'),
                            subtitle: const Text('EV charging station available'),
                            value: electricCarCharging,
                            onChanged: (bool? value) {
                              setState(() {
                                electricCarCharging = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                      isExpanded: isFilterExpanded,
                    ),
                    
                    // Date Section
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            // Check-in Date
                            Row(
                              children: [
                                const Icon(Icons.flight_takeoff, color: Colors.grey),
                                const SizedBox(width: 12),
                                const Text(
                                  'check-in',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        checkInDate != null
                                            ? '${checkInDate!.year}.${checkInDate!.month.toString().padLeft(2, '0')}.${checkInDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(checkInDate!)})'
                                            : '2018.10.05 (FRI)',
                                        style: TextStyle(
                                          color: checkInDate != null ? Colors.black : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        checkInDate != null ? '${checkInDate!.hour}:${checkInDate!.minute.toString().padLeft(2, '0')} am' : '9:30 am',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: checkInDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2025, 12, 31),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: Colors.blue,
                                            colorScheme: const ColorScheme.light(primary: Colors.blue),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null && picked != checkInDate) {
                                      setState(() {
                                        checkInDate = picked;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue[100],
                                    foregroundColor: Colors.blue,
                                    elevation: 0,
                                  ),
                                  child: const Text('select date'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Check-out Date
                            Row(
                              children: [
                                const Icon(Icons.flight_land, color: Colors.grey),
                                const SizedBox(width: 12),
                                const Text(
                                  'check-out',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        checkOutDate != null
                                            ? '${checkOutDate!.year}.${checkOutDate!.month.toString().padLeft(2, '0')}.${checkOutDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(checkOutDate!)})'
                                            : '2018.10.07 (SUN)',
                                        style: TextStyle(
                                          color: checkOutDate != null ? Colors.black : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        '11:00 am',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: checkOutDate ?? (checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1))),
                                      firstDate: checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
                                      lastDate: DateTime(2025, 12, 31),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: Colors.blue,
                                            colorScheme: const ColorScheme.light(primary: Colors.blue),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null && picked != checkOutDate) {
                                      setState(() {
                                        checkOutDate = picked;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue[100],
                                    foregroundColor: Colors.blue,
                                    elevation: 0,
                                  ),
                                  child: const Text('select date'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                      isExpanded: isDateExpanded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showSearchResultDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[date.weekday - 1];
  }

  void _showSearchResultDialog(BuildContext context) {
    List<String> selectedFilters = [];
    
    if (noKidsZone) selectedFilters.add('No Kids Zone');
    if (petFriendly) selectedFilters.add('Pet-Friendly');
    if (freeBreakfast) selectedFilters.add('Free breakfast');
    if (freeWifi) selectedFilters.add('Free Wifi');
    if (electricCarCharging) selectedFilters.add('Electric Car Charging');
    
    String checkInText = checkInDate != null 
        ? '${checkInDate!.year}.${checkInDate!.month.toString().padLeft(2, '0')}.${checkInDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(checkInDate!)})'
        : 'Not selected';
    
    String checkOutText = checkOutDate != null 
        ? '${checkOutDate!.year}.${checkOutDate!.month.toString().padLeft(2, '0')}.${checkOutDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(checkOutDate!)})'
        : 'Not selected';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: const Text(
              'Please check\nyour choice :)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          titlePadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFilters.isEmpty ? 'No filters selected' : selectedFilters.join(' / ') + ' /',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text('IN', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(checkInText, style: const TextStyle(fontSize: 14)),
                ],
              ),
              if (checkOutDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 28),
                    const Text('OUT', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(checkOutText, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search completed!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

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
              'SHRINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.lightBlueAccent),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.lightBlueAccent),
            title: const Text('Search'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/search');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city, color: Colors.lightBlueAccent),
            title: const Text('Favorite Hotels'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/favorite-hotels');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.lightBlueAccent),
            title: const Text('My Page'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/my-page');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.lightBlueAccent),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

class FavoriteHotelsPage extends StatefulWidget {
  const FavoriteHotelsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteHotelsPage> createState() => _FavoriteHotelsPageState();
}

class _FavoriteHotelsPageState extends State<FavoriteHotelsPage> {
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

  void _removeFavorite(Product product) {
    setState(() {
      _favoritesManager.removeFromFavorites(product);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${product.name} from favorites'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _favoritesManager.addToFavorites(product);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteHotels = _favoritesManager.favoriteHotels;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Hotels (${favoriteHotels.length})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: favoriteHotels.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorite hotels yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Double tap on hotel images to add them to favorites!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriteHotels.length,
              itemBuilder: (context, index) {
                final hotel = favoriteHotels[index];
                return Dismissible(
                  key: Key('favorite-hotel-${hotel.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (direction) {
                    _removeFavorite(hotel);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 0.2,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(product: hotel),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: const Center(
        child: Text(
          'My Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Shared drawer widget for all pages
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
            'SHRINE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Colors.lightBlueAccent),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.search, color: Colors.lightBlueAccent),
          title: const Text('Search'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/search');
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_city, color: Colors.lightBlueAccent),
          title: const Text('Favorite Hotels'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/favorite-hotels');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.lightBlueAccent),
          title: const Text('My Page'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/my-page');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.lightBlueAccent),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}