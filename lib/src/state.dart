// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * State of the state machine.
 */
class State {

  final Machine _machine;
  final List<Transition> _transitions = new List();

  State._internal(this._machine);

  /**
   * Triggers the [callback] when [stream] triggers an event. The stream
   * must be a boradcast stream.
   */
  void on(Stream stream, void callback(event)) {
    assert(stream.isBroadcast);
    _transitions.add(new StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [milliseconds] ellapse.
   */
  void onTimeout(int milliseconds, void callback()) {
    assert(milliseconds > 0);
    _transitions.add(new TimeoutTransition(milliseconds, callback));
  }

  /**
   * Call this method to enter this state.
   */
  void enter() {
    _machine.current = this;
  }

}

