import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/survey_response.dart';

class StorageService {
  static const String _fileName = 'responses.jsonl';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> append(SurveyResponse response) async {
    final file = await _file();
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final sink = file.openWrite(mode: FileMode.append);
    try {
      sink.writeln(response.toJsonLine());
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  Future<List<SurveyResponse>> readAll() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final lines = await file.readAsLines();
    final result = <SurveyResponse>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      try {
        final map = jsonDecode(line) as Map<String, dynamic>;
        result.add(SurveyResponse.fromJson(map));
      } catch (_) {
        // Ignore corrupt lines but keep going.
      }
    }
    return result;
  }

  Future<int> count() async {
    final file = await _file();
    if (!await file.exists()) return 0;
    final lines = await file.readAsLines();
    return lines.where((l) => l.trim().isNotEmpty).length;
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> fileHandle() => _file();
}
