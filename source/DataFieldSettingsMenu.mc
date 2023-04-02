//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

//! The settings menu
class DataFieldSettingsMenu extends WatchUi.Menu2 {
  //! Constructor
  public function initialize() {
    Menu2.initialize({ :title => "Settings" });
  }
}

//! Handles menu input and stores the menu data
class DataFieldSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
  private var _currentMenuItem as MenuItem?;
  private var _view as DataFieldSettingsView;

  //! Constructor
  public function initialize(view as DataFieldSettingsView) {
    Menu2InputDelegate.initialize();
    _view = view;
  }

  //! Handle a menu item selection
  //! @param menuItem The selected menu item
  public function onSelect(menuItem as MenuItem) as Void {
    _currentMenuItem = menuItem;
    var id = menuItem.getId();

    if (id instanceof String && (id.equals("menuDistance") or id.equals("menuDistanceDebug"))) {      
      var distanceMenu = new WatchUi.Menu2({ :title => "Set distance for" });

      var mi = new WatchUi.MenuItem("Odo", null, "totalDistance", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Year", null, "totalDistanceYear", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Month", null, "totalDistanceMonth", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Week", null, "totalDistanceWeek", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Ride", null, "totalDistanceRide", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Front", null, "totalDistanceFrontTyre", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Back", null, "totalDistanceBackTyre", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Max Odo", null, "maxDistance", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem(
        "Last year",
        null,
        "totalDistanceLastYear",
        null
      );
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem(
        "Last month",
        null,
        "totalDistanceLastMonth",
        null
      );
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem(
        "Last week",
        null,
        "totalDistanceLastWeek",
        null
      );
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem(
        "Last ride",
        null,
        "totalDistanceLastRide",
        null
      );
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem(
        "Max front",
        null,
        "maxDistanceFrontTyre",
        null
      );
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      mi = new WatchUi.MenuItem("Max back", null, "maxDistanceBackTyre", null);
      mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
      distanceMenu.addItem(mi);

      var debug = id.equals("menuDistanceDebug");

      WatchUi.pushView(
        distanceMenu,
        new $.DistanceMenuDelegate(debug),
        WatchUi.SLIDE_UP
      );
    } else if (id instanceof String && id.equals("showFocusSmallField")) {
      var focusMenu = new WatchUi.Menu2({ :title => "Show focus on" });
      var current =
        $.getStorageElseApplicationProperty(id as String, Types.FocusNothing) as
        Types.EnumFocus;
      focusMenu.addItem(
        new WatchUi.MenuItem("Nothing", null, Types.FocusNothing, {})
      );
      focusMenu.addItem(new WatchUi.MenuItem("Odo", null, Types.FocusOdo, {}));
      focusMenu.addItem(
        new WatchUi.MenuItem("Year", null, Types.FocusYear, {})
      );
      focusMenu.addItem(
        new WatchUi.MenuItem("Month", null, Types.FocusMonth, {})
      );
      focusMenu.addItem(
        new WatchUi.MenuItem("Week", null, Types.FocusWeek, {})
      );
      focusMenu.addItem(
        new WatchUi.MenuItem("Ride", null, Types.FocusRide, {})
      );
      focusMenu.addItem(
        new WatchUi.MenuItem("Front", null, Types.FocusFront, {})
      );
      focusMenu.addItem(
        new WatchUi.MenuItem("Back", null, Types.FocusBack, {})
      );
      focusMenu.setFocus(current); // 0-index
      WatchUi.pushView(
        focusMenu,
        new $.FocusMenuDelegate(self),
        WatchUi.SLIDE_UP
      );
    } else if (id instanceof String && menuItem instanceof ToggleMenuItem) {
      Storage.setValue(id as String, menuItem.isEnabled());
    }
    // if (WatchUi has :TextPicker) {
    //   WatchUi.pushView(
    //     new WatchUi.TextPicker(currentDistanceInKm.format("%d")),
    //     new $.KeyboardListener(_view, self),
    //     WatchUi.SLIDE_DOWN
    //   );
    // }
  }

  public function onAcceptFocus() as Void {
    // update menu sublabel
    if (_currentMenuItem != null) {
      var mi = _currentMenuItem as MenuItem;
      var id = mi.getId();
      if (id instanceof String && (id as String).equals("showFocusSmallField")) {
        mi.setSubLabel($.getFocusMenuSubLabel(mi.getId() as String));
      }
    }
  }
  // public function cancelCurrent() as Void {
  //   _currentField = "";
  // }
}

class DistanceMenuDelegate extends WatchUi.Menu2InputDelegate {
  private var _currentDistanceField as String = "";
  private var _currentPrompt as String = "";
  private var _currentMenuItem as MenuItem?;
  private var _debug as Boolean = false;

  public function initialize(debug as Boolean) {
    Menu2InputDelegate.initialize();
    _debug = debug;
  }

  public function onSelect(item as MenuItem) as Void {
    _currentDistanceField = item.getId() as String;
    _currentMenuItem = item;
    _currentPrompt = item.getLabel();

    var currentDistanceInKm = (
      ($.getStorageValue(_currentDistanceField, 0.0f) as Float) / 1000
    ).toFloat();
    var view = new $.NumericInputView(
      _debug,
      self,
      _currentPrompt,
      currentDistanceInKm
    );

    Toybox.WatchUi.pushView(
      view,
      new $.NumericInputDelegate(_debug, view, self),
      WatchUi.SLIDE_RIGHT
    );
  }

  public function onAcceptNumericinput(distanceInKm as Float) as Void {
    try {
      if (_currentDistanceField.length() > 0) {
        var distanceInMeters = distanceInKm * 1000.0f;
        Storage.setValue(_currentDistanceField, distanceInMeters);

        // update menu sublabel
        if (_currentMenuItem != null) {
          var mi = _currentMenuItem as MenuItem;
          mi.setSubLabel($.getDistanceMenuSubLabel(mi.getId() as String));
        }
      }
    } catch (ex) {
      ex.printStackTrace();
    }
  }

  public function onNumericinput(editData as Array<Char>, cursorPos as Number, insert as Boolean) as Void {
    // Hack to refresh screen
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    var view = new $.NumericInputView(
      _debug,
      self,
      _currentPrompt,
      0.0f      
    );
    view.setEditData(editData, cursorPos, insert);

    Toybox.WatchUi.pushView(
      view,
      new $.NumericInputDelegate(_debug, view, self),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }

  //! Handle the done item being selected
  public function onDone() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
class FocusMenuDelegate extends WatchUi.Menu2InputDelegate {
  private var _delegate as DataFieldSettingsMenuDelegate;

  public function initialize(delegate as DataFieldSettingsMenuDelegate) {
    Menu2InputDelegate.initialize();
    _delegate = delegate;
  }

  public function onSelect(item as MenuItem) as Void {
    Storage.setValue("showFocusSmallField", item.getId() as Types.EnumFocus);
    onBack();
    return;
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    _delegate.onAcceptFocus();
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }

  //! Handle the done item being selected
  public function onDone() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
