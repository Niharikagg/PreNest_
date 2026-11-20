import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'doctor_summary_provider.dart';

class DoctorSummaryPdfService {
  const DoctorSummaryPdfService();

  static const PdfColor _tealPrimary = PdfColor.fromInt(0xFF0F766E);
  static const PdfColor _tealDark = PdfColor.fromInt(0xFF115E59);
  static const PdfColor _tealLight = PdfColor.fromInt(0xFFCCFBF1);
  static const PdfColor _roseAccent = PdfColor.fromInt(0xFFE11D48);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor _textMuted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _borderLight = PdfColor.fromInt(0xFFCBD5E1);
  static const PdfColor _bgSlate = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _amberDark = PdfColor.fromInt(0xFFB45309);
  static const PdfColor _amberBg = PdfColor.fromInt(0xFFFEF3C7);
  static const PdfColor _amberBorder = PdfColor.fromInt(0xFFFDE68A);

  /// Generates a single-page A4 PDF document containing all 5 clinical summary sections.
  Future<Uint8List> buildOnePagePdf(DoctorSummaryData data) async {
    final pdf = pw.Document();

    final fontBase = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontOblique = pw.Font.helveticaOblique();

    final theme = pw.ThemeData.withFont(
      base: fontBase,
      bold: fontBold,
      italic: fontOblique,
    );

    // Limit items for guaranteed single-page A4 fit
    final displayedLabs = data.measuredLabs.take(5).toList();
    final displayedVitals = data.measuredVitals.take(2).toList();
    final displayedObservations = data.appObservations.take(3).toList();
    final displayedUncertain = data.uncertainItems.take(2).toList();
    final displayedQuestions = data.allQuestions.take(4).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. TOP HEADER & PATIENT META
              _buildHeader(data),
              pw.SizedBox(height: 5),

              // 2. CLINICAL SAFETY ALERT (NON-DIAGNOSTIC NOTICE)
              _buildSafetyDisclaimerBanner(),
              pw.SizedBox(height: 6),

              // 3. SECTION 1: MEASURED LAB & VITALS FACTS
              _buildSectionTitle(
                '1. Measured Lab & Vitals Facts (Verified Records)',
              ),
              pw.SizedBox(height: 3),
              _buildLabVitalsTable(displayedLabs, displayedVitals),
              pw.SizedBox(height: 6),

              // 4. SECTION 2 & 3: 2-COLUMN ROW (CYCLE SUMMARY & APP OBSERVATIONS)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: 6-Month Cycle & PCOD/PCOS Summary
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('2. Cycle & PCOD/PCOS Summary'),
                        pw.SizedBox(height: 3),
                        _buildCycleSummaryCard(data.cycleSummary),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  // Right: App Observations (Non-Diagnostic)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle(
                          '3. App Observations (Non-Diagnostic)',
                        ),
                        pw.SizedBox(height: 3),
                        _buildObservationsCard(displayedObservations),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              // 5. SECTION 4: UNCERTAIN / NEEDS-REVIEW ITEMS
              _buildSectionTitle(
                '4. Uncertain / Needs-Review Items (Verify Paper Lab Report)',
              ),
              pw.SizedBox(height: 3),
              _buildUncertainItemsCard(displayedUncertain),
              pw.SizedBox(height: 6),

              // 6. SECTION 5: QUESTIONS TO ASK YOUR DOCTOR
              _buildSectionTitle('5. Questions to Ask Your Doctor / Clinician'),
              pw.SizedBox(height: 3),
              _buildQuestionsCard(displayedQuestions),
              pw.SizedBox(height: 6),

              // 7. FOOTER DISCLAIMER
              _buildFooterDisclaimer(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- PDF COMPONENT BUILDERS ---

  pw.Widget _buildHeader(DoctorSummaryData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _bgSlate,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _tealLight, width: 1.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: const pw.BoxDecoration(
                      color: _tealPrimary,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    'PreNest — One-Page Doctor Visit Summary',
                    style: pw.TextStyle(
                      fontSize: 12.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _tealDark,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Confidential Clinical Discussion Aid • Prepared On-Device',
                style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Patient: ${data.partnerName} (${data.partnerRole}, Age: ${data.partnerAge}, Blood Group: ${data.bloodGroup})',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                'Stage: ${data.stageDisplayName} • Date: ${_formatDate(data.generatedAt)}',
                style: const pw.TextStyle(fontSize: 7.5, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSafetyDisclaimerBanner() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: pw.BoxDecoration(
        color: _amberBg,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _amberBorder, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: pw.BoxDecoration(
              color: _amberDark,
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              'NON-DIAGNOSTIC AID',
              style: pw.TextStyle(
                fontSize: 6,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              'This summary organizes user-entered records, vitals, and trends for discussion with a registered medical practitioner. '
              'PreNest does not diagnose medical conditions, prescribe drugs, or replace clinical consultations.',
              style: const pw.TextStyle(fontSize: 6.5, color: _amberDark),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 9,
          decoration: pw.BoxDecoration(
            color: _tealPrimary,
            borderRadius: pw.BorderRadius.circular(1),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: _tealDark,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildLabVitalsTable(
    List<LabFactItem> labs,
    List<VitalFactItem> vitals,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _borderLight, width: 0.8),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: _borderLight, width: 0.5),
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(2.2),
          1: pw.FlexColumnWidth(1.4),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(1.4),
        },
        children: [
          // Table Header
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _bgSlate),
            children: [
              _buildTableHeaderCell('Test / Vital Parameter'),
              _buildTableHeaderCell('Recorded Value'),
              _buildTableHeaderCell('Date'),
              _buildTableHeaderCell('Printed Lab Reference Range'),
              _buildTableHeaderCell('Status / Verification'),
            ],
          ),
          // Labs Rows
          ...labs.map((lab) {
            return pw.TableRow(
              children: [
                _buildTableCell(lab.testName, isBold: true),
                _buildTableCell(
                  lab.valueWithUnit,
                  textColor: lab.isFlagged ? _roseAccent : _textDark,
                  isBold: lab.isFlagged,
                ),
                _buildTableCell(lab.dateStr),
                _buildTableCell(lab.referenceRange),
                _buildTableCell(
                  lab.statusLabel,
                  textColor: lab.isFlagged ? _amberDark : _tealPrimary,
                ),
              ],
            );
          }),
          // Vitals Rows
          ...vitals.map((v) {
            return pw.TableRow(
              children: [
                _buildTableCell('Vital: ${v.label}', isBold: true),
                _buildTableCell(v.value, isBold: true),
                _buildTableCell(v.dateStr),
                _buildTableCell('Clinical baseline guideline'),
                _buildTableCell(v.category, textColor: _tealPrimary),
              ],
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 6.8,
          fontWeight: pw.FontWeight.bold,
          color: _tealDark,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isBold = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      child: pw.Text(
        text,
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
        style: pw.TextStyle(
          fontSize: 6.8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? _textDark,
        ),
      ),
    );
  }

  pw.Widget _buildCycleSummaryCard(CycleSummaryData cycle) {
    final modeLabel = cycle.irregularCycleMode
        ? 'Irregular / Flexible Mode (PCOD/PCOS)'
        : 'Regular Window (~${cycle.averageCycleLength} days)';

    final symptomsStr = cycle.activeSymptoms.isEmpty
        ? 'No acute symptoms reported this cycle'
        : cycle.activeSymptoms.join(', ');

    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _borderLight, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildCompactPair('Tracking Mode:', modeLabel, isBoldValue: true),
          _buildCompactPair(
            'Cycle Status:',
            'Day ${cycle.currentCycleDay} • Last Period: ${cycle.lastPeriodDateStr} • Flow: ${cycle.flowIntensity}',
          ),
          _buildCompactPair('Top Symptoms:', symptomsStr),
          _buildCompactPair(
            'PCOS Self-Check:',
            '${cycle.flaggedPcosCount} of ${cycle.totalPcosCount} indicators noted',
            textColor: cycle.flaggedPcosCount > 0 ? _roseAccent : _tealPrimary,
          ),
          if (cycle.flaggedPcosNames.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.5),
              child: pw.Text(
                'Flagged: ${cycle.flaggedPcosNames.take(3).join("; ")}',
                style: const pw.TextStyle(fontSize: 6.2, color: _textMuted),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildObservationsCard(List<AppObservationItem> observations) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _borderLight, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: observations.map((obs) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 2, right: 3),
                  width: 3,
                  height: 3,
                  decoration: pw.BoxDecoration(
                    color: obs.isAttentionNeeded ? _roseAccent : _tealPrimary,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '${obs.title}: ',
                          style: pw.TextStyle(
                            fontSize: 6.5,
                            fontWeight: pw.FontWeight.bold,
                            color: obs.isAttentionNeeded
                                ? _roseAccent
                                : _textDark,
                          ),
                        ),
                        pw.TextSpan(
                          text: obs.detail,
                          style: const pw.TextStyle(
                            fontSize: 6.2,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildUncertainItemsCard(List<UncertainItem> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: _bgSlate,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _borderLight, width: 0.8),
      ),
      child: pw.Column(
        children: items.map((item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '[Review] ',
                  style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _amberDark,
                  ),
                ),
                pw.Text(
                  '${item.title}: ',
                  style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '${item.reason} — ${item.recommendation}',
                    style: const pw.TextStyle(fontSize: 6.2, color: _textMuted),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildQuestionsCard(List<String> questions) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _tealLight, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: questions.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final q = entry.value;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 10,
                  child: pw.Text(
                    '$idx.',
                    style: pw.TextStyle(
                      fontSize: 6.8,
                      fontWeight: pw.FontWeight.bold,
                      color: _tealPrimary,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    q,
                    style: const pw.TextStyle(fontSize: 6.5, color: _textDark),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildFooterDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _bgSlate,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _borderLight, width: 0.5),
      ),
      child: pw.Center(
        child: pw.Text(
          'Informational summary generated on-device by PreNest. Not a medical diagnosis or prescription. '
          'Please verify against original physical lab reports.',
          style: pw.TextStyle(
            fontSize: 6.2,
            fontStyle: pw.FontStyle.italic,
            color: _textMuted,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildCompactPair(
    String label,
    String value, {
    bool isBoldValue = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label ',
            style: pw.TextStyle(
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
              color: _textMuted,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 6.5,
                fontWeight: isBoldValue
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
                color: textColor ?? _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Builds a clean plain-text formatted summary for quick copy or SMS/message sharing.
  String buildPlainTextSummary(DoctorSummaryData data) {
    final buffer = StringBuffer();
    buffer.writeln('====================================');
    buffer.writeln('PreNest — One-Page Doctor Visit Summary');
    buffer.writeln('====================================');
    buffer.writeln(
      'Patient: ${data.partnerName} (${data.partnerRole}, Age: ${data.partnerAge}, Blood Group: ${data.bloodGroup})',
    );
    buffer.writeln(
      'Stage / Mode: ${data.stageDisplayName} — ${data.stageDescription}',
    );
    buffer.writeln('Generated: ${_formatDate(data.generatedAt)}');
    buffer.writeln(
      'Notice: Informational only. Not a medical diagnosis or prescription.',
    );
    buffer.writeln('');

    buffer.writeln('1. MEASURED LAB & VITALS FACTS:');
    for (final lab in data.measuredLabs) {
      buffer.writeln(
        '  • ${lab.testName}: ${lab.valueWithUnit} (Printed Ref: ${lab.referenceRange}) [${lab.dateStr}] — ${lab.statusLabel}',
      );
    }
    for (final vital in data.measuredVitals) {
      buffer.writeln(
        '  • ${vital.label}: ${vital.value} (${vital.category}) [${vital.dateStr}]',
      );
    }
    buffer.writeln('');

    buffer.writeln('2. 6-MONTH CYCLE & PCOD/PCOS SUMMARY:');
    buffer.writeln(
      '  • Mode: ${data.cycleSummary.irregularCycleMode ? "Irregular / Flexible Mode (PCOD/PCOS)" : "Regular Mode (~${data.cycleSummary.averageCycleLength} days)"}',
    );
    buffer.writeln(
      '  • Cycle Status: Day ${data.cycleSummary.currentCycleDay} • Last Period: ${data.cycleSummary.lastPeriodDateStr} • Flow: ${data.cycleSummary.flowIntensity}',
    );
    buffer.writeln(
      '  • Top Symptoms: ${data.cycleSummary.activeSymptoms.isEmpty ? "None reported" : data.cycleSummary.activeSymptoms.join(", ")}',
    );
    buffer.writeln(
      '  • PCOS Self-Check: ${data.cycleSummary.flaggedPcosCount} of ${data.cycleSummary.totalPcosCount} indicators noted',
    );
    if (data.cycleSummary.flaggedPcosNames.isNotEmpty) {
      buffer.writeln(
        '    - Flagged signs: ${data.cycleSummary.flaggedPcosNames.join("; ")}',
      );
    }
    buffer.writeln('  • Pattern Note: ${data.cycleSummary.patternSummary}');
    buffer.writeln('');

    buffer.writeln('3. APP OBSERVATIONS (NON-DIAGNOSTIC):');
    for (final obs in data.appObservations) {
      buffer.writeln('  • [${obs.category}] ${obs.title}: ${obs.detail}');
    }
    buffer.writeln('');

    buffer.writeln('4. UNCERTAIN / NEEDS-REVIEW ITEMS:');
    for (final item in data.uncertainItems) {
      buffer.writeln(
        '  • ${item.title} (${item.confidencePercent}): ${item.reason} -> Recommendation: ${item.recommendation}',
      );
    }
    buffer.writeln('');

    buffer.writeln('5. QUESTIONS TO ASK YOUR DOCTOR:');
    var qNum = 1;
    for (final q in data.allQuestions) {
      buffer.writeln('  $qNum. $q');
      qNum++;
    }
    buffer.writeln('');
    buffer.writeln('====================================');
    buffer.writeln(
      'Disclaimer: Informational summary generated on-device by PreNest. Not a medical diagnosis or prescription. Please verify against original lab reports.',
    );
    buffer.writeln('====================================');
    return buffer.toString();
  }
}
