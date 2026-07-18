import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/services/psgc_service.dart';

void main() {
  group('Barangay.fromJson', () {
    test('uses cityCode when PSGC returns a city barangay payload', () {
      final barangay = Barangay.fromJson(const {
        'code': '012805001',
        'name': 'Aglipay (Pob.)',
        'oldName': '',
        'cityCode': '012805000',
        'municipalityCode': false,
        'subMunicipalityCode': false,
        'provinceCode': '012800000',
        'regionCode': '010000000',
        'islandGroupCode': 'luzon',
      });

      expect(barangay.cityMunicipalityCode, '012805000');
      expect(barangay.provinceCode, '012800000');
    });

    test('falls back to municipalityCode when cityCode is absent', () {
      final barangay = Barangay.fromJson(const {
        'code': '012901001',
        'name': 'Sample',
        'oldName': '',
        'cityCode': false,
        'municipalityCode': '012901000',
        'subMunicipalityCode': false,
        'provinceCode': '012900000',
        'regionCode': '010000000',
        'islandGroupCode': 'luzon',
      });

      expect(barangay.cityMunicipalityCode, '012901000');
    });
  });
}
