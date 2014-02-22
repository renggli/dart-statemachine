part of statemachine;

/**
 * State of the state machine.
 */
class State {

  final Machine _machine;
  final String _name;
  final List<Transition> _transitions = new List();

  State._internal(this._machine, this._name);

  /**
   * Triggers the [callback] when [stream] triggers an event. The stream
   * must be a broadcast stream.
   */
  void onStream(Stream stream, void callback(value)) {
    _transitions.add(new StreamTransition(stream, callback));
  }

  /**
   * Triggers the [callback] when [future] provides a value.
   */
  void onFuture(Future future, void callback(value)) {
    _transitions.add(new FutureTransition(future, callback));
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

  /**
   * Returns a debug string of this state.
   */
  String toString() => _name == null ? super.toString() : 'State[$_name]';

}

