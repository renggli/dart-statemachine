import 'machine.dart';
import 'state.dart';

/// Transition event.
class TransitionEvent<T> {
  /// Constructs a transition event.
  TransitionEvent(this.machine, this.source, this.target,
      [this.errors = const []]);

  /// The state machine triggering this event.
  final Machine<T> machine;

  /// The source state of the transition.
  final State<T>? source;

  /// The target state of the transition.
  final State<T>? target;

  /// List of errors triggered during the transition.
  final List<Object> errors;
}

/// Transition error thrown at the end of a failing transition.
class TransitionError<T> extends TransitionEvent<T> implements Exception {
  /// Constructs a transition error.
  TransitionError(Machine<T> machine, State<T>? source, State<T>? target,
      List<Object> errors)
      : super(machine, source, target, errors);
}
