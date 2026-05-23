/// Low-level exceptions thrown by data sources. Repositories translate these
/// into [Failure]s before they reach the presentation layer.
class CacheException implements Exception {
  CacheException(this.message);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  NotFoundException(this.message);
  final String message;
  @override
  String toString() => 'NotFoundException: $message';
}
