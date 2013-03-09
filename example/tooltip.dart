library tooltip;

import 'dart:html';
import 'dart:async';

import '../lib/statemachine.dart';

/**
 *
 */
class TooltipMachine {

  /** Callback when the tooltip should be shown. */
  final Function _onShow;

  /** Callback when the tooltip should be moved. */
  final Function _onMove;

  /** Callback when the tooltip should be hidden. */
  final Function _onHide;

  final Machine _machine = new Machine();

  State _waiting;
  State _heating;
  State _display;
  State _cooling;

  final Set<Element> _elements = new Set();
  Element _element;

  TooltipMachine(this._onShow, this._onMove, this._onHide) {
    _waiting = _machine.newState();
    _heating = _machine.newState();
    _display = _machine.newState();
    _cooling = _machine.newState();

    _waiting.on(document.onMouseOver, (Event event) {
      if (_elements.contains(event.target)) {
        _element = event.target;
        _heating.enter();
      }
    });

    _heating.on(document.onMouseOut, (Event event) {
      _element = null;
      _waiting.enter();
    });
    _heating.onTimeout(new Duration(milliseconds: 500), () {
      _onShow(_element);
      _display.enter();
    });

    _display.on(document.onMouseOut, (Event event) {
      if (_elements.contains(event.target)) {
        _onHide(_element);
        _element = null;
        _cooling.enter();
      }
    });
    _display.on(document.onMouseMove, (Event event) {
      if (_elements.contains(event.target)) {
        _onMove(_element);
      }
    });

    _cooling.on(document.onMouseOver, (Event event) {
      if (_elements.contains(event.target)) {
        _element = event.target;
        _onShow(_element);
        _display.enter();
      }
    });
    _cooling.onTimeout(new Duration(milliseconds: 500), () {
      _waiting.enter();
    });

    _machine.reset();
  }

  void add(Element element) {
    _elements.add(element);
  }

}