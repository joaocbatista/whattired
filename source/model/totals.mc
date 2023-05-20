import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Activity;
import Toybox.Math;
import Toybox.StringUtil;
import Toybox.Attention;

class Totals {
  private var elapsedDistanceActivity as Float = 0.0f;
  // odo
  private var totalDistance as Float = 0.0f;
  private var maxDistance as Float = 0.0f;

  private var lastYear as Number = 0;
  private var totalDistanceLastYear as Float = 0.0f;
  private var currentYear as Number = 0;
  private var totalDistanceYear as Float = 0.0f;

  private var totalDistanceLastMonth as Float = 0.0f;
  private var currentMonth as Number = 0;
  private var totalDistanceMonth as Float = 0.0f;

  private var currentWeek as Number = 0;
  private var totalDistanceLastWeek as Float = 0.0f;
  private var totalDistanceWeek as Float = 0.0f;

  private var totalDistanceLastRide as Float = 0.0f;
  private var totalDistanceRide as Float = 0.0f;
  private var startDistanceCourse as Float = 0.0f;
  private var totalDistanceToDestination as Float = 0.0f;

  private var rideStarted as Boolean = false;
  private var rideTimerState as Number = Activity.TIMER_STATE_OFF;

  private var totalDistanceFrontTyre as Float = 0.0f;
  private var maxDistanceFrontTyre as Float = 0.0f;
  private var totalDistanceBackTyre as Float = 0.0f;
  private var maxDistanceBackTyre as Float = 0.0f;

  public function GetTotalDistance() as Float {
    return totalDistance + elapsedDistanceActivity;
  }
  public function GetMaxDistance() as Float {
    return maxDistance;
  }
  public function GetTotalDistanceYear() as Float {
    return totalDistanceYear + elapsedDistanceActivity;
  }
  public function GetTotalDistanceMonth() as Float {
    return totalDistanceMonth + elapsedDistanceActivity;
  }
  public function GetTotalDistanceWeek() as Float {
    return totalDistanceWeek + elapsedDistanceActivity;
  }
  public function GetTotalDistanceRide() as Float {
    return elapsedDistanceActivity;
  }
  public function GetTotalDistanceLastYear() as Float {
    return totalDistanceLastYear;
  }
  public function GetTotalDistanceLastMonth() as Float {
    return totalDistanceLastMonth;
  }
  public function GetTotalDistanceLastWeek() as Float {
    return totalDistanceLastWeek;
  }
  public function GetTotalDistanceLastRide() as Float {
    return totalDistanceLastRide;
  }
  public function GetElapsedDistanceToDestination() as Float {
    return elapsedDistanceActivity - startDistanceCourse;
  }
  public function GetDistanceToDestination() as Float {
    return totalDistanceToDestination;
  }
  public function IsCourseActive() as Boolean {
    System.println("totalDistanceToDestination:");
    System.println(totalDistanceToDestination / 1000.0);
    System.println("GetElapsedDistanceToDestination()");
    System.println(GetElapsedDistanceToDestination() / 1000.0);
    System.println("startDistanceCourse()");
    System.println(startDistanceCourse / 1000.0);
    System.println("elapsedDistanceActivity");
    System.println(elapsedDistanceActivity / 1000.0);

    return totalDistanceToDestination > 0;
  }

  public function IsActivityStopped() as Boolean {
    return rideTimerState == Activity.TIMER_STATE_STOPPED;
  }

  public function GetTotalDistanceFrontTyre() as Float {
    return totalDistanceFrontTyre + elapsedDistanceActivity;
  }
  public function GetMaxDistanceFrontTyre() as Float {
    return maxDistanceFrontTyre;
  }
  public function GetTotalDistanceBackTyre() as Float {
    return totalDistanceBackTyre + elapsedDistanceActivity;
  }
  public function GetMaxDistanceBackTyre() as Float {
    return maxDistanceBackTyre;
  }

  public function HasOdo() as Boolean {
    return $.gShowOdo;
  }
  public function HasYear() as Boolean {
    return $.gShowYear;
  }
  public function HasMonth() as Boolean {
    return $.gShowMonth;
  }
  public function HasWeek() as Boolean {
    return $.gShowWeek;
  }
  public function HasRide() as Boolean {
    return $.gShowRide;
  }
  public function HasFrontTyre() as Boolean {
    return $.gShowFront; // && maxDistanceFrontTyre >= 1000;
  }
  public function HasBackTyre() as Boolean {
    return $.gShowBack; // && maxDistanceBackTyre >= 1000;
  }

  function initialize() {}

  function compute(info as Activity.Info) as Void {
    if (info has :elapsedDistance) {
      if (info.elapsedDistance != null) {
        elapsedDistanceActivity = info.elapsedDistance as Float;
      } else {
        elapsedDistanceActivity = 0.0f;
      }
    }

    if (info has :timerState) {
      if (info.timerState != null) {
        rideTimerState = info.timerState as Number;
        if (rideTimerState == Activity.TIMER_STATE_STOPPED) {
          rideStarted = false;
        }
        if (!rideStarted && rideTimerState == Activity.TIMER_STATE_ON) {
          handleDate();
        }
      }
    }

    totalDistanceToDestination = 0.0f;
    if (info has :distanceToDestination) {
      if (info.distanceToDestination != null) {
        totalDistanceToDestination = info.distanceToDestination as Float;
      }
    }
    // Remeber the distance, when course is started
    if (totalDistanceToDestination == 0.0f) {
      startDistanceCourse = 0.0f;
    } else if (startDistanceCourse == 0.0f) {
      startDistanceCourse = elapsedDistanceActivity;
    }
  }

  function save(loadValues as Boolean) as Void {
    try {
      setDistanceAsMeters("totalDistance", totalDistance + elapsedDistanceActivity);

      Toybox.Application.Storage.setValue("lastYear", lastYear);
      setDistanceAsMeters("totalDistanceLastYear", totalDistanceLastYear);

      Toybox.Application.Storage.setValue("currentYear", currentYear);
      setDistanceAsMeters("totalDistanceYear", totalDistanceYear + elapsedDistanceActivity);

      Toybox.Application.Storage.setValue("currentMonth", currentMonth);
      setDistanceAsMeters("totalDistanceLastMonth", totalDistanceLastMonth);
      setDistanceAsMeters("totalDistanceMonth", totalDistanceMonth + elapsedDistanceActivity);

      Toybox.Application.Storage.setValue("currentWeek", currentWeek);
      setDistanceAsMeters("totalDistanceLastWeek", totalDistanceLastWeek);
      setDistanceAsMeters("totalDistanceWeek", totalDistanceWeek + elapsedDistanceActivity);

      System.println(
        Lang.format("save: rideStarted [$1$] ride [$2$] last ride [$3$] ", [
          rideStarted,
          elapsedDistanceActivity,
          totalDistanceLastRide,
        ])
      );

      setDistanceAsMeters("totalDistanceLastRide", totalDistanceLastRide);
      setDistanceAsMeters("totalDistanceRide", elapsedDistanceActivity);

      setDistanceAsMeters("totalDistanceFrontTyre", totalDistanceFrontTyre + elapsedDistanceActivity);
      setDistanceAsMeters("totalDistanceBackTyre", totalDistanceBackTyre + elapsedDistanceActivity);

      System.println("totals saved");
      if (loadValues) {        
        load(false);
      }
    } catch (ex) {
      ex.printStackTrace();
    }
  }

  hidden function setDistanceAsMeters(key as String, distanceMeters as Float) as Void {
    Toybox.Application.Storage.setValue(key, distanceMeters);
  }

  // Storage values are in meters, (overrule) properties are in kilometers!
  // Save will happen during pause / stop switch to connect iq widget
  // so load values and correct with elapsed distance.
  function load(processDate as Boolean) as Void {
    totalDistance = getDistanceAsMeters("totalDistance");
    maxDistance = getDistanceAsMeters("maxDistance");

    lastYear = $.getStorageValue("lastYear", 0) as Number;
    totalDistanceLastYear = getDistanceAsMeters("totalDistanceLastYear");
    currentYear = $.getStorageValue("currentYear", 0) as Number;
    totalDistanceYear = getDistanceAsMeters("totalDistanceYear");

    currentMonth = $.getStorageValue("currentMonth", 0) as Number;
    totalDistanceLastMonth = getDistanceAsMeters("totalDistanceLastMonth");
    totalDistanceMonth = getDistanceAsMeters("totalDistanceMonth");

    currentWeek = $.getStorageValue("currentWeek", 0) as Number;
    totalDistanceLastWeek = getDistanceAsMeters("totalDistanceLastWeek");
    totalDistanceWeek = getDistanceAsMeters("totalDistanceWeek");

    totalDistanceLastRide = getDistanceAsMeters("totalDistanceLastRide");
    totalDistanceRide = getDistanceAsMeters("totalDistanceRide");

    System.println(
      Lang.format("load: rideStarted [$1$] ride [$2$] last ride [$3$] ", [
        rideStarted,
        totalDistanceRide,
        totalDistanceLastRide,
      ])
    );

    if (processDate) {
      handleDate();
    }

    totalDistanceFrontTyre = getDistanceAsMeters("totalDistanceFrontTyre");
    maxDistanceFrontTyre = getDistanceAsMeters("maxDistanceFrontTyre");
    totalDistanceBackTyre = getDistanceAsMeters("totalDistanceBackTyre");
    maxDistanceBackTyre = getDistanceAsMeters("maxDistanceBackTyre");
  }

  function triggerFrontBack() as Void {
    var switchFB = $.getStorageValue("switch_front_back", false) as Boolean;

    totalDistanceFrontTyre = getDistanceAsMeters("totalDistanceFrontTyre");
    maxDistanceFrontTyre = getDistanceAsMeters("maxDistanceFrontTyre");
    totalDistanceBackTyre = getDistanceAsMeters("totalDistanceBackTyre");
    maxDistanceBackTyre = getDistanceAsMeters("maxDistanceBackTyre");

    var reset = $.getStorageValue("reset_front", false) as Boolean;
    if (reset) {
      totalDistanceFrontTyre = 0.0f;
      Storage.setValue("reset_front", false);
      if (!switchFB) {
        setDistanceAsMeters("totalDistanceFrontTyre", totalDistanceFrontTyre);
      }
    }

    reset = $.getStorageValue("reset_back", false) as Boolean;
    if (reset) {
      totalDistanceBackTyre = 0.0f;
      Storage.setValue("reset_back", false);
      if (!switchFB) {
        setDistanceAsMeters("totalDistanceBackTyre", totalDistanceFrontTyre);
      }
    }

    if (switchFB) {
      Storage.setValue("switch_front_back", false);
      var tmpBack = totalDistanceBackTyre;
      totalDistanceBackTyre = totalDistanceFrontTyre;
      totalDistanceFrontTyre = tmpBack;
      setDistanceAsMeters("totalDistanceFrontTyre", totalDistanceFrontTyre);
      setDistanceAsMeters("totalDistanceBackTyre", totalDistanceBackTyre);
    }
  }

  hidden function getDistanceAsMeters(key as String) as Float {
    try {
      return $.getStorageValue(key, 0.0f) as Float;
    } catch (ex) {
      ex.printStackTrace();
      return 0.0f;
    }
  }

  hidden function handleDate() as Void {
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var dateChange = false;
    if (currentYear == 0) {
      dateChange = true;

      totalDistanceYear = 0.0f;
      currentYear = today.year;

      currentMonth = today.month as Number;
      totalDistanceLastMonth = 0.0f;
      totalDistanceMonth = 0.0f;

      currentWeek = getWeekNumber(Time.now());
      totalDistanceLastWeek = 0.0f;
      totalDistanceWeek = 0.0f;

      totalDistanceLastRide = 0.0f;
      totalDistanceRide = 0.0f;
    }

    // year change
    if (currentYear != today.year) {
      dateChange = true;
      totalDistanceLastYear = totalDistanceYear;
      lastYear = currentYear;

      totalDistanceYear = 0.0f;
      currentYear = today.year;
    }
    // month change
    var month = today.month as Number;
    if (currentMonth != month) {
      dateChange = true;
      currentMonth = month;
      totalDistanceLastMonth = totalDistanceMonth;
      totalDistanceMonth = 0.0f;
    }
    // week change
    var week = getWeekNumber(Time.now());
    if (currentWeek != week) {
      dateChange = true;
      currentWeek = week;
      totalDistanceLastWeek = totalDistanceWeek;
      totalDistanceWeek = 0.0f;
    }

    // ride started - via activity?
    if (!rideStarted && rideTimerState == Activity.TIMER_STATE_ON) {
      // Only valid rides..
      if (totalDistanceRide > 500.0) {
        totalDistanceLastRide = totalDistanceRide;
        dateChange = true;
      }
      totalDistanceRide = 0.0f; // same as elapseddistance
      rideStarted = true;
      System.println(
        Lang.format("handledate: rideStarted [$1$] ride [$2$] last ride [$3$] ", [
          rideStarted,
          totalDistanceRide,
          totalDistanceLastRide,
        ])
      );
    }

    if (dateChange) {
      save(true);
    }
  }

  hidden function setProperty(key as PropertyKeyType, value as PropertyValueType) as Void {
    Application.Properties.setValue(key, value);
  }

  hidden function getWeekNumber(time as Time.Moment) as Number {
    var day = Gregorian.info(time, Time.FORMAT_SHORT);

    var options = {
      :year => day.year - 1,
      :month => 12,
      :day => 31,
      :hour => 0,
      :minute => 0,
    };
    var firstDayOfYear = Gregorian.moment(options);
    var seconds = time.compare(firstDayOfYear);
    return (Math.round(seconds / (86400 * 7)) + 1) as Number;
  }
}

class Total {
  public var title as String = "";
  public var abbreviated as String = "";
  public var distance as Float = 0.0f;
  public var distanceLast as Float = 0.0f;
}
