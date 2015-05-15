StateMachine
============

[![Pub Package](https://img.shields.io/pub/v/statemachine.svg)](https://pub.dartlang.org/packages/statemachine)
[![Build Status](https://travis-ci.org/renggli/dart-statemachine.svg)](https://travis-ci.org/renggli/dart-statemachine)
[![Coverage Status](https://coveralls.io/repos/renggli/dart-statemachine/badge.svg)](https://coveralls.io/r/renggli/dart-statemachine)

A simple, but generic state machine framework for Dart.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/renggli/dart-statemachine). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/statemachine+dart).

Up-to-date [class documentation](http://www.dartdocs.org/documentation/statemachine/latest/index.html) is created with every release.

This code was inspired by work of Vassily Boykov on his [Smalltalk Announcement framework](http://www.cincomsmalltalk.com/userblogs/vbykov/blogView?searchCategory=Announcements%20Framework).

Tutorial
--------

To create a new state machine instantiate `Machine`:

```dart
var machine = new Machine();
```

To create states call `Machine.newState` and store them in variables. Optionally you can provide a name as argument to ease debugging.

```dart
var inactive = machine.newState();
var active = machine.newState('active');
```

To start a state machine or to reset its state to its starting state call `Machine.start`:

```dart
machine.start();
```

To enter a specific state call [State.enter].

```dart
inactive.enter();
```

You can define transitions between states that are triggered by events of any kind using `State.onStream`. The example below registers for click events when the inactive state is entered. In case of a click event the callback is executed and the state machine transitions into the active state:

```dart
inactive.onStream(element.onClick, (value) => active.enter());
```

Also, transitions can be triggered by the completion of a future using `State.onFuture`. Since futures cannot be suspended or cancelled the future continues to run even if the owning state is deactivated. Should the state be activated value is immediately supplied into the callback. Further activations have no effect.

```dart
inactive.onFuture(computation, (value) => active.enter());
```

Also, you can automatically trigger callbacks after a timeout using `State.onTimeout`. The following snippet calls the callback 1 second after the active state is entered and falls back to the inactive state:

```dart
active.onTimeout(const Duration({seconds: 1}), () => inactive.enter());
```

Callbacks often contain code to check for additional constraints and update other objects or UI element before entering a different state. See the tooltip infrastructure in the example directory for a more complete illustration of the functionality provided by this library.


Misc
----

### License

The MIT License, see [LICENSE](https://github.com/renggli/dart-statemachine/raw/master/LICENSE).
