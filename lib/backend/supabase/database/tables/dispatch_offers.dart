import '../database.dart';

class DispatchOffersTable extends SupabaseTable<DispatchOffersRow> {
  @override
  String get tableName => 'dispatch_offers';

  @override
  DispatchOffersRow createRow(Map<String, dynamic> data) =>
      DispatchOffersRow(data);
}

class DispatchOffersRow extends SupabaseDataRow {
  DispatchOffersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DispatchOffersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get jobId => getField<String>('job_id')!;
  set jobId(String value) => setField<String>('job_id', value);

  String get providerId => getField<String>('provider_id')!;
  set providerId(String value) => setField<String>('provider_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get offeredAt => getField<DateTime>('offered_at');
  set offeredAt(DateTime? value) => setField<DateTime>('offered_at', value);

  DateTime? get respondedAt => getField<DateTime>('responded_at');
  set respondedAt(DateTime? value) =>
      setField<DateTime>('responded_at', value);
}
