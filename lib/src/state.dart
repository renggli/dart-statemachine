import 'dart:async';

import 'callback.dart';
import 'machine.dart';
import 'transition.dart';
import 'transitions/entry.dart';
import 'transitions/exit.dart';
import 'transitions/future.dart';
import 'transitions/nested.dart';
import 'transitions/stream.dart';
import 'transitions/timeout.dart';

/// A state within the [Machine].
///
/// States are the building blocks of the state machine. They hold transitions
/// to other states and execute callbacks when entered or left.
class State<T> {
  /// Constructs a new state with an identifier.
  State(this.machine, this.identifier);

  /// The state machine holding this state.
  final Machine machine;

  /// Object identifying this state.
  final T identifier;

  /// The list of transitions of this state.
  final transitions = <Transition>[];

  /// A human readable name of the state.
  String get name => identifier.toString();

  /// Adds a new [transition] to this state.
  void addTransition(Transition transition) => transitions.add(transition);

  /// Triggers the [callback] when the state is entered.
  ///
  /// ```dart
  /// state.onEntry(() => print('State entered'));
  /// ```
  void onEntry(Callback0 callback) => addTransition(EntryTransition(callback));

  /// Triggers the [callback] when the state is left.
  ///
  /// ```dart
  /// state.onExit(() => print('State left'));
  /// ```
  void onExit(Callback0 callback) => addTransition(ExitTransition(callback));

  /// Triggers the [callback] when [stream] emits an event.
  ///
  /// The stream must be a broadcast stream if it's shared among multiple
  /// states.
  ///
  /// ```dart
  /// state.onStream(controller.stream, (value) => print('Received $value'));
  /// ```
  void onStream<S>(Stream<S> stream, Callback1<S> callback) =>
      onStreamProvider<S>(() => stream, callback);

  /// Triggers the [callback] when the [Stream] provided by [provider] emits
  /// an event.
  ///
  /// Useful when the stream is not available at the time of state creation.
  void onStreamProvider<S>(
    Provider<Stream<S>> provider,
    Callback1<S> callback,
  ) => addTransition(StreamTransition<S>(provider, callback));

  /// Triggers the [callback] when [future] completes with a value.
  ///
  /// ```dart
  /// state.onFuture(future, (value) => print('Future completed with $value'));
  /// ```
  void onFuture<S>(Future<S> future, Callback1<S> callback) =>
      onFutureProvider<S>(() => future, callback);

  /// Triggers the [callback] when the [Future] provided by [provider] completes
  /// with a value.
  ///
  /// Useful when the future is not available at the time of state creation.
  void onFutureProvider<S>(
    Provider<Future<S>> provider,
    Callback1<S> callback,
  ) => addTransition(FutureTransition<S>(provider, callback));

  /// Triggers the [callback] when [duration] has elapsed.
  ///
  /// ```dart
  /// state.onTimeout(const Duration(seconds: 1), () => nextState.enter());
  /// ```
  void onTimeout(Duration duration, Callback0 callback) =>
      addTransition(TimeoutTransition(duration, callback));

  /// Adds a nested [machine] that gets started when this state is entered, and
  /// stopped when this state is left.
  ///
  /// ```dart
  /// state.addNested(nestedMachine);
  /// ```
  void addNested<S>(Machine<S> machine) =>
      addTransition(NestedTransition<S>(machine));

  /// Call this method to enter this state.
  void enter() => machine.current = this;

  /// Returns a debug string of this state.
  @override
  String toString() => 'State[$name]';
}
