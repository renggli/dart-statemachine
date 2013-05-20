// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library statemachine_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:statemachine/statemachine.dart';

void main() {
  group('stream transitions', () {
    var emitterA = new StreamController();
    var emitterB = new StreamController();
    var emitterC = new StreamController();

    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onStream(emitterB.stream, (event) => stateB.enter());
    stateA.onStream(emitterC.stream, (event) => stateC.enter());

    stateB.onStream(emitterA.stream, (event) => stateA.enter());
    stateB.onStream(emitterC.stream, (event) => stateC.enter());

    stateC.onStream(emitterA.stream, (event) => stateA.enter());
    stateC.onStream(emitterB.stream, (event) => stateB.enter());

    test('initial state', () {
      machine.reset();
      expect(machine.current, stateA);
    });
    test('simple transition', () {
      machine.reset();
      emitterB.add('*');
      expect(machine.current, stateB);
    });
    test('double transition', () {
      machine.reset();
      emitterB.add('*');
      emitterC.add('*');
      expect(machine.current, stateC);
    });
    test('triple transition', () {
      machine.reset();
      emitterB.add('*');
      emitterC.add('*');
      emitterA.add('*');
      expect(machine.current, stateA);
    });
    test('many transitions', () {
      machine.reset();
      for (var i = 0; i < 100; i++) {
        emitterB.add('*');
        emitterA.add('*');
      }
      expect(machine.current, stateA);
    });
  });
  test('conflicting transitions', () {
    var emitter = new StreamController();
    var stream = emitter.stream.asBroadcastStream();

    var machine = new Machine();

    var stateA = machine.newState('a');
    var stateB = machine.newState('b');
    var stateC = machine.newState('c');

    stateA.onStream(stream, (value) => stateB.enter());
    stateA.onStream(stream, (value) => stateC.enter());

    machine.reset();
    emitter.add('*');
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
        expectAsync1((value) {
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
        expectAsync0(() {
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
        expectAsync0(() {
          expect(machine.current, stateB);
          stateC.enter();
        }));

    machine.reset();
  });

}