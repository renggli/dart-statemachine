import 'dart:async';

import 'package:statemachine/statemachine.dart';
import 'package:test/test.dart';

TypeMatcher<BeforeTransitionEvent<T>> isBeforeTransitionEvent<T>({
  required Machine<T> machine,
  State<T>? source,
  State<T>? target,
  bool? isAborted = false,
}) => isA<BeforeTransitionEvent<T>>()
    .having((event) => event.machine, 'machine', machine)
    .having((event) => event.source, 'source', source)
    .having((event) => event.target, 'target', target)
    .having((event) => event.isAborted, 'isAborted', isAborted);

TypeMatcher<AfterTransitionEvent<T>> isAfterTransitionEvent<T>({
  required Machine<T> machine,
  State<T>? source,
  State<T>? target,
  List<Object> errors = const [],
}) => isA<AfterTransitionEvent<T>>()
    .having((event) => event.machine, 'machine', machine)
    .having((event) => event.source, 'source', source)
    .having((event) => event.target, 'target', target)
    .having((event) => event.errors, 'errors', errors);

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
      expect(machine.current, isNull);
      machine.start();
      expect(machine.current, startState);
      machine.stop();
      expect(machine.current, stopState);
    });
    test('duplicated definition', () {
      expect(() => machine.newState(1), throwsArgumentError);
      expect(() => machine.newState(2), throwsArgumentError);
    });
    test('enumerate states', () {
      expect(machine.states, [state1, state2]);
    });
    test('accessing states', () {
      expect(machine[state1.identifier], state1);
      expect(machine[state2.identifier], state2);
    });
    test('accessing unknown states', () {
      expect(() => machine[3], throwsArgumentError);
    });
    test('set state by state', () {
      machine.current = state1;
      expect(machine.current, state1);
      machine.current = state2;
      expect(machine.current, state2);
    });
    test('set state by unknown state', () {
      final otherMachine = Machine<int>();
      final otherState = otherMachine.newState(2);
      machine.current = state1;
      expect(machine.current, state1);
      expect(() => machine.current = otherState, throwsArgumentError);
      expect(machine.current, state1);
    });
    test('set state by identifier', () {
      machine.current = state1.identifier;
      expect(machine.current, state1);
    });
    test('set state to by unknown identifier', () {
      machine.current = state1.identifier;
      expect(() => machine.current = 3, throwsArgumentError);
      expect(machine.current, state1);
    });
    test('unset state', () {
      machine.current = state1;
      machine.current = null;
      expect(machine.current, isNull);
    });
    test('states', () {
      expect(machine.states, [state1, state2]);
    });
    test('toString', () {
      expect(machine.toString(), 'Machine');
      machine.current = state1;
      expect(machine.toString(), 'Machine[1]');
    });
  });
  group('states', () {
    test('machine', () {
      expect(state1.machine, machine);
      expect(state2.machine, machine);
    });
    test('identifier', () {
      expect(state1.identifier, 1);
      expect(state2.identifier, 2);
    });
    test('name', () {
      expect(state1.name, '1');
      expect(state2.name, '2');
    });
    test('toString', () {
      expect(state1.toString(), 'State[1]');
      expect(state2.toString(), 'State[2]');
    });
  });
  group('transitions', () {
    test('future', () {
      final log = <String>[];
      final machine = Machine<String>();
      final stateA = machine.newState('a');
      final stateB = machine.newState('b');
      stateA.onFuture<String>(
        Future.delayed(const Duration(milliseconds: 100), () => 'something'),
        (value) => fail('should never be called'),
      );
      stateA.onFuture<String>(
        Future.delayed(
          const Duration(milliseconds: 10),
          () => 'something else',
        ),
        expectAsync1<String, Object>((value) {
          expect(log, isEmpty);
          expect(value, 'something else');
          expect(machine.current, stateA);
          log.add('a');
          stateB.enter();
          return 'done';
        }),
      );
      stateB.onFuture<String>(
        Future.delayed(const Duration(milliseconds: 1), () => 'completer'),
        expectAsync1<String, Object>((value) {
          expect(log, ['a']);
          expect(value, 'completer');
          return 'done';
        }),
      );
      machine.start();
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
        expect(machine.current, stateA);
      });
      test('simple transition', () {
        machine.start();
        controllerB.add('*');
        expect(machine.current, stateB);
      });
      test('double transition', () {
        machine.start();
        controllerB.add('*');
        controllerC.add('*');
        expect(machine.current, stateC);
      });
      test('triple transition', () {
        machine.start();
        controllerB.add('*');
        controllerC.add('*');
        controllerA.add('*');
        expect(machine.current, stateA);
      });
      test('many transitions', () {
        machine.start();
        for (var i = 0; i < 100; i++) {
          controllerB.add('*');
          controllerA.add('*');
        }
        expect(machine.current, stateA);
      });
    });
    test('timeout', () {
      final machine = Machine<String>();
      final stateA = machine.newState('a');
      final stateB = machine.newState('b');
      final stateC = machine.newState('c');
      stateA.onTimeout(
        const Duration(milliseconds: 10),
        expectAsync0(() {
          expect(machine.current, stateA);
          stateB.enter();
        }),
      );
      stateA.onTimeout(
        const Duration(milliseconds: 20),
        () => fail('should never be called'),
      );
      stateB.onTimeout(
        const Duration(milliseconds: 20),
        () => fail('should never be called'),
      );
      stateB.onTimeout(
        const Duration(milliseconds: 10),
        expectAsync0(() {
          expect(machine.current, stateB);
          stateC.enter();
        }),
      );
      machine.start();
    });
    test('entry and exit', () {
      final log = <String>[];
      final machine = Machine<String>();
      final stateA =
          machine.newState('a')
            ..onEntry(() => log.add('on a'))
            ..onExit(() => log.add('off a'));
      final stateB =
          machine.newState('b')
            ..onEntry(() => log.add('on b'))
            ..onExit(() => log.add('off b'));
      machine.start();
      stateB.enter();
      expect(log, ['on a', 'off a', 'on b']);
      stateA.enter();
      expect(log, ['on a', 'off a', 'on b', 'off b', 'on a']);
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
      expect(log, ['outer entry a', 'inner entry 1']);
      outer.stop();
      expect(log, [
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
      machine.onBeforeTransition.forEach((event) {
        expect(event.machine, machine);
        expect(event.source, machine.current);
        expect(event.isAborted, isFalse);
        if (event.target == entryAbort || event.source == exitAbort) {
          event.abort();
          expect(event.isAborted, isTrue);
        }
      });
      machine.onAfterTransition.forEach((event) {
        expect(event.machine, machine);
        expect(event.target, machine.current);
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
    test('no errors', () {
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: start,
            target: other,
          ),
        ),
      );
      expectLater(
        machine.onAfterTransition,
        emits(
          isAfterTransitionEvent(
            machine: machine,
            source: start,
            target: other,
          ),
        ),
      );
      machine.current = other;
      expect(machine.current, other);
    });
    test('errors on entry', () {
      machine.current = other;
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: other,
            target: entryError,
          ),
        ),
      );
      expectLater(
        machine.onAfterTransition,
        emits(
          isAfterTransitionEvent(
            machine: machine,
            source: other,
            target: entryError,
            errors: ['Entry 1', 'Entry 2'],
          ),
        ),
      );
      expect(
        () => machine.current = entryError,
        throwsA(
          isAfterTransitionEvent(
            machine: machine,
            source: other,
            target: entryError,
            errors: ['Entry 1', 'Entry 2'],
          ),
        ),
      );
      expect(machine.current, entryError);
    });
    test('errors on exit', () {
      machine.current = exitError;
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: exitError,
            target: other,
          ),
        ),
      );
      expectLater(
        machine.onAfterTransition,
        emits(
          isAfterTransitionEvent(
            machine: machine,
            source: exitError,
            target: other,
            errors: ['Exit 1', 'Exit 2'],
          ),
        ),
      );
      expect(
        () => machine.current = other,
        throwsA(
          isAfterTransitionEvent(
            machine: machine,
            source: exitError,
            target: other,
            errors: ['Exit 1', 'Exit 2'],
          ),
        ),
      );
      expect(machine.current, other);
    });
    test('errors on entry and exit', () {
      machine.current = exitError;
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: exitError,
            target: entryError,
          ),
        ),
      );
      expectLater(
        machine.onAfterTransition,
        emits(
          isAfterTransitionEvent(
            machine: machine,
            source: exitError,
            target: entryError,
            errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
          ),
        ),
      );
      expect(
        () => machine.current = entryError,
        throwsA(
          isAfterTransitionEvent(
            machine: machine,
            source: exitError,
            target: entryError,
            errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
          ),
        ),
      );
      expect(machine.current, entryError);
    });
    test('clear all errors', () {
      machine.current = exitError;
      machine.onAfterTransition.forEach((event) {
        expect(
          event,
          isAfterTransitionEvent(
            machine: machine,
            source: exitError,
            target: entryError,
            errors: ['Exit 1', 'Exit 2', 'Entry 1', 'Entry 2'],
          ),
        );
        event.errors.clear();
      });
      machine.current = entryError;
      expect(machine.current, entryError);
    });
    test('abort on entry', () {
      machine.current = other;
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: other,
            target: entryAbort,
            isAborted: true,
          ),
        ),
      );
      machine.current = entryAbort;
      expect(machine.current, other);
    });
    test('abort on exit', () {
      machine.current = exitAbort;
      expectLater(
        machine.onBeforeTransition,
        emits(
          isBeforeTransitionEvent(
            machine: machine,
            source: exitAbort,
            target: other,
            isAborted: true,
          ),
        ),
      );
      machine.current = other;
      expect(machine.current, exitAbort);
    });
  });
}
