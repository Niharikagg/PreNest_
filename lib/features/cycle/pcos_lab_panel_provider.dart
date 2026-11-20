import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PcosLabCategory { metabolic, hormone }

enum PcosRangeStatus { withinRange, outsideRange, unspecified }

class PcosLabMarker {
  final String id;
  final String name;
  final String shortCode;
  final PcosLabCategory category;
  final String defaultUnit;
  final String standardReferenceRange;
  final double? normalMin;
  final double? normalMax;
  final String clinicalContext;
  final double? value;
  final String? customUnit;
  final String? printedReferenceRange;
  final DateTime? loggedDate;
  final String? notes;

  const PcosLabMarker({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
    required this.defaultUnit,
    required this.standardReferenceRange,
    this.normalMin,
    this.normalMax,
    required this.clinicalContext,
    this.value,
    this.customUnit,
    this.printedReferenceRange,
    this.loggedDate,
    this.notes,
  });

  bool get isLogged => value != null;

  String get activeUnit => (customUnit != null && customUnit!.trim().isNotEmpty)
      ? customUnit!
      : defaultUnit;

  String get activeReferenceRange =>
      (printedReferenceRange != null &&
          printedReferenceRange!.trim().isNotEmpty)
      ? printedReferenceRange!
      : standardReferenceRange;

  PcosRangeStatus get rangeStatus {
    if (value == null) return PcosRangeStatus.unspecified;
    if (normalMin != null && normalMax != null) {
      if (value! >= normalMin! && value! <= normalMax!) {
        return PcosRangeStatus.withinRange;
      } else {
        return PcosRangeStatus.outsideRange;
      }
    }
    return PcosRangeStatus.unspecified;
  }

  String get rangeStatusLabel {
    switch (rangeStatus) {
      case PcosRangeStatus.withinRange:
        return 'Within printed lab range';
      case PcosRangeStatus.outsideRange:
        return 'Outside printed lab range — discuss with your doctor';
      case PcosRangeStatus.unspecified:
        return 'Discuss with doctor for clinical interpretation';
    }
  }

  PcosLabMarker copyWith({
    double? value,
    String? customUnit,
    String? printedReferenceRange,
    DateTime? loggedDate,
    String? notes,
    bool clearValue = false,
  }) {
    return PcosLabMarker(
      id: id,
      name: name,
      shortCode: shortCode,
      category: category,
      defaultUnit: defaultUnit,
      standardReferenceRange: standardReferenceRange,
      normalMin: normalMin,
      normalMax: normalMax,
      clinicalContext: clinicalContext,
      value: clearValue ? null : (value ?? this.value),
      customUnit: customUnit ?? this.customUnit,
      printedReferenceRange:
          printedReferenceRange ?? this.printedReferenceRange,
      loggedDate: clearValue ? null : (loggedDate ?? this.loggedDate),
      notes: notes ?? this.notes,
    );
  }
}

/// Baseline definitions for the 10 PCOS Hormone and Metabolic Markers.
final List<PcosLabMarker> kInitialPcosMarkers = [
  // --- METABOLIC PANEL ---
  PcosLabMarker(
    id: 'fasting_blood_sugar',
    name: 'Fasting Blood Sugar',
    shortCode: 'FBS',
    category: PcosLabCategory.metabolic,
    defaultUnit: 'mg/dL',
    standardReferenceRange: '70 – 99 mg/dL',
    normalMin: 70.0,
    normalMax: 99.0,
    clinicalContext: 'Fasting glucose baseline for screening glycemic balance.',
    value: 92.0,
    printedReferenceRange: '70 – 99 mg/dL',
    loggedDate: DateTime.now().subtract(const Duration(days: 4)),
    notes: 'Sample fasting lab result (10 hr overnight fast)',
  ),
  PcosLabMarker(
    id: 'hba1c',
    name: 'HbA1c',
    shortCode: 'HbA1c',
    category: PcosLabCategory.metabolic,
    defaultUnit: '%',
    standardReferenceRange: '4.0 – 5.6%',
    normalMin: 4.0,
    normalMax: 5.6,
    clinicalContext:
        '3-month average glucose index for insulin resistance evaluation.',
    value: 5.4,
    printedReferenceRange: '4.0 – 5.6%',
    loggedDate: DateTime.now().subtract(const Duration(days: 4)),
    notes: 'Annual metabolic checkup',
  ),
  PcosLabMarker(
    id: 'fasting_insulin',
    name: 'Fasting Insulin',
    shortCode: 'F-Insulin',
    category: PcosLabCategory.metabolic,
    defaultUnit: 'µIU/mL',
    standardReferenceRange: '2.6 – 24.9 µIU/mL',
    normalMin: 2.6,
    normalMax: 24.9,
    clinicalContext:
        'Key marker for assessing hyperinsulinemia and insulin resistance.',
    value: 11.4,
    printedReferenceRange: '2.6 – 24.9 µIU/mL',
    loggedDate: DateTime.now().subtract(const Duration(days: 4)),
    notes: 'Normal baseline insulin sensitivity',
  ),
  const PcosLabMarker(
    id: 'lipid_panel',
    name: 'Lipid Panel',
    shortCode: 'Lipids',
    category: PcosLabCategory.metabolic,
    defaultUnit: 'mg/dL',
    standardReferenceRange: '< 200 mg/dL (Total Chol)',
    normalMin: 100.0,
    normalMax: 200.0,
    clinicalContext:
        'Cardiometabolic lipid screening (Total, HDL, LDL, Triglycerides).',
    value: null, // Left as "Not logged yet"
  ),

  // --- HORMONE PANEL ---
  PcosLabMarker(
    id: 'tsh',
    name: 'TSH',
    shortCode: 'TSH',
    category: PcosLabCategory.hormone,
    defaultUnit: 'mIU/L',
    standardReferenceRange: '0.4 – 4.0 mIU/L',
    normalMin: 0.4,
    normalMax: 4.0,
    clinicalContext: 'Thyroid-stimulating hormone; rules out thyroid etiology for cycle shifts.',
    value: 2.10,
    printedReferenceRange: '0.4 – 4.0 mIU/L',
    loggedDate: DateTime.now().subtract(const Duration(days: 4)),
    notes: 'Thyroid profile within standard range',
  ),
  const PcosLabMarker(
    id: 'amh',
    name: 'AMH',
    shortCode: 'AMH',
    category: PcosLabCategory.hormone,
    defaultUnit: 'ng/mL',
    standardReferenceRange: '1.0 – 3.5 ng/mL',
    normalMin: 1.0,
    normalMax: 3.5,
    clinicalContext: 'Anti-Müllerian Hormone reflects ovarian follicular reserve; often elevated in PCOS.',
    value: null, // Left as "Not logged yet"
  ),
  const PcosLabMarker(
    id: 'testosterone',
    name: 'Testosterone',
    shortCode: 'Testo',
    category: PcosLabCategory.hormone,
    defaultUnit: 'ng/dL',
    standardReferenceRange: '15 – 70 ng/dL',
    normalMin: 15.0,
    normalMax: 70.0,
    clinicalContext:
        'Total & Free Testosterone; evaluates biochemical hyperandrogenism.',
    value: null, // Left as "Not logged yet"
  ),
  const PcosLabMarker(
    id: 'lh',
    name: 'LH',
    shortCode: 'LH',
    category: PcosLabCategory.hormone,
    defaultUnit: 'mIU/mL',
    standardReferenceRange: '2.0 – 12.0 mIU/mL (Follicular)',
    normalMin: 2.0,
    normalMax: 12.0,
    clinicalContext: 'Luteinizing Hormone; elevated LH:FSH ratio (>2:1) is frequently seen in PCOS.',
    value: null, // Left as "Not logged yet"
  ),
  const PcosLabMarker(
    id: 'fsh',
    name: 'FSH',
    shortCode: 'FSH',
    category: PcosLabCategory.hormone,
    defaultUnit: 'mIU/mL',
    standardReferenceRange: '3.5 – 12.5 mIU/mL (Follicular)',
    normalMin: 3.5,
    normalMax: 12.5,
    clinicalContext: 'Follicle-Stimulating Hormone; evaluated alongside LH for ovarian signaling.',
    value: null, // Left as "Not logged yet"
  ),
  const PcosLabMarker(
    id: 'prolactin',
    name: 'Prolactin',
    shortCode: 'PRL',
    category: PcosLabCategory.hormone,
    defaultUnit: 'ng/mL',
    standardReferenceRange: '4.8 – 23.3 ng/mL',
    normalMin: 4.8,
    normalMax: 23.3,
    clinicalContext: 'Screens for hyperprolactinemia as an alternate cause of missed cycles.',
    value: null, // Left as "Not logged yet"
  ),
];

/// State managing the 10 PCOS markers.
class PcosLabPanelState {
  final Map<String, PcosLabMarker> markers;

  const PcosLabPanelState({required this.markers});

  List<PcosLabMarker> get allMarkers => markers.values.toList();

  List<PcosLabMarker> get metabolicMarkers => markers.values
      .where((m) => m.category == PcosLabCategory.metabolic)
      .toList();

  List<PcosLabMarker> get hormoneMarkers => markers.values
      .where((m) => m.category == PcosLabCategory.hormone)
      .toList();

  List<PcosLabMarker> get loggedMarkers =>
      markers.values.where((m) => m.isLogged).toList();

  int get loggedCount => loggedMarkers.length;
  int get totalCount => markers.length;

  PcosLabMarker? getMarker(String id) => markers[id];

  PcosLabPanelState copyWith({Map<String, PcosLabMarker>? markers}) {
    return PcosLabPanelState(markers: markers ?? this.markers);
  }
}

/// Riverpod State Notifier for PCOS Hormone and Metabolic Lab Panel.
class PcosLabPanelNotifier extends Notifier<PcosLabPanelState> {
  @override
  PcosLabPanelState build() {
    final map = <String, PcosLabMarker>{};
    for (final marker in kInitialPcosMarkers) {
      map[marker.id] = marker;
    }
    return PcosLabPanelState(markers: map);
  }

  void updateMarker({
    required String id,
    required double value,
    String? customUnit,
    String? printedReferenceRange,
    DateTime? loggedDate,
    String? notes,
  }) {
    final existing = state.markers[id];
    if (existing == null) return;

    final updated = existing.copyWith(
      value: value,
      customUnit: customUnit,
      printedReferenceRange: printedReferenceRange,
      loggedDate: loggedDate ?? DateTime.now(),
      notes: notes,
    );

    final map = Map<String, PcosLabMarker>.from(state.markers);
    map[id] = updated;
    state = state.copyWith(markers: map);
  }

  void clearMarker(String id) {
    final existing = state.markers[id];
    if (existing == null) return;

    final cleared = existing.copyWith(clearValue: true);
    final map = Map<String, PcosLabMarker>.from(state.markers);
    map[id] = cleared;
    state = state.copyWith(markers: map);
  }

  void resetToDefaults() {
    final map = <String, PcosLabMarker>{};
    for (final marker in kInitialPcosMarkers) {
      map[marker.id] = marker;
    }
    state = PcosLabPanelState(markers: map);
  }
}

/// Riverpod provider for the PCOS Lab Panel.
final pcosLabPanelProvider =
    NotifierProvider<PcosLabPanelNotifier, PcosLabPanelState>(
      PcosLabPanelNotifier.new,
    );
