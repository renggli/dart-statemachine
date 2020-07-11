library statemachine.state;

import 'dart:async';

import 'callback.dart';
import 'machine.dart';
import 'transition.dart';
import 'transition_entry.dart';
import 'transition_exit.dart';
import 'transition_future.dart';
import 'transition_nested.dart';
import 'transition_stream.dart';
import 'transition_timeout.dart';

/// State of the state machine.
class State {
  /// The state machine holding this state.
  final Machine machine;

  /// A human readable name of the state.
  final String name;

  /// The list of transitions of this state.
  final List<Transition> transitions = [];

  /// Constructs a new state with an optional name.
  State(this.machine, [this.name]) {
    if (machine == null) {
      throw ArgumentError('States must be associated with a machine.');
    }
  }

  /// Adds a new [transition] to this state.
  void addTransition(Transition transition) {
    transitions.add(transition);
  }

  /// Triggers the [callback] when the state is entered.
  void onEntry(Callback0 callback) {
    addTransition(EntryTransition(callback));
  }

  /// Triggers the [callback] when the state is left.
  void onExit(Callback0 callback) {
    addTransition(ExitTransition(callback));
  }

  /// Triggers the [callback] when [stream] triggers an event. The stream
  /// must be a broadcast stream.
  void onStream<T>(Stream<T> stream, Callback1<T> callback) {
    addTransition(StreamTransition<T>(stream, callback));
  }

  /// Triggers the [callback] when [future] provides a value.
  void onFuture<T>(Future<T> future, Callback1<T> callback) {
    addTransition(FutureTransition(future, callback));
  }

  /// Triggers the [callback] when [duration] elapses.
  void onTimeout(Duration duration, Callback0 callback) {
    addTransition(TimeoutTransition(duration, callback));
  }

  /// Adds a nested [machine] that gets started when this state is entered, and
  /// stopped when this state is left.
  void addNested(Machine machine) {
    addTransition(NestedTransition(machine));
  }

  /// Call this method to enter this state.
  void enter() {
    machine.current = this;
  }

  /// Returns a debug string of this state.
  @override
  String toString() => name == null ? super.toString() : 'State[$name]';
}
