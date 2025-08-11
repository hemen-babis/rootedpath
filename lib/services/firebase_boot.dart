import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseBoot {
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Optional: if you want web offline persistence.
    // try {
    //   if (kIsWeb) {
    //     await FirebaseFirestore.instance.enablePersistence(
    //       const PersistenceSettings(synchronizeTabs: true),
    //     );
    //   }
    // } catch (_) {}
    _inited = true;
  }
}
