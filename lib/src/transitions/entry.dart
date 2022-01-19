import '../callback.dart';
import '../transition.dart';

/// A callback that is triggered when the state activates.
class EntryTransition extends Transition {
  EntryTransition(this.callback);

  /// The callback to be evaluated when the state activates.
  final Callback0 callback;

  @override
  void activate() => callback();
}
