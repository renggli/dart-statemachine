part of statemachine;

/// A callback that is triggered when the state deactivates.
class ExitTransition extends Transition {

  /// The callback to be evaluated when the state deactivates.
  final Callback0 callback;

  ExitTransition(this.callback);

  @override
  void activate() => null;

  @override
  void deactivate() => callback();

}
