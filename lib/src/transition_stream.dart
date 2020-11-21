library statemachine.transition.stream;

import 'dart:async';

import 'callback.dart';
import 'transition.dart';

/// A transition that is triggered through a stream.
class StreamTransition<T> extends Transition {
  /// The stream triggering this transition.
  final Stream<T> stream;

  /// The callback to be evaluated when the stream triggers.
  final Callback1<T> callback;

  /// Current subscription
  late StreamSubscription<T> _subscription;

  StreamTransition(this.stream, this.callback);

  @override
  void activate() => _subscription = stream.listen(callback);

  @override
  void deactivate() => _subscription.cancel();
}
