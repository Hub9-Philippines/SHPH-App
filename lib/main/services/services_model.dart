import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/service_listings.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import 'services_widget.dart' show ServicesScreen;

class ServicesModel extends FlutterFlowModel<ServicesScreen> {
  String? selectedCategory;
  String? selectedFilter;
  String searchQuery = '';
  bool isRecommended = false;
  bool isTopService = false;

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  final Set<int> favorites = <int>{};

  List<String> get categories {
    if (allServices.isEmpty) {
      return ['All'];
    }

    final uniqueCategories = allServices
        .map((service) => service['category'] as String)
        .toSet()
        .toList()
      ..sort();

    if (selectedCategory != null && selectedCategory != 'All') {
      uniqueCategories.remove(selectedCategory);
      return ['All', selectedCategory!, ...uniqueCategories];
    }

    return ['All', ...uniqueCategories];
  }

  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {
    filteredServices = List.from(allServices);
    _loadServicesFromDatabase().then((_) {
      isLoading = false;
      _coerceSelectedCategoryToAvailable();
      applyFilters();
      LoggingService.debug(
        'Service catalog loaded with ${allServices.length} items',
        tag: 'ServicesModel',
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }

  Future<void> _loadServicesFromDatabase() async {
    try {
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) =>
            q.eq('is_available', 'true').order('rating', ascending: false),
      );

      allServices = services
          .map((service) => {
                'id': service.id,
                'serviceId': service.id,
                'title': service.title,
                'category': service.categoryName ?? 'Service',
                'description': service.description ?? '',
                'price': service.basePrice != null
                    ? 'PHP ${service.basePrice}${service.priceUnit ?? ''}'
                    : 'PHP 0',
                'rating': double.tryParse(service.rating ?? '0') ?? 0.0,
                'reviewCount': service.reviewCount ?? 0,
                'imageUrl': service.thumbnail ?? '',
                'providerId': service.provider?.toString() ?? '',
                'providerName': service.providerName ?? 'Provider',
                'providerPhoto': service.providerPhoto ?? '',
                'isTimeMaterial': service.isTimeMaterial ?? false,
              })
          .toList();

      filteredServices = List.from(allServices);
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading services from database',
        tag: 'ServicesModel',
        error: e,
        stackTrace: stackTrace,
      );
      allServices = [];
      filteredServices = [];
    }
  }

  void applyFilters() {
    _coerceSelectedCategoryToAvailable();
    filteredServices = List.from(allServices);

    if (selectedCategory != null && selectedCategory != 'All') {
      filteredServices = filteredServices
          .where(
            (service) => _matchesCategory(
              selectedCategory!,
              service['category'] as String? ?? '',
            ),
          )
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filteredServices = filteredServices
          .where((service) {
            final query = searchQuery.toLowerCase();
            return (service['title'] as String).toLowerCase().contains(query) ||
                (service['category'] as String).toLowerCase().contains(query);
          })
          .toList();
    }

    switch (selectedFilter) {
      case 'recommended':
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
        filteredServices.sort((a, b) {
          final ratingA = a['rating'] as double;
          final ratingB = b['rating'] as double;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'lowestPrice':
        filteredServices.sort((a, b) {
          final priceA = _extractPrice(a['price'] as String);
          final priceB = _extractPrice(b['price'] as String);
          return priceA.compareTo(priceB);
        });
        break;
      case 'nearest':
        filteredServices.sort((a, b) {
          final ratingA = a['rating'] as double;
          final ratingB = b['rating'] as double;
          return ratingB.compareTo(ratingA);
        });
        break;
      default:
        break;
    }
  }

  double _extractPrice(String priceString) {
    final regex = RegExp(r'[\d,]+\.?\d*');
    final match = regex.firstMatch(priceString);
    if (match != null) {
      return double.parse(match.group(0)!.replaceAll(',', ''));
    }
    return 0;
  }

  void _coerceSelectedCategoryToAvailable() {
    final selected = selectedCategory;
    if (selected == null || selected == 'All' || allServices.isEmpty) {
      return;
    }

    final availableCategories = allServices
        .map((service) => service['category'] as String? ?? '')
        .where((category) => category.isNotEmpty)
        .toSet();

    for (final category in availableCategories) {
      if (_matchesCategory(selected, category)) {
        selectedCategory = category;
        return;
      }
    }
  }

  bool _matchesCategory(String selected, String actual) {
    final selectedNormalized = _normalizeCategory(selected);
    final actualNormalized = _normalizeCategory(actual);

    if (selectedNormalized == actualNormalized) {
      return true;
    }

    if (_categoryAlias(selectedNormalized) == _categoryAlias(actualNormalized)) {
      return true;
    }

    return actualNormalized.contains(selectedNormalized) ||
        selectedNormalized.contains(actualNormalized);
  }

  String _categoryAlias(String category) {
    switch (category) {
      case 'clean':
      case 'cleaning':
      case 'cleaningservice':
      case 'cleaningservices':
        return 'cleaning';
      case 'plumb':
      case 'plumbing':
      case 'plumbingservice':
      case 'plumbingservices':
        return 'plumbing';
      case 'electric':
      case 'electrical':
      case 'electricalservice':
      case 'electricalservices':
        return 'electrical';
      case 'paint':
      case 'painting':
      case 'paintingdecorating':
      case 'paintinganddecorating':
      case 'paintingdecoratingservice':
      case 'paintingdecoratingservices':
        return 'paintingdecorating';
      default:
        return category;
    }
  }

  String _normalizeCategory(String value) => value
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp('[^a-z0-9]+'), '');
}
