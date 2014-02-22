library statemachine_test_junit;

import 'package:junitconfiguration/junitconfiguration.dart';
import 'statemachine_test.dart' as statemachine_test;

void main() {
  JUnitConfiguration.install();
  statemachine_test.main();
}
