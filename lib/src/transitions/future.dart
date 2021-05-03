import 'dart:async';

import '../callback.dart';
import '../transition.dart';

/// A transition that is triggered by a future.
class FutureTransition<T> extends Transition {
  /// The provider of a future triggering this transition.
  final Provider<Future<T>> provider;

  /// The callback to be evaluated when the future triggers.
  final Callback1<T> callback;

  /// The currently active future.
  Future<T>? _future;

  FutureTransition(this.provider, this.callback);

  @override
  void activate() {
    assert(_future == null, 'future must be inactive');
    final future = _future = provider();
    future.then((value) {
      if (_future == future) {
        _future = null;
        callback(value);
      }
    });
  }

  @override
  void deactivate() => _future = null;
}
