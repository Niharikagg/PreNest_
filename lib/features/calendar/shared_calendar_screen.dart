import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import 'shared_calendar_provider.dart';

class SharedCalendarScreen extends ConsumerStatefulWidget {
  const SharedCalendarScreen({super.key});

  @override
  ConsumerState<SharedCalendarScreen> createState() =>
      _SharedCalendarScreenState();
}

class _SharedCalendarScreenState extends ConsumerState<SharedCalendarScreen> {
  late DateTime _displayedMonth;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
    ref.read(sharedCalendarProvider.notifier).setSelectedDate(now);
  }

  String _formatDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = _monthNames[date.month - 1];
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  void _readAloudSelectedDay(
    List<CalendarEvent> events,
    DateTime selectedDate,
    AppLanguage lang,
  ) {
    final tts = ref.read(ttsServiceProvider);
    if (events.isEmpty) {
      tts.speak(
        'No events or reminders scheduled for ${_monthNames[selectedDate.month - 1]} ${selectedDate.day}.',
        lang,
      );
      return;
    }

    final buffer = StringBuffer(
      'Schedule for ${_monthNames[selectedDate.month - 1]} ${selectedDate.day}. ${events.length} item${events.length == 1 ? '' : 's'}. ',
    );

    for (int i = 0; i < events.length; i++) {
      final ev = events[i];
      buffer.write('${i + 1}: ${ev.title}. ');
      if (ev.note.isNotEmpty) {
        buffer.write('${ev.note}. ');
      }
    }

    tts.speak(buffer.toString(), lang);
  }

  void _showAddReminderSheet(
    BuildContext context,
    DateTime initialDate,
    String activePartnerName,
  ) {
    DateTime pickedDate = initialDate;
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    CalendarEventType pickedCategory = CalendarEventType.checkupReminder;
    PregnancyStage pickedStage = PregnancyStage.pregnancy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomPadding + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTealLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add Shared Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Saved to shared calendar for $activePartnerName and partner.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Row
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: pickedDate,
                          firstDate: DateTime(2024, 1, 1),
                          lastDate: DateTime(2030, 12, 31),
                        );
                        if (picked != null) {
                          setModalState(() {
                            pickedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_rounded,
                                  size: 18,
                                  color: AppTheme.primaryTeal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Date: ${_monthNames[pickedDate.month - 1]} ${pickedDate.day}, ${pickedDate.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title Field
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title / Appointment Name *',
                        hintText: 'e.g. Ultrasound Scan, Fasting Glucose Check',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    DropdownButtonFormField<CalendarEventType>(
                      value: pickedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: CalendarEventType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: type.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            pickedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Stage Dropdown
                    DropdownButtonFormField<PregnancyStage>(
                      value: pickedStage,
                      decoration: const InputDecoration(
                        labelText: 'Stage Scope',
                      ),
                      items: PregnancyStage.values.map((stage) {
                        return DropdownMenuItem(
                          value: stage,
                          child: Text(stage.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            pickedStage = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Note Field
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Clinical Notes or Prep Instructions',
                        hintText:
                            'e.g. Bring fasting report, pack water bottle',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Save to Shared Calendar'),
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          ref
                              .read(sharedCalendarProvider.notifier)
                              .addEvent(
                                date: pickedDate,
                                title: title,
                                category: pickedCategory,
                                stage: pickedStage,
                                note: noteController.text.trim(),
                                createdBy: activePartnerName,
                              );
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reminder added to shared calendar.',
                              ),
                              backgroundColor: AppTheme.primaryTeal,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(sharedCalendarProvider);
    final currentLang = ref.watch(languageProvider);
    final couple = ref.watch(coupleProvider);
    final activePartnerName = couple.activePartner.name;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = calendarState.selectedDate;
    final selectedEvents = calendarState.selectedDayEvents;

    // Days in current displayed month
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // weekday is 1 for Mon, 7 for Sun. We want Mon to be col 0.
    final startingCol = firstDayOfMonth.weekday - 1;

    // Total cells in grid (previous padding + days)
    final totalCells = startingCol + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(AppStrings.t('Shared Calendar', currentLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: 'Read today\'s schedule aloud',
            onPressed: () => _readAloudSelectedDay(
              selectedEvents,
              selectedDate,
              currentLang,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Jump to today',
            onPressed: _jumpToToday,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reminder'),
        onPressed: () =>
            _showAddReminderSheet(context, selectedDate, activePartnerName),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Clinical Disclaimer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shared couple schedule: Dot-coded across all 4 modes. Confirm clinical dates with your doctor.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Stage Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      FilterChip(
                        selected: calendarState.filterStage == null,
                        label: const Text('All Modes'),
                        onSelected: (_) {
                          ref
                              .read(sharedCalendarProvider.notifier)
                              .setFilterStage(null);
                        },
                        selectedColor: AppTheme.primaryTealLight,
                        checkmarkColor: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      ...PregnancyStage.values.map((stage) {
                        final isSelected = calendarState.filterStage == stage;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(stage.displayName),
                            onSelected: (_) {
                              ref
                                  .read(sharedCalendarProvider.notifier)
                                  .setFilterStage(isSelected ? null : stage);
                            },
                            selectedColor: AppTheme.primaryTealLight,
                            checkmarkColor: AppTheme.primaryTeal,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Main Calendar Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Month Header & Navigation Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              tooltip: 'Previous Month',
                              onPressed: _previousMonth,
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_monthNames[month - 1]} $year',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                if (year != today.year || month != today.month)
                                  InkWell(
                                    onTap: _jumpToToday,
                                    child: const Text(
                                      'Back to current month',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppTheme.primaryTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              tooltip: 'Next Month',
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Weekdays Header Row
                        Row(
                          children: _weekdays.map((wd) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  wd,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 6),

                        // Monthly Day Grid
                        Column(
                          children: List.generate(totalRows, (rowIndex) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: List.generate(7, (colIndex) {
                                  final cellIndex = rowIndex * 7 + colIndex;
                                  final dayNum = cellIndex - startingCol + 1;

                                  if (dayNum < 1 || dayNum > daysInMonth) {
                                    return const Expanded(
                                      child: SizedBox(height: 48),
                                    );
                                  }

                                  final cellDate = DateTime(
                                    year,
                                    month,
                                    dayNum,
                                  );
                                  final isToday =
                                      cellDate.year == today.year &&
                                      cellDate.month == today.month &&
                                      cellDate.day == today.day;
                                  final isSelected =
                                      cellDate.year == selectedDate.year &&
                                      cellDate.month == selectedDate.month &&
                                      cellDate.day == selectedDate.day;

                                  final dayEvents = calendarState.eventsForDay(
                                    cellDate,
                                  );

                                  return Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        ref
                                            .read(
                                              sharedCalendarProvider.notifier,
                                            )
                                            .setSelectedDate(cellDate);
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 48,
                                        margin: const EdgeInsets.all(1.5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.primaryTealLight
                                              : (isToday
                                                    ? const Color(0xFFF0FDF4)
                                                    : Colors.transparent),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primaryTeal
                                                : (isToday
                                                      ? AppTheme.successGreen
                                                      : Colors.transparent),
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$dayNum',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    isSelected || isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppTheme.primaryTealDark
                                                    : (isToday
                                                          ? AppTheme
                                                                .successGreen
                                                          : AppTheme.textDark),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            // Event Dots (up to 3)
                                            if (dayEvents.isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: dayEvents.take(3).map((
                                                  e,
                                                ) {
                                                  return Container(
                                                    width: 4.5,
                                                    height: 4.5,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 1.0,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: e.category.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            else
                                              const SizedBox(height: 4.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Color-Coded Dot Legend
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildLegendItem(
                              CalendarEventType.periodOrCycle.color,
                              'Period & Cycle',
                            ),
                            _buildLegendItem(
                              CalendarEventType.fertileWindow.color,
                              'Fertile & Planning',
                            ),
                            _buildLegendItem(
                              CalendarEventType.ancVisit.color,
                              'ANC Visits',
                            ),
                            _buildLegendItem(
                              CalendarEventType.labDue.color,
                              'Labs / Scans',
                            ),
                            _buildLegendItem(
                              CalendarEventType.uipVaccine.color,
                              'Newborn UIP',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Selected Day Events Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(selectedDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedEvents.length} scheduled item${selectedEvents.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: AppTheme.primaryTeal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Event'),
                      onPressed: () => _showAddReminderSheet(
                        context,
                        selectedDate,
                        activePartnerName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Selected Day Events List
                if (selectedEvents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No events scheduled for this day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Either partner can tap "+ Add Reminder" to record a clinic appointment, lab due date, or mutual health check-in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = selectedEvents[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.category.color.withOpacity(0.3),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: item.category.containerColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.category.icon,
                                size: 20,
                                color: item.category.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.category.containerColor,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          item.category.displayName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: item.category.color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          item.stage.displayName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: item.isCompleted
                                          ? AppTheme.textMuted
                                          : AppTheme.textDark,
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (item.note.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.note,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Logged by ${item.createdBy}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppTheme.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                item.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: item.isCompleted
                                    ? AppTheme.successGreen
                                    : Colors.grey.shade400,
                              ),
                              tooltip: item.isCompleted
                                  ? 'Mark as incomplete'
                                  : 'Mark as completed',
                              onPressed: () {
                                ref
                                    .read(sharedCalendarProvider.notifier)
                                    .toggleEventCompletion(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
