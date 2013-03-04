// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

abstract class _Transition {
  void activate();
  void deactivate();
}

class _StreamTransition extends _Transition {

  final Stream _stream;
  final Function _callback;
  StreamSubscription _subscription;

  _StreamTransition(this._stream, this._callback);

  void activate() {
    _subscription = _stream.listen(this._callback);
  }

  void deactivate() {
    _subscription.cancel();
    _subscription = null;
  }

}

class _TimeoutTransition extends _Transition {

  final int _milliseconds;
  final Function _callback;
  Timer _timer;

  _TimeoutTransition(this._milliseconds, this._callback);

  void activate() {
    _timer = new Timer(_milliseconds, (Timer timer) => _callback());
  }

  void deactivate() {
    _timer.cancel();
    _timer = null;
  }

}