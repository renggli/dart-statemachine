import 'package:meta/meta.dart';

import 'state.dart';
import 'transition_error.dart';

/// The state machine itself.
@optionalTypeArgs
class Machine<T> {
  /// All the known states of this machine.
  final Map<T, State<T>> _states = {};

  /// The start state of this machine.
  State<T>? _start;

  /// The stop state of this machine.
  State<T>? _stop;

  /// The current state of this machine.
  State<T>? _current;

  /// Constructor of a state machine.
  Machine();

  /// Returns a new state. The first call to this method defines the start state
  /// of the machine. To identify states a unique identifier has to be provided.
  State<T> newState(T identifier) {
    if (_states.containsKey(identifier)) {
      throw ArgumentError.value(
          identifier, 'identifier', 'Duplicated state identifier');
    }
    final state = State<T>(this, identifier);
    _states[identifier] = state;
    _start ??= state;
    return state;
  }

  /// Returns a new start state for this machine.
  State<T> newStartState(T identifier) => _start = newState(identifier);

  /// Returns a new stop state for this machine.
  State<T> newStopState(T identifier) => _stop = newState(identifier);

  /// Returns the states of this machine.
  Iterable<State<T>> get states => _states.values;

  /// Returns the state of the provided identifier.
  State<T> operator [](T identifier) => _states.containsKey(identifier)
      ? _states[identifier]!
      : throw ArgumentError.value(
          identifier, 'identifier', 'Unknown identifier');

  /// Returns the current state of this machine, or `null`.
  State? get current => _current;

  /// Sets this machine to the given [state], either specified with a [State]
  /// object, one of its identifiers, or `null` to remove the active state.
  ///
  /// Throws an [ArgumentError], if the state is unknown or from a different
  /// [Machine]. Errors happening during the transition are collected and
  /// a [TransitionError] is thrown in case of a problem.
  set current(/*State<T>|T|Null*/ Object? state) {
    // Figure out and validate the target state:
    final target = state is State<T>
        ? state
        : state is T
            ? this[state]
            : state == null
                ? null
                : throw ArgumentError.value(state, 'state', 'Invalid state');
    if (target != null && target.machine != this) {
      throw ArgumentError.value(state, 'state', 'Invalid machine');
    }
    // We are in a good state, perform the transition no matter what happens:
    final source = _current;
    final errors = <Object>[];
    if (source != null) {
      for (final transition in source.transitions) {
        try {
          transition.deactivate();
        } catch (error) {
          errors.add(error);
        }
      }
    }
    _current = target;
    if (target != null) {
      for (final transition in target.transitions) {
        try {
          transition.activate();
        } catch (error) {
          errors.add(error);
        }
      }
    }
    // Rethrow all errors, if we encountered some during the transition:
    if (errors.isNotEmpty) {
      throw TransitionError(errors);
    }
  }

  /// Sets the machine to its start state.
  void start() => current = _start;

  /// Sets the machine to its stop state.
  void stop() => current = _stop;

  /// Returns a debug string of this state.
  @override
  String toString() => '${super.toString()}[$current]';
}
