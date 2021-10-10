State Machine
=============

[![Pub Package](https://img.shields.io/pub/v/statemachine.svg)](https://pub.dev/packages/statemachine)
[![Build Status](https://github.com/renggli/dart-statemachine/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/renggli/dart-statemachine/actions/workflows/dart.yml)
[![Code Coverage](https://codecov.io/gh/renggli/dart-statemachine/branch/main/graph/badge.svg?token=BcQSTotPss)](https://codecov.io/gh/renggli/dart-statemachine)
[![GitHub Issues](https://img.shields.io/github/issues/renggli/dart-statemachine.svg)](https://github.com/renggli/dart-statemachine/issues)
[![GitHub Forks](https://img.shields.io/github/forks/renggli/dart-statemachine.svg)](https://github.com/renggli/dart-statemachine/network)
[![GitHub Stars](https://img.shields.io/github/stars/renggli/dart-statemachine.svg)](https://github.com/renggli/dart-statemachine/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/renggli/dart-statemachine/main/LICENSE)

A simple, yet powerful state machine framework for Dart supporting Flutter and web apps.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/renggli/dart-statemachine). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](https://stackoverflow.com/questions/tagged/statemachine+dart).

The package is hosted on [dart packages](https://pub.dev/packages/statemachine). Up-to-date [class documentation](https://pub.dev/documentation/statemachine/latest/) is created with every release.


Tutorial
--------

### Installation

Follow the installation instructions on [dart packages](https://pub.dev/packages/statemachine/install).

Import the package into your Dart code using:

```dart
import 'package:statemachine/statemachine.dart';
```

### Creating a machine

To create a new state machine instantiate `Machine`:

```dart
final machine = Machine<String>();
```

The type of the state machine is used to uniquely identify states of the machine. In this simple example we use a `String`; but typically you would use an enum, a `Symbol`, or an arbitrary other identifying object.

### Defining states

To create states call `Machine.newState` and store them in variables. Each state needs an identifying key of the declared type, as described above we use a `String` that helps debugging. 

```dart
final startState = machine.newState('start');
final activeState = machine.newState('active');
```

By default, the first state created is also the start state of the machine. It is possible to explicitly create start and stop states of the machine using `Machine.newStartState` and `Machine.newStopState`.

### Callbacks on states

States support callbacks whenever a state is entered or left.

```dart
someState.onEntry(() => print('activated'));
someState.onExit(() => print('deactivate'));
```

### Starting and stopping a machine

To start a state machine and set its state to its starting state call `Machine.start`:

```dart
machine.start();
```

Similarly, you can stop a machine by calling `Machine.stop`.

### Transitioning between states

There are various ways in which your machine can switch states.

#### Manually triggered transition

From anywhere within your code you can enter a specific state by calling `State.enter`.

```dart
someState.enter();
```

Depending on context, it might be easier to set the current state using the accessor on the state machine itself:

```dart
machine.current = someState;
```

Alternatively, you can also use the identifying object to set the active state:

```dart
machine.current = 'active';
```

#### Event triggered transition

You can define transitions between states that are triggered by events using `State.onStream`. The example below registers for click events when the inactive state is entered. In case of a click event the callback is executed, and the state machine transitions into the new state:

```dart
someState.onStream(element.onClick, (value) => anotherState.enter());
```

#### Future completion transition

Also, transitions can be triggered by the completion of a future using `State.onFuture`. Since futures cannot be suspended or cancelled, the future continues to run even if the owning state is deactivated. Should the state be activated, and the future value is already present, then the value is immediately supplied into the callback. Further activations have no effect.

```dart
someState.onFuture(computation, (value) => anotherState.enter());
```

#### Time based transition

Also, you can automatically trigger callbacks after a timeout using `State.onTimeout`. The following snippet calls the callback 1 second after the active state is entered and falls back to another state:

```dart
someState.onTimeout(Duration({seconds: 1}), () => anotherState.enter());
```

Callbacks often contain code to check for additional constraints and update other objects or UI element before entering a different state. See the tooltip example directory for a more complete illustration of the functionality provided by this library.

### Nested machines

Machines can be nested. Simply add another machine that gets started when the state is entered, and stopped when the state is left.

```dart
someState.addNested(anotherMachine);
```

Misc
----

### Resources

- [The Rise Of The State Machines.](https://www.smashingmagazine.com/2018/01/rise-state-machines/)
- [You are managing state? Think twice.](https://krasimirtsonev.com/blog/article/managing-state-in-javascript-with-state-machines-stent)
- [Robust React User Interfaces with Finite State Machines.](https://css-tricks.com/robust-react-user-interfaces-with-finite-state-machines/)

### License

The MIT License, see [LICENSE](https://github.com/renggli/dart-statemachine/raw/main/LICENSE).
