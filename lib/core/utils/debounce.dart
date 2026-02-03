import 'dart:async';

/// A debouncer that delays the execution of a function
/// until a specified duration has passed without new calls
class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce({this.duration = const Duration(milliseconds: 500)});

  /// Runs the action after the debounce duration
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Disposes the debouncer and cancels any pending action
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Returns true if there's a pending action
  bool get isPending => _timer?.isActive ?? false;
}

/// Extension method for easy debouncing with Future
extension DebounceExtension<T> on Future<T> Function() {
  /// Creates a debounced version of this function
  Future<T> Function() debounced(Duration duration) {
    Timer? timer;
    Completer<T>? completer;

    return () {
      timer?.cancel();
      completer ??= Completer<T>();

      timer = Timer(duration, () async {
        try {
          final result = await this();
          completer?.complete(result);
        } catch (e) {
          completer?.completeError(e);
        }
        completer = null;
      });

      return completer!.future;
    };
  }
}

