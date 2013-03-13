// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A state machine.
 *
 * To create a new state machine instantiate this class:
 *
 *     var machine = new Machine();
 *
 * To create states call [Machine#newState()] and store them in variables:
 *
 *     var inactive = machine.newState();
 *     var active = machine.newState();
 *
 * To reset a state machine to its initial state call [Machine#reset()]:
 *
 *     machine.reset();
 *
 * To enter a specific state call [State#enter()].
 *
 *     inactive.enter();
 *
 * You can define transitions between states that are triggered by events of
 * any kind. The example below registers for click events when the inactive
 * state is entered. In case of a click event the callback is executed and the
 * state machine transitions into the active state:
 *
 *     inactive.on(element.onClick, (event) => active.enter());
 *
 * Also you can automatically trigger callbacks after a timeout. The following
 * snippet calls the callback 1 second after the active state is entered and
 * falls back to the inactive state:
 *
 *     active.onTimeout(const Duration({seconds: 1}), () => inactive.enter());
 *
 * Callbacks often contain code to check for additional constraints and update
 * other objects or UI element before entering a different state. See the
 * tooltip infrastructure in the example directory for a more complete
 * illustration of the functionality provided by this library.
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
   * the initial state of the machine.
   */
  State newState() {
    var state = new State._internal(this);
    if (_initial == null) _initial = state;
    return state;
  }

  /**
   * Resets the state machine to its initial state and starts it.
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
   * Updates this machine to the given [state].
   */
  set current(State state) {
    assert(state != null);
    if (_current != null) {
      _current._transitions.forEach((each) => each.deactivate());
    }
    _current = state;
    _current._transitions.forEach((each) => each.activate());
  }

}