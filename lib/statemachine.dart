// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * To create a new state machine instantiate [Machine]:
 *
 *     var machine = new Machine();
 *
 * To create states call [Machine#newState] and store them in variables:
 *
 *     var inactive = machine.newState();
 *     var active = machine.newState();
 *
 * To reset a state machine to its initial state call [Machine#reset]:
 *
 *     machine.reset();
 *
 * To enter a specific state call [State#enter].
 *
 *     inactive.enter();
 *
 * You can define transitions between states that are triggered by events of
 * any kind using [State#on]. The example below registers for click events
 * when the inactive state is entered. In case of a click event the callback
 * is executed and the state machine transitions into the active state:
 *
 *     inactive.on(element.onClick, (event) => active.enter());
 *
 * Also, you can automatically trigger callbacks after a timeout using
 * [State#onTimeout]. The following snippet calls the callback 1 second after
 * the active state is entered and falls back to the inactive state:
 *
 *     active.onTimeout(const Duration({seconds: 1}), () => inactive.enter());
 *
 * Callbacks often contain code to check for additional constraints and update
 * other objects or UI element before entering a different state. See the
 * tooltip infrastructure in the example directory for a more complete
 * illustration of the functionality provided by this library.
 */
library statemachine;

import 'dart:async';
import 'dart:collection';

part 'src/machine.dart';
part 'src/state.dart';
part 'src/transition.dart';
part 'src/transition_stream.dart';
part 'src/transition_timeout.dart';