/// Address resource from SHPH API.yaml (`/api/profiles/addresses/*`).
class ShphAddress {
  const ShphAddress({
    required this.id,
    this.label,
    this.street,
    this.barangay,
    this.city,
    this.province,
    this.zipCode,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String? label;
  final String? street;
  final String? barangay;
  final String? city;
  final String? province;
  final String? zipCode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  factory ShphAddress.fromJson(Map<String, dynamic> json) {
    return ShphAddress(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String?,
      street: json['street'] as String?,
      barangay: json['barangay'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      zipCode: (json['zip_code'] as String?) ?? (json['postal_code'] as String?),
      isDefault: json['is_default'] as bool? ?? false,
      latitude: _firstLatitude(json),
      longitude: _firstLongitude(json),
    );
  }

  /// Request payload for create/update.
  Map<String, dynamic> toRequest() => {
        if (label != null) 'label': label,
        if (street != null) 'street': street,
        if (barangay != null) 'barangay': barangay,
        if (city != null) 'city': city,
        if (province != null) 'province': province,
        if (zipCode != null) 'zip_code': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };

  /// Shape for [FFAppState] selected-address tracking (includes `id`).
  Map<String, dynamic> toSelectedMap() => {
        'id': id,
        ...toRequest(),
      };

  static double? _firstLatitude(Map<String, dynamic> json) {
    final direct = _toDouble(json['latitude'] ?? json['lat']);
    if (direct != null) return direct;
    final location = json['location'];
    if (location is Map<String, dynamic>) {
      final inLocation = _toDouble(location['latitude'] ?? location['lat']);
      if (inLocation != null) return inLocation;
      final coordinates = location['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        return _toDouble(coordinates[1]);
      }
    }
    return null;
  }

  static double? _firstLongitude(Map<String, dynamic> json) {
    final direct = _toDouble(json['longitude'] ?? json['lng']);
    if (direct != null) return direct;
    final location = json['location'];
    if (location is Map<String, dynamic>) {
      final inLocation = _toDouble(location['longitude'] ?? location['lng']);
      if (inLocation != null) return inLocation;
      final coordinates = location['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        return _toDouble(coordinates[0]);
      }
    }
    return null;
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
