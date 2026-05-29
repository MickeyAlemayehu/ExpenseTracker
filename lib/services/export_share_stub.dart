/// Stub implementation, replaced at compile time by the io or web variant
/// via conditional import in [export_service.dart].
Future<void> saveCsv({required String csv, required String filename}) {
  throw UnsupportedError('CSV export is not supported on this platform.');
}
