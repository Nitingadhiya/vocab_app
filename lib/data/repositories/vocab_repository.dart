import 'package:vocab_app/data/models/index.dart';
import 'package:vocab_app/data/sources/local/vocab_local_data_source.dart';

class CategoryWithCount {
  final Category category;
  final int wordCount;

  const CategoryWithCount({required this.category, required this.wordCount});
}

/// Read-only access to the bundled vocabulary content.
class VocabRepository {
  final VocabLocalDataSource localDataSource;

  VocabRepository({required this.localDataSource});

  Future<List<Category>> getCategories() => localDataSource.loadCategories();

  Future<List<Word>> getAllWords() => localDataSource.loadWords();

  Future<List<CategoryWithCount>> getCategoriesWithWordCounts() async {
    final categories = await getCategories();
    final words = await getAllWords();
    return categories
        .map((c) => CategoryWithCount(
              category: c,
              wordCount: words.where((w) => w.categoryId == c.id).length,
            ))
        .toList();
  }

  Future<Category> getCategory(String categoryId) async {
    final categories = await getCategories();
    return categories.firstWhere((c) => c.id == categoryId);
  }

  Future<List<Word>> getWords(String categoryId) async {
    final words = await localDataSource.loadWords();
    return words.where((w) => w.categoryId == categoryId).toList();
  }

  Future<Word?> getWord(String wordId) async {
    final words = await localDataSource.loadWords();
    for (final word in words) {
      if (word.id == wordId) return word;
    }
    return null;
  }
}
