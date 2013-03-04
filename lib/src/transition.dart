// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of statemachine;

/**
 * A transition from one state to another.
 */
abstract class Transition {

  /** Called when the source state is activate. */
  void activate();

  /** Called when the source state is deactivated. */
  void deactivate();

}