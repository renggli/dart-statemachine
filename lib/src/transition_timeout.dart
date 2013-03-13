// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A transition that happens automatically after a certain duration elapsed.
 */
class TimeoutTransition extends Transition {

  final Duration _duration;
  final Function _callback;

  Timer _timer;

  TimeoutTransition(this._duration, this._callback);

  void activate() {
    assert(_timer == null);
    _timer = new Timer(_duration, _callback);
  }

  void deactivate() {
    assert(_timer != null);
    _timer.cancel();
    _timer = null;
  }

}