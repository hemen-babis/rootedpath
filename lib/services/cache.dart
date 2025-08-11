import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static late Box _box;
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('cache_v1');
  }

  static T? get<T>(String key) => _box.get(key) as T?;
  static Future<void> put<T>(String key, T value) => _box.put(key, value);
  static Future<void> delete(String key) => _box.delete(key);
  static Future<void> clearAll() async => _box.clear();

  // New helpers
  static Future<void> clear() => _box.clear();
  static Future<void> addFeedback(String text) async {
    if (text.isEmpty) return;
    final list = List<String>.from(_box.get('feedback_list') ?? <String>[]);
    list.add(text);
    await _box.put('feedback_list', list);
  }
}
