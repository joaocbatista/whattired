using Toybox.System;
using Toybox.WatchUi;
using Toybox.Lang;

class NumericInputDelegate extends WatchUi.InputDelegate {
  var _view as NumericInputView;
  
  public function initialize(
    view as NumericInputView
  ) {
    WatchUi.InputDelegate.initialize();
    _view = view;    
  }

  function onTap(clickEvent) {    
    _view.setCoord(clickEvent.getCoordinates());
    _view.getKeyPressed(clickEvent.getCoordinates());
    // _view.setClickType(clickEvent.getType());
    _view.onKeyPressed(clickEvent.getCoordinates());   
    return true;
  }
}
