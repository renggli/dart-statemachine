part of statemachine;

/**
 * A transition that is triggered through a stream.
 */
class StreamTransition extends Transition {

  /** The stream triggering this transition. */
  final Stream stream;

  /** The callback to be evaluated when the stream triggers. */
  final Function callback;

  StreamSubscription _subscription;

  StreamTransition(this.stream, this.callback);

  @override
  void activate() {
    assert(_subscription == null);
    _subscription = stream.listen(this.callback);
  }

  @override
  void deactivate() {
    assert(_subscription != null);
    _subscription.cancel();
    _subscription = null;
  }

}
