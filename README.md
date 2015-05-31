StateMachine
============

[![Pub Package](https://img.shields.io/pub/v/statemachine.svg)](https://pub.dartlang.org/packages/statemachine)
[![Build Status](https://travis-ci.org/renggli/dart-statemachine.svg)](https://travis-ci.org/renggli/dart-statemachine)
[![Coverage Status](https://coveralls.io/repos/renggli/dart-statemachine/badge.svg)](https://coveralls.io/r/renggli/dart-statemachine)
[![Github Issues](http://githubbadges.herokuapp.com/renggli/dart-statemachine/issues.svg)](https://github.com/renggli/dart-statemachine/issues)

A simple, but generic state machine framework for Dart.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/renggli/dart-statemachine). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/statemachine+dart).

Up-to-date [class documentation](http://www.dartdocs.org/documentation/statemachine/latest/index.html) is created with every release.

This code was inspired by work of Vassily Boykov on his [Smalltalk Announcement framework](http://www.cincomsmalltalk.com/userblogs/vbykov/blogView?searchCategory=Announcements%20Framework).

Tutorial
--------

### Creating a machine

To create a new state machine instantiate `Machine`:

```dart
var machine = new Machine();
```

### Defining states

To create states call `Machine.newState` and store them in variables. The first state created it the start state of the machine. Optionally you can provide a name as argument to ease debugging.

```dart
var startState = machine.newState();
var activeState = machine.newState('active');
```

It is possible to explicitely create start and stop states of the machine using `Machine.newStartState` and `Machine.newStopState`.

### Callbacks on states

States support callbacks whenever a state is entered or left.

```dart
activeState.onEntry(() => print('activated'));
activeState.onExit(() => print('deactivate'));
```

### Starting and stopping a machine

To start a state machine and set its state to its starting state call `Machine.start`:

```dart
machine.start();
```

Similarly you can stop a machine by calling `Machine.stop`.

### Transitioning between states

There are various ways in which your machine can switch states.

#### Manually triggered transition

From anywhere within your code you can enter a specific state by call `State.enter`.

```dart
activeState.enter();
```

#### Event triggered transition

You can define transitions between states that are triggered by events of any kind using `State.onStream`. The example below registers for click events when the inactive state is entered. In case of a click event the callback is executed and the state machine transitions into the active state:

```dart
startState.onStream(element.onClick, (value) => activeState.enter());
```

#### Future completion transition

Also, transitions can be triggered by the completion of a future using `State.onFuture`. Since futures cannot be suspended or cancelled the future continues to run even if the owning state is deactivated. Should the state be activated value is immediately supplied into the callback. Further activations have no effect.

```dart
startState.onFuture(computation, (value) => activeState.enter());
```

#### Time based transition

Also, you can automatically trigger callbacks after a timeout using `State.onTimeout`. The following snippet calls the callback 1 second after the active state is entered and falls back to the inactive state:

```dart
activeState.onTimeout(const Duration({seconds: 1}), () => startState.enter());
```

Callbacks often contain code to check for additional constraints and update other objects or UI element before entering a different state. See the tooltip example directory for a more complete illustration of the functionality provided by this library.

### Nested machines

Machines can be nested. Simply add another machine that gets started when the state is entered, and stopped when the state is left.

```dart
activeState.addNested(anotherMachine);
```

Misc
----

### License

The MIT License, see [LICENSE](https://github.com/renggli/dart-statemachine/raw/master/LICENSE).
