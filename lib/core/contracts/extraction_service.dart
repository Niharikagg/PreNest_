import 'dart:io';

import '../models/extracted_field.dart';

abstract class ExtractionService {
  Future<List<ExtractedField>> extract(File image);
}