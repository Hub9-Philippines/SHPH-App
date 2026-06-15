import 'package:flutter/foundation.dart';

import '/services/psgc_service.dart';

class GeographicSelectionModel extends ChangeNotifier {
  GeographicSelectionModel();

  bool isLoading = false;
  Map<String, List<dynamic>> groupedItems = {};
  List<dynamic> allItems = [];

  void loadData(GeographicSelectionType type, String? parentCode) async {
    isLoading = true;
    notifyListeners();

    try {
      List<dynamic> items;
      switch (type) {
        case GeographicSelectionType.region:
          items = await PSGCService.getRegions();
          break;
        case GeographicSelectionType.province:
          if (parentCode != null) {
            items = await PSGCService.getProvincesByRegion(parentCode);
          } else {
            items = [];
          }
          break;
        case GeographicSelectionType.cityMunicipality:
          if (parentCode != null) {
            items =
                await PSGCService.getCitiesMunicipalitiesByProvince(parentCode);
          } else {
            items = [];
          }
          break;
        case GeographicSelectionType.barangay:
          if (parentCode != null) {
            items =
                await PSGCService.getBarangaysByCityMunicipality(parentCode);
          } else {
            items = [];
          }
          break;
      }

      allItems = items;
      _groupItems(items);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading geographic data: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _groupItems(List<dynamic> items) {
    groupedItems = {};
    for (final item in items) {
      final name = item.name;
      if (name.isNotEmpty) {
        final firstLetter = name[0].toUpperCase();
        if (!groupedItems.containsKey(firstLetter)) {
          groupedItems[firstLetter] = [];
        }
        groupedItems[firstLetter]!.add(item);
      }
    }

    // Sort alphabetically
    final sortedKeys = groupedItems.keys.toList()..sort();
    groupedItems = {for (final key in sortedKeys) key: groupedItems[key]!};

    // Sort items within each group
    for (final key in groupedItems.keys) {
      groupedItems[key]!.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      _groupItems(allItems);
    } else {
      final filtered = allItems.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
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
