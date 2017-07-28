library statemachine.machine;

import 'package:statemachine/src/state.dart';

/// The state machine itself.
class Machine {
  /// The start state of this machine.
  State _start;

  /// The stop state of this machine.
  State _stop;

  /// The current state of this machine.
  State _current;

  /// Constructor of a state machine.
  Machine();

  /// Returns a new state. The first call to this method defines the start state
  /// of the machine. For debugging purposes an optional [name] can be provided.
  State newState([String name]) {
    var state = new State(this, name);
    _start ??= state;
    return state;
  }

  /// Returns a new start state for this machine.
  State newStartState([String name]) => _start = newState(name);

  /// Returns a new stop state for this machine.
  State newStopState([String name]) => _stop = newState(name);

  /// Returns the current state of this machine.
  State get current => _current;

  /// Sets this machine to the given [state].
  set current(State state) {
    if (_current != null) {
      for (var transition in _current.transitions) {
        transition.deactivate();
      }
    }
    _current = state;
    if (_current != null) {
      for (var transition in _current.transitions) {
        transition.activate();
      }
    }
  }

  /// Sets the machine to its start state.
  void start() {
    current = _start;
  }

  /// Sets the machine to its stop state.
  void stop() {
    current = _stop;
  }

  /// Returns a debug string of this state.
  @override
  String toString() => '${super.toString()}[$current]';
}
