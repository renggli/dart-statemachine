/// An error thrown when one or more errors happen during a transition.
class TransitionError extends Error {
  /// The errors that happened during the transition.
  final List<Object> errors;

  /// Constructor of a transition error.
  TransitionError(this.errors);
}
