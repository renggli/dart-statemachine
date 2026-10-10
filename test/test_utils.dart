import 'package:checks/checks.dart';
import 'package:statemachine/statemachine.dart';

/// Extension on [Subject] of [TransitionEvent] providing domain-specific checks.
extension TransitionEventChecks<T> on Subject<TransitionEvent<T>> {
  /// Extracts the machine.
  Subject<Machine<T>> get machine => has((e) => e.machine, 'machine');

  /// Extracts the source state.
  Subject<State<T>?> get source => has((e) => e.source, 'source');

  /// Extracts the target state.
  Subject<State<T>?> get target => has((e) => e.target, 'target');
}

/// Extension on [Subject] of [BeforeTransitionEvent] providing domain-specific checks.
extension BeforeTransitionEventChecks<T> on Subject<BeforeTransitionEvent<T>> {
  /// Extracts whether the transition was aborted.
  Subject<bool> get isAborted => has((e) => e.isAborted, 'isAborted');

  /// Checks expected fields of a [BeforeTransitionEvent].
  void matchesBeforeTransition({
    required Machine<T> machine,
    State<T>? source,
    State<T>? target,
    bool isAborted = false,
  }) {
    this.machine.equals(machine);
    this.source.equals(source);
    this.target.equals(target);
    this.isAborted.equals(isAborted);
  }
}

/// Extension on [Subject] of [AfterTransitionEvent] providing domain-specific checks.
extension AfterTransitionEventChecks<T> on Subject<AfterTransitionEvent<T>> {
  /// Extracts errors list.
  Subject<List<Object>> get errors => has((e) => e.errors, 'errors');

  /// Checks expected fields of an [AfterTransitionEvent].
  void matchesAfterTransition({
    required Machine<T> machine,
    State<T>? source,
    State<T>? target,
    List<Object> errors = const [],
  }) {
    this.machine.equals(machine);
    this.source.equals(source);
    this.target.equals(target);
    this.errors.deepEquals(errors);
  }
}
