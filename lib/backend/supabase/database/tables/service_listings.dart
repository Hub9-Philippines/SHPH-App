import '../database.dart';

class ServiceListingsTable extends SupabaseTable<ServiceListingsRow> {
  @override
  String get tableName => 'service_listings';

  @override
  ServiceListingsRow createRow(Map<String, dynamic> data) => ServiceListingsRow(data);
}

class ServiceListingsRow extends SupabaseDataRow {
  ServiceListingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ServiceListingsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get category => getField<int>('category');
  set category(int? value) => setField<int>('category', value);

  String? get categoryName => getField<String>('category_name');
  set categoryName(String? value) => setField<String>('category_name', value);

  int? get provider => getField<int>('provider');
  set provider(int? value) => setField<int>('provider', value);

  String? get providerName => getField<String>('provider_name');
  set providerName(String? value) => setField<String>('provider_name', value);

  String? get providerPhoto => getField<String>('provider_photo');
  set providerPhoto(String? value) => setField<String>('provider_photo', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double? get basePrice => getField<double>('base_price');
  set basePrice(double? value) => setField<double>('base_price', value);

  String? get priceUnit => getField<String>('price_unit');
  set priceUnit(String? value) => setField<String>('price_unit', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get isAvailable => getField<String>('is_available');
  set isAvailable(String? value) => setField<String>('is_available', value);

  String? get rating => getField<String>('rating');
  set rating(String? value) => setField<String>('rating', value);

  String? get thumbnail => getField<String>('thumbnail');
  set thumbnail(String? value) => setField<String>('thumbnail', value);

  int? get reviewCount => getField<int>('review_count');
  set reviewCount(int? value) => setField<int>('review_count', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
