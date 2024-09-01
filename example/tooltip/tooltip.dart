import 'dart:async';

import 'package:statemachine/statemachine.dart';
import 'package:web/web.dart';

/// A pretty HTML tooltip machine.
class Tooltip {
  /// Constructor for tooltip machine.
  Tooltip(this.root,
      {this.attributeKey = 'data-tooltip',
      this.baseCssClass = 'tooltip',
      this.visibleCssClass = 'visible',
      this.offsetX = 0,
      this.offsetY = 0,
      Duration delay = const Duration(milliseconds: 500)}) {
    tooltip.classList.add(baseCssClass);

    final waiting = machine.newState(#waiting);
    final heating = machine.newState(#heating);
    final display = machine.newState(#display);
    final cooling = machine.newState(#cooling);

    waiting.onStream<MouseEvent>(root.onMouseOver, (event) {
      final element = event.target;
      if (element is HTMLElement && element.hasAttribute(attributeKey)) {
        _element = element;
        heating.enter();
      }
    });

    heating.onStream<MouseEvent>(root.onMouseOut, (event) {
      _element = null;
      waiting.enter();
    });
    heating.onTimeout(delay, () {
      show(_element, _element?.getAttribute(attributeKey));
      display.enter();
    });

    display.onStream<MouseEvent>(root.onMouseOut, (event) {
      cooling.enter();
    });

    cooling.onStream<MouseEvent>(root.onMouseOver, (event) {
      final element = event.target;
      if (element is HTMLElement && element.hasAttribute(attributeKey)) {
        show(_element = element, _element?.getAttribute(attributeKey));
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

  /// The element this tooltip machine is installed on.
  final HTMLElement root;

  /// The attribute key used to retrieve the tooltip text.
  final String attributeKey;

  /// The CSS class applied to the tooltip style.
  final String baseCssClass;

  /// The CSS class applied to the tooltip to show it.
  final String visibleCssClass;

  /// The X offset of the tooltip element.
  final int offsetX;

  /// The Y offset of the tooltip element.
  final int offsetY;

  /// The dom element that shows the tooltip contents.
  final HTMLElement tooltip = document.createElement('div') as HTMLElement;

  /// The actual state machine for the tooltips.
  final machine = Machine<Symbol>();

  /// The currently active element.
  HTMLElement? _element;

  /// Shows tooltip with [message] relative to [element].
  void show(HTMLElement? element, String? message) {
    final parent = element?.parentNode;
    if (element != null && parent != null && message != null) {
      final left = element.offsetLeft + element.offsetWidth / 2 + offsetX;
      final top = element.offsetTop + element.offsetHeight + offsetY;
      tooltip.style.left = '${left}px';
      tooltip.style.top = '${top}px';
      tooltip.innerText = message;
      parent.insertBefore(tooltip, element.nextElementSibling);
      Timer.run(() => tooltip.classList.add(visibleCssClass));
    }
  }

  /// Removes the tooltip.
  void hide() {
    tooltip.classList.remove(visibleCssClass);
  }
}
