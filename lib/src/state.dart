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
   * must be a broadcast stream.
   */
  void onStream(Stream stream, void callback(value)) {
    assert(stream.isBroadcast);
    _transitions.add(new StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [duration] elapses.
   */
  void onTimeout(Duration duration, void callback()) {
    _transitions.add(new TimeoutTransition(duration, callback));
  }

  /**
   * Call this method to enter this state.
   */
  void enter() {
    _machine.current = this;
  }

}

