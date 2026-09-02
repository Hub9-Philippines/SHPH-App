/// Core emergency service domains for the Serbisyo marketplace.
///
/// Single source of truth so Explore, Categories, and the Services rail all
/// flag and filter the same set (spec: service-search-workflow).
library;

const Set<String> coreEmergencyCategories = {
  'Electrical',
  'Locksmith',
  'Plumbing',
  'Pest Control',
};

/// Case-insensitive containment match against a category name or slug, so
/// variants like "Aircon & Electrical Repair" or "plumbing-services" still
/// flag. Over-matching is preferred over missing an electrical emergency.
bool isEmergencyCategory(String? nameOrSlug) {
  final value = (nameOrSlug ?? '').trim().toLowerCase();
  if (value.isEmpty) return false;
  return coreEmergencyCategories.any(
    (domain) =>
        value.contains(domain.toLowerCase()) ||
        domain.toLowerCase().contains(value),
  );
}
