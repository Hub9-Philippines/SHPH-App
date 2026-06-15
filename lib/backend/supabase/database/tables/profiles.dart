import '../database.dart';

class ProfilesTable extends SupabaseTable<ProfilesRow> {
  @override
  String get tableName => 'profiles';

  @override
  ProfilesRow createRow(Map<String, dynamic> data) => ProfilesRow(data);
}

class ProfilesRow extends SupabaseDataRow {
  ProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  bool? get isProfileComplete => getField<bool>('is_profile_complete');
  set isProfileComplete(bool? value) =>
      setField<bool>('is_profile_complete', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  String? get skillProfession => getField<String>('skill_profession');
  set skillProfession(String? value) =>
      setField<String>('skill_profession', value);

  String? get bioDetails => getField<String>('bio_details');
  set bioDetails(String? value) => setField<String>('bio_details', value);

  String? get faceScanUrl => getField<String>('face_scan_url');
  set faceScanUrl(String? value) => setField<String>('face_scan_url', value);

  String? get idDocumentUrl => getField<String>('id_document_url');
  set idDocumentUrl(String? value) =>
      setField<String>('id_document_url', value);

  // Alias for document_url (same as id_document_url)
  String? get documentUrl => getField<String>('document_url');
  set documentUrl(String? value) => setField<String>('document_url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  // Document verification fields
  String? get verificationStatus => getField<String>('verification_status');
  set verificationStatus(String? value) => setField<String>('verification_status', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  // Face verification fields
  bool? get isFaceVerified => getField<bool>('is_face_verified');
  set isFaceVerified(bool? value) => setField<bool>('is_face_verified', value);

  String? get faceVerificationToken => getField<String>('face_verification_token');
  set faceVerificationToken(String? value) => setField<String>('face_verification_token', value);

  DateTime? get lastVerificationDate => getField<DateTime>('last_verification_date');
  set lastVerificationDate(DateTime? value) => setField<DateTime>('last_verification_date', value);

  double? get faceVerificationScore => getField<double>('face_verification_score');
  set faceVerificationScore(double? value) => setField<double>('face_verification_score', value);
}
