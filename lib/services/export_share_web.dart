// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: trigger a browser download via a Blob URL.
Future<void> saveCsv({required String csv, required String filename}) async {
  // UTF-8 with BOM so Excel opens non-ASCII characters correctly.
  final blob = html.Blob(['\uFEFF$csv'], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
