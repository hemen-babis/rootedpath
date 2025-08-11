import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/cache.dart';

class ReadingsRepo {
  final _col = FirebaseFirestore.instance.collection('readings');

  Future<String?> getReading({required String dateId, required String lang}) async {
    final doc = await _col.doc(dateId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final val = data[lang] ?? data['en'];
    return (val is String) ? val : null;
  }

  /// Prefetch N days starting today and put into CacheService.
  Future<void> prefetchDays(int days, String lang) async {
    final now = DateTime.now();
    for (var i = 0; i < days; i++) {
      final d = now.add(Duration(days: i));
      final id = DateFormat('yyyyMMdd').format(d);
      final cacheKey = 'reading:$id:$lang';
      final cached = CacheService.get<String>(cacheKey);
      if (cached != null) continue;
      try {
        final text = await getReading(dateId: id, lang: lang);
        if (text != null) {
          CacheService.put(cacheKey, text);
        }
      } catch (_) {/* ignore individual failures */}
    }
  }
}
