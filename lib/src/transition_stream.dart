library statemachine.transition.stream;

import 'dart:async';

import 'package:statemachine/src/callback.dart';
import 'package:statemachine/src/transition.dart';

/// A transition that is triggered through a stream.
class StreamTransition<T> extends Transition {
  /// The stream triggering this transition.
  final Stream<T> stream;

  /// The callback to be evaluated when the stream triggers.
  final Callback1<T> callback;

  StreamSubscription<T> _subscription;

  StreamTransition(this.stream, this.callback);

  @override
  void activate() {
    assert(_subscription == null);
    _subscription = stream.listen(callback);
  }

  @override
  void deactivate() {
    assert(_subscription != null);
    _subscription.cancel();
    _subscription = null;
  }
}
