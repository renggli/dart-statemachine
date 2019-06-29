library statemachine.test.statemachine_test;

import 'dart:async';

import 'package:statemachine/statemachine.dart';
import 'package:test/test.dart';

void main() {
  group('stream transitions', () {
    StreamController<String> controllerA, controllerB, controllerC;
    Machine machine;
    State stateA, stateB, stateC;

    setUp(() {
      controllerA = StreamController.broadcast(sync: true);
      controllerB = StreamController.broadcast(sync: true);
      controllerC = StreamController.broadcast(sync: true);

      machine = Machine();

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
      expect(machine.toString(), 'Instance of \'Machine\'[null]');
      machine.start();
      expect(machine.toString(), 'Instance of \'Machine\'[State[a]]');
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
    test('state without machine', () {
      expect(() => State(null), throwsArgumentError);
    });
  });
  test('conflicting transitions', () {
    final controller = StreamController<String>.broadcast(sync: true);

    try {
      final machine = Machine();

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
    final machine = Machine();
    final log = <String>[];

    final stateA = machine.newState('a');
    final stateB = machine.newState('b');

    stateA.onFuture<String>(Future.delayed(const Duration(milliseconds: 100)),
        (value) => fail('should never be called'));
    stateA.onFuture<String>(
        Future.delayed(const Duration(milliseconds: 10), () => 'something'),
        expectAsync1<String, Object>((value) {
      expect(log, isEmpty);
      expect(value, 'something');
      expect(machine.current, stateA);
      log.add('a');
      stateB.enter();
      return null;
    }));
    stateB.onFuture<String>(Future.delayed(const Duration(milliseconds: 1)),
        expectAsync1<String, Object>((value) {
      expect(log, ['a']);
      expect(value, isNull);
      return null;
    }));

    machine.start();
  });
  test('timeout transitions', () {
    final machine = Machine();

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
    final machine = Machine();
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
    final machine = Machine();
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
    final inner = Machine();
    inner.newState('a')
      ..onEntry(() => log.add('inner entry a'))
      ..onExit(() => log.add('inner exit a'));
    final outer = Machine();
    outer.newState('a')
      ..onEntry(() => log.add('outer entry a'))
      ..onExit(() => log.add('outer exit a'))
      ..addNested(inner);
    outer.start();
    expect(log, ['outer entry a', 'inner entry a']);
    outer.stop();
    expect(log,
        ['outer entry a', 'inner entry a', 'outer exit a', 'inner exit a']);
  });
}
