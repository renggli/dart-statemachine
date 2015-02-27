part of statemachine;

/**
 * State of the state machine.
 */
class State {

  /// The state machine holding this state.
  final Machine machine;

  /// A human readable name of the state.
  final String name;

  /// The list of outgoing transitions from this state.
  final List<Transition> transitions = new List();

  State._internal(this.machine, this.name);

  /**
   * Triggers the [callback] when the state enters.
   */
  void onActivate(Callback0 callback) {
    transitions.add(new ActivateTransition(callback));
  }

  /**
   * Triggers the [callback] when the state leaves.
   */
  void onDeactivate(Callback0 callback) {
    transitions.add(new DeactivateTransition(callback));
  }

  /**
   * Triggers the [callback] when [stream] triggers an event. The stream
   * must be a broadcast stream.
   */
  void onStream(Stream stream, Callback1 callback) {
    transitions.add(new StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [future] provides a value.
   */
  void onFuture(Future future, Callback1 callback) {
    transitions.add(new FutureTransition(future, callback));
  }

  /**
   * Triggers the [callback] when [duration] elapses.
   */
  void onTimeout(Duration duration, Callback0 callback) {
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

