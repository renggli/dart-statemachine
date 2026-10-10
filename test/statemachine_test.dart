import 'dart:async';

import 'package:async/async.dart';
import 'package:checks/checks.dart';
import 'package:statemachine/statemachine.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  late Machine<int> machine;
  late State<int> state1, state2;
  setUp(() {
    machine = Machine<int>();
    state1 = machine.newState(1);
    state2 = machine.newState(2);
  });
  group('machine', () {
    test('start/stop state', () {
      final machine = Machine<String>();
      final startState = machine.newStartState('a');
      final stopState = machine.newStopState('b');
      check(machine.current).isNull();
      machine.start();
      check(machine.current).equals(startState);
      machine.stop();
      check(machine.current).equals(stopState);
    });
    test('duplicated definition', () {
      check(() => machine.newState(1)).throws<ArgumentError>();
      check(() => machine.newState(2)).throws<ArgumentError>();
    });
    test('enumerate states', () {
      check(machine.states).deepEquals([state1, state2]);
    });
    test('accessing states', () {
      check(machine[state1.identifier]).equals(state1);
      check(machine[state2.identifier]).equals(state2);
    });
    test('accessing unknown states', () {
      check(() => machine[3]).throws<ArgumentError>();
    });
    test('set state by state', () {
      machine.current = state1;
      check(machine.current).equals(state1);
      machine.current = state2;
      check(machine.current).equals(state2);
    });
    test('set state by unknown state', () {
      final otherMachine = Machine<int>();
      final otherState = otherMachine.newState(2);
      machine.current = state1;
      check(machine.current).equals(state1);
      check(() => machine.current = otherState).throws<ArgumentError>();
      check(machine.current).equals(state1);
    });
    test('set state by identifier', () {
      machine.current = state1.identifier;
      check(machine.current).equals(state1);
    });
    test('set state to by unknown identifier', () {
      machine.current = state1.identifier;
      check(() => machine.current = 3).throws<ArgumentError>();
      check(machine.current).equals(state1);
    });
    test('unset state', () {
      machine.current = state1;
      machine.current = null;
      check(machine.current).isNull();
    });
    test('states', () {
      check(machine.states).deepEquals([state1, state2]);
    });
    test('toString', () {
      check(machine.toString()).equals('Machine');
      machine.current = state1;
      check(machine.toString()).equals('Machine[1]');
    });
  });
  group('states', () {
    test('machine', () {
      check(state1.machine).equals(machine);
      check(state2.machine).equals(machine);
    });
    test('identifier', () {
      check(state1.identifier).equals(1);
      check(state2.identifier).equals(2);
    });
    test('name', () {
      check(state1.name).equals('1');
      check(state2.name).equals('2');
    });
    test('toString', () {
      check(state1.toString()).equals('State[1]');
      check(state2.toString()).equals('State[2]');
    });
  });
  group('transitions', () {
    test('future', () async {
      final log = <String>[];
      final machine = Machine<String>();
      final stateA = machine.newState('a');
      final stateB = machine.newState('b');
      final completerA = Completer<void>();
      final completerB = Completer<void>();
      var failed = false;
      stateA.onFuture<String>(
        Future.delayed(const Duration(milliseconds: 100), () => 'something'),
        (value) => failed = true,
      );
      stateA.onFuture<String>(
        Future.delayed(
          const Duration(milliseconds: 10),
          () => 'something else',
        ),
        (value) {
          check(log).isEmpty();
          check(value).equals('something else');
          check(machine.current).equals(stateA);
          log.add('a');
          stateB.enter();
          completerA.complete();
        },
      );
      stateB.onFuture<String>(
        Future.delayed(const Duration(milliseconds: 1), () => 'completer'),
        (value) {
          check(log).deepEquals(['a']);
          check(value).equals('completer');
          completerB.complete();
        },
      );
      machine.start();
      await completerA.future;
      await completerB.future;
      check(failed).isFalse();
    });
    group('stream transitions', () {
      late StreamController<String> controllerA, controllerB, controllerC;
      late Machine<String> machine;
      late State<String> stateA, stateB, stateC;
      setUp(() {
        controllerA = StreamController.broadcast(sync: true);
        controllerB = StreamController.broadcast(sync: true);
        controllerC = StreamController.broadcast(sync: true);
        machine = Machine<String>();
        stateA = machine.newState('a');
        stateB = machine.newState('b');
        stateC = machine.newState('c');
        stateA.onStream<String>(controllerB.stream, (event) => stateB.enter());
        stateA.onStream<String>(controllerC.stream, (event) => stateC.enter());
        stateB.onStream<String>(controllerA.stream, (event) => stateA.enter());
        stateB.onStream<String>(controllerC.stream, (event) => stateC.enter());
        stateC.onStream<String>(controllerA.stream, (event) => stateA.enter());
        stateC.onStream<String>(controllerB.stream, (event) => stateB.enter());
      });
      tearDown(() {
        controllerA.close();
        controllerB.close();
        controllerC.close();
      });
      test('initial state', () {
        machine.start();
        check(machine.current).equals(stateA);
      });
      test('simple transition', () {
        machine.start();
        controllerB.add('*');
        check(machine.current).equals(stateB);
      });
      test('double transition', () {
        machine.start();
        controllerB.add('*');
        controllerC.add('*');
        check(machine.current).equals(stateC);
      });
      test('triple transition', () {
        machine.start();
        controllerB.add('*');
        controllerC.add('*');
        controllerA.add('*');
        check(machine.current).equals(stateA);
      });
      test('many transitions', () {
        machine.start();
        for (var i = 0; i < 100; i++) {
          controllerB.add('*');
          controllerA.add('*');
        }
        check(machine.current).equals(stateA);
      });
    });
    test('timeout', () async {
      final machine = Machine<String>();
      final stateA = machine.newState('a');
      final stateB = machine.newState('b');
      final stateC = machine.newState('c');
      final completerB = Completer<void>();
      final completerC = Completer<void>();
      var failed = false;
      stateA.onTimeout(const Duration(milliseconds: 10), () {
        check(machine.current).equals(stateA);
        stateB.enter();
        completerB.complete();
      });
      stateA.onTimeout(const Duration(milliseconds: 20), () => failed = true);
      stateB.onTimeout(const Duration(milliseconds: 20), () => failed = true);
      stateB.onTimeout(const Duration(milliseconds: 10), () {
        check(machine.current).equals(stateB);
        stateC.enter();
        completerC.complete();
      });
      machine.start();
      await completerB.future;
      await completerC.future;
      check(failed).isFalse();
    });
    test('entry and exit', () {
      final log = <String>[];
      final machine = Machine<String>();
      final stateA = machine.newState('a')
        ..onEntry(() => log.add('on a'))
        ..onExit(() => log.add('off a'));
      final stateB = machine.newState('b')
        ..onEntry(() => log.add('on b'))
        ..onExit(() => log.add('off b'));
      machine.start();
      stateB.enter();
      check(log).deepEquals(['on a', 'off a', 'on b']);
      stateA.enter();
      check(log).deepEquals(['on a', 'off a', 'on b', 'off b', 'on a']);
    });
    test('nested machine', () {
      final log = <String>[];
      final inner = Machine<int>();
      inner.newState(1)
        ..onEntry(() => log.add('inner entry 1'))
        ..onExit(() => log.add('inner exit 1'));
      final outer = Machine<String>();
      outer.newState('a')
        ..onEntry(() => log.add('outer entry a'))
        ..onExit(() => log.add('outer exit a'))
        ..addNested(inner);
      outer.start();
      check(log).deepEquals(['outer entry a', 'inner entry 1']);
      outer.stop();
      check(log).deepEquals([
        'outer entry a',
        'inner entry 1',
        'outer exit a',
        'inner exit 1',
      ]);
    });
  });
  group('events', () {
    late Machine<Symbol> machine;
    late State<Symbol> start;
    late State<Symbol> other;
    late State<Symbol> entryError;
    late State<Symbol> exitError;
    late State<Symbol> entryAbort;
    late State<Symbol> exitAbort;
    setUp(() {
      machine = Machine<Symbol>();
      machine.onBeforeTransition.listen((event) {
        check(event.machine).equals(machine);
        check(event.source).equals(machine.current);
        check(event.isAborted).isFalse();
        if (event.target == entryAbort || event.source == exitAbort) {
          event.abort();
          check(event.isAborted).isTrue();
        }
      });
      machine.onAfterTransition.listen((event) {
        check(event.machine).equals(machine);
        check(event.target).equals(machine.current);
      });
      start = machine.newState(#start);
      other = machine.newState(#other);
      entryError = machine.newState(#entryError);
      entryError.onEntry(() => throw 'Entry 1');
      entryError.onEntry(() => throw 'Entry 2');
      exitError = machine.newState(#exitError);
      exitError.onExit(() => throw 'Exit 1');
      exitError.onExit(() => throw 'Exit 2');
      entryAbort = machine.newState(#entryAbort);
      exitAbort = machine.newState(#exitAbort);
      machine.start();
    });
    test('no errors', () async {
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      final afterQueue = StreamQueue(machine.onAfterTransition);
      machine.current = other;
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: start,
          target: other,
        ),
      );
      await check(afterQueue).emits(
        (it) => it.isA<AfterTransitionEvent<Symbol>>().matchesAfterTransition(
          machine: machine,
          source: start,
          target: other,
        ),
      );
      check(machine.current).equals(other);
      await beforeQueue.cancel();
      await afterQueue.cancel();
    });
    test('errors on entry', () async {
      machine.current = other;
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      final afterQueue = StreamQueue(machine.onAfterTransition);
      check(() => machine.current = entryError)
          .throws<TransitionError<Symbol>>()
          .matchesAfterTransition(
            machine: machine,
            source: other,
            target: entryError,
            errors: ['Entry 1', 'Entry 2'],
          );
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: other,
          target: entryError,
        ),
      );
      await check(afterQueue).emits(
        (it) => it.isA<AfterTransitionEvent<Symbol>>().matchesAfterTransition(
          machine: machine,
          source: other,
          target: entryError,
          errors: ['Entry 1', 'Entry 2'],
        ),
      );
      check(machine.current).equals(entryError);
      await beforeQueue.cancel();
      await afterQueue.cancel();
    });
    test('errors on exit', () async {
      machine.current = exitError;
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      final afterQueue = StreamQueue(machine.onAfterTransition);
      check(() => machine.current = other)
          .throws<TransitionError<Symbol>>()
          .matchesAfterTransition(
            machine: machine,
            source: exitError,
            target: other,
            errors: ['Exit 1', 'Exit 2'],
          );
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: exitError,
          target: other,
        ),
      );
      await check(afterQueue).emits(
        (it) => it.isA<AfterTransitionEvent<Symbol>>().matchesAfterTransition(
          machine: machine,
          source: exitError,
          target: other,
          errors: ['Exit 1', 'Exit 2'],
        ),
      );
      check(machine.current).equals(other);
      await beforeQueue.cancel();
      await afterQueue.cancel();
    });
    test('errors on entry and exit', () async {
      machine.current = exitError;
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      final afterQueue = StreamQueue(machine.onAfterTransition);
      check(() => machine.current = entryError)
          .throws<TransitionError<Symbol>>()
          .matchesAfterTransition(
            machine: machine,
            source: exitError,
            target: entryError,
            errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
          );
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: exitError,
          target: entryError,
        ),
      );
      await check(afterQueue).emits(
        (it) => it.isA<AfterTransitionEvent<Symbol>>().matchesAfterTransition(
          machine: machine,
          source: exitError,
          target: entryError,
          errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
        ),
      );
      check(machine.current).equals(entryError);
      await beforeQueue.cancel();
      await afterQueue.cancel();
    });
    test('clear all errors', () {
      machine.current = exitError;
      machine.onAfterTransition.listen((event) {
        check(event).matchesAfterTransition(
          machine: machine,
          source: exitError,
          target: entryError,
          errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
        );
        event.errors.clear();
      });
      machine.current = entryError;
      check(machine.current).equals(entryError);
    });
    test('abort on entry', () async {
      machine.current = other;
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      machine.current = entryAbort;
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: other,
          target: entryAbort,
          isAborted: true,
        ),
      );
      check(machine.current).equals(other);
      await beforeQueue.cancel();
    });
    test('abort on exit', () async {
      machine.current = exitAbort;
      final beforeQueue = StreamQueue(machine.onBeforeTransition);
      machine.current = other;
      await check(beforeQueue).emits(
        (it) => it.isA<BeforeTransitionEvent<Symbol>>().matchesBeforeTransition(
          machine: machine,
          source: exitAbort,
          target: other,
          isAborted: true,
        ),
      );
      check(machine.current).equals(exitAbort);
      await beforeQueue.cancel();
    });
  });
}
