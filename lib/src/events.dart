import 'machine.dart';
import 'state.dart';

/// Base class for all transition events.
///
/// Describes a transition from a [source] state to a [target] state within a
/// [machine].
abstract class TransitionEvent<T> {
  /// Constructs a transition event.
  const TransitionEvent(this.machine, this.source, this.target);

  /// The state machine triggering this event.
  final Machine<T> machine;

  /// The source state of the transition.
  final State<T>? source;

  /// The target state of the transition.
  final State<T>? target;
}

/// An event emitted before a transition starts.
///
/// This event allows listeners to observe and strictly control state changes.
/// Calling [abort] will prevent the transition from happening.
class BeforeTransitionEvent<T> extends TransitionEvent<T> {
  BeforeTransitionEvent(super.machine, super.source, super.target);

  bool _aborted = false;

  /// Returns true, if the transition was aborted.
  bool get isAborted => _aborted;

  /// Marks the transition as aborted.
  void abort() => _aborted = true;
}

/// An event emitted after a transition has completed.
///
/// This event contains information about the completed transition, including
/// any [errors] that occurred during the process.
class AfterTransitionEvent<T> extends TransitionEvent<T> {
  /// Constructs an after transition event.
  const AfterTransitionEvent(
    super.machine,
    super.source,
    super.target,
    this.errors,
  );

  /// List of errors triggered during the transition. Can be modified to prevent
  /// a [TransitionError] from being thrown at the end of the transition.
  final List<Object> errors;
}

/// An error thrown when a transition fails.
///
/// This exception aggregates one or more [errors] that occurred during the
/// entry or exit phases of a transition.
class TransitionError<T> extends AfterTransitionEvent<T> implements Exception {
  /// Constructs a transition error.
  const TransitionError(
    super.machine,
    super.source,
    super.target,
    super.errors,
  );
}
