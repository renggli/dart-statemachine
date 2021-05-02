import '../machine.dart';
import '../transition.dart';

/// A transition that triggers a nested state machine.
class NestedTransition<T> extends Transition {
  /// The nested state machine.
  final Machine<T> machine;

  NestedTransition(this.machine);

  @override
  void activate() => machine.start();

  @override
  void deactivate() => machine.stop();
}
