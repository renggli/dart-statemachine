part of statemachine;

/**
 * State of the state machine.
 */
class State {

  /** The state machine holding this state. */
  final Machine machine;

  /** A human readable name of the state. */
  final String name;

  /** The list of outgoing transitions from this state. */
  final List<Transition> transitions = new List();

  State._internal(this.machine, this.name);

  /**
   * Triggers the [callback] when [stream] triggers an event. The stream
   * must be a broadcast stream.
   */
  void onStream(Stream stream, void callback(value)) {
    transitions.add(new StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [future] provides a value.
   */
  void onFuture(Future future, void callback(value)) {
    transitions.add(new FutureTransition(future, callback));
  }

  /**
   * Triggers the [callback] when [duration] elapses.
   */
  void onTimeout(Duration duration, void callback()) {
    transitions.add(new TimeoutTransition(duration, callback));
  }

  /**
   * Call this method to enter this state.
   */
  void enter() {
    machine.current = this;
  }

  /**
   * Returns a debug string of this state.
   */
  String toString() => name == null ? super.toString() : 'State[$name]';

}

