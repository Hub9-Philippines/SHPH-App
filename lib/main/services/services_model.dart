import 'package:flutter/material.dart';

import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/app_state.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/auth_service.dart';
import '/services/favorites_service.dart';
import '/services/logging_service.dart';
import '/utils/emergency_categories.dart';
import '/utils/geo_utils.dart';
import '/utils/tagalog_service_keywords.dart';
import 'services_widget.dart' show ServicesScreen;

class ServicesModel extends FlutterFlowModel<ServicesScreen> {
  String? selectedCategory;
  String? selectedFilter;
  String searchQuery = '';
  bool isRecommended = false;
  bool isTopService = false;

  /// Urgent Assistance entry: limits categories/results to the core
  /// emergency domains (spec: service-search-workflow).
  bool emergencyMode = false;

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  /// Server-synced favorite listing IDs. Loaded from the favorites API on
  /// page init and updated optimistically on toggle.
  final Set<int> favorites = <int>{};

  /// Loads the user's favorites from the API into [favorites]. Best-effort:
  /// failures keep whatever is already loaded (heart states stay consistent
  /// within the session). Only meaningful when signed in.
  Future<void> loadFavorites() async {
    if (!AuthService.instance.isAuthenticated) {
      return;
    }
    try {
      final rows = await FavoritesService.instance.getFavoriteServices();
      favorites
        ..clear()
        ..addAll(rows.map((row) => row.id));
      LoggingService.debug(
        'Loaded ${favorites.length} favorites',
        tag: 'ServicesModel',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to load favorites',
        tag: 'ServicesModel',
        error: e,
      );
    }
  }

  /// Optimistically toggles a favorite and syncs to the API. Returns the new
  /// favorite state, or null when the API call failed (local state is then
  /// reverted) or the user is not authenticated.
  Future<bool?> toggleFavorite(int serviceId) async {
    if (!AuthService.instance.isAuthenticated) {
      return null;
    }
    final wasFavorite = favorites.contains(serviceId);
    // Optimistic update so the heart reacts instantly.
    if (wasFavorite) {
      favorites.remove(serviceId);
    } else {
      favorites.add(serviceId);
    }

    final ok = wasFavorite
        ? await FavoritesService.instance.removeFromFavorites(serviceId)
        : await FavoritesService.instance.addToFavorites(serviceId);

    if (!ok) {
      // Revert on failure.
      if (wasFavorite) {
        favorites.add(serviceId);
      } else {
        favorites.remove(serviceId);
      }
      return null;
    }
    return !wasFavorite;
  }

  List<String> get categories {
    if (allServices.isEmpty) {
      return ['All'];
    }

    final uniqueCategories = allServices
        .map((service) => service['category'] as String)
        .toSet()
        .toList()
      ..sort();

    if (emergencyMode) {
      uniqueCategories.retainWhere(isEmergencyCategory);
    }

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
    loadFavorites();
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
      // Pass the user's pinned location so the backend computes the real
      // distance_km for each listing; otherwise distances are null.
      final appState = FFAppState();
      final useLocation = GeoUtils.hasValidLocation(
        appState.selectedLatitude,
        appState.selectedLongitude,
      );
      final services = await ShphServicesApi.instance.listListings(
        ordering: '-rating',
        pageSize: 100,
        latitude: useLocation ? appState.selectedLatitude : null,
        longitude: useLocation ? appState.selectedLongitude : null,
      );
      final listings = services.results;

      allServices = listings.map((service) {
        return {
          'id': service.id,
          'serviceId': service.id,
          'title': service.title,
          'category': service.categoryName ?? 'Service',
          'description': service.description ?? '',
          'price': service.basePrice != null
              ? 'PHP ${_formatPrice(service.basePrice!)}${_priceUnitSuffix(service.priceUnit)}'
              : 'PHP 0',
          'rating': double.tryParse(service.rating ?? '0') ?? 0.0,
          'reviewCount': service.reviewCount ?? 0,
          'imageUrl': service.thumbnail ?? '',
          'providerId': service.provider?.toString() ?? '',
          'providerName': service.providerName ?? 'Provider',
          'providerPhoto': service.providerPhoto ?? '',
          'isTimeMaterial': service.isTimeMaterial,
          'distanceKm': service.distanceKm ?? 99.0,
          'distanceText': service.distanceKm != null
              ? _formatDistance(service.distanceKm!)
              : _locationFallback(service),
          'providerLatitude': service.latitude,
          'providerLongitude': service.longitude,
          'nearbyPros': const <Map<String, dynamic>>[],
        };
      }).toList();

      filteredServices = List.from(allServices);
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading services from API',
        tag: 'ServicesModel',
        error: e,
        stackTrace: stackTrace,
      );
      allServices = [];
      filteredServices = [];
    }
  }

  static String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }

  /// Renders the base price without a forced decimal (500, not 500.0) while
  /// keeping fractional amounts intact (499.5).
  static String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.round().toString();
    }
    return price.toStringAsFixed(2);
  }

  /// Builds the " per visit"-style suffix with the leading space the raw
  /// price_unit string lacks (previously rendered "PHP 500.0pervisit").
  static String _priceUnitSuffix(String? unit) {
    final trimmed = unit?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '';
    }
    return ' $trimmed';
  }

  /// Distance is only computed server-side when the request carries lat/lng.
  /// Without it, show the listing's registered city instead of "Unknown";
  /// null when nothing is on file (widget falls back to a localized label).
  static String? _locationFallback(ShphServiceListing service) {
    final city = service.city?.trim() ?? '';
    final province = service.province?.trim() ?? '';
    if (city.isNotEmpty) {
      return province.isNotEmpty && province.toLowerCase() != city.toLowerCase()
          ? '$city, $province'
          : city;
    }
    if (province.isNotEmpty) {
      return province;
    }
    return null;
  }

  void applyFilters() {
    _coerceSelectedCategoryToAvailable();
    filteredServices = List.from(allServices);

    if (emergencyMode) {
      filteredServices = filteredServices
          .where(
            (service) => isEmergencyCategory(
              service['category'] as String? ?? '',
            ),
          )
          .toList();
    }

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
      final terms = expandTagalogQuery(searchQuery);
      filteredServices = filteredServices.where((service) {
        final title = (service['title'] as String).toLowerCase();
        final category = (service['category'] as String).toLowerCase();
        return terms.any((term) => title.contains(term) || category.contains(term));
      }).toList();
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
          final distA = a['distanceKm'] as double;
          final distB = b['distanceKm'] as double;
          return distA.compareTo(distB);
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

    if (_categoryAlias(selectedNormalized) ==
        _categoryAlias(actualNormalized)) {
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
