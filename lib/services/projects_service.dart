import '/api/resources/projects_api.dart';
import '/services/logging_service.dart';

class ProjectsService {
  ProjectsService._();
  static final ProjectsService instance = ProjectsService._();

  final _api = ShphProjectsApi.instance;

  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final resp = await _api.list();
      final results = resp['results'] ?? resp['projects'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching projects: $e',
          tag: 'ProjectsService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProject(String id) async {
    try {
      return await _api.detail(id);
    } catch (e) {
      LoggingService.error('Error fetching project: $e',
          tag: 'ProjectsService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createProject(
      Map<String, dynamic> payload) async {
    try {
      return await _api.create(payload);
    } catch (e) {
      LoggingService.error('Error creating project: $e',
          tag: 'ProjectsService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> quoteProject(String id) async {
    try {
      return await _api.quote(id);
    } catch (e) {
      LoggingService.error('Error quoting project: $e',
          tag: 'ProjectsService');
      return null;
    }
  }

  Future<bool> cancelProject(String id) async {
    try {
      await _api.cancel(id);
      return true;
    } catch (e) {
      LoggingService.error('Error cancelling project: $e',
          tag: 'ProjectsService');
      return false;
    }
  }
}
