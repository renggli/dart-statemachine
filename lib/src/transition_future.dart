library statemachine.transition.future;

import 'dart:async';

import 'package:statemachine/src/callback.dart';
import 'package:statemachine/src/transition.dart';


/// A transition that is triggered one time by a future.
class FutureTransition<T> extends Transition {

  /// The future triggering this transition.
  final Future<T> future;

  /// The callback to be evaluated when the future triggers.
  final Callback1<T> callback;

  bool _active = false;
  bool _started = false;
  bool _waiting = false;

  T _value;

  FutureTransition(this.future, this.callback);

  @override
  void activate() {
    assert(!_active);
    _active = true;
    if (!_started) {
      _started = true;
      future.then((value) {
        if (_active) {
          callback(value);
        } else {
          _waiting = true;
          _value = value;
        }
      });
    } else if (_waiting) {
      callback(_value);
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
