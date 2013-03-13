// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library statemachine_test_jenkins;

import 'package:junitconfiguration/junitconfiguration.dart';
import 'statemachine_test.dart' as statemachine_test;

void main() {
  JUnitConfiguration.install();
  statemachine_test.main();
}