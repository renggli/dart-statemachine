library statemachine.transition.exit;

import 'package:statemachine/src/callback.dart';
import 'package:statemachine/src/transition.dart';

/// A callback that is triggered when the state deactivates.
class ExitTransition extends Transition {
  /// The callback to be evaluated when the state deactivates.
  final Callback0 callback;

  ExitTransition(this.callback);

  @override
  void activate() {}

  @override
  void deactivate() => callback();
}
