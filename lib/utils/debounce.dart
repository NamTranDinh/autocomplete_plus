import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class for debouncing actions, preventing rapid and frequent
/// executions of a callback within a specified time interval.
///
/// The [DebounceHelper] allows you to run a callback function only if a certain
/// amount of time has passed since the last invocation. This is useful in scenarios
/// where you want to delay the execution of an action until a certain idle period
/// has passed, ignoring rapid and consecutive calls.
///
/// Example usage:
/// ```dart
/// // Create an instance of DebounceHelper with a specified time interval (milliseconds).
/// final debounceHelper = DebounceHelper(milliseconds: 300);
///
/// // Run the callback, and it will be executed only if there is no other
/// // invocation within the specified time interval.
/// debounceHelper.run(() {
///   // Your callback logic goes here.
/// });
///
/// // Dispose of the DebounceHelper when it's no longer needed to cancel any pending actions.
/// debounceHelper.dispose();
/// ```
class DebounceHelper {
  /// Retrieves the singleton instance of [DebounceHelper].
  factory DebounceHelper({int? milliseconds}) => _instance..milliseconds = milliseconds;

  /// Creates an instance of [DebounceHelper] with a specified time interval (milliseconds).
  DebounceHelper._privateConstructor();

  /// The singleton instance of the [DebounceHelper] class.
  static final DebounceHelper _instance = DebounceHelper._privateConstructor();

  /// The time interval in milliseconds for debouncing.
  int? milliseconds;

  /// A timer to track the delay period between consecutive invocations.
  Timer? _timer;

  /// Runs the specified callback, ensuring it is executed only if there is no other
  /// invocation within the specified time interval.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds ?? 500), action);
  }

  /// Disposes of the [DebounceHelper], canceling any pending actions.
  void dispose() {
    _timer?.cancel();
  }
}
