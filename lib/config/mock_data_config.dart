import 'package:flutter/foundation.dart';

class MockDataConfig {
  MockDataConfig._();

  /// Set with `--dart-define=USE_MOCK_DATA_ON_FAILURE=false` once the API is stable.
  static const bool useMockDataOnFailure = bool.fromEnvironment(
    'USE_MOCK_DATA_ON_FAILURE',
    defaultValue: true,
  );

  static void logFallback(String feature, Object error) {
    if (kDebugMode) debugPrint('[$feature] backend unavailable; using mock data: $error');
  }
}
