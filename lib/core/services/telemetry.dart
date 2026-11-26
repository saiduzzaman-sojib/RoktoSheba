import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// One place for crash reporting and analytics.
/// Data is collected only in release builds, so your own testing does not pollute it.
class Telemetry {
  Telemetry._();

  static final observer =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  static Future<void> init() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
      // Crashlytics does not support web.
      if (kIsWeb) return;
      final c = FirebaseCrashlytics.instance;
      await c.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = c.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        c.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (_) {}
  }

  /// Example: Telemetry.event('request_created', {'urgency': 'Critical'})
  static void event(String name, [Map<String, Object>? params]) {
    try {
      FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  /// For errors you catch yourself but still want to see in the console.
  static void error(Object e, [StackTrace? s]) {
    if (kIsWeb) return;
    try {
      FirebaseCrashlytics.instance.recordError(e, s);
    } catch (_) {}
  }
}