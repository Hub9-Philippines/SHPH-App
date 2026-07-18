import '../database.dart';

class AddressesTable extends ShphDataTable<AddressesRow> {
  @override
  String get tableName => 'addresses';

  @override
  AddressesRow createRow(Map<String, dynamic> data) => AddressesRow(data);
}

class AddressesRow extends ShphDataRow {
  AddressesRow(Map<String, dynamic> data) : super(data);

  @override
  ShphDataTable get table => AddressesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get addressLine1 => getField<String>('address_line1');
  set addressLine1(String? value) => setField<String>('address_line1', value);

  String? get addressLine2 => getField<String>('address_line2');
  set addressLine2(String? value) => setField<String>('address_line2', value);

  String? get barangay => getField<String>('barangay');
  set barangay(String? value) => setField<String>('barangay', value);

  String? get barangayCode => getField<String>('barangay_code');
  set barangayCode(String? value) => setField<String>('barangay_code', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  String? get cityMunicipalityCode =>
      getField<String>('city_municipality_code');
  set cityMunicipalityCode(String? value) =>
      setField<String>('city_municipality_code', value);

  String? get province => getField<String>('province');
  set province(String? value) => setField<String>('province', value);

  String? get provinceCode => getField<String>('province_code');
  set provinceCode(String? value) => setField<String>('province_code', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  String? get regionCode => getField<String>('region_code');
  set regionCode(String? value) => setField<String>('region_code', value);

  String? get postalCode => getField<String>('postal_code');
  set postalCode(String? value) => setField<String>('postal_code', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  bool? get isDefault => getField<bool>('is_default');
  set isDefault(bool? value) => setField<bool>('is_default', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
