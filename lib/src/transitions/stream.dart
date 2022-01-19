import 'dart:async';

import '../callback.dart';
import '../transition.dart';

/// A transition that is triggered through a stream.
class StreamTransition<T> extends Transition {
  StreamTransition(this.provider, this.callback);

  /// The provider of a stream triggering this transition.
  final Provider<Stream<T>> provider;

  /// The callback to be evaluated when the stream triggers.
  final Callback1<T> callback;

  /// Current subscription
  StreamSubscription<T>? _subscription;

  @override
  void activate() {
    assert(_subscription == null, 'subscription must be null');
    _subscription = provider().listen(callback);
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    _subscription = null;
  }
}
