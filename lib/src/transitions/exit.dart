import '../callback.dart';
import '../transition.dart';

/// A transition that triggers a callback when the state is left.
class ExitTransition extends Transition {
  ExitTransition(this.callback);

  /// The callback to be evaluated when the state deactivates.
  final Callback0 callback;

  @override
  void deactivate() => callback();
}
