import 'dart:async';

import 'package:statemachine/statemachine.dart';
import 'package:test/test.dart';

void main() {
  group('states', () {
    late Machine<int> machine;
    late State<int> state1, state2;
    setUp(() {
      machine = Machine<int>();
      state1 = machine.newState(1);
      state2 = machine.newState(2);
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
  });
  group('stream transitions', () {
    late StreamController<String> controllerA, controllerB, controllerC;
    late Machine<String> machine;
    late State stateA, stateB, stateC;

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

    test('string', () {
      expect(machine.toString(), 'Instance of \'Machine<String>\'[null]');
      machine.start();
      expect(machine.toString(), 'Instance of \'Machine<String>\'[State[a]]');
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
    test('name', () {
      expect(stateA.toString(), 'State[a]');
      expect(stateB.toString(), 'State[b]');
      expect(stateC.toString(), 'State[c]');
    });
  });
  test('conflicting transitions', () {
    final controller = StreamController<String>.broadcast(sync: true);

    try {
      final machine = Machine<String>();

      final stateA = machine.newState('a');
      final stateB = machine.newState('b');
      final stateC = machine.newState('c');

      stateA.onStream<String>(controller.stream, (value) => stateB.enter());
      stateA.onStream<String>(controller.stream, (value) => stateC.enter());

      machine.start();
      controller.add('*');
      expect(machine.current, stateB);
    } finally {
      controller.close();
    }
  });
  test('future transitions', () {
    final machine = Machine<String>();
    final log = <String>[];

    final stateA = machine.newState('a');
    final stateB = machine.newState('b');

    stateA.onFuture<String>(
        Future.delayed(
          const Duration(milliseconds: 100),
          () => 'something',
        ),
        (value) => fail('should never be called'));
    stateA.onFuture<String>(
        Future.delayed(
          const Duration(milliseconds: 10),
          () => 'something else',
        ), expectAsync1<String, Object>((value) {
      expect(log, isEmpty);
      expect(value, 'something else');
      expect(machine.current, stateA);
      log.add('a');
      stateB.enter();
      return 'done';
    }));
    stateB.onFuture<String>(
        Future.delayed(
          const Duration(milliseconds: 1),
          () => 'completer',
        ), expectAsync1<String, Object>((value) {
      expect(log, ['a']);
      expect(value, 'completer');
      return 'done';
    }));

    machine.start();
  });
  test('timeout transitions', () {
    final machine = Machine<String>();

    final stateA = machine.newState('a');
    final stateB = machine.newState('b');
    final stateC = machine.newState('c');

    stateA.onTimeout(const Duration(milliseconds: 10), expectAsync0(() {
      expect(machine.current, stateA);
      stateB.enter();
    }));
    stateA.onTimeout(
        const Duration(milliseconds: 20), () => fail('should never be called'));
    stateB.onTimeout(
        const Duration(milliseconds: 20), () => fail('should never be called'));
    stateB.onTimeout(const Duration(milliseconds: 10), expectAsync0(() {
      expect(machine.current, stateB);
      stateC.enter();
    }));

    machine.start();
  });
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
  test('entry/exit transitions', () {
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
    expect(log,
        ['outer entry a', 'inner entry 1', 'outer exit a', 'inner exit 1']);
  });
  group('error transitions', () {
    late Machine<Symbol> machine;
    late State<Symbol> state;
    setUp(() {
      machine = Machine<Symbol>();
      state = machine.newStartState(#error);
      state.onEntry(() => throw 'Enter 1'); // ignore: only_throw_errors
      state.onEntry(() => throw 'Enter 2'); // ignore: only_throw_errors
      state.onExit(() => throw 'Exit 1'); // ignore: only_throw_errors
      state.onExit(() => throw 'Exit 2'); // ignore: only_throw_errors
    });
    test('enter', () {
      expect(
          () => machine.current = state,
          throwsA(isA<TransitionError>().having(
              (error) => error.errors, 'errors', ['Enter 1', 'Enter 2'])));
      expect(machine.current, state);
    });
    test('exit', () {
      expect(() => machine.current = state, throwsA(isA<TransitionError>()));
      expect(
          () => machine.current = null,
          throwsA(isA<TransitionError>().having(
              (error) => error.errors, 'errors', ['Exit 1', 'Exit 2'])));
      expect(machine.current, isNull);
    });
    test('enter / exit', () {
      expect(() => machine.current = state, throwsA(isA<TransitionError>()));
      expect(
          () => machine.current = state,
          throwsA(isA<TransitionError>().having((error) => error.errors,
              'errors', ['Exit 1', 'Exit 2', 'Enter 1', 'Enter 2'])));
      expect(machine.current, state);
    });
  });
}
