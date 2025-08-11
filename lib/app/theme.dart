import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    fontFamily: 'AbyssinicaSIL', // declared in pubspec.yaml
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E5A88)),
    useMaterial3: true,
  );
}
