import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/service_listings.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'services_widget.dart' show ServicesScreen;

class ServicesModel extends FlutterFlowModel<ServicesScreen> {
  ///  State fields for stateful widgets in this page.

  // Filter state
  String? selectedCategory;
  String?
      selectedFilter; // Combined filter: 'recommended', 'topRated', 'lowestPrice', 'nearest'
  String searchQuery = '';
  bool isRecommended = false;
  bool isTopService = false;

  // Search controller
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  // Favorites tracking (local state - needs database integration)
  final Set<int> favorites = <int>{};

  // Categories - dynamically generated from available services
  List<String> get categories {
    if (allServices.isEmpty) return ['All'];
    final uniqueCategories = allServices
        .map((service) => service['category'] as String)
        .toSet()
        .toList()
      ..sort();

    // If a category is selected, move it to the front after "All"
    if (selectedCategory != null && selectedCategory != 'All') {
      uniqueCategories.remove(selectedCategory);
      return ['All', selectedCategory!, ...uniqueCategories];
    }

    return ['All', ...uniqueCategories];
  }

  // Master list of services
  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {
    filteredServices = List.from(allServices);
    _loadServicesFromDatabase().then((_) {
      print('ServicesModel - Data loaded, setting isLoading to false');
      isLoading = false;
      // Re-apply filters after data is loaded
      print(
          'ServicesModel - Applying filters after data load. Category: $selectedCategory, Search: $searchQuery');
      applyFilters();
    });
    print('ServicesModel - initState completed');
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }

  /// Load services from database
  Future<void> _loadServicesFromDatabase() async {
    try {
      print('ServicesModel - Loading services from database...');
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) =>
            q.eq('is_available', 'true').order('rating', ascending: false),
      );

      print('ServicesModel - Loaded ${services.length} services from database');

      allServices = services
          .map((service) => {
                'id': service.id,
                'title': service.title,
                'category': service.categoryName ?? 'Service',
                'price': service.basePrice != null
                    ? '₱${service.basePrice}${service.priceUnit ?? ''}'
                    : '₱0',
                'rating': double.tryParse(service.rating ?? '0') ?? 0.0,
                'reviewCount': service.reviewCount ?? 0,
                'imageUrl': service.thumbnail ?? '',
              })
          .toList();

      print('ServicesModel - Mapped services: ${allServices.length}');
      print('ServicesModel - Categories: $categories');

      filteredServices = List.from(allServices);
    } catch (e) {
      print('Error loading services from database: $e');
      // Fallback to empty list if database fails
      allServices = [];
      filteredServices = [];
    }
  }

  /// Apply all filters to the service list
  void applyFilters() {
    print(
        'ServicesModel - applyFilters called. Category: $selectedCategory, Search: $searchQuery, Total services: ${allServices.length}');
    filteredServices = List.from(allServices);

    // Filter by category
    if (selectedCategory != null && selectedCategory != 'All') {
      print('ServicesModel - Filtering by category: $selectedCategory');
      filteredServices = filteredServices
          .where((service) => service['category'] == selectedCategory)
          .toList();
      print(
          'ServicesModel - After category filter: ${filteredServices.length} services');
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      print('ServicesModel - Filtering by search: $searchQuery');
      filteredServices = filteredServices
          .where((service) =>
              (service['title'] as String)
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              (service['category'] as String)
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
      print(
          'ServicesModel - After search filter: ${filteredServices.length} services');
    }

    // Apply combined filter
    switch (selectedFilter) {
      case 'recommended':
        // Sort by rating/review count
        filteredServices.sort((a, b) {
          final ratingA = a['rating'] as double;
          final ratingB = b['rating'] as double;
          final reviewCountA = a['reviewCount'] as int;
          final reviewCountB = b['reviewCount'] as int;

          if (ratingA != ratingB) {
            return ratingB.compareTo(ratingA);
          }
          return reviewCountB.compareTo(reviewCountA);
        });
        break;
      case 'topRated':
        // Sort by rating only
        filteredServices.sort((a, b) {
          final ratingA = a['rating'] as double;
          final ratingB = b['rating'] as double;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'lowestPrice':
        // Sort by price low to high
        filteredServices.sort((a, b) {
          final priceA = _extractPrice(a['price'] as String);
          final priceB = _extractPrice(b['price'] as String);
          return priceA.compareTo(priceB);
        });
        break;
      case 'nearest':
        // TODO: Implement location-based sorting
        // For now, sort by rating as placeholder
        filteredServices.sort((a, b) {
          final ratingA = a['rating'] as double;
          final ratingB = b['rating'] as double;
          return ratingB.compareTo(ratingA);
        });
        break;
      default:
        // No sorting
        break;
    }

    print(
        'ServicesModel - Final filtered services: ${filteredServices.length}');
  }

  /// Extract numeric price from price string (e.g., "₱500/hour" -> 500)
  double _extractPrice(String priceString) {
    final regex = RegExp(r'[\d,]+\.?\d*');
    final match = regex.firstMatch(priceString);
    if (match != null) {
      return double.parse(match.group(0)!.replaceAll(',', ''));
    }
    return 0;
  }
}
