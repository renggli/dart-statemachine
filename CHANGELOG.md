# Changelog

## 3.3.0 (unpublished)

* Dart 2.17 requirement.
* Add the ability to abort transitions from the `onBeforeTransition` event.

## 3.2.0

* Dart 2.16 requirement.
* Avoid dynamic calls across the code.
* Improve typing of State<T> across the code-base.

## 3.1.0

* Add `onBeforeTransition` and `onAfterTransition` to let others observe state transitions.
* Throw a composite `TransitionError` at the end of a transition where something went wrong.
* Allow `Future` and `Stream` transitions to recreate their source on activation using a provider function.

## 3.0.0

* Make machines and states typed, so that a custom object can be associated and used for identification of each state.
* To migrate existing code change the type of your state machine from `Machine` to `Machine<String>` and make sure to provide a unique name for each call to `newState`, `newStartState`, and `newStopState`.

## 2.0.0

* Dart 2.12 requirement and null-safety.

## 1.6.0

* Dart 2.3 compatibility and requirement.

## 1.5.0

* Dart 2.2 compatibility and requirement.

## 1.4.0

* Drop Dart 1.0 compatibility.

## 1.3.0

* Reformat all code.
* Reorganize into micro libraries.

## 1.2.3

* Replace deprecated async code.

## 1.2.2

* Fix CSS problem in example.

## 1.2.1

* Update documentation.

## 1.2.0

* Fix linter warnings.
* Update documentation.
* Address missing coverage.

## 1.1.1

* Fix a broken test.

## 1.1.0

* Update to use Travis.

## 1.0.6

* Support for nested machines.
* Support for enter/exist state events.

## 1.0.3

* Improve test coverage.

## 1.0.0

* Initial version.
