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
    var boolean = Storage.getValue("reset_front") ? true : false;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Reset front",
        null,
        "reset_front",
        boolean,
        null
      )
    );

    boolean = Storage.getValue("reset_back") ? true : false;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Reset back",
        null,
        "reset_back",
        boolean,
        null
      )
    );

    var mi = new WatchUi.MenuItem("Focus", null, "showFocusSmallField", null);
    mi.setSubLabel($.getFocusMenuSubLabel(mi.getId() as String));
    menu.addItem(mi);

    mi = new WatchUi.MenuItem("Distance", null, "menuDistance", null);
    mi.setSubLabel("Manage distance settings");
    menu.addItem(mi);

    boolean =
      $.getStorageElseApplicationProperty("showColors", true) as Boolean;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Show colors",
        null,
        "showColors",
        boolean,
        null
      )
    );
    boolean =
      $.getStorageElseApplicationProperty("showValues", true) as Boolean;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Show values",
        null,
        "showValues",
        boolean,
        null
      )
    );
    boolean =
      $.getStorageElseApplicationProperty("showColorsSmallField", true) as
      Boolean;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Show colors small field",
        null,
        "showColorsSmallField",
        boolean,
        null
      )
    );
    boolean =
      $.getStorageElseApplicationProperty("showValuesSmallField", false) as
      Boolean;
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        "Show values small field",
        null,
        "showValuesSmallField",
        boolean,
        null
      )
    );

    mi = new WatchUi.MenuItem("Distance (debug)", null, "menuDistanceDebug", null);
    mi.setSubLabel("Manage distance settings");
    menu.addItem(mi);

    var view = new $.DataFieldSettingsView();
    WatchUi.pushView(
      menu,
      new $.DataFieldSettingsMenuDelegate(view),
      WatchUi.SLIDE_IMMEDIATE
    );
    return true;
  }

  public function onBack() as Boolean {
    getApp().onSettingsChanged();
    return false;
  }
}

// Globals
//Always in km
function getDistanceMenuSubLabel(key as Application.PropertyKeyType) as String {
  return ((getStorageValue(key, 0.0f) as Float) / 1000).format("%.2f") + " km";
}

function getFocusMenuSubLabel(key as Application.PropertyKeyType) as String {
  var current =
    $.getStorageElseApplicationProperty(key, Types.FocusNothing) as
    Types.EnumFocus;
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
    default:
      return "Nothing";
  }
}
