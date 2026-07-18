import '../database.dart';

class BookingsTable extends ShphDataTable<BookingsRow> {
  @override
  String get tableName => 'bookings';

  @override
  BookingsRow createRow(Map<String, dynamic> data) => BookingsRow(data);
}

class BookingsRow extends ShphDataRow {
  BookingsRow(Map<String, dynamic> data) : super(data);

  @override
  ShphDataTable get table => BookingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get serviceListingId => getField<int>('service_listing_id')!;
  set serviceListingId(int value) => setField<int>('service_listing_id', value);

  String? get providerId => getField<String>('provider_id');
  set providerId(String? value) => setField<String>('provider_id', value);

  DateTime get bookingDate => getField<DateTime>('booking_date')!;
  set bookingDate(DateTime value) => setField<DateTime>('booking_date', value);

  String get bookingTime => getField<String>('booking_time')!;
  set bookingTime(String value) => setField<String>('booking_time', value);

  int? get addressId => getField<int>('address_id');
  set addressId(int? value) => setField<int>('address_id', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get paymentStatus => getField<String>('payment_status');
  set paymentStatus(String? value) => setField<String>('payment_status', value);

  double? get totalPrice => getField<double>('total_price');
  set totalPrice(double? value) => setField<double>('total_price', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  DateTime? get cancelledAt => getField<DateTime>('cancelled_at');
  set cancelledAt(DateTime? value) => setField<DateTime>('cancelled_at', value);
}
