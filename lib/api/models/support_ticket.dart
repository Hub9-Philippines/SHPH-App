/// A support ticket submitted by a user.
///
/// Mirrors `shph-api/support/serializers.py::SupportTicketSerializer`.
class ShphSupportTicket {
  const ShphSupportTicket({
    required this.id,
    required this.category,
    required this.message,
    this.user,
    this.userDisplayName,
    this.status = 'open',
    this.booking,
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  factory ShphSupportTicket.fromJson(Map<String, dynamic> json) =>
      ShphSupportTicket(
        id: json['id'] as int? ?? 0,
        user: json['user'] as int?,
        userDisplayName: json['user_display_name'] as String?,
        category: json['category'] as String? ?? 'general',
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
        booking: json['booking'] as int?,
        attachments: _strings(json['attachments']),
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        resolvedAt: json['resolved_at'] as String?,
      );

  final int id;
  final int? user;
  final String? userDisplayName;
  final String category;
  final String message;
  final String status;
  final int? booking;
  final List<String> attachments;
  final String? createdAt;
  final String? updatedAt;
  final String? resolvedAt;

  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';

  static List<String> _strings(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

/// A FAQ entry returned by `/api/support/faq/`.
class ShphFaq {
  const ShphFaq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.order = 0,
  });

  factory ShphFaq.fromJson(Map<String, dynamic> json) => ShphFaq(
        id: json['id'] as int? ?? 0,
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        category: json['category'] as String?,
        order: json['order'] as int? ?? 0,
      );

  final int id;
  final String question;
  final String answer;
  final String? category;
  final int order;
}
