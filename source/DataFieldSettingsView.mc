//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

//! Initial view for the settings
class DataFieldSettingsView extends WatchUi.View {
  //! Constructor
  public function initialize() {
    View.initialize();
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Dc) as Void {
    dc.clearClip();
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    var mySettings = System.getDeviceSettings();
    var version = mySettings.monkeyVersion;
    var versionString = Lang.format("$1$.$2$.$3$", version);

    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() / 2 - 30,
      Graphics.FONT_SMALL,
      "Press Menu \nfor settings \nCIQ " + versionString,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }
}

//! Handle opening the settings menu
class DataFieldSettingsDelegate extends WatchUi.BehaviorDelegate {
  //! Constructor
  public function initialize() {
    BehaviorDelegate.initialize();
  }

  //! Handle the menu event
  //! @return true if handled, false otherwise
  public function onMenu() as Boolean {
    var menu = new $.DataFieldSettingsMenu();
    var boolean = $.getStorageValue("reset_front", false) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Reset front", null, "reset_front", boolean, null));

    boolean =  $.getStorageValue("reset_back", false) as Boolean; 
    menu.addItem(new WatchUi.ToggleMenuItem("Reset back", null, "reset_back", boolean, null));

    boolean = $.getStorageValue("switch_front_back", false) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Front <-> back", null, "switch_front_back", boolean, null));

    boolean =  $.getStorageValue("reset_track", false) as Boolean; 
    menu.addItem(new WatchUi.ToggleMenuItem("Reset track", null, "reset_track", boolean, null));

    var mi = new WatchUi.MenuItem("Focus", null, "showFocusSmallField", null);
    mi.setSubLabel($.getFocusMenuSubLabel(mi.getId() as String));
    menu.addItem(mi);

    mi = new WatchUi.MenuItem("Distance", null, "menuDistance", null);
    mi.setSubLabel("Manage distance settings");
    menu.addItem(mi);

    boolean = $.getStorageValue("showColors", true) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Show colors", null, "showColors", boolean, null));
    boolean = $.getStorageValue("showValues", true) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Show values", null, "showValues", boolean, null));
    boolean = $.getStorageValue("showColorsSmallField", true) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Show colors small field", null, "showColorsSmallField", boolean, null));
    boolean = $.getStorageValue("showValuesSmallField", false) as Boolean;
    menu.addItem(new WatchUi.ToggleMenuItem("Show values small field", null, "showValuesSmallField", boolean, null));

    mi = new WatchUi.MenuItem("Show fields", null, "menuFields", null);
    mi.setSubLabel("Display data");
    menu.addItem(mi);
   
    var view = new $.DataFieldSettingsView();
    WatchUi.pushView(menu, new $.DataFieldSettingsMenuDelegate(view), WatchUi.SLIDE_IMMEDIATE);
    return true;
  }

  public function onBack() as Boolean {
    getApp().onSettingsChanged();
    getApp().triggerFrontBack();
    return false;
  }
}

// Globals
//Always in km
function getDistanceMenuSubLabel(key as Application.PropertyKeyType) as String {
  return ((getStorageValue(key, 0.0f) as Float) / 1000).format("%.2f") + " km";
}

function getFocusMenuSubLabel(key as Application.PropertyKeyType) as String {
  var current = $.getStorageValue(key, Types.FocusNothing) as Types.EnumFocus;
  switch (current) {
    case Types.FocusNothing:
      return "Nothing";
    case Types.FocusOdo:
      return "Odo";
    case Types.FocusYear:
      return "Year";
    case Types.FocusMonth:
      return "Month";
    case Types.FocusWeek:
      return "Week";
    case Types.FocusRide:
      return "Ride";
    case Types.FocusFront:
      return "Front";
    case Types.FocusBack:
      return "Back";
    case Types.FocusCourse:
      return "Course";
    default:
      return "Nothing";
  }
}
