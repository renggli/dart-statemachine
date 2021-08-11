import 'dart:async';
import 'dart:html';

import 'package:statemachine/statemachine.dart';

/// A pretty HTML tooltip machine.
class Tooltip {
  /// The element this tooltip machine is installed on.
  final Element root;

  /// The data key used to retrieve the tooltip text.
  final String dataKey;

  /// The CSS class applied to the tooltip style.
  final String baseCssClass;

  /// The CSS class applied to the tooltip to show it.
  final String visibleCssClass;

  /// The X offset of the tooltip element.
  final int offsetX;

  /// The Y offset of the tooltip element.
  final int offsetY;

  /// The dom element that shows the tooltip contents.
  final Element tooltip = DivElement();

  /// The actual state machine for the tooltips.
  final machine = Machine<Symbol>();

  /// The currently active element.
  Element? _element;

  /// Constructor for tooltip machine.
  Tooltip(this.root,
      {this.dataKey = 'tooltip',
      this.baseCssClass = 'tooltip',
      this.visibleCssClass = 'visible',
      this.offsetX = 0,
      this.offsetY = 0,
      Duration delay = const Duration(milliseconds: 500)}) {
    tooltip.classes.add(baseCssClass);

    final waiting = machine.newState(#waiting);
    final heating = machine.newState(#heating);
    final display = machine.newState(#display);
    final cooling = machine.newState(#cooling);

    waiting.onStream<MouseEvent>(root.onMouseOver, (event) {
      final element = event.target;
      if (element is Element && element.dataset.containsKey(dataKey)) {
        _element = element;
        heating.enter();
      }
    });

    heating.onStream<MouseEvent>(root.onMouseOut, (event) {
      _element = null;
      waiting.enter();
    });
    heating.onTimeout(delay, () {
      show(_element, _element?.dataset[dataKey]);
      display.enter();
    });

    display.onStream<MouseEvent>(root.onMouseOut, (event) {
      cooling.enter();
    });

    cooling.onStream<MouseEvent>(root.onMouseOver, (event) {
      final element = event.target;
      if (element is Element && element.dataset.containsKey(dataKey)) {
        show(_element = element, _element?.dataset[dataKey]);
        display.enter();
      }
    });
    cooling.onTimeout(delay, () {
      hide();
      _element = null;
      waiting.enter();
    });

    machine.start();
  }

  /// Shows tooltip with [message] relative to [element].
  void show(Element? element, String? message) {
    final parent = element?.parentNode;
    if (element != null && parent != null && message != null) {
      final left = element.offset.left + element.offset.width / 2 + offsetX;
      final top = element.offset.top + element.offset.height + offsetY;
      tooltip.style.left = '${left}px';
      tooltip.style.top = '${top}px';
      tooltip.innerHtml = message;
      parent.insertBefore(tooltip, element.nextNode);
      Timer.run(() => tooltip.classes.add(visibleCssClass));
    }
  }

  /// Removes the tooltip.
  void hide() {
    tooltip.classes.remove(visibleCssClass);
  }
}
