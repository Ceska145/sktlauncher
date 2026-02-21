// Web-specific CSV implementation
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Web implementation of CSV download
Future<void> downloadCsvImpl(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Web implementation of CSV file picker
Future<String?> pickAndReadCsvImpl() async {
  final html.FileUploadInputElement input = html.FileUploadInputElement()
    ..accept = '.csv'
    ..click();

  await input.onChange.first;

  if (input.files?.isEmpty ?? true) {
    return null;
  }

  final file = input.files!.first;
  final reader = html.FileReader();
  reader.readAsText(file);
  await reader.onLoad.first;

  return reader.result as String?;
}
