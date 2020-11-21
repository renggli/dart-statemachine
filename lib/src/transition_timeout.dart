library statemachine.transition.timeout;

import 'dart:async';

import 'callback.dart';
import 'transition.dart';

/// A transition that happens automatically after a certain duration elapsed.
class TimeoutTransition extends Transition {
  /// The duration to wait before the timer triggers.
  final Duration duration;

  /// The callback to be evaluated when the timer triggers.
  final Callback0 callback;

  /// Time triggering after a timeout.
  late Timer _timer;

  TimeoutTransition(this.duration, this.callback);

  @override
  void activate() => _timer = Timer(duration, callback);

  @override
  void deactivate() => _timer.cancel();
}
