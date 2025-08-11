import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // <-- for TimeOfDay

class AppPrefs {
  static late SharedPreferences _sp;

  static const _kUiLang = 'uiLang';             // 'en' | 'am'
  static const _kContentLang = 'contentLang';   // 'en' | 'am' | 'ti' | 'om'
  static const _kAge  = 'age';                  // children | youth | adult
  static const _kOnboarded = 'onboarded';

  static bool get isOnboarded => _sp.getBool(_kOnboarded) ?? false;
  static Future<bool> setOnboarded(bool v) => _sp.setBool(_kOnboarded, v);

  static Future<void> init() async {
    _sp = await SharedPreferences.getInstance();

    // Back-compat: if old 'lang' exists, migrate it to content/ui.
    final old = _sp.getString('lang');
    if (old != null) {
      _sp.setString(_kContentLang, old);
      if (old == 'en' || old == 'am') {
        _sp.setString(_kUiLang, old);
      }
      _sp.remove('lang');
    }
  }

  // UI locale (only en/am supported by Material/Cupertino)
  static String get uiLangCode => _sp.getString(_kUiLang) ?? 'en';
  static Future<bool> setUiLangCode(String code) => _sp.setString(_kUiLang, code);

  // Content locale (en/am/ti/om supported by our strings)
  static String get contentLangCode => _sp.getString(_kContentLang) ?? 'en';
  static Future<bool> setContentLangCode(String code) => _sp.setString(_kContentLang, code);

  // Age group
  static String get ageGroup => _sp.getString(_kAge) ?? 'adult';
  static Future<bool> setAgeGroup(String age) => _sp.setString(_kAge, age);

  static const _kReminderEnabled = 'reminderEnabled';
  static const _kReminderHour = 'reminderHour';
  static const _kReminderMinute = 'reminderMinute';

  static bool get reminderEnabled => _sp.getBool(_kReminderEnabled) ?? false;
  static Future<bool> setReminderEnabled(bool v) => _sp.setBool(_kReminderEnabled, v);

  static TimeOfDay get reminderTime {
    final h = _sp.getInt(_kReminderHour) ?? 7;
    final m = _sp.getInt(_kReminderMinute) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }
  static Future<void> setReminderTime(TimeOfDay t) async {
    await _sp.setInt(_kReminderHour, t.hour);
    await _sp.setInt(_kReminderMinute, t.minute);
  }
}
