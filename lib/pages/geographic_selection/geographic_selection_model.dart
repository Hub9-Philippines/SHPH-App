import 'package:flutter/foundation.dart';

import '/api/shph_api.dart';

class GeographicSelectionModel extends ChangeNotifier {
  GeographicSelectionModel();

  bool isLoading = false;
  Map<String, List<Map<String, dynamic>>> groupedItems = {};
  List<Map<String, dynamic>> allItems = [];

  void loadData(
    GeographicSelectionType type,
    String? parentCode, {
    bool isRegionFallback = false,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      List<Map<String, dynamic>> items;
      switch (type) {
        case GeographicSelectionType.region:
          items = await ShphLocationsApi.instance.listProvinces();
          break;
        case GeographicSelectionType.province:
          if (parentCode != null) {
            items = await ShphLocationsApi.instance.listCities(parentCode);
          } else {
            items = [];
          }
          break;
        case GeographicSelectionType.cityMunicipality:
          if (parentCode != null) {
            items = await ShphLocationsApi.instance.listBarangays(parentCode);
          } else {
            items = [];
          }
          break;
        case GeographicSelectionType.barangay:
          items = [];
          break;
      }
      allItems = items;
      _groupItems(items);
    } catch (e) {
      if (kDebugMode) print('Error loading geographic data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _groupItems(List<Map<String, dynamic>> items) {
    groupedItems = {};
    for (final item in items) {
      final name = item['name'] as String? ?? '';
      if (name.isNotEmpty) {
        final firstLetter = name[0].toUpperCase();
        groupedItems.putIfAbsent(firstLetter, () => []);
        groupedItems[firstLetter]!.add(item);
      }
    }
    final sortedKeys = groupedItems.keys.toList()..sort();
    groupedItems = {for (final key in sortedKeys) key: groupedItems[key]!};
    for (final key in groupedItems.keys) {
      groupedItems[key]!.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      _groupItems(allItems);
    } else {
      final filtered = allItems
          .where((item) => (item['name'] as String? ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
      _groupItems(filtered);
    }
    notifyListeners();
  }

  String getTitle(GeographicSelectionType type) {
    switch (type) {
      case GeographicSelectionType.region:
        return 'Select Region';
      case GeographicSelectionType.province:
        return 'Select Province';
      case GeographicSelectionType.cityMunicipality:
        return 'Select City/Municipality';
      case GeographicSelectionType.barangay:
        return 'Select Barangay';
    }
  }
}

enum GeographicSelectionType {
  region,
  province,
  cityMunicipality,
  barangay,
}
