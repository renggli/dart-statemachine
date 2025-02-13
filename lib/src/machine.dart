import 'dart:async';

import 'package:meta/meta.dart';

import 'events.dart';
import 'state.dart';

/// The state machine itself.
@optionalTypeArgs
class Machine<T> {
  /// Constructor of a state machine.
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

  /// Returns a new state. The first call to this method defines the start state
  /// of the machine. To identify states a unique [identifier] has to be provided.
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

  /// Returns a new start state for this machine.
  State<T> newStartState(T identifier) => _start = newState(identifier);

  /// Returns a new stop state for this machine.
  State<T> newStopState(T identifier) => _stop = newState(identifier);

  /// Returns the states of this machine.
  Iterable<State<T>> get states => _states.values;

  /// Returns the state of the provided identifier.
  State<T> operator [](T identifier) =>
      _states.containsKey(identifier)
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

  /// Returns the current state of this machine, or `null`.
  State<T>? get current => _current;

  /// Sets this machine to the given [state], either specified with a [State]
  /// object, one of its identifiers, or `null` to remove the active state.
  ///
  /// Throws an [ArgumentError], if the state is unknown or from a different
  /// [Machine].
  ///
  /// Triggers a [BeforeTransitionEvent] event before the transition starts.
  /// This gives listeners the opportunity to observe the transitions and
  /// possibly abort before it starts.
  ///
  /// Triggers a [AfterTransitionEvent] event after the transition completes.
  /// Errors during the transition phase are collected and included in the
  /// event. Handlers can inspect and clear the errors. If any errors remain,
  /// a single [TransitionError] is rethrown at the end of the state change.
  set current(/*State<T>|T|Null*/ Object? state) {
    // Find and validate the target state.
    final target =
        state is State<T>
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

  /// Sets the machine to its start state.
  void start() => current = _start;

  /// Sets the machine to its stop state.
  void stop() => current = _stop;

  /// Returns a debug string of this state.
  @override
  String toString() => 'Machine${current != null ? '[${current?.name}]' : ''}';
}
