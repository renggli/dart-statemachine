part of statemachine;

/**
 * A transition that is triggered when the state activates.
 */
class ActivateTransition extends Transition {

  /// The callback to be evaluated when the state triggers.
  final Callback0 callback;

  ActivateTransition(this.callback);

  @override
  void activate() => callback();

  @override
  void deactivate() => null;

}
