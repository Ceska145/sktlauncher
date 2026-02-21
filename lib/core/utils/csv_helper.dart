// CSV Helper with platform-specific imports
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import 'csv_helper_stub.dart'
    if (dart.library.html) 'csv_helper_web.dart'
    if (dart.library.io) 'csv_helper_mobile.dart';

/// CSV Helper - Platform agnostic wrapper
class CsvHelper {
  /// Ürünleri CSV string'e dönüştür
  static String productsToCsv(List<Product> products) {
    final bytes = generateCsv(products);
    return utf8.decode(bytes.sublist(3)); // Skip BOM
  }

  /// Dosya adı oluştur
  static String generateFilename({String suffix = ''}) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HHmm').format(now);
    final suffixPart = suffix.isNotEmpty ? '_$suffix' : '';
    return 'urunler_${dateStr}$suffixPart.csv';
  }

  /// Örnek şablon CSV oluştur
  static String createTemplateCsv() {
    return '''id,barcode,name,brand,category,expiryDate,shelfLifeDays,addedDate,notes,storeId,isStockOut
sample_001,8690000000001,Örnek Ürün 1,Marka A,Süt Ürünleri,2026-12-31,7,2026-02-10T10:00:00.000,Örnek not,store_001,0
sample_002,8690000000002,Örnek Ürün 2,Marka B,Peynir,2026-11-30,30,2026-02-10T11:00:00.000,,store_001,0''';
  }

  /// CSV dosyası seç ve oku - wrapper method
  static Future<String?> pickAndReadCsvFile() async {
    return await pickAndReadCsvImpl();
  }

  /// CSV'yi byte array olarak oluştur
  static Uint8List generateCsv(List<Product> products) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'id,barcode,name,brand,category,expiryDate,shelfLifeDays,addedDate,notes,storeId,isStockOut');

    // Rows
    for (final product in products) {
      buffer.writeln([
        _escapeCsv(product.id),
        _escapeCsv(product.barcode),
        _escapeCsv(product.name),
        _escapeCsv(product.brand ?? ''),
        _escapeCsv(product.category ?? ''),
        product.expiryDate?.toIso8601String() ?? '',
        product.shelfLifeDays,
        product.addedDate.toIso8601String(),
        _escapeCsv(product.notes ?? ''),
        _escapeCsv(product.storeId),
        product.isStockOut ? '1' : '0',
      ].join(','));
    }

    // UTF-8 BOM for Excel compatibility
    final bom = [0xEF, 0xBB, 0xBF];
    final csvBytes = utf8.encode(buffer.toString());
    return Uint8List.fromList([...bom, ...csvBytes]);
  }

  /// CSV indirme - platform-specific implementation
  static Future<void> downloadCsv(
    String csvContent,
    String filename,
  ) async {
    // Convert string to bytes with BOM
    final bom = [0xEF, 0xBB, 0xBF];
    final csvBytes = utf8.encode(csvContent);
    final bytes = Uint8List.fromList([...bom, ...csvBytes]);
    
    await downloadCsvImpl(bytes, filename);
  }

  /// CSV parse etme
  static List<Map<String, dynamic>> parseCsv(String csvContent) {
    final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return [];
    }

    // Header
    final headers = _parseCsvLine(lines[0]);

    // Rows
    final result = <Map<String, dynamic>>[];
    for (int i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      if (values.length != headers.length) {
        continue; // Skip invalid rows
      }

      final row = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j];
      }
      result.add(row);
    }

    return result;
  }

  /// CSV satırını parse et (virgül ve tırnak desteği)
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString().trim());
    return result;
  }

  /// CSV field'ını escape et
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
