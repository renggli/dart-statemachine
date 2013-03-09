library example;

import 'dart:html';
import 'tooltip.dart';

void main() {

  Element tootlip = query('#tooltip');

  TooltipMachine tooltip = new TooltipMachine(
    (event) => print("show"),
    (event) => null,
    (event) => print("hide")
  );

  tooltip.add(query('#button_1'));
  tooltip.add(query('#button_2'));
  tooltip.add(query('#button_3'));

}