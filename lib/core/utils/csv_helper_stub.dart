import 'dart:typed_data';

/// Stub implementation - should never be called
Future<void> downloadCsvImpl(Uint8List bytes, String filename) async {
  throw UnsupportedError('CSV download not supported on this platform');
}

Future<String?> pickAndReadCsvImpl() async {
  throw UnsupportedError('CSV file picking not supported on this platform');
}
