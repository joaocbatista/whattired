using Toybox.System;
using Toybox.WatchUi;
using Toybox.Lang;

// Note that on wearable products, input events are not supported for data fields. 
// class NumericInputDelegate extends WatchUi.InputDelegate {
class NumericInputDelegate extends WatchUi.BehaviorDelegate {
  var _debug as Lang.Boolean = false;
  var _view as NumericInputView;
  var _delegate as DistanceMenuDelegate;

  public function initialize(debug as Lang.Boolean, view as NumericInputView, delegate as DistanceMenuDelegate) {
    WatchUi.BehaviorDelegate.initialize();
    _debug = debug;
    _view = view;
    _delegate = delegate;
  }

  function onTap(event as WatchUi.ClickEvent) {
    if (_debug) {
      _view.setDebugInfo("onTap", event.getCoordinates());
    }
    // _view.setClickType(clickEvent.getType());
    _view.onKeyPressed(event.getCoordinates());
    _delegate.refreshUi();
    //WatchUi.requestUpdate();
    return true;
  }

  // function onFlick(event as WatchUi.FlickEvent) {
  //   if (_debug) {
  //     _view.setDebugInfo("onFlick", event.getCoordinates());
  //   }
  //   _view.onKeyPressed(event.getCoordinates());
  //   return true;
  // }
}
