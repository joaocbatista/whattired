import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var gShowColors as Boolean = true;
var gShowValues as Boolean = true;
var gShowColorsSmallField as Boolean = true;
var gShowValuesSmallField as Boolean = false;
var gShowCurrentProfile as Boolean = false;
var gShowFocusSmallField as Types.EnumFocus = Types.FocusNothing;

var gShowOdo as Boolean = true;
var gShowYear as Boolean = true;
var gShowMonth as Boolean = true;
var gShowWeek as Boolean = true;
var gShowRide as Boolean = true;
var gShowFront as Boolean = true;
var gShowBack as Boolean = true;
var gNrOfDefaultFields as Number = 5;

class whattiredApp extends Application.AppBase {
  var mTotals as Totals = new Totals();

  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    mTotals.save();
  }

  //! Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    loadUserSettings();
    return [new whattiredView()] as Array<Views or InputDelegates>;
  }

  //! Return the settings view and delegate for the app
  //! @return Array Pair [View, Delegate]
  public function getSettingsView() as Array<Views or InputDelegates>? {
    return (
      [new $.DataFieldSettingsView(), new $.DataFieldSettingsDelegate()] as
      Array<Views or InputDelegates>
    );
  }

  function onSettingsChanged() {
    loadUserSettings();
  }

  (:typecheck(disableBackgroundCheck))
  function loadUserSettings() as Void {
    try {
      System.println("Load usersettings");

      mTotals.load(true);
      $.gShowColors =
        $.getStorageElseApplicationProperty("showColors", true) as Boolean;
      $.gShowValues =
        $.getStorageElseApplicationProperty("showValues", true) as Boolean;
      $.gShowColorsSmallField =
        $.getStorageElseApplicationProperty("showColorsSmallField", true) as
        Boolean;
      $.gShowValuesSmallField =
        $.getStorageElseApplicationProperty("showValuesSmallField", false) as
        Boolean;

      $.gShowFocusSmallField =
        $.getStorageElseApplicationProperty(
          "showFocusSmallField",
          Types.FocusNothing
        ) as Types.EnumFocus;

      var showFields = (
        getApplicationProperty("showFields", "ORMWYFB") as String
      ).toUpper();
      $.gShowOdo = showFields.find("O") != null;
      $.gShowYear = showFields.find("Y") != null;
      $.gShowMonth = showFields.find("M") != null;
      $.gShowWeek = showFields.find("W") != null;
      $.gShowRide = showFields.find("R") != null;

      $.gShowFront = showFields.find("F") != null;
      $.gShowBack = showFields.find("B") != null;
      $.gNrOfDefaultFields = 0;
      if ($.gShowOdo) {
        $.gNrOfDefaultFields = $.gNrOfDefaultFields + 1;
      }
      if ($.gShowYear) {
        $.gNrOfDefaultFields = $.gNrOfDefaultFields + 1;
      }
      if ($.gShowMonth) {
        $.gNrOfDefaultFields = $.gNrOfDefaultFields + 1;
      }
      if ($.gShowWeek) {
        $.gNrOfDefaultFields = $.gNrOfDefaultFields + 1;
      }
      if ($.gShowRide) {
        $.gNrOfDefaultFields = $.gNrOfDefaultFields + 1;
      }

      System.println("loadUserSettings loaded");
    } catch (ex) {
      ex.printStackTrace();
    }
  }
}

function getApp() as whattiredApp {
  return Application.getApp() as whattiredApp;
}
