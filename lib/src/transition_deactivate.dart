part of statemachine;

/**
 * A transition that is triggered when the state deactivates.
 */
class DeactivateTransition extends Transition {

  /// The callback to be evaluated when the state deactivates.
  final Callback0 callback;

  DeactivateTransition(this.callback);

  @override
  void activate() => null;

  @override
  void deactivate() => callback();

}
