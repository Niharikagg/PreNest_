import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/models/extracted_field.dart';
import 'normaliser.dart';

/// Representation of an OCR line with text, optional bounding box, and confidence.
class OcrLineItem {
  final String text;
  final Rect? bbox;
  final double? confidence;

  const OcrLineItem({
    required this.text,
    this.bbox,
    this.confidence,
  });
}

/// Layout-aware parser that transforms OCR blocks and text into standardized ExtractedFields.
class ReportParser {
  final LabNormaliser normaliser;

  const ReportParser({this.normaliser = const LabNormaliser()});

  /// Parse RecognizedText directly from Google ML Kit Text Recognition.
  List<ExtractedField> parseRecognizedText(RecognizedText recognizedText) {
    if (recognizedText.text.trim().isEmpty) {
      return const [];
    }

    final lineItems = <OcrLineItem>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line.text.trim().isNotEmpty) {
          lineItems.add(
            OcrLineItem(
              text: line.text.trim(),
              bbox: line.boundingBox,
              confidence: line.confidence,
            ),
          );
        }
      }
    }

    // Try parsing grouped OCR lines with bounding boxes
    final fields = parseOcrLineItems(lineItems);
    if (fields.isNotEmpty) {
      return fields;
    }

    // Fallback to plain text parsing
    return parsePlainText(recognizedText.text);
  }

  /// Parse a list of OCR line items by grouping them into horizontal rows using vertical proximity.
  List<ExtractedField> parseOcrLineItems(List<OcrLineItem> lineItems) {
    if (lineItems.isEmpty) return const [];

    // 1. Detect report date from line items
    final reportDate = _extractReportDate(lineItems.map((e) => e.text).toList());

    // 2. Group items into horizontal rows using Y coordinate proximity
    final groupedRows = _groupLinesIntoRows(lineItems);

    final extractedFields = <ExtractedField>[];
    int fieldCounter = 0;

    for (final row in groupedRows) {
      // Merge texts horizontally
      final rowText = row.items.map((e) => e.text).join(' ').trim();
      if (_isHeaderOrNoiseRow(rowText)) {
        continue;
      }

      final parsed = _parseCandidateRow(
        rowText,
        reportDate: reportDate,
        rowBbox: row.bbox,
        averageOcrConfidence: row.averageConfidence,
        idIndex: ++fieldCounter,
      );

      if (parsed != null) {
        extractedFields.add(parsed);
      }
    }

    return extractedFields;
  }

  /// Fallback parser for plain text, mock strings, or unboxed OCR output.
  List<ExtractedField> parsePlainText(
    String text, {
    DateTime? fallbackDate,
    Rect? fallbackBbox,
  }) {
    final rawLines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (rawLines.isEmpty) return const [];

    final reportDate = fallbackDate ?? _extractReportDate(rawLines);
    final extractedFields = <ExtractedField>[];
    int fieldCounter = 0;

    for (final line in rawLines) {
      if (_isHeaderOrNoiseRow(line)) {
        continue;
      }

      final parsed = _parseCandidateRow(
        line,
        reportDate: reportDate,
        rowBbox: fallbackBbox,
        averageOcrConfidence: 0.85,
        idIndex: ++fieldCounter,
      );

      if (parsed != null) {
        extractedFields.add(parsed);
      }
    }

    return extractedFields;
  }

  /// Groups OCR line items whose vertical centers are close together.
  List<_RowCluster> _groupLinesIntoRows(List<OcrLineItem> items) {
    final validItems = items.where((i) => i.bbox != null).toList();
    if (validItems.isEmpty) {
      return items.map((i) => _RowCluster(items: [i], bbox: i.bbox)).toList();
    }

    // Sort by vertical position (top)
    validItems.sort((a, b) => a.bbox!.top.compareTo(b.bbox!.top));

    final clusters = <_RowCluster>[];

    for (final item in validItems) {
      final itemCenterY = item.bbox!.top + (item.bbox!.height / 2.0);
      bool merged = false;

      for (final cluster in clusters) {
        final clusterCenterY = cluster.bbox.top + (cluster.bbox.height / 2.0);
        final verticalTolerance = max(12.0, cluster.bbox.height * 0.65);

        if ((itemCenterY - clusterCenterY).abs() <= verticalTolerance) {
          cluster.add(item);
          merged = true;
          break;
        }
      }

      if (!merged) {
        clusters.add(_RowCluster(items: [item], bbox: item.bbox!));
      }
    }

    // Within each row, sort left-to-right
    for (final cluster in clusters) {
      cluster.items.sort((a, b) => a.bbox!.left.compareTo(b.bbox!.left));
    }

    return clusters;
  }

  /// Check whether a line is a known report header, footer, or column title.
  bool _isHeaderOrNoiseRow(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty) return true;

    const noiseKeywords = [
      'apex clinical',
      'diagnostics',
      'investigation observed',
      'observed unit',
      'reference range',
      'patient:',
      'patient name',
      'age/sex',
      'sample:',
      'lab director',
      'status: final',
      'wellness panel',
      'dr.',
      'page of',
      'report date',
      'authorized',
      'clinical pathology',
    ];

    for (final keyword in noiseKeywords) {
      if (lower.contains(keyword)) {
        return true;
      }
    }

    // If row starts with 'Investigation' column label
    if (lower.startsWith('investigation') || lower.startsWith('test name')) {
      return true;
    }

    return false;
  }

  /// Extracts report date from lines or returns today's date if not found.
  DateTime _extractReportDate(List<String> lines) {
    final dateRegex1 = RegExp(
      r'\b(\d{1,2})[-/.]([A-Za-z]{3,9}|\d{1,2})[-/.](20\d{2}|\d{2})\b',
    );
    final dateRegex2 = RegExp(
      r'\b([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(20\d{2})\b',
    );

    for (final line in lines) {
      final match1 = dateRegex1.firstMatch(line);
      if (match1 != null) {
        final day = int.tryParse(match1.group(1) ?? '') ?? 1;
        final monthStr = match1.group(2) ?? '';
        final yearRaw = int.tryParse(match1.group(3) ?? '') ?? 2026;
        final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
        final month = _parseMonth(monthStr);
        return DateTime(year, month, day);
      }

      final match2 = dateRegex2.firstMatch(line);
      if (match2 != null) {
        final monthStr = match2.group(1) ?? '';
        final day = int.tryParse(match2.group(2) ?? '') ?? 1;
        final year = int.tryParse(match2.group(3) ?? '') ?? 2026;
        final month = _parseMonth(monthStr);
        return DateTime(year, month, day);
      }
    }

    return DateTime.now();
  }

  static int _parseMonth(String monthStr) {
    final num = int.tryParse(monthStr);
    if (num != null && num >= 1 && num <= 12) return num;

    final lower = monthStr.toLowerCase();
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    for (int i = 0; i < months.length; i++) {
      if (lower.startsWith(months[i])) {
        return i + 1;
      }
    }
    return 11;
  }

  /// Parses a single candidate row line into an ExtractedField.
  ExtractedField? _parseCandidateRow(
    String rowText, {
    required DateTime reportDate,
    required Rect? rowBbox,
    required double averageOcrConfidence,
    required int idIndex,
  }) {
    String remaining = rowText.trim();
    if (remaining.isEmpty) return null;

    // 1. Extract printed reference range if present
    String? printedRange;
    final rangeRegex = RegExp(
      r'(?:[\(\[]\s*)?(\d+(?:\.\d+)?\s*(?:-|–|—|to)\s*\d+(?:\.\d+)?)(?:\s*[\)\]])?',
    );
    final inequalityRangeRegex = RegExp(
      r'(?:[\(\[]\s*)?((?:<|>|<=|>=)\s*\d+(?:\.\d+)?)(?:\s*[\)\]])?',
    );

    final rangeMatch = rangeRegex.firstMatch(remaining);
    final ineqMatch = inequalityRangeRegex.firstMatch(remaining);

    if (rangeMatch != null) {
      printedRange = rangeMatch.group(1)?.trim();
      // Remove range from remaining string to prevent interference with observed value
      remaining = remaining.replaceRange(
        rangeMatch.start,
        rangeMatch.end,
        ' ',
      );
    } else if (ineqMatch != null) {
      printedRange = ineqMatch.group(1)?.trim();
      remaining = remaining.replaceRange(
        ineqMatch.start,
        ineqMatch.end,
        ' ',
      );
    }

    // 2. Extract standard units
    String? extractedUnit;
    const knownUnits = [
      'g/dL',
      'g/dl',
      'gm/dl',
      'mg/dL',
      'mg/dl',
      'mIU/L',
      'miu/l',
      'uIU/mL',
      'uiu/ml',
      'µIU/mL',
      'ng/mL',
      'ng/ml',
      'pg/mL',
      'mmol/L',
      'mmol/l',
      'µmol/L',
      'x10^3/uL',
      '10^3/uL',
      '10^3/µL',
      'cells/mcL',
      'lakh/cumm',
      '/cumm',
      'mm/hr',
      'mmHg',
      'mm hg',
      'U/L',
      'IU/L',
      'pmol/L',
      'nmol/L',
      'ng/dL',
      'k/uL',
      '%',
      'kg',
      'lbs',
    ];

    for (final u in knownUnits) {
      final unitRegex = RegExp(
        r'\b' + RegExp.escape(u) + r'\b',
        caseSensitive: false,
      );
      final uMatch = unitRegex.firstMatch(remaining);
      if (uMatch != null) {
        extractedUnit = u;
        remaining = remaining.replaceRange(uMatch.start, uMatch.end, ' ');
        break;
      }
    }

    // 3. Extract observed numeric value
    double? extractedValue;
    final valueRegex = RegExp(r'\b(\d+(?:\.\d+)?)\b');
    final valMatches = valueRegex.allMatches(remaining).toList();

    if (valMatches.isNotEmpty) {
      // The observed value is typically the last remaining number
      final lastValMatch = valMatches.last;
      extractedValue = double.tryParse(lastValMatch.group(1) ?? '');
      if (extractedValue != null) {
        remaining = remaining.replaceRange(
          lastValMatch.start,
          lastValMatch.end,
          ' ',
        );
      }
    }

    // 4. Clean up remaining text to form testNameRaw
    final testNameRaw = remaining
        .replaceAll(RegExp(r'[:;,\|\-\_\.]+$'), '')
        .replaceAll(RegExp(r'^[:;,\|\-\_\.]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (testNameRaw.isEmpty || testNameRaw.length < 2) {
      return null;
    }

    // 5. Match with LabNormaliser
    final match = normaliser.matchTest(testNameRaw);

    // If similarity is extremely poor and no value was found, reject noise
    if (match.score < 0.35 && extractedValue == null) {
      return null;
    }

    // Use standardized values from dictionary if available
    final canonicalName = match.canonicalName;
    final unit = extractedUnit ?? match.definition?.standardUnits.first;
    final finalPrintedRange = printedRange ?? match.definition?.typicalRange;

    // 6. Calculate transparent confidence score
    final confResult = normaliser.calculateConfidence(
      ocrConfidence: averageOcrConfidence,
      nameMatchScore: match.score,
      value: extractedValue,
      unit: unit,
      definition: match.definition,
    );

    return ExtractedField(
      id: 'field_${idIndex}_${DateTime.now().millisecondsSinceEpoch}',
      testNameRaw: testNameRaw,
      testNameStd: canonicalName ?? testNameRaw,
      value: extractedValue,
      unit: unit,
      date: reportDate,
      printedRange: finalPrintedRange,
      confidence: confResult.score,
      status: confResult.status,
      bbox: rowBbox,
    );
  }
}

/// Helper container representing a horizontal row cluster of OCR items.
class _RowCluster {
  final List<OcrLineItem> items;
  Rect bbox;

  _RowCluster({required this.items, Rect? bbox})
      : bbox = bbox ??
            (items.isNotEmpty && items.first.bbox != null
                ? items.first.bbox!
                : Rect.zero);

  void add(OcrLineItem item) {
    items.add(item);
    if (item.bbox != null) {
      bbox = bbox.expandToInclude(item.bbox!);
    }
  }

  double get averageConfidence {
    final confs = items
        .map((e) => e.confidence)
        .whereType<double>()
        .toList();
    if (confs.isEmpty) return 0.85;
    return confs.reduce((a, b) => a + b) / confs.length;
  }
}
