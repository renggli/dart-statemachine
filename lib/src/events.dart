import 'machine.dart';
import 'state.dart';

/// Transition event.
abstract class TransitionEvent<T> {
  /// Constructs a transition event.
  TransitionEvent(this.machine, this.source, this.target);

  /// The state machine triggering this event.
  final Machine<T> machine;

  /// The source state of the transition.
  final State<T>? source;

  /// The target state of the transition.
  final State<T>? target;
}

/// Transition event emitted before a transition starts, can be aborted.
class BeforeTransitionEvent<T> extends TransitionEvent<T> {
  BeforeTransitionEvent(super.machine, super.source, super.target);

  bool _aborted = false;

  /// Returns true, if the transition was aborted.
  bool get isAborted => _aborted;

  /// Marks the transition as aborted.
  void abort() => _aborted = true;
}

/// Transition event emitted after a transition completed.
class AfterTransitionEvent<T> extends TransitionEvent<T> {
  AfterTransitionEvent(super.machine, super.source, super.target, this.errors);

  /// List of errors triggered during the transition. Can be modified to prevent
  /// a [TransitionError] from being thrown at the end of the transition.
  final List<Object> errors;
}

/// Transition error thrown at the end of a failing transition.
class TransitionError<T> extends AfterTransitionEvent<T> implements Exception {
  /// Constructs a transition error.
  TransitionError(super.machine, super.source, super.target, super.errors);
}
