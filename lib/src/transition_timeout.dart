part of statemachine;

/// A transition that happens automatically after a certain duration elapsed.
class TimeoutTransition extends Transition {

  /// The duration to wait before the timer triggers.
  final Duration duration;

  /// The callback to be evaluated when the timer triggers.
  final Callback0 callback;

  Timer _timer;

  TimeoutTransition(this.duration, this.callback);

  @override
  void activate() {
    assert(_timer == null);
    _timer = new Timer(duration, callback);
  }

  @override
  void deactivate() {
    assert(_timer != null);
    _timer.cancel();
    _timer = null;
  }

}
