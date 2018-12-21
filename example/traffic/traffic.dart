library statemachine.example.traffic;

import 'dart:io';

import 'package:statemachine/statemachine.dart';

const String ansiReset = '\u001b[0m';
const String ansiRed = '\u001b[31m';
const String ansiGreen = '\u001b[32m';
const String ansiYellow = '\u001b[33m';

void output(String output) {
  stdout.write('\r$output$ansiReset');
}

Callback1<String> keyboardDispatcher([State nextState]) {
  return (input) {
    switch (input) {
      case ' ':
        if (nextState != null) {
          nextState.enter();
        }
        break;
      case 'q':
        stdin.echoMode = true;
        stdin.lineMode = true;
        exit(0);
        break;
    }
  };
}

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
  final machine = Machine();

  final green = machine.newState('green');
  final yellowToRed = machine.newState('yellow');
  final yellowToGreen = machine.newState('yellow');
  final red = machine.newState('red');

  green.onEntry(() => output('${ansiGreen}GREEN '));
  green.onStream(input, keyboardDispatcher(yellowToRed));
  green.onTimeout(const Duration(seconds: 10), yellowToRed.enter);

  yellowToRed.onEntry(() => output('${ansiYellow}YELLOW'));
  yellowToRed.onStream(input, keyboardDispatcher());
  yellowToRed.onTimeout(const Duration(seconds: 1), red.enter);

  yellowToGreen.onEntry(() => output('${ansiYellow}YELLOW'));
  yellowToGreen.onStream(input, keyboardDispatcher());
  yellowToGreen.onTimeout(const Duration(seconds: 2), green.enter);

  red.onEntry(() => output('${ansiRed}RED   '));
  red.onStream(input, keyboardDispatcher(yellowToGreen));
  red.onTimeout(const Duration(seconds: 20), yellowToGreen.enter);

  // Start the machine
  machine.start();
}
