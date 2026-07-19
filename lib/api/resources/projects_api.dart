import '/api/models/paginated_response.dart';
import '/api/models/project.dart';
import '/api/shph_api_client.dart';

// A transport seam keeps endpoint and payload behavior testable without
// mutating the process-wide Dio client.
// ignore: one_member_abstracts
abstract interface class ProjectsApiTransport {
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  });
}

class ShphProjectsApiTransport implements ProjectsApiTransport {
  const ShphProjectsApiTransport();

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await ShphApiClient.instance.post<Map<String, dynamic>>(
      path,
      data: data,
    );
    return response.data ?? {};
  }
}

/// Projects endpoints verified against the production web client contract.
class ShphProjectsApi {
  ShphProjectsApi({ProjectsApiTransport? transport})
      : _transport = transport ?? const ShphProjectsApiTransport();

  static final ShphProjectsApi instance = ShphProjectsApi();
  final ProjectsApiTransport _transport;

  Future<ShphProject> create(Map<String, dynamic> payload) async {
    _validateCreatePayload(payload);
    return ShphProject.fromJson(
      await _transport.post('/api/projects/', data: payload),
    );
  }

  Future<PaginatedResponse<ShphProject>> list({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    _validatePage(page, pageSize);
    final normalizedStatus = status?.trim();
    final data = await _transport.post(
      '/api/projects/list/',
      data: {
        if (normalizedStatus != null && normalizedStatus.isNotEmpty)
          'status': normalizedStatus,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    return PaginatedResponse.fromJson(data, ShphProject.fromJson);
  }

  Future<ShphProject> detail(int id) async => ShphProject.fromJson(
        await _transport.post('/api/projects/${_validId(id)}/'),
      );

  Future<ShphProject> quote(
    int id, {
    String? contextHint,
    int? maxRoleLines,
  }) async {
    if (maxRoleLines != null && maxRoleLines <= 0) {
      throw const FormatException('maxRoleLines must be positive');
    }
    return ShphProject.fromJson(
      await _transport.post(
        '/api/projects/${_validId(id)}/quote/',
        data: {
          if (contextHint != null && contextHint.trim().isNotEmpty)
            'context_hint': contextHint.trim(),
          if (maxRoleLines != null) 'max_role_lines': maxRoleLines,
        },
      ),
    );
  }

  Future<ShphProject> match(int id, {required int roleLineId}) async =>
      ShphProject.fromJson(
        await _transport.post(
          '/api/projects/${_validId(id)}/match/',
          data: {'role_line_id': _validId(roleLineId)},
        ),
      );

  Future<ShphProject> cancel(int id) async => ShphProject.fromJson(
        await _transport.post('/api/projects/${_validId(id)}/cancel/'),
      );

  Future<Map<String, dynamic>> prospectAction({
    required int prospectId,
    required String action,
    double? agreedPrice,
  }) {
    final normalizedAction = action.trim();
    if (normalizedAction.isEmpty) {
      throw const FormatException('Project prospect action is required');
    }
    if (agreedPrice != null && (!agreedPrice.isFinite || agreedPrice < 0)) {
      throw const FormatException('Agreed price must be a non-negative number');
    }
    return _transport.post(
      '/api/projects/prospects/action/',
      data: {
        'prospect_id': _validId(prospectId),
        'action': normalizedAction,
        if (agreedPrice != null) 'agreed_price': agreedPrice,
      },
    );
  }

  static int _validId(int value) {
    if (value <= 0) {
      throw const FormatException('Project id must be positive');
    }
    return value;
  }

  static void _validatePage(int? page, int? pageSize) {
    if (page != null && page <= 0) {
      throw const FormatException('Page must be positive');
    }
    if (pageSize != null && (pageSize <= 0 || pageSize > 100)) {
      throw const FormatException('Page size must be between 1 and 100');
    }
  }

  static void _validateCreatePayload(Map<String, dynamic> payload) {
    final title = payload['title']?.toString().trim() ?? '';
    final description = payload['description']?.toString().trim() ?? '';
    final category = int.tryParse(payload['category']?.toString() ?? '');
    if (title.isEmpty ||
        description.isEmpty ||
        category == null ||
        category <= 0) {
      throw const FormatException(
        'Project title, description, and category are required',
      );
    }
  }
}
