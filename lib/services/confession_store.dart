import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfessionStore {
  static const _key = 'confession_notes_v1';
  static const _storage = FlutterSecureStorage(); // iOS/macOS Keychain, Android Keystore

  static Future<String> load() async => await _storage.read(key: _key) ?? '';
  static Future<void> save(String text) async => _storage.write(key: _key, value: text);
  static Future<void> clear() async => _storage.delete(key: _key);
}
