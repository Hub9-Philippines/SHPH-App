import '../database.dart';

class JobRequestsTable extends SupabaseTable<JobRequestsRow> {
  @override
  String get tableName => 'job_requests';

  @override
  JobRequestsRow createRow(Map<String, dynamic> data) => JobRequestsRow(data);
}

class JobRequestsRow extends SupabaseDataRow {
  JobRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JobRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get clientId => getField<String>('client_id');
  set clientId(String? value) => setField<String>('client_id', value);

  String get serviceType => getField<String>('service_type')!;
  set serviceType(String value) => setField<String>('service_type', value);

  double get locationLat => getField<double>('location_lat')!;
  set locationLat(double value) => setField<double>('location_lat', value);

  double get locationLng => getField<double>('location_lng')!;
  set locationLng(double value) => setField<double>('location_lng', value);

  DateTime get requestedTime => getField<DateTime>('requested_time')!;
  set requestedTime(DateTime value) =>
      setField<DateTime>('requested_time', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get assignedProviderId => getField<String>('assigned_provider_id');
  set assignedProviderId(String? value) =>
      setField<String>('assigned_provider_id', value);

  String? get bookingId => getField<String>('booking_id');
  set bookingId(String? value) => setField<String>('booking_id', value);
}
