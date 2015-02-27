library statemachine_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:statemachine/statemachine.dart';

void main() {
  group('stream transitions', () {
    var controllerA = new StreamController.broadcast(sync: true);
    var controllerB = new StreamController.broadcast(sync: true);
    var controllerC = new StreamController.broadcast(sync: true);

    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onStream(controllerB.stream, (event) => stateB.enter());
    stateA.onStream(controllerC.stream, (event) => stateC.enter());

    stateB.onStream(controllerA.stream, (event) => stateA.enter());
    stateB.onStream(controllerC.stream, (event) => stateC.enter());

    stateC.onStream(controllerA.stream, (event) => stateA.enter());
    stateC.onStream(controllerB.stream, (event) => stateB.enter());

    test('initial state', () {
      machine.reset();
      expect(machine.current, stateA);
    });
    test('simple transition', () {
      machine.reset();
      controllerB.add('*');
      expect(machine.current, stateB);
    });
    test('double transition', () {
      machine.reset();
      controllerB.add('*');
      controllerC.add('*');
      expect(machine.current, stateC);
    });
    test('triple transition', () {
      machine.reset();
      controllerB.add('*');
      controllerC.add('*');
      controllerA.add('*');
      expect(machine.current, stateA);
    });
    test('many transitions', () {
      machine.reset();
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
    var controller = new StreamController.broadcast(sync: true);

    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onStream(controller.stream, (value) => stateB.enter());
    stateA.onStream(controller.stream, (value) => stateC.enter());

    machine.reset();
    controller.add('*');
    expect(machine.current, stateB);
  });
  test('future transitions', () {
    var completerB = new Completer();
    var completerC = new Completer();

    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onFuture(
        completerB.future,
        expectAsync((value) {
          expect(machine.current, stateA);
          stateB.enter();
        }));
    stateA.onFuture(
        completerC.future,
        (value) => fail('should never be called'));

    machine.reset();
    completerB.complete();
  });
  test('timeout transitions', () {
    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onTimeout(
        new Duration(milliseconds: 10),
        expectAsync(() {
          expect(machine.current, stateA);
          stateB.enter();
        }));
    stateA.onTimeout(
        new Duration(milliseconds: 20),
        () => fail('should never be called'));
    stateB.onTimeout(
        new Duration(milliseconds: 20),
        () => fail('should never be called'));
    stateB.onTimeout(
        new Duration(milliseconds: 10),
        expectAsync(() {
          expect(machine.current, stateB);
          stateC.enter();
        }));

    machine.reset();
  });
  test('activate/deactivate transitions', () {
    var log = new List();

    var machine = new Machine();
    var stateA = machine.newState('a')
        ..onActivate(() => log.add('on a'))
        ..onDeactivate(() => log.add('off a'));
    var stateB = machine.newState('b')
        ..onActivate(() => log.add('on b'))
        ..onDeactivate(() => log.add('off b'));

    machine.reset();
    stateB.enter();

    expect(log, ['on a', 'off a', 'on b']);
  });
}
