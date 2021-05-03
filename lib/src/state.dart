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

/// State of the state machine.
class State<T> {
  /// The state machine holding this state.
  final Machine machine;

  /// Object identifying this state.
  final T identifier;

  /// The list of transitions of this state.
  final List<Transition> transitions = [];

  /// Constructs a new state with an identifier.
  State(this.machine, this.identifier);

  /// A human readable name of the state.
  String get name => identifier.toString();

  /// Adds a new [transition] to this state.
  void addTransition(Transition transition) => transitions.add(transition);

  /// Triggers the [callback] when the state is entered.
  void onEntry(Callback0 callback) => addTransition(EntryTransition(callback));

  /// Triggers the [callback] when the state is left.
  void onExit(Callback0 callback) => addTransition(ExitTransition(callback));

  /// Triggers the [callback] when [stream] triggers an event.
  void onStream<S>(Stream<S> stream, Callback1<S> callback) =>
      onStreamProvider<S>(() => stream, callback);

  /// Triggers the [callback] when the [Stream] provided by [provider] triggers
  /// an event.
  void onStreamProvider<S>(
          Provider<Stream<S>> provider, Callback1<S> callback) =>
      addTransition(StreamTransition<S>(provider, callback));

  /// Triggers the [callback] when a [future] yields a value.
  void onFuture<S>(Future<S> future, Callback1<S> callback) =>
      onFutureProvider<S>(() => future, callback);

  /// Triggers the [callback] when the [Future] provided by [provider] yields a
  /// value.
  void onFutureProvider<S>(
          Provider<Future<S>> provider, Callback1<S> callback) =>
      addTransition(FutureTransition<S>(provider, callback));

  /// Triggers the [callback] when [duration] elapses.
  void onTimeout(Duration duration, Callback0 callback) =>
      addTransition(TimeoutTransition(duration, callback));

  /// Adds a nested [machine] that gets started when this state is entered, and
  /// stopped when this state is left.
  void addNested<S>(Machine<S> machine) =>
      addTransition(NestedTransition<S>(machine));

  /// Call this method to enter this state.
  void enter() => machine.current = this;

  /// Returns a debug string of this state.
  @override
  String toString() => 'State[$identifier]';
}
