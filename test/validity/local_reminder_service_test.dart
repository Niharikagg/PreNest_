import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/features/reminders/local_reminder_service.dart';
import 'package:prenest/features/reminders/reminder.dart';

void main() {
  late Directory directory;
  late LocalReminderService service;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('prenest-reminders-');
    service = LocalReminderService(directoryProvider: () async => directory);
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'creates, lists, updates, deletes, and persists reminders locally',
    () async {
      final later = Reminder(
        id: 'later',
        title: 'Later reminder',
        scheduledAt: DateTime(2026, 3),
      );
      await service.create(later);
      await service.create(
        Reminder(
          id: 'earlier',
          title: 'Earlier reminder',
          scheduledAt: DateTime(2026, 1),
        ),
      );

      final listed = await LocalReminderService(
        directoryProvider: () async => directory,
      ).list();
      expect(listed.map((item) => item.id), ['earlier', 'later']);

      final updated = Reminder(
        id: 'later',
        title: 'Updated reminder',
        scheduledAt: later.scheduledAt,
        note: 'Updated note',
      );
      await service.update(updated);
      expect((await service.list()).last.title, 'Updated reminder');

      await service.delete('earlier');
      expect((await service.list()).map((item) => item.id), ['later']);
    },
  );

  test('rejects duplicate IDs and updates of missing reminders', () async {
    final reminder = Reminder(
      id: 'one',
      title: 'One',
      scheduledAt: DateTime(2026),
    );
    await service.create(reminder);

    await expectLater(service.create(reminder), throwsArgumentError);
    await expectLater(
      service.update(
        Reminder(id: 'missing', title: 'Missing', scheduledAt: DateTime(2026)),
      ),
      throwsStateError,
    );
  });
}
