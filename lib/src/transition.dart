/// A transition defines the behavior when a state is active.
abstract class Transition {
  /// Called when the source state is activated.
  void activate() {}

  /// Called when the source state is deactivated.
  void deactivate() {}
}
