import '../database.dart';

class NotificationsTable extends ShphDataTable<NotificationsRow> {
  @override
  String get tableName => 'notifications';

  @override
  NotificationsRow createRow(Map<String, dynamic> data) =>
      NotificationsRow(data);
}

class NotificationsRow extends ShphDataRow {
  NotificationsRow(Map<String, dynamic> data) : super(data);

  @override
  ShphDataTable get table => NotificationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get body => getField<String>('body');
  set body(String? value) => setField<String>('body', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  bool get isRead => getField<bool>('is_read') ?? false;
  set isRead(bool value) => setField<bool>('is_read', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get actionUrl => getField<String>('action_url');
  set actionUrl(String? value) => setField<String>('action_url', value);

  Map<String, dynamic>? get metadata =>
      getField<Map<String, dynamic>>('metadata');
  set metadata(Map<String, dynamic>? value) =>
      setField<Map<String, dynamic>>('metadata', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);
}
