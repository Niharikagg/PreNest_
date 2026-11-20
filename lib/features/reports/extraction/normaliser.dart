import 'dart:math';

import '../../../core/models/extracted_field.dart';

/// Definition of a canonical lab test with aliases, standard units, and plausible reference ranges.
class LabTestDefinition {
  final String canonicalName;
  final List<String> aliases;
  final List<String> standardUnits;
  final String typicalRange;
  final double plausibleMin;
  final double plausibleMax;

  const LabTestDefinition({
    required this.canonicalName,
    required this.aliases,
    required this.standardUnits,
    required this.typicalRange,
    required this.plausibleMin,
    required this.plausibleMax,
  });

  /// Check whether the extracted value falls within physiological / plausible bounds.
  bool isPlausible(double value) {
    return value >= plausibleMin && value <= plausibleMax;
  }

  /// Check whether an extracted unit matches standard units for this test.
  bool isUnitMatch(String? unit) {
    if (unit == null || unit.trim().isEmpty) return false;
    final normalized = unit.trim().toLowerCase().replaceAll(' ', '');
    return standardUnits.any((std) {
      final stdNorm = std.toLowerCase().replaceAll(' ', '');
      return stdNorm == normalized ||
          stdNorm.contains(normalized) ||
          normalized.contains(stdNorm);
    });
  }
}

/// Built-in clinical dictionary of common lab tests covering preconception,
/// maternal wellness, metabolic markers, and couples' reproductive health.
class LabDictionary {
  static const List<LabTestDefinition> definitions = [
    // 1. Hemoglobin
    LabTestDefinition(
      canonicalName: 'Hemoglobin',
      aliases: [
        'hb',
        'hemoglobin',
        'haemoglobin',
        'hgb',
        'blood hemoglobin',
        'hemoglobin (hb)',
        'haemoglobin (hb)',
        'total hemoglobin',
      ],
      standardUnits: ['g/dL', 'g/dl', 'gm/dl', 'g/L'],
      typicalRange: '12.0 - 15.5',
      plausibleMin: 3.0,
      plausibleMax: 25.0,
    ),

    // 2. Fasting Blood Sugar / Glucose
    LabTestDefinition(
      canonicalName: 'Fasting Blood Sugar',
      aliases: [
        'fasting blood sugar',
        'fasting blood sugar (glucose)',
        'fasting blood glucose',
        'fasting glucose',
        'fbs',
        'fbg',
        'glucose fasting',
        'blood sugar fasting',
        'blood glucose (fasting)',
      ],
      standardUnits: ['mg/dL', 'mg/dl', 'mmol/L', 'mmol/l'],
      typicalRange: '70.0 - 99.0',
      plausibleMin: 30.0,
      plausibleMax: 500.0,
    ),

    // 3. HbA1c
    LabTestDefinition(
      canonicalName: 'HbA1c',
      aliases: [
        'hba1c',
        'a1c',
        'glycated hemoglobin',
        'glycohemoglobin',
        'hba1c (glycated hemoglobin)',
        'glycosylated hemoglobin',
        'hemoglobin a1c',
      ],
      standardUnits: ['%', 'percent', 'mmol/mol'],
      typicalRange: '4.0 - 5.6',
      plausibleMin: 3.0,
      plausibleMax: 18.0,
    ),

    // 4. TSH
    LabTestDefinition(
      canonicalName: 'TSH',
      aliases: [
        'tsh',
        'thyroid stimulating hormone',
        'tsh (thyroid stimulating hormone)',
        's.tsh',
        'serum tsh',
        'thyrotropin',
      ],
      standardUnits: ['mIU/L', 'miu/l', 'uIU/mL', 'uiu/ml', 'µIU/mL', 'uIU/ml'],
      typicalRange: '0.4 - 4.0',
      plausibleMin: 0.01,
      plausibleMax: 60.0,
    ),

    // 5. Vitamin D
    LabTestDefinition(
      canonicalName: 'Vitamin D',
      aliases: [
        'vitamin d',
        'vit d',
        '25-oh vitamin d',
        'vitamin d (25-oh cholecalciferol)',
        '25-hydroxy vitamin d',
        '25-oh vit d',
        'cholecalciferol',
      ],
      standardUnits: ['ng/mL', 'ng/ml', 'nmol/L', 'nmol/l'],
      typicalRange: '30.0 - 100.0',
      plausibleMin: 3.0,
      plausibleMax: 200.0,
    ),

    // 6. Ferritin
    LabTestDefinition(
      canonicalName: 'Ferritin',
      aliases: [
        'serum ferritin',
        'ferritin',
        's. ferritin',
        'serum ferritin level',
      ],
      standardUnits: ['ng/mL', 'ng/ml', 'µg/L', 'ug/l'],
      typicalRange: '15.0 - 150.0',
      plausibleMin: 1.0,
      plausibleMax: 1000.0,
    ),

    // 7. AMH (Anti-Müllerian Hormone)
    LabTestDefinition(
      canonicalName: 'AMH',
      aliases: [
        'anti-müllerian hormone',
        'anti-mullerian hormone',
        'amh',
        'anti-müllerian hormone (amh)',
        's. amh',
      ],
      standardUnits: ['ng/mL', 'ng/ml', 'pmol/L', 'pmol/l'],
      typicalRange: '1.5 - 4.0',
      plausibleMin: 0.05,
      plausibleMax: 25.0,
    ),

    // 8. Platelet Count
    LabTestDefinition(
      canonicalName: 'Platelet Count',
      aliases: [
        'platelet count',
        'platelets',
        'plt',
        'thrombocyte count',
        'total platelets',
      ],
      standardUnits: [
        '10^3/uL',
        'x10^3/uL',
        '10^3/µL',
        'cells/mcL',
        'lakh/cumm',
        'x10^9/L',
        '/cumm',
        'k/uL',
        'k/ul',
      ],
      typicalRange: '150 - 450',
      plausibleMin: 10.0,
      plausibleMax: 1500.0,
    ),

    // 9. Blood Pressure Systolic
    LabTestDefinition(
      canonicalName: 'Blood Pressure Systolic',
      aliases: [
        'blood pressure systolic',
        'systolic',
        'systolic bp',
        'systolic blood pressure',
        'bp systolic',
      ],
      standardUnits: ['mmHg', 'mm hg'],
      typicalRange: '90 - 120',
      plausibleMin: 50.0,
      plausibleMax: 260.0,
    ),

    // 10. Blood Pressure Diastolic
    LabTestDefinition(
      canonicalName: 'Blood Pressure Diastolic',
      aliases: [
        'blood pressure diastolic',
        'diastolic',
        'diastolic bp',
        'diastolic blood pressure',
        'bp diastolic',
      ],
      standardUnits: ['mmHg', 'mm hg'],
      typicalRange: '60 - 80',
      plausibleMin: 30.0,
      plausibleMax: 160.0,
    ),

    // 11. Weight
    LabTestDefinition(
      canonicalName: 'Weight',
      aliases: ['weight', 'body weight', 'wt', 'patient weight'],
      standardUnits: ['kg', 'lbs', 'kilograms'],
      typicalRange: '45.0 - 85.0',
      plausibleMin: 25.0,
      plausibleMax: 250.0,
    ),

    // 12. WBC Count
    LabTestDefinition(
      canonicalName: 'WBC Count',
      aliases: [
        'wbc',
        'wbc count',
        'white blood cells',
        'tlc',
        'total leukocyte count',
        'total white blood count',
      ],
      standardUnits: ['10^3/uL', '/cumm', 'cells/mcL', 'x10^9/L'],
      typicalRange: '4.0 - 11.0',
      plausibleMin: 1.0,
      plausibleMax: 50.0,
    ),

    // 13. RBC Count
    LabTestDefinition(
      canonicalName: 'RBC Count',
      aliases: [
        'rbc',
        'rbc count',
        'red blood cells',
        'total rbc count',
        'red blood cell count',
      ],
      standardUnits: ['10^6/uL', 'x10^6/uL', 'mil/uL', 'x10^12/L'],
      typicalRange: '3.8 - 5.2',
      plausibleMin: 1.5,
      plausibleMax: 8.0,
    ),

    // 14. Calcium
    LabTestDefinition(
      canonicalName: 'Calcium',
      aliases: ['calcium', 'serum calcium', 's. calcium', 'total calcium', 'ca'],
      standardUnits: ['mg/dL', 'mg/dl', 'mmol/L'],
      typicalRange: '8.5 - 10.5',
      plausibleMin: 4.0,
      plausibleMax: 16.0,
    ),

    // 15. Total Cholesterol
    LabTestDefinition(
      canonicalName: 'Total Cholesterol',
      aliases: [
        'cholesterol',
        'total cholesterol',
        'serum cholesterol',
        'cholesterol total',
      ],
      standardUnits: ['mg/dL', 'mg/dl', 'mmol/L'],
      typicalRange: '125 - 200',
      plausibleMin: 50.0,
      plausibleMax: 500.0,
    ),

    // 16. Triglycerides
    LabTestDefinition(
      canonicalName: 'Triglycerides',
      aliases: ['triglycerides', 'tg', 'serum triglycerides'],
      standardUnits: ['mg/dL', 'mg/dl', 'mmol/L'],
      typicalRange: '50 - 150',
      plausibleMin: 20.0,
      plausibleMax: 1000.0,
    ),

    // 17. HDL Cholesterol
    LabTestDefinition(
      canonicalName: 'HDL Cholesterol',
      aliases: [
        'hdl',
        'hdl cholesterol',
        'high density lipoprotein',
        'good cholesterol',
      ],
      standardUnits: ['mg/dL', 'mg/dl'],
      typicalRange: '40 - 60',
      plausibleMin: 10.0,
      plausibleMax: 150.0,
    ),

    // 18. LDL Cholesterol
    LabTestDefinition(
      canonicalName: 'LDL Cholesterol',
      aliases: [
        'ldl',
        'ldl cholesterol',
        'low density lipoprotein',
        'bad cholesterol',
      ],
      standardUnits: ['mg/dL', 'mg/dl'],
      typicalRange: '60 - 100',
      plausibleMin: 20.0,
      plausibleMax: 300.0,
    ),

    // 19. Serum Creatinine
    LabTestDefinition(
      canonicalName: 'Serum Creatinine',
      aliases: ['creatinine', 'serum creatinine', 's. creatinine', 'cr'],
      standardUnits: ['mg/dL', 'mg/dl', 'µmol/L'],
      typicalRange: '0.5 - 1.2',
      plausibleMin: 0.2,
      plausibleMax: 15.0,
    ),

    // 20. Blood Urea Nitrogen (BUN)
    LabTestDefinition(
      canonicalName: 'BUN',
      aliases: ['bun', 'blood urea nitrogen', 'urea', 'blood urea'],
      standardUnits: ['mg/dL', 'mg/dl', 'mmol/L'],
      typicalRange: '7 - 20',
      plausibleMin: 2.0,
      plausibleMax: 150.0,
    ),

    // 21. ALT / SGPT
    LabTestDefinition(
      canonicalName: 'ALT (SGPT)',
      aliases: ['alt', 'sgpt', 'alanine aminotransferase', 'alt/sgpt'],
      standardUnits: ['U/L', 'u/l', 'IU/L'],
      typicalRange: '7 - 56',
      plausibleMin: 2.0,
      plausibleMax: 500.0,
    ),

    // 22. AST / SGOT
    LabTestDefinition(
      canonicalName: 'AST (SGOT)',
      aliases: ['ast', 'sgot', 'aspartate aminotransferase', 'ast/sgot'],
      standardUnits: ['U/L', 'u/l', 'IU/L'],
      typicalRange: '10 - 40',
      plausibleMin: 2.0,
      plausibleMax: 500.0,
    ),

    // 23. Urine Protein
    LabTestDefinition(
      canonicalName: 'Urine Protein',
      aliases: ['urine protein', 'proteinuria', 'urine albumin', 'alb'],
      standardUnits: ['mg/dL', 'mg/dl', 'g/24h', 'negative', 'nil'],
      typicalRange: 'Negative',
      plausibleMin: 0.0,
      plausibleMax: 500.0,
    ),

    // 24. Semen Analysis Motility
    LabTestDefinition(
      canonicalName: 'Semen Analysis Motility',
      aliases: [
        'semen analysis motility',
        'semen motility',
        'sperm motility',
        'motility',
      ],
      standardUnits: ['%'],
      typicalRange: '40 - 100',
      plausibleMin: 0.0,
      plausibleMax: 100.0,
    ),

    // 25. Serum Testosterone
    LabTestDefinition(
      canonicalName: 'Serum Testosterone',
      aliases: [
        'serum testosterone',
        'testosterone',
        'total testosterone',
        's. testosterone',
      ],
      standardUnits: ['ng/dL', 'ng/dl', 'nmol/L'],
      typicalRange: '300 - 1000',
      plausibleMin: 10.0,
      plausibleMax: 2000.0,
    ),
  ];
}

/// Normalisation match result for a test name.
class NormalisationMatch {
  final LabTestDefinition? definition;
  final String? canonicalName;
  final double score; // 0.0 to 1.0
  final String? matchedAlias;

  const NormalisationMatch({
    required this.definition,
    required this.canonicalName,
    required this.score,
    this.matchedAlias,
  });
}

/// Detailed breakdown of confidence calculation.
class ConfidenceResult {
  final double score; // 0.0 to 1.0
  final ExtractionStatus status;
  final String reasoning;

  const ConfidenceResult({
    required this.score,
    required this.status,
    required this.reasoning,
  });
}

/// Normaliser and confidence helper.
class LabNormaliser {
  final List<LabTestDefinition> dictionary;

  const LabNormaliser({this.dictionary = LabDictionary.definitions});

  /// Normalize string by lowercasing and stripping special punctuation.
  static String cleanString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Levenshtein distance between two strings.
  static int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  /// String similarity between two strings returning a value between 0.0 and 1.0.
  static double stringSimilarity(String a, String b) {
    final cleanA = cleanString(a);
    final cleanB = cleanString(b);

    if (cleanA.isEmpty || cleanB.isEmpty) return 0.0;
    if (cleanA == cleanB) return 1.0;

    // Direct containment bonus (e.g. "fasting blood glucose" contains "fasting glucose")
    if (cleanA.contains(cleanB) || cleanB.contains(cleanA)) {
      final ratio = min(cleanA.length, cleanB.length) /
          max(cleanA.length, cleanB.length);
      return (0.85 + (0.15 * ratio)).clamp(0.0, 1.0);
    }

    // Levenshtein edit distance
    final maxLen = max(cleanA.length, cleanB.length);
    final distance = levenshteinDistance(cleanA, cleanB);
    final levScore = (1.0 - (distance / maxLen)).clamp(0.0, 1.0);

    // Word token overlap (Jaccard similarity)
    final tokensA = cleanA.split(' ').where((w) => w.isNotEmpty).toSet();
    final tokensB = cleanB.split(' ').where((w) => w.isNotEmpty).toSet();
    final intersection = tokensA.intersection(tokensB).length;
    final union = tokensA.union(tokensB).length;
    final jaccard = union > 0 ? intersection / union : 0.0;

    // Return the strongest signal
    return max(levScore, jaccard).clamp(0.0, 1.0);
  }

  /// Match a raw OCR test name to canonical lab dictionary.
  NormalisationMatch matchTest(String rawTestName) {
    if (rawTestName.trim().isEmpty) {
      return const NormalisationMatch(
        definition: null,
        canonicalName: null,
        score: 0.0,
      );
    }

    LabTestDefinition? bestDef;
    String? bestAlias;
    double maxScore = 0.0;

    for (final def in dictionary) {
      // Check similarity with canonical name
      final canonScore = stringSimilarity(rawTestName, def.canonicalName);
      if (canonScore > maxScore) {
        maxScore = canonScore;
        bestDef = def;
        bestAlias = def.canonicalName;
      }

      // Check similarity with all aliases
      for (final alias in def.aliases) {
        final aliasScore = stringSimilarity(rawTestName, alias);
        if (aliasScore > maxScore) {
          maxScore = aliasScore;
          bestDef = def;
          bestAlias = alias;
        }
      }
    }

    // Only assign canonical name if match score exceeds minimum confidence threshold (0.50)
    if (maxScore >= 0.50 && bestDef != null) {
      return NormalisationMatch(
        definition: bestDef,
        canonicalName: bestDef.canonicalName,
        score: maxScore,
        matchedAlias: bestAlias,
      );
    }

    return NormalisationMatch(
      definition: null,
      canonicalName: null,
      score: maxScore,
      matchedAlias: bestAlias,
    );
  }

  /// Transparent confidence scoring formula combining:
  /// - OCR character/line confidence (0.0 to 1.0)
  /// - Dictionary test name match score (0.0 to 1.0)
  /// - Value plausibility check (0.0 to 1.0)
  /// - Standard unit consistency (0.0 to 1.0)
  ConfidenceResult calculateConfidence({
    required double ocrConfidence,
    required double nameMatchScore,
    required double? value,
    required String? unit,
    required LabTestDefinition? definition,
  }) {
    // 1. OCR Confidence clamped
    final ocrScore = ocrConfidence.clamp(0.0, 1.0);

    // 2. Name Match Score clamped
    final nameScore = nameMatchScore.clamp(0.0, 1.0);

    // 3. Value plausibility score
    double valScore;
    if (value == null) {
      valScore = 0.0;
    } else if (definition != null) {
      if (definition.isPlausible(value)) {
        valScore = 1.0;
      } else {
        // Border check: if within 30% outside bounds, partial plausibility
        final minB = definition.plausibleMin * 0.7;
        final maxB = definition.plausibleMax * 1.3;
        if (value >= minB && value <= maxB) {
          valScore = 0.6;
        } else {
          valScore = 0.2;
        }
      }
    } else {
      valScore = 0.75; // Numeric value found, but uncataloged test
    }

    // 4. Unit consistency score
    double unitScore;
    if (unit == null || unit.trim().isEmpty) {
      unitScore = 0.3;
    } else if (definition != null) {
      if (definition.isUnitMatch(unit)) {
        unitScore = 1.0;
      } else {
        unitScore = 0.4;
      }
    } else {
      unitScore = 0.75;
    }

    // Weighted combination:
    // Name: 35%, OCR: 25%, Value: 25%, Unit: 15%
    const ocrWeight = 0.25;
    const nameWeight = 0.35;
    const valWeight = 0.25;
    const unitWeight = 0.15;

    final rawConfidence =
        (ocrScore * ocrWeight) +
        (nameScore * nameWeight) +
        (valScore * valWeight) +
        (unitScore * unitWeight);

    // Clamp strictly to [0.0, 1.0] and round to 2 decimals
    final score = ((rawConfidence.clamp(0.0, 1.0)) * 100).round() / 100.0;

    // Determine ExtractionStatus:
    // Status is auto when overall confidence >= 0.80, a numeric value is present, and name match >= 0.70.
    final status =
        (score >= 0.80 && value != null && nameScore >= 0.70)
            ? ExtractionStatus.auto
            : ExtractionStatus.needsReview;

    final reasoning =
        'OCR: ${(ocrScore * 100).toInt()}%, Name: ${(nameScore * 100).toInt()}%, '
        'Value: ${(valScore * 100).toInt()}%, Unit: ${(unitScore * 100).toInt()}% '
        '=> Final: ${(score * 100).toInt()}% [${status.name}]';

    return ConfidenceResult(
      score: score,
      status: status,
      reasoning: reasoning,
    );
  }
}
