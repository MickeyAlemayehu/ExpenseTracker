import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Native (mobile/desktop) implementation: write to a temp file and open the
/// OS share/save sheet.
Future<void> saveCsv({required String csv, required String filename}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(csv);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv', name: filename)],
    subject: 'Transactions export',
  );
}
