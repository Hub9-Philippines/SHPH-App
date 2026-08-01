/// Maps a category name to a local bundled asset (web-parity icons).
///
/// Supabase storage URLs are gone, so category icons now come from
/// `assets/images/`. Categories without a matching asset fall back to null so
/// callers can render a themed icon instead.
library;

const Map<String, String> _categoryAssets = {
  'aircon': 'assets/images/Aircon.png',
  'aircon services': 'assets/images/Aircon.png',
  'aircon repair': 'assets/images/Aircon.png',
  'hvac': 'assets/images/Aircon.png',
  'hvac services': 'assets/images/Aircon.png',
  'car wash': 'assets/images/Car Wash.png',
  'car wash services': 'assets/images/Car Wash.png',
  'carpentry': 'assets/images/Carpentry.png',
  'carpentry services': 'assets/images/Carpentry.png',
  'woodcrafts': 'assets/images/Carpentry.png',
  'woodcraft': 'assets/images/Carpentry.png',
  'cleaning': 'assets/images/cleaning.png',
  'cleaning services': 'assets/images/cleaning.png',
  'general cleaning': 'assets/images/cleaning.png',
  'house cleaning': 'assets/images/cleaning.png',
  'electrical': 'assets/images/electrical.png',
  'electrical services': 'assets/images/electrical.png',
  'electrician': 'assets/images/electrical.png',
  'general labor': 'assets/images/general labor.png',
  'general labour': 'assets/images/general labor.png',
  'general services': 'assets/images/general labor.png',
  'handyman': 'assets/images/general labor.png',
  'handyman services': 'assets/images/general labor.png',
  'landscape': 'assets/images/landscape.png',
  'landscaping': 'assets/images/landscape.png',
  'landscaping services': 'assets/images/landscape.png',
  'gardening': 'assets/images/landscape.png',
  'locksmith': 'assets/images/Locksmith.png',
  'locksmithing': 'assets/images/Locksmith.png',
  'safety and security': 'assets/images/Locksmith.png',
  'safety & security': 'assets/images/Locksmith.png',
  'painting': 'assets/images/painting.png',
  'painting services': 'assets/images/painting.png',
  'painters': 'assets/images/painting.png',
  'plumbing': 'assets/images/Plumbing.png',
  'plumbing services': 'assets/images/Plumbing.png',
};

/// Return the bundled asset path for a category, or null when no icon exists
/// yet (callers should fall back to a themed icon).
String? categoryAssetPath(String name) {
  final normalized = name.trim().toLowerCase();
  final direct = _categoryAssets[normalized];
  if (direct != null) {
    return direct;
  }
  for (final entry in _categoryAssets.entries) {
    if (normalized.contains(entry.key)) {
      return entry.value;
    }
  }
  return null;
}
