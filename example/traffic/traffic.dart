import 'dart:io';

import 'package:statemachine/statemachine.dart';

enum TrafficState {
  green,
  yellowToRed,
  yellowToGreen,
  red,
}

const String ansiReset = '\u001b[0m';
const String ansiRed = '\u001b[31m';
const String ansiGreen = '\u001b[32m';
const String ansiYellow = '\u001b[33m';

void output(String output) {
  stdout.write('\r$output$ansiReset');
}

Callback1<String> keyboardDispatcher(Machine<TrafficState> machine,
        [TrafficState? state]) =>
    (input) {
      if (input == ' ') {
        if (state != null) {
          machine.current = state;
        }
      } else if (input == 'q') {
        stdin.echoMode = true;
        stdin.lineMode = true;
        exit(0);
      }
    };

void main() {
  // Require stdout to be connected to terminal.
  if (!stdout.hasTerminal) {
    stderr.writeln('Unable to connect to terminal window.');
    exit(1);
  }

  // Require the support of ANSI colors.
  if (!stdout.supportsAnsiEscapes) {
    stderr.writeln('Unsupported ANSI escape sequences.');
    exit(2);
  }

  // Print an explanation.
  stdout.writeln('Press space to switch between states, q to quit.');

  // Configure terminal to be interactive.
  stdin.echoMode = false;
  stdin.lineMode = false;

  // Setup a consumable input stream.
  final input = stdin
      .asBroadcastStream()
      .expand((charCodes) => charCodes)
      .map((charCode) => String.fromCharCode(charCode));

  // Configure the machine.
  final machine = Machine<TrafficState>();
  machine.newState(TrafficState.green)
    ..onEntry(() => output('${ansiGreen}GREEN '))
    ..onStream(input, keyboardDispatcher(machine, TrafficState.yellowToRed))
    ..onTimeout(
      const Duration(seconds: 10),
      () => machine.current = TrafficState.yellowToRed,
    );
  machine.newState(TrafficState.yellowToRed)
    ..onEntry(() => output('${ansiYellow}YELLOW'))
    ..onStream(input, keyboardDispatcher(machine))
    ..onTimeout(
      const Duration(seconds: 1),
      () => machine.current = TrafficState.red,
    );
  machine.newState(TrafficState.yellowToGreen)
    ..onEntry(() => output('${ansiYellow}YELLOW'))
    ..onStream(input, keyboardDispatcher(machine))
    ..onTimeout(
      const Duration(seconds: 2),
      () => machine.current = TrafficState.green,
    );
  machine.newState(TrafficState.red)
    ..onEntry(() => output('${ansiRed}RED   '))
    ..onStream(input, keyboardDispatcher(machine, TrafficState.yellowToGreen))
    ..onTimeout(
      const Duration(seconds: 20),
      () => machine.current = TrafficState.yellowToGreen,
    );

  // Start the machine
  machine.start();
}
