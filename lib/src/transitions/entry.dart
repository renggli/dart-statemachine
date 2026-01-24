import '../callback.dart';
import '../transition.dart';

/// A transition that triggers a callback when the state is entered.
class EntryTransition extends Transition {
  EntryTransition(this.callback);

  /// The callback to be evaluated when the state activates.
  final Callback0 callback;

  @override
  void activate() => callback();
}
