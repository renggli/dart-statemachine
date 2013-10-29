// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A transition that is triggered one time by a future.
 */
class FutureTransition extends Transition {

  final Future _future;
  final Function _callback;

  bool _active = false;
  bool _started = false;
  bool _waiting = false;

  dynamic _value;

  FutureTransition(this._future, this._callback);

  @override
  void activate() {
    assert(!_active);
    _active = true;
    if (!_started) {
      _started = true;
      _future.then((value) {
        if (_active) {
          _callback(value);
        } else {
          _waiting = true;
          _value = value;
        }
      });
    } else if (_waiting) {
      _callback(_value);
      _waiting = false;
      _value = null;
    }
  }

  @override
  void deactivate() {
    assert(_active);
    _active = false;
  }

}