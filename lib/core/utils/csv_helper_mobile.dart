// Mobile-specific CSV implementation
import 'dart:typed_data';

/// Mobile implementation of CSV download
/// On mobile, this feature is not supported - users should use export/share instead
Future<void> downloadCsvImpl(Uint8List bytes, String filename) async {
  // On mobile, CSV download is not directly supported
  // Users should use the Share functionality or save to storage
  throw UnsupportedError(
    'Direct CSV download not supported on mobile. Please use Share functionality.',
  );
}

/// Mobile implementation of CSV file picker
/// On mobile, this feature is not supported - users should use file_picker package
Future<String?> pickAndReadCsvImpl() async {
  // On mobile, file picking requires file_picker package
  throw UnsupportedError(
    'File picking not supported on mobile without file_picker package.',
  );
}
