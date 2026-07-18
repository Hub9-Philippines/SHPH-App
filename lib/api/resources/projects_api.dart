import '/api/models/paginated_response.dart';
import '/api/models/project.dart';
import '/api/shph_api_client.dart';

/// Projects endpoints (`/api/projects/*`).
///
/// Backend: `shph-api/projects/urls.py`. List and detail endpoints accept
/// POST (POST-over-GET pattern) to keep authenticated user data off GET.
class ShphProjectsApi {
  ShphProjectsApi._();

  static final ShphProjectsApi instance = ShphProjectsApi._();
  final _client = ShphApiClient.instance;

  /// POST `/api/projects/` — create a new project demand.
  Future<ShphProject> create(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/',
      data: payload,
    );
    return ShphProject.fromJson(response.data ?? {});
  }

  /// POST `/api/projects/list/` — list the current user's projects.
  Future<PaginatedResponse<ShphProject>> list({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/list/',
      data: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphProject.fromJson,
    );
  }

  /// POST `/api/projects/<pk>/` — fetch a single project (POST-over-GET).
  Future<ShphProject> detail(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/',
    );
    return ShphProject.fromJson(response.data ?? {});
  }

  /// POST `/api/projects/<pk>/quote/` — generate/refresh the AI quote.
  ///
  /// Both fields are optional; the backend derives role lines from the
  /// project description when omitted.
  Future<ShphProject> quote(
    int id, {
    String? contextHint,
    int? maxRoleLines,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/quote/',
      data: {
        if (contextHint != null) 'context_hint': contextHint,
        if (maxRoleLines != null) 'max_role_lines': maxRoleLines,
      },
    );
    return ShphProject.fromJson(response.data ?? {});
  }

  /// POST `/api/projects/<pk>/match/` — find provider prospects for a role line.
  Future<ShphProject> match(int id, {required int roleLineId}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/match/',
      data: {'role_line_id': roleLineId},
    );
    return ShphProject.fromJson(response.data ?? {});
  }

  /// POST `/api/projects/<pk>/cancel/` — cancel a project demand.
  Future<ShphProject> cancel(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/cancel/',
    );
    return ShphProject.fromJson(response.data ?? {});
  }

  /// POST `/api/projects/prospects/action/` — shortlist/invite/accept/decline.
  Future<Map<String, dynamic>> prospectAction({
    required int prospectId,
    required String action,
    double? agreedPrice,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/prospects/action/',
      data: {
        'prospect_id': prospectId,
        'action': action,
        if (agreedPrice != null) 'agreed_price': agreedPrice,
      },
    );
    return response.data ?? {};
  }
}
