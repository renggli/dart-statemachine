import 'dart:async';

import 'package:meta/meta.dart';

import 'events.dart';
import 'state.dart';

/// A state machine manages a set of states and transitions between them.
///
/// To create a new state machine, instantiate it:
///
/// ```dart
/// final machine = Machine<String>();
/// ```
///
/// The type parameter [T] represents the identifier used to distinguish states.
/// This is typically an enum, a string, or a symbol.
@optionalTypeArgs
class Machine<T> {
  /// Constructs a new state machine.
  Machine();

  /// All the known states of this machine.
  final _states = <T, State<T>>{};

  /// The start state of this machine.
  State<T>? _start;

  /// The stop state of this machine.
  State<T>? _stop;

  /// The current state of this machine.
  State<T>? _current;

  /// Stream controller for events triggered before each transition.
  final StreamController<BeforeTransitionEvent<T>> _beforeTransitionController =
      StreamController.broadcast(sync: true);

  /// Stream controller for events triggered after each transition.
  final StreamController<AfterTransitionEvent<T>> _afterTransitionController =
      StreamController.broadcast(sync: true);

  /// Internal helper that can be overridden by subclasses to customize the
  /// creation of [State] objects.
  @protected
  State<T> createState(T identifier) => State<T>(this, identifier);

  /// Creates and returns a new state with the given [identifier].
  ///
  /// The first state created becomes the start state of the machine.
  ///
  /// ```dart
  /// final startState = machine.newState('start');
  /// final otherState = machine.newState('other');
  /// ```
  ///
  /// Throws an [ArgumentError] if a state with the same [identifier] already
  /// exists.
  State<T> newState(T identifier) {
    if (_states.containsKey(identifier)) {
      throw ArgumentError.value(
        identifier,
        'identifier',
        'Duplicated state identifier',
      );
    }
    final state = createState(identifier);
    _states[identifier] = state;
    _start ??= state;
    return state;
  }

  /// Creates and returns a new start state with the given [identifier].
  ///
  /// This explicitly sets the start state, separate from the order of creation.
  State<T> newStartState(T identifier) => _start = newState(identifier);

  /// Creates and returns a new stop state with the given [identifier].
  ///
  /// This state is entered when the machine is stopped.
  State<T> newStopState(T identifier) => _stop = newState(identifier);

  /// Returns the states of this machine.
  Iterable<State<T>> get states => _states.values;

  /// Returns the state of the provided identifier.
  State<T> operator [](T identifier) => _states.containsKey(identifier)
      ? _states[identifier]!
      : throw ArgumentError.value(
          identifier,
          'identifier',
          'Unknown identifier',
        );

  /// Returns an event stream that is triggered before each transition.
  Stream<BeforeTransitionEvent<T>> get onBeforeTransition =>
      _beforeTransitionController.stream;

  /// Returns an event stream that is triggered after each transition.
  Stream<AfterTransitionEvent<T>> get onAfterTransition =>
      _afterTransitionController.stream;

  /// Returns the currently active state of this machine, or `null` if not
  /// started.
  State<T>? get current => _current;

  /// Sets the currently active state to [state].
  ///
  /// The [state] can be a [State] object, a state identifier, or `null` to
  /// deactivate the current state.
  ///
  /// ```dart
  /// machine.current = startState;
  /// machine.current = 'active';
  /// ```
  ///
  /// Throws an [ArgumentError] if the state is unknown or belongs to a
  /// different machine.
  ///
  /// This setter triggers the following sequence:
  /// 1. A [BeforeTransitionEvent] is emitted. Listeners can abort the
  ///    transition.
  /// 2. The current state is deactivated (callbacks are executed).
  /// 3. The new state is set.
  /// 4. The new state is activated (callbacks are executed).
  /// 5. An [AfterTransitionEvent] is emitted.
  ///
  /// If any errors occur during deactivation or activation, they are collected
  /// and passed to the [AfterTransitionEvent]. If the errors are not handled
  /// by listeners, a [TransitionError] is thrown.
  set current(/*State<T>|T|Null*/ Object? state) {
    // Find and validate the target state.
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
    // Notify listeners about the upcoming transition. Check if any of the
    // listeners wish to abort the transition.
    final source = _current;
    if (_beforeTransitionController.hasListener) {
      final transitionEvent = BeforeTransitionEvent<T>(this, source, target);
      _beforeTransitionController.add(transitionEvent);
      if (transitionEvent.isAborted) {
        return;
      }
    }
    // Deactivate the source state.
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
    // Switch to the target state.
    _current = target;
    // Activate the target state.
    if (target != null) {
      for (final transition in target.transitions) {
        try {
          transition.activate();
        } catch (error) {
          errors.add(error);
        }
      }
    }
    // Notify listeners about the completed transition.
    if (_afterTransitionController.hasListener) {
      _afterTransitionController.add(
        AfterTransitionEvent<T>(this, source, target, errors),
      );
    }
    // Rethrow any remaining transition errors at the end.
    if (errors.isNotEmpty) {
      throw TransitionError<T>(this, source, target, errors);
    }
  }

  /// Starts the machine by setting the current state to the start state.
  void start() => current = _start;

  /// Stops the machine by setting the current state to the stop state.
  void stop() => current = _stop;

  /// Returns a debug string of this state.
  @override
  String toString() => 'Machine${current != null ? '[${current?.name}]' : ''}';
}
