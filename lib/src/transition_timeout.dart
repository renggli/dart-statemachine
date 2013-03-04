// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A transition that happens automatically after a certain amount of
 * milliseconds ellapse.
 */
class TimeoutTransition extends Transition {

  final int _milliseconds;
  final Function _callback;
  Timer _timer;

  TimeoutTransition(this._milliseconds, this._callback);

  void activate() {
    _timer = new Timer(_milliseconds, (Timer timer) => _callback());
  }

  void deactivate() {
    _timer.cancel();
    _timer = null;
  }

}