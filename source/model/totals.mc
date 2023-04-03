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
  private var distanceToDestination as Float = 0.0f;

  private var rideStarted as Boolean = false;

  private var currentProfile as String = "";

  private const MAX_COUNTER = 10;
  private var triggerFrontTyre as String = "";
  private var totalDistanceFrontTyre as Float = 0.0f;
  private var maxDistanceFrontTyre as Float = 0.0f;
  private var counterFrontTyreReset as Number = MAX_COUNTER;
  private var triggerBackTyre as String = "";
  private var totalDistanceBackTyre as Float = 0.0f;
  private var maxDistanceBackTyre as Float = 0.0f;
  private var counterBackTyreReset as Number = MAX_COUNTER;

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
    return totalDistanceRide + elapsedDistanceActivity;
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
    if (distanceToDestination > 0) {
      return distanceToDestination;
    }
    return totalDistanceLastRide;
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
  public function HasFrontTyreTrigger() as Boolean {
    return (
      $.gShowFront &&
      triggerFrontTyre.length() > 0 &&
      maxDistanceFrontTyre > 1000
    );
  }
  public function HasBackTyreTrigger() as Boolean {
    return (
      $.gShowBack && triggerBackTyre.length() > 0 && maxDistanceBackTyre > 1000
    );
  }

  public function GetCurrentProfile() as String {
    return currentProfile;
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
        if (info.timerState == Activity.TIMER_STATE_STOPPED) {
          rideStarted = false;
        }
        if (!rideStarted && info.timerState == Activity.TIMER_STATE_ON) {
          handleDate();
        }
      }
    }

    distanceToDestination = 0.0f;
    if (info has :distanceToDestination) {
      if (info.distanceToDestination != null) {
        distanceToDestination = info.distanceToDestination as Float;
      }
    }
    
    handleTyreReset(Activity.getProfileInfo());
  }

  function handleTyreReset(profile as Activity.ProfileInfo?) as Void {
    if (profile == null || profile.name == null) {
      return;
    }
    var profileName = (profile.name as String).toLower();
    if (!currentProfile.equals(profileName)) {
      currentProfile = profileName;
      counterFrontTyreReset = MAX_COUNTER;
      counterBackTyreReset = MAX_COUNTER;
    }
    if (triggerFrontTyre.length() > 0 && totalDistanceFrontTyre > 0.0f) {
      if (profileName.find(triggerFrontTyre) != null) {
        counterFrontTyreReset = counterFrontTyreReset - 1;
        if (counterFrontTyreReset < 0) {
          totalDistanceFrontTyre = 0.0f;
          attentionReset();
        } else {
          attentionCountDown();
        }
      }
    }

    if (triggerBackTyre.length() > 0 && totalDistanceBackTyre > 0.0f) {
      if (profileName.find(triggerBackTyre) != null) {
        counterBackTyreReset = counterBackTyreReset - 1;
        if (counterBackTyreReset < 0) {
          totalDistanceBackTyre = 0.0f;
          attentionReset();
        } else {
          attentionCountDown();
        }
      }
    }
  }

  function attentionCountDown() as Void {
    if (Attention has :playTone) {
      if (Attention has :ToneProfile) {
        var toneProfileBeeps =
          [new Attention.ToneProfile(1500, 50)] as
          Lang.Array<Attention.ToneProfile>;
        Attention.playTone({ :toneProfile => toneProfileBeeps });
      } else {
        Attention.playTone(Attention.TONE_ALERT_LO);
      }
    }
  }

  function attentionReset() as Void {
    if (Attention has :playTone) {
      Attention.playTone(Attention.TONE_RESET);
    }
  }

  function save() as Void {
    try {
      setDistanceAsMeters(
        "totalDistance",
        totalDistance + elapsedDistanceActivity
      );

      Toybox.Application.Storage.setValue("lastYear", lastYear);
      setDistanceAsMeters("totalDistanceLastYear", totalDistanceLastYear);

      Toybox.Application.Storage.setValue("currentYear", currentYear);
      setDistanceAsMeters(
        "totalDistanceYear",
        totalDistanceYear + elapsedDistanceActivity
      );

      Toybox.Application.Storage.setValue("currentMonth", currentMonth);
      setDistanceAsMeters("totalDistanceLastMonth", totalDistanceLastMonth);
      setDistanceAsMeters(
        "totalDistanceMonth",
        totalDistanceMonth + elapsedDistanceActivity
      );

      Toybox.Application.Storage.setValue("currentWeek", currentWeek);
      setDistanceAsMeters("totalDistanceLastWeek", totalDistanceLastWeek);
      setDistanceAsMeters(
        "totalDistanceWeek",
        totalDistanceWeek + elapsedDistanceActivity
      );

      setDistanceAsMeters("totalDistanceLastRide", totalDistanceLastRide);
      setDistanceAsMeters(
        "totalDistanceRide",
        totalDistanceRide + elapsedDistanceActivity
      );

      setDistanceAsMeters(
        "totalDistanceFrontTyre",
        totalDistanceFrontTyre + elapsedDistanceActivity
      );
      setDistanceAsMeters(
        "totalDistanceBackTyre",
        totalDistanceBackTyre + elapsedDistanceActivity
      );

      System.println("totals saved");
      load(false);
    } catch (ex) {
      ex.printStackTrace();
    }
  }

  hidden function setDistanceAsMeters(
    key as String,
    distanceMeters as Float
  ) as Void {
    Toybox.Application.Storage.setValue(key, distanceMeters);
  }

  // Storage values are in meters, (overrule) properties are in kilometers!
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

    if (processDate) {
      handleDate();
    }

    var switchFB = Storage.getValue("switch_front_back") ? true : false;

    triggerFrontTyre = (
      getApplicationProperty("triggerFrontTyre", "") as String
    ).toLower();
    totalDistanceFrontTyre = getDistanceAsMeters("totalDistanceFrontTyre");
    maxDistanceFrontTyre = getDistanceAsMeters("maxDistanceFrontTyre");
    var reset = Storage.getValue("reset_front") ? true : false;
    if (reset) {
      totalDistanceFrontTyre = 0.0f;
      Storage.setValue("reset_front", false);
      if (!switchFB) {
        setDistanceAsMeters("totalDistanceFrontTyre", totalDistanceFrontTyre);
      }
    }
    triggerBackTyre = (
      getApplicationProperty("triggerBackTyre", "") as String
    ).toLower();
    totalDistanceBackTyre = getDistanceAsMeters("totalDistanceBackTyre");
    maxDistanceBackTyre = getDistanceAsMeters("maxDistanceBackTyre");
    reset = Storage.getValue("reset_back") ? true : false;
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
      var overrule = getApplicationProperty(key, 0) as Number;
      if (overrule > 0) {
        setProperty(key, 0);
        var distanceMeters = overrule.toFloat() * 1000.0f;
        Toybox.Application.Storage.setValue(key, distanceMeters);
        return distanceMeters as Float;
      }
      return getStorageValue(key, 0.0f) as Float;
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
    if (!rideStarted) {
      // Only valid rides..
      if (totalDistanceRide > 5.0) {
        totalDistanceLastRide = totalDistanceRide;
        dateChange = true;
      }
      totalDistanceRide = 0.0f;
      rideStarted = true;
    }

    if (dateChange) {
      save();
    }
  }

  hidden function setProperty(
    key as PropertyKeyType,
    value as PropertyValueType
  ) as Void {
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
