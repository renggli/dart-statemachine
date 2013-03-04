// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * State of the state machine.
 */
class State {

  final Machine _machine;
  final List<_Transition> _transitions = new List();

  State._internal(this._machine);

  /**
   * Triggers the [callback] when [stream] triggers an event.
   */
  void on(Stream stream, void callback(event)) {
    _transitions.add(new _StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [milliseconds] ellapse.
   */
  void onTimeout(int milliseconds, void callback()) {
    _transitions.add(new _TimeoutTransition(milliseconds, callback));
  }

  /**
   * Call this method to enter the state.
   */
  void enter() {
    _machine.current = this;
  }

}

