import 'package:flutter/material.dart';

/// Shared slug/name → icon mapping for category tiles.
///
/// Used by the categories grid and the Explore shortcut row so both render
/// identical artwork for a given category.
class CategoryIcons {
  CategoryIcons._();

  static IconData? bySlug(String? slug) {
    if (slug == null) {
      return null;
    }
    switch (slug.trim().toLowerCase()) {
      case 'key':
        return Icons.key_rounded;
      case 'wrench':
        return Icons.plumbing_rounded;
      case 'zap':
        return Icons.bolt_rounded;
      case 'sparkles':
        return Icons.cleaning_services_rounded;
      case 'wind':
        return Icons.ac_unit_rounded;
      case 'tool':
        return Icons.kitchen_rounded;
      case 'bug':
        return Icons.bug_report_rounded;
      case 'car':
        return Icons.local_car_wash_rounded;
      case 'hammer':
        return Icons.handyman_rounded;
      case 'paint-bucket':
        return Icons.format_paint_rounded;
      case 'home':
        return Icons.roofing_rounded;
      case 'layers':
        return Icons.layers_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      case 'users':
        return Icons.engineering_rounded;
      default:
        return null;
    }
  }

  static IconData byName(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (normalized.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (normalized.contains('paint')) {
      return Icons.format_paint_rounded;
    }
    if (normalized.contains('electric')) {
      return Icons.bolt_rounded;
    }
    if (normalized.contains('aircon') || normalized.contains('hvac')) {
      return Icons.ac_unit_rounded;
    }
    if (normalized.contains('car wash')) {
      return Icons.local_car_wash_rounded;
    }
    if (normalized.contains('carpent') || normalized.contains('wood')) {
      return Icons.handyman_rounded;
    }
    if (normalized.contains('lock')) {
      return Icons.key_rounded;
    }
    if (normalized.contains('appliance')) {
      return Icons.kitchen_rounded;
    }
    if (normalized.contains('pest')) {
      return Icons.bug_report_rounded;
    }
    if (normalized.contains('roof')) {
      return Icons.roofing_rounded;
    }
    if (normalized.contains('mason')) {
      return Icons.layers_rounded;
    }
    if (normalized.contains('weld')) {
      return Icons.local_fire_department_rounded;
    }
    if (normalized.contains('landscap') || normalized.contains('garden')) {
      return Icons.park_rounded;
    }
    if (normalized.contains('mov')) {
      return Icons.local_shipping_rounded;
    }
    if (normalized.contains('labor') || normalized.contains('handyman')) {
      return Icons.engineering_rounded;
    }
    return Icons.category_rounded;
  }

  /// Slug first, then name-based fallback.
  static IconData resolve({String? slug, required String name}) =>
      bySlug(slug) ?? byName(name);
}
