bool isProtectedProjectPath(String path) =>
    path == '/projects' || path.startsWith('/projects/');

int parseProjectRouteId(String? value) {
  final id = int.tryParse(value ?? '');
  return id != null && id > 0 ? id : 0;
}
