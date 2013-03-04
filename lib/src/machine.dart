// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

class Machine {

  State _initial;
  State _current;

  /**
   * Constructor of a state machine.
   */
  Machine();

  /**
   * Returns a new state.
   */
  State newState() {
    var state = new State._internal(this);
    if (_initial == null) _initial = state;
    return state;
  }

  /**
   * Sets the current state of this machine to the initial one.
   */
  void reset() {
    assert(_initial != null);
    current = _initial;
  }

  /**
   * Returns the current state of this machine.
   */
  State get current => _current;

  /**
   * Updates this machie to the given [state].
   */
  set current(State state) {
    if (_current != null) {
      _current._transitions.forEach((each) => each.deactivate());
    }
    _current = state;
    _current._transitions.forEach((each) => each.activate());
  }

}