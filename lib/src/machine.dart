part of statemachine;

/**
 * The state machine itself.
 */
class Machine {

  /** The initial state of this machine. */
  State _initial;

  /** The current state of this machine. */
  State _current;

  /**
   * Constructor of a state machine.
   */
  Machine();

  /**
   * Returns a new state. The first call to this method defines
   * the initial state of the machine. For debugging purposes an
   * optional [name] can be provided.
   */
  State newState([String name]) {
    var state = new State._internal(this, name);
    if (_initial == null) {
      _initial = state;
    }
    return state;
  }

  /**
   * Resets the state machine to its initial state.
   */
  void reset() {
    assert(_initial != null);
    current = _initial;
  }

  /**
   * Returns the current state of this machine (for testing only).
   */
  State get current => _current;

  /**
   * Updates this machine to the given [state].
   */
  set current(State state) {
    assert(state != null);
    if (_current != null) {
      _current.transitions.forEach((each) => each.deactivate());
    }
    _current = state;
    _current.transitions.forEach((each) => each.activate());
  }

}
