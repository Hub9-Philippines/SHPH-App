import 'package:flutter/foundation.dart';

import '/api/models/paginated_response.dart';
import '/api/models/project.dart';
import '/api/resources/projects_api.dart';
import '/services/logging_service.dart';

enum ProjectsState { idle, loading, ready, mutating, error }

typedef LoadProjects = Future<PaginatedResponse<ShphProject>> Function({
  String? status,
  int? page,
  int? pageSize,
});
typedef LoadProject = Future<ShphProject> Function(int id);
typedef CreateProject = Future<ShphProject> Function(
  Map<String, dynamic> payload,
);
typedef QuoteProject = Future<ShphProject> Function(
  int id, {
  String? contextHint,
  int? maxRoleLines,
});
typedef MatchProject = Future<ShphProjectRoleLine> Function(
  int id, {
  required int roleLineId,
});
typedef CancelProject = Future<ShphProject> Function(int id);
typedef ActOnProjectProspect = Future<ShphProjectProspect> Function({
  required int prospectId,
  required String action,
  double? agreedPrice,
});

/// Non-UI Projects state adapted from the source pages and production web
/// store, with serialized mutations and safe user-facing errors.
class ProjectsController extends ChangeNotifier {
  ProjectsController({
    required LoadProjects loadProjects,
    required LoadProject loadProject,
    required CreateProject createProject,
    required QuoteProject quoteProject,
    required MatchProject matchProject,
    required CancelProject cancelProject,
    required ActOnProjectProspect actOnProspect,
  })  : _loadProjects = loadProjects,
        _loadProject = loadProject,
        _createProject = createProject,
        _quoteProject = quoteProject,
        _matchProject = matchProject,
        _cancelProject = cancelProject,
        _actOnProspect = actOnProspect;

  factory ProjectsController.production([ShphProjectsApi? api]) {
    final projectsApi = api ?? ShphProjectsApi.instance;
    return ProjectsController(
      loadProjects: projectsApi.list,
      loadProject: projectsApi.detail,
      createProject: projectsApi.create,
      quoteProject: projectsApi.quote,
      matchProject: projectsApi.match,
      cancelProject: projectsApi.cancel,
      actOnProspect: projectsApi.prospectAction,
    );
  }

  final LoadProjects _loadProjects;
  final LoadProject _loadProject;
  final CreateProject _createProject;
  final QuoteProject _quoteProject;
  final MatchProject _matchProject;
  final CancelProject _cancelProject;
  final ActOnProjectProspect _actOnProspect;

  ProjectsState _state = ProjectsState.idle;
  List<ShphProject> _projects = const [];
  ShphProject? _currentProject;
  String? _errorMessage;

  ProjectsState get state => _state;
  List<ShphProject> get projects => List.unmodifiable(_projects);
  ShphProject? get currentProject => _currentProject;
  String? get errorMessage => _errorMessage;
  bool get isBusy =>
      _state == ProjectsState.loading || _state == ProjectsState.mutating;

  Future<bool> load({String? status, int? page, int? pageSize}) async {
    if (!_begin(ProjectsState.loading)) {
      return false;
    }
    try {
      final response = await _loadProjects(
        status: status,
        page: page,
        pageSize: pageSize,
      );
      _projects = List.unmodifiable(response.results);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to load projects.', error, stackTrace);
      return false;
    }
  }

  Future<bool> open(int id) async {
    if (id <= 0 || !_begin(ProjectsState.loading)) {
      return false;
    }
    try {
      _currentProject = await _loadProject(id);
      _replaceProject(_currentProject!);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to load this project.', error, stackTrace);
      return false;
    }
  }

  Future<ShphProject?> create(Map<String, dynamic> payload) async {
    if (!_begin(ProjectsState.mutating)) {
      return null;
    }
    try {
      final project = await _createProject(payload);
      _currentProject = project;
      _replaceProject(project, prepend: true);
      _complete();
      return project;
    } catch (error, stackTrace) {
      _fail('Unable to create the project.', error, stackTrace);
      return null;
    }
  }

  Future<bool> quote({String? contextHint, int? maxRoleLines}) async {
    final project = _currentProject;
    if (project == null || !_begin(ProjectsState.mutating)) {
      return false;
    }
    try {
      final updated = await _quoteProject(
        project.id,
        contextHint: contextHint,
        maxRoleLines: maxRoleLines,
      );
      _currentProject = updated;
      _replaceProject(updated);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to generate the project quote.', error, stackTrace);
      return false;
    }
  }

  Future<bool> match(int roleLineId) async {
    final project = _currentProject;
    if (project == null || roleLineId <= 0 || !_begin(ProjectsState.mutating)) {
      return false;
    }
    try {
      await _matchProject(project.id, roleLineId: roleLineId);
      await _refreshCurrent(project.id);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to match providers for this role.', error, stackTrace);
      return false;
    }
  }

  Future<bool> actOnProspect({
    required int prospectId,
    required String action,
    double? agreedPrice,
  }) async {
    final project = _currentProject;
    if (project == null || prospectId <= 0 || !_begin(ProjectsState.mutating)) {
      return false;
    }
    try {
      await _actOnProspect(
        prospectId: prospectId,
        action: action,
        agreedPrice: agreedPrice,
      );
      await _refreshCurrent(project.id);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to update this provider prospect.', error, stackTrace);
      return false;
    }
  }

  Future<bool> cancel() async {
    final project = _currentProject;
    if (project == null || !_begin(ProjectsState.mutating)) {
      return false;
    }
    try {
      await _cancelProject(project.id);
      _projects = List.unmodifiable(
        _projects.where((item) => item.id != project.id),
      );
      _currentProject = null;
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to cancel this project.', error, stackTrace);
      return false;
    }
  }

  bool _begin(ProjectsState next) {
    if (isBusy) {
      return false;
    }
    _state = next;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<void> _refreshCurrent(int id) async {
    final refreshed = await _loadProject(id);
    _currentProject = refreshed;
    _replaceProject(refreshed);
  }

  void _replaceProject(ShphProject project, {bool prepend = false}) {
    final updated = [..._projects];
    final index = updated.indexWhere((item) => item.id == project.id);
    if (index >= 0) {
      updated[index] = project;
    } else if (prepend) {
      updated.insert(0, project);
    } else {
      updated.add(project);
    }
    _projects = List.unmodifiable(updated);
  }

  void _complete() {
    _state = ProjectsState.ready;
    _errorMessage = null;
    notifyListeners();
  }

  void _fail(String message, Object error, StackTrace stackTrace) {
    _state = ProjectsState.error;
    _errorMessage = message;
    LoggingService.warning(
      'Projects operation failed',
      tag: 'ProjectsController',
      error: error,
      stackTrace: stackTrace,
    );
    notifyListeners();
  }
}
