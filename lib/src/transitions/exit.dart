import '../callback.dart';
import '../transition.dart';

/// A callback that is triggered when the state deactivates.
class ExitTransition extends Transition {
  ExitTransition(this.callback);

  /// The callback to be evaluated when the state deactivates.
  final Callback0 callback;

  @override
  void deactivate() => callback();
}
