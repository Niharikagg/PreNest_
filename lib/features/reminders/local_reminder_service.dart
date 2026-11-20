import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'reminder.dart';

typedef ReminderDirectoryProvider = Future<Directory> Function();

class LocalReminderService {
  LocalReminderService({ReminderDirectoryProvider? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  static const _fileName = 'prenest_reminders.json';

  final ReminderDirectoryProvider _directoryProvider;
  Future<void> _pendingOperations = Future<void>.value();

  Future<Reminder> create(Reminder reminder) => _serialize(() async {
    _validate(reminder);
    final reminders = await _readAll();
    if (reminders.any((existing) => existing.id == reminder.id)) {
      throw ArgumentError.value(
        reminder.id,
        'id',
        'Reminder ID already exists.',
      );
    }
    reminders.add(reminder);
    await _writeAll(reminders);
    return reminder;
  });

  Future<List<Reminder>> list() => _serialize(() async {
    final reminders = await _readAll()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return List<Reminder>.unmodifiable(reminders);
  });

  Future<Reminder> update(Reminder reminder) => _serialize(() async {
    _validate(reminder);
    final reminders = await _readAll();
    final index = reminders.indexWhere((item) => item.id == reminder.id);
    if (index < 0) {
      throw StateError('Reminder "${reminder.id}" does not exist.');
    }
    reminders[index] = reminder;
    await _writeAll(reminders);
    return reminder;
  });

  Future<void> delete(String id) => _serialize(() async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Reminder ID must not be empty.');
    }
    final reminders = await _readAll();
    final oldLength = reminders.length;
    reminders.removeWhere((item) => item.id == id);
    if (reminders.length == oldLength) {
      throw StateError('Reminder "$id" does not exist.');
    }
    await _writeAll(reminders);
  });

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pendingOperations.then((_) => operation());
    _pendingOperations = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Future<List<Reminder>> _readAll() async {
    final file = await _storageFile();
    if (!await file.exists()) {
      return <Reminder>[];
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! List) {
      throw const FormatException('Stored reminders must be a JSON list.');
    }
    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Stored reminder must be a JSON object.');
      }
      return Reminder.fromJson(Map<String, Object?>.from(item));
    }).toList();
  }

  Future<void> _writeAll(List<Reminder> reminders) async {
    final file = await _storageFile();
    await file.writeAsString(
      jsonEncode(reminders.map((item) => item.toJson()).toList()),
      flush: true,
    );
  }

  Future<File> _storageFile() async {
    final directory = await _directoryProvider();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  void _validate(Reminder reminder) {
    if (reminder.id.trim().isEmpty) {
      throw ArgumentError.value(
        reminder.id,
        'id',
        'Reminder ID must not be empty.',
      );
    }
    if (reminder.title.trim().isEmpty) {
      throw ArgumentError.value(
        reminder.title,
        'title',
        'Reminder title must not be empty.',
      );
    }
  }
}
