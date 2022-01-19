import '../machine.dart';
import '../transition.dart';

/// A transition that triggers a nested state machine.
class NestedTransition<T> extends Transition {
  NestedTransition(this.machine);

  /// The nested state machine.
  final Machine<T> machine;

  @override
  void activate() => machine.start();

  @override
  void deactivate() => machine.stop();
}
