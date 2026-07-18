/// Log levels for categorizing log messages across the app.
///
/// Kept in a separate file so crash reporting and logging services can both
/// depend on it without creating an import cycle.
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  critical,
}
