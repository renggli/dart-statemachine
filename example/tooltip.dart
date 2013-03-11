library tooltip;

import 'dart:html';
import 'dart:async';

import '../lib/statemachine.dart';

/**
 *
 */
class Tooltip {

  /** The element this tooltip machine is installed on. */
  final Element _root;

  /** The data key used to retrieve the tooltip text. */
  final String _dataKey;

  /** The CSS class applied to the tooltip its style. */
  final String _baseCssClass;

  /** The CSS class applied to the tooltip to show it. */
  final String _visibleCssClass;

  /** The X offset of the tooltip element. */
  final int _offsetX;

  /** The Y offset of the tooltip element. */
  final int _offsetY;

  /** The dom element that shows the tooltip contents. */
  final Element _tooltip = new DivElement();

  /** The actual state machine for the tooltips. */
  final Machine _machine = new Machine();

  /** Various (internal) states of the tooltip machine. */
  State _waiting;
  State _heating;
  State _display;
  State _cooling;

  /** The currently active element. */
  Element _element;

  /** Constructor for tooltip machine. */
  factory Tooltip({Element root: null, String dataKey: 'tooltip',
      String baseCssClass: 'tooltip', String visibleCssClass: 'visible',
      int offsetX: 0, int offsetY: 0,
      Duration delay: const Duration(milliseconds: 500)}) {
    return new Tooltip._internal(root == null ? document.body : root,
        dataKey, baseCssClass, visibleCssClass, offsetX, offsetY,
        delay);
  }

  Tooltip._internal(this._root, this._dataKey, this._baseCssClass,
      this._visibleCssClass, this._offsetX, this._offsetY,
      Duration dealy) {
    _tooltip.classes.add(_baseCssClass);

    _waiting = _machine.newState();
    _heating = _machine.newState();
    _display = _machine.newState();
    _cooling = _machine.newState();

    _waiting.on(_root.onMouseOver, (Event event) {
      var element = event.target as Element;
      if (element.dataset.containsKey(_dataKey)) {
        _element = element;
        _heating.enter();
      }
    });

    _heating.on(_root.onMouseOut, (Event event) {
      _element = null;
      _waiting.enter();
    });
    _heating.onTimeout(dealy, () {
      show(_element, _element.dataset[_dataKey]);
      _display.enter();
    });

    _display.on(_root.onMouseOut, (Event event) {
      _cooling.enter();
    });

    _cooling.on(_root.onMouseOver, (Event event) {
      var element = event.target as Element;
      if (element.dataset.containsKey(_dataKey)) {
        show(_element = element, _element.dataset[_dataKey]);
        _display.enter();
      }
    });
    _cooling.onTimeout(dealy, () {
      hide();
      _element = null;
      _waiting.enter();
    });

    _machine.reset();
  }

  /** Shows tooltip with [message] relative to [element]. */
  void show(Element element, String message) {
    var left = element.offsetLeft + element.offsetWidth / 2 + _offsetX;
    var top = element.offsetTop + element.offsetHeight + _offsetY;
    _tooltip.style.left = '${left}px';
    _tooltip.style.top = '${top}px';
    _tooltip.innerHtml = message;
    element.parentNode.insertBefore(_tooltip, element.nextNode);
    _tooltip.classes.add(_visibleCssClass);
  }

  /** Removes the tooltip. */
  void hide() {
    _tooltip.classes.remove(_visibleCssClass);
  }

}