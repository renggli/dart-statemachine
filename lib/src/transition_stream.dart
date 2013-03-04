// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A transition that is triggered through a stream.
 */
class StreamTransition extends Transition {

  final Stream _stream;
  final Function _callback;
  StreamSubscription _subscription;

  StreamTransition(this._stream, this._callback);

  void activate() {
    assert(_subscription == null);
    _subscription = _stream.listen(this._callback);
  }

  void deactivate() {
    assert(_subscription != null);
    _subscription.cancel();
    _subscription = null;
  }

}