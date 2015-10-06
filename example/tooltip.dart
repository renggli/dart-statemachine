library tooltip;

import 'dart:html';
import 'dart:async';

import '../lib/statemachine.dart';

/// A pretty HTML tooltip machine.
class Tooltip {

  /// The element this tooltip machine is installed on.
  final Element root;

  /// The data key used to retrieve the tooltip text.
  final String dataKey;

  /// The CSS class applied to the tooltip its style.
  final String baseCssClass;

  /// The CSS class applied to the tooltip to show it.
  final String visibleCssClass;

  /// The X offset of the tooltip element.
  final int offsetX;

  /// The Y offset of the tooltip element.
  final int offsetY;

  /// The dom element that shows the tooltip contents.
  final Element tooltip = new DivElement();

  /// The actual state machine for the tooltips.
  final Machine machine = new Machine();

  /// Various (internal) states of the tooltip machine.
  State _waiting;
  State _heating;
  State _display;
  State _cooling;

  /// The currently active element.
  Element _element;

  /// Constructor for tooltip machine.
  factory Tooltip({Element root: null, String dataKey: 'tooltip', String baseCssClass: 'tooltip',
      String visibleCssClass: 'visible', int offsetX: 0, int offsetY: 0,
      Duration delay: const Duration(milliseconds: 500)}) {
    return new Tooltip._internal(root == null ? document.body : root, dataKey, baseCssClass,
        visibleCssClass, offsetX, offsetY, delay);
  }

  Tooltip._internal(this.root, this.dataKey, this.baseCssClass, this.visibleCssClass, this.offsetX,
      this.offsetY, Duration delay) {
    tooltip.classes.add(baseCssClass);

    _waiting = machine.newState('waiting');
    _heating = machine.newState('heating');
    _display = machine.newState('display');
    _cooling = machine.newState('cooling');

    _waiting.onStream(root.onMouseOver, (Event event) {
      var element = event.target as Element;
      if (element.dataset.containsKey(dataKey)) {
        _element = element;
        _heating.enter();
      }
    });

    _heating.onStream(root.onMouseOut, (Event event) {
      _element = null;
      _waiting.enter();
    });
    _heating.onTimeout(delay, () {
      show(_element, _element.dataset[dataKey]);
      _display.enter();
    });

    _display.onStream(root.onMouseOut, (Event event) {
      _cooling.enter();
    });

    _cooling.onStream(root.onMouseOver, (Event event) {
      var element = event.target as Element;
      if (element.dataset.containsKey(dataKey)) {
        show(_element = element, _element.dataset[dataKey]);
        _display.enter();
      }
    });
    _cooling.onTimeout(delay, () {
      hide();
      _element = null;
      _waiting.enter();
    });

    machine.start();
  }

  /// Shows tooltip with [message] relative to [element].
  void show(Element element, String message) {
    var left = element.offset.left + element.offset.width / 2 + offsetX;
    var top = element.offset.top + element.offset.height + offsetY;
    tooltip.style.left = '${left}px';
    tooltip.style.top = '${top}px';
    tooltip.innerHtml = message;
    element.parentNode.insertBefore(tooltip, element.nextNode);
    Timer.run(() => tooltip.classes.add(visibleCssClass));
  }

  /// Removes the tooltip.
  void hide() {
    tooltip.classes.remove(visibleCssClass);
  }
}
