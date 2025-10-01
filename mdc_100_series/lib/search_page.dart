import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ===== Filters =====
  bool noKidsZone = false;
  bool petFriendly = false;
  bool freeBreakfast = true;   
  bool freeWifi = false;
  bool electricCarCharging = false;

  // ===== Dates =====
  DateTime? checkInDate;
  DateTime? checkOutDate;

  // ===== Expansion states (Filter, Date) =====
  List<bool> _isExpanded = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Theme(
                  // 미세한 구분선 색상
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.grey.shade300,
                  ),
                  child: ExpansionPanelList(
                    elevation: 0,
                    animationDuration: const Duration(milliseconds: 300),
                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                    children: [
                      // ===== Filter Panel =====
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _isExpanded[0],
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            leading: const Icon(Icons.filter_list, color: Colors.blue),
                            title: const Text(
                              'Filter',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'select filters',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              _filterTile(
                                label: 'No Kids Zone',
                                value: noKidsZone,
                                onChanged: (v) => setState(() => noKidsZone = v),
                              ),
                              _filterTile(
                                label: 'Pet-Friendly',
                                value: petFriendly,
                                onChanged: (v) => setState(() => petFriendly = v),
                              ),
                              _filterTile(
                                label: 'Free breakfast',
                                value: freeBreakfast,
                                onChanged: (v) => setState(() => freeBreakfast = v),
                              ),
                              
                            ],
                          ),
                        ),
                      ),

                      // ===== Date Panel =====
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _isExpanded[1],
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            leading: Icon(Icons.calendar_today, color: Colors.blue),
                            title: Text(
                              'Date',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Check-in
                              Row(
                                children: const [
                                  Icon(Icons.flight_takeoff, color: Colors.grey),
                                  SizedBox(width: 12),
                                  Text('check-in', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _dateTexts(checkInDate, fallbackDate: '2018.10.05 (FRI)', fallbackTime: '9:30 am')),
                                  ElevatedButton(
                                    onPressed: _pickCheckIn,
                                    style: _dateBtnStyle(),
                                    child: const Text('select date'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Check-out
                              Row(
                                children: const [
                                  Icon(Icons.flight_land, color: Colors.grey),
                                  SizedBox(width: 12),
                                  Text('check-out', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _dateTexts(checkOutDate, fallbackDate: '2018.10.07 (SUN)', fallbackTime: '11:00 am')),
                                  ElevatedButton(
                                    onPressed: _pickCheckOut,
                                    style: _dateBtnStyle(),
                                    child: const Text('select date'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== Bottom Search Button =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSummaryDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI helpers ----------
  CheckboxListTile _filterTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  static ButtonStyle _dateBtnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlue[100],
      foregroundColor: Colors.blue,
      elevation: 0,
    );
  }

  static Widget _dateTexts(DateTime? dt, {required String fallbackDate, required String fallbackTime}) {
    final bool has = dt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          has ? _fmtYmdDow(dt) : fallbackDate,
          style: TextStyle(color: has ? Colors.black : Colors.grey, fontSize: 14),
        ),
        Text(
          has ? _fmtHourMin(dt) : fallbackTime,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ---------- Pickers ----------
  Future<void> _pickCheckIn() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: checkInDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030, 12, 31),
      builder: _pickerTheme,
    );
    if (picked != null) {
      setState(() {
        checkInDate = picked;
        // 체크인보다 이전인 체크아웃을 자동 보정
        if (checkOutDate != null && !checkOutDate!.isAfter(checkInDate!)) {
          checkOutDate = checkInDate!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final base = checkInDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: checkOutDate ?? base.add(const Duration(days: 1)),
      firstDate: base.add(const Duration(days: 1)),
      lastDate: DateTime(2030, 12, 31),
      builder: _pickerTheme,
    );
    if (picked != null) {
      setState(() => checkOutDate = picked);
    }
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(primary: Colors.blue),
      ),
      child: child!,
    );
  }

  // ---------- Dialog ----------
  void _showSummaryDialog() {
    final filters = <String>[
      if (noKidsZone) 'No Kids Zone',
      if (petFriendly) 'Pet-Friendly',
      if (freeBreakfast) 'Free breakfast',
      if (freeWifi) 'Free Wifi',
      if (electricCarCharging) 'Electric Car Charging',
    ];
    final filtersText = filters.isEmpty ? 'No filters selected' : '${filters.join(' / ')} /';

    final inText = checkInDate != null ? _fmtYmdDow(checkInDate!) : 'Not selected';
    final outText = checkOutDate != null ? _fmtYmdDow(checkOutDate!) : 'Not selected';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue,
          child: const Text(
            'Please check\nyour choice :)',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(filtersText)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text('IN', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(inText),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 28),
                const Text('OUT', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(outText),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search completed!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // ---------- Utils ----------
  static String _fmtYmdDow(DateTime d) {
    const dow = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} (${dow[d.weekday - 1]})';
    // 필요하면 intl 패키지로 현지화 가능
  }

  static String _fmtHourMin(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'am' : 'pm';
    return '$h:$m $ampm';
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('SHRINE', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.lightBlueAccent),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.lightBlueAccent),
            title: const Text('Search'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.location_city, color: Colors.lightBlueAccent),
            title: const Text('Favorite Hotels'),
            onTap: () => Navigator.pushReplacementNamed(context, '/favorite-hotels'),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.lightBlueAccent),
            title: const Text('My Page'),
            onTap: () => Navigator.pushReplacementNamed(context, '/my-page'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.lightBlueAccent),
            title: const Text('Logout'),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
