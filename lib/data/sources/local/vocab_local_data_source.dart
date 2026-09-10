import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab_app/data/models/index.dart';

/// Loads the bundled vocabulary content from `assets/data/*.json`.
class VocabLocalDataSource {
  List<Category>? _categories;
  List<Word>? _words;

  Future<List<Category>> loadCategories() async {
    if (_categories != null) return _categories!;
    final raw = await rootBundle.loadString('assets/data/categories.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _categories = list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    return _categories!;
  }

  Future<List<Word>> loadWords() async {
    if (_words != null) return _words!;
    final raw = await rootBundle.loadString('assets/data/words.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _words = list.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
    return _words!;
  }
}
