import 'package:flutter/foundation.dart';

import '/api/resources/locations_api.dart';

String? _stringValue(dynamic value) => value is String ? value : null;

// ignore: avoid_classes_with_only_static_members
abstract final class PSGCService {
  static final _api = ShphLocationsApi.instance;

  static Future<List<Region>> getRegions() async {
    return (await _api.listRegions()).map(Region.fromJson).toList();
  }

  static Future<List<Province>> getProvincesByRegion(String regionCode) async {
    return (await _api.listProvinces(regionCode: regionCode))
        .map(Province.fromJson)
        .toList();
  }

  static Future<List<CityMunicipality>> getCitiesMunicipalitiesByRegion(
      String regionCode) async {
    return (await _api.listCities(null, regionCode: regionCode))
        .map(CityMunicipality.fromJson)
        .toList();
  }

  static Future<List<CityMunicipality>> getCitiesMunicipalitiesByProvince(
      String provinceCode) async {
    return (await _api.listCities(provinceCode))
        .map(CityMunicipality.fromJson)
        .toList();
  }

  static Future<List<Barangay>> getBarangaysByCityMunicipality(
      String cityMunicipalityCode) async {
    return (await _api.listBarangays(cityMunicipalityCode))
        .map(Barangay.fromJson)
        .toList();
  }
}

@immutable
class Region {
  const Region({
    required this.code,
    required this.name,
    required this.regionName,
    required this.islandGroupCode,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        code: json['code'] as String,
        name: json['name'] as String,
        regionName: json['regionName'] as String,
        islandGroupCode: json['islandGroupCode'] as String,
      );
  final String code;
  final String name;
  final String regionName;
  final String islandGroupCode;

  @override
  String toString() => regionName;
}

@immutable
class Province {
  const Province({
    required this.code,
    required this.name,
    required this.regionCode,
    required this.islandGroupCode,
  });

  factory Province.fromJson(Map<String, dynamic> json) => Province(
        code: json['code'] as String,
        name: json['name'] as String,
        regionCode: json['regionCode'] as String,
        islandGroupCode: json['islandGroupCode'] as String,
      );
  final String code;
  final String name;
  final String regionCode;
  final String islandGroupCode;

  @override
  String toString() => name;
}

@immutable
class CityMunicipality {
  const CityMunicipality({
    required this.code,
    required this.name,
    required this.isCapital,
    required this.isCity,
    required this.isMunicipality,
    required this.regionCode,
    required this.islandGroupCode,
    this.oldName,
    this.districtCode,
    this.provinceCode,
  });

  factory CityMunicipality.fromJson(Map<String, dynamic> json) =>
      CityMunicipality(
        code: json['code'] as String,
        name: json['name'] as String,
        oldName: json['oldName'] as String?,
        isCapital: json['isCapital'] as bool? ?? false,
        isCity: json['isCity'] as bool? ?? false,
        isMunicipality: json['isMunicipality'] as bool? ?? false,
        districtCode: json['districtCode'] is String
            ? json['districtCode'] as String?
            : null,
        provinceCode: json['provinceCode'] is String
            ? json['provinceCode'] as String?
            : null,
        regionCode: json['regionCode'] as String,
        islandGroupCode: json['islandGroupCode'] as String,
      );
  final String code;
  final String name;
  final String? oldName;
  final bool isCapital;
  final bool isCity;
  final bool isMunicipality;
  final String? districtCode;
  final String? provinceCode;
  final String regionCode;
  final String islandGroupCode;

  @override
  String toString() => name;
}

@immutable
class Barangay {
  const Barangay({
    required this.code,
    required this.name,
    required this.cityMunicipalityCode,
    required this.regionCode,
    required this.islandGroupCode,
    this.oldName,
    this.provinceCode,
  });

  factory Barangay.fromJson(Map<String, dynamic> json) => Barangay(
        code: json['code'] as String,
        name: json['name'] as String,
        oldName: json['oldName'] as String?,
        cityMunicipalityCode: _stringValue(json['cityMunicipalityCode']) ??
            _stringValue(json['cityCode']) ??
            _stringValue(json['municipalityCode']) ??
            _stringValue(json['subMunicipalityCode']) ??
            '',
        regionCode: json['regionCode'] as String,
        provinceCode: _stringValue(json['provinceCode']),
        islandGroupCode: json['islandGroupCode'] as String,
      );
  final String code;
  final String name;
  final String? oldName;
  final String cityMunicipalityCode;
  final String regionCode;
  final String? provinceCode;
  final String islandGroupCode;

  @override
  String toString() => name;
}
