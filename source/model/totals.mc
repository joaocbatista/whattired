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

class Totals {
  private var elapsedDistanceActivity as Float = 0.0f;
  // odo
  private var totalDistance as Float = 0.0f;

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

  private var rideStarted as Boolean = false;
  
  public function GetTotalDistance() as Float { return totalDistance + elapsedDistanceActivity; }
  public function GetTotalDistanceYear() as Float { return totalDistanceYear + elapsedDistanceActivity; }
  public function GetTotalDistanceMonth() as Float { return totalDistanceMonth + elapsedDistanceActivity; }
  public function GetTotalDistanceWeek() as Float { return totalDistanceWeek + elapsedDistanceActivity; }
  public function GetTotalDistanceRide() as Float { return totalDistanceRide + elapsedDistanceActivity; }
  public function GetTotalDistanceLastYear() as Float { return totalDistanceLastYear; }
  public function GetTotalDistanceLastMonth() as Float { return totalDistanceLastMonth; }
  public function GetTotalDistanceLastWeek() as Float { return totalDistanceLastWeek; }
  public function GetTotalDistanceLastRide() as Float { return totalDistanceLastRide; }

  function initialize() {}

  function compute(info as Activity.Info) as Void {
    if(info has :elapsedDistance){
        if(info.elapsedDistance != null){
            elapsedDistanceActivity = info.elapsedDistance as Float;
        } else {
            elapsedDistanceActivity = 0.0f;
        }
    }
  
    if(info has :timerState){
        if(info.timerState != null){
          if (info.timerState == Activity.TIMER_STATE_STOPPED) {
            rideStarted = false;
          } 
          if (!rideStarted && (info.timerState == Activity.TIMER_STATE_ON)) {
            handleDate();
          }
        } 
    }    
  }

  function save()  as Void {
    setDistanceAsMeters("totalDistance", (totalDistance + elapsedDistanceActivity));
    
    Toybox.Application.Storage.setValue("lastYear", lastYear);
    setDistanceAsMeters("totalDistanceLastYear", totalDistanceLastYear);
  
    Toybox.Application.Storage.setValue("currentYear", currentYear);    
    setDistanceAsMeters("totalDistanceYear", (totalDistanceYear + elapsedDistanceActivity));

    Toybox.Application.Storage.setValue("currentMonth", currentMonth);
    setDistanceAsMeters("totalDistanceLastMonth", totalDistanceLastMonth);
    setDistanceAsMeters("totalDistanceMonth", (totalDistanceMonth + elapsedDistanceActivity));

    Toybox.Application.Storage.setValue("currentWeek", currentWeek);
    setDistanceAsMeters("totalDistanceLastWeek", totalDistanceLastWeek);    
    setDistanceAsMeters("totalDistanceWeek", (totalDistanceWeek + elapsedDistanceActivity));

    setDistanceAsMeters("totalDistanceLastRide", totalDistanceLastRide);    
    setDistanceAsMeters("totalDistanceRide", (totalDistanceRide + elapsedDistanceActivity));

    load(false);
  }

  hidden function setDistanceAsMeters(key as String, distanceMeters as Float) as Void {
    Toybox.Application.Storage.setValue(key, distanceMeters);
  }

  // Storage values are in meters, (overrule) properties are in kilometers!
  function load(processDate as Boolean)  as Void {
    totalDistance = getDistanceAsMeters("totalDistance");

    lastYear = getStorageValue("lastYear", 0) as Number;  
    totalDistanceLastYear = getDistanceAsMeters("totalDistanceLastYear");  
    currentYear = getStorageValue("currentYear", 0) as Number;  
    totalDistanceYear = getDistanceAsMeters("totalDistanceYear");  

    currentMonth = getStorageValue("currentMonth", 0) as Number;  
    totalDistanceLastMonth = getDistanceAsMeters("totalDistanceLastMonth");  
    totalDistanceMonth = getDistanceAsMeters("totalDistanceMonth");  
    
    currentWeek = getStorageValue("currentWeek", 0) as Number;  
    totalDistanceLastWeek = getDistanceAsMeters("totalDistanceLastWeek");  
    totalDistanceWeek = getDistanceAsMeters("totalDistanceWeek");  

    totalDistanceLastRide = getDistanceAsMeters("totalDistanceLastRide");  
    totalDistanceRide = getDistanceAsMeters("totalDistanceRide");  

    if (processDate) { handleDate(); }
  }

  hidden function getDistanceAsMeters(key as String) as Float {
    var overrule = getApplicationProperty(key, 0) as Number;
    if (overrule > 0) {
      setProperty(key, 0);
      var distanceMeters = overrule.toFloat() * 1000.0f;
      Toybox.Application.Storage.setValue(key, distanceMeters);
      return distanceMeters as Float;
    }
    return getStorageValue(key, 0.0f) as Float;
  }

  hidden function handleDate() as Void {
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var firstRide = false;
    if (currentYear == 0) {
      firstRide = true;

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
      totalDistanceLastYear = totalDistanceYear;
      lastYear = currentYear;

      totalDistanceYear = 0.0f;
      currentYear = today.year;
    }
    // month change
    var month = today.month as Number;
    if (currentMonth != month) {      
      currentMonth = month;
      totalDistanceLastMonth = totalDistanceMonth;
      totalDistanceMonth = 0.0f;
    }
    // week change
    var week = getWeekNumber(Time.now());
    if (currentWeek != week) {
      currentWeek = week;
      totalDistanceLastWeek = totalDistanceWeek;
      totalDistanceWeek = 0.0f;
    }
    
    // ride started - via activity?
    if (!rideStarted) {
      totalDistanceLastRide = totalDistanceRide;
      totalDistanceRide = 0.0f;  
      rideStarted = true;
    }

    if (firstRide) {
      save();
    }
  }

  hidden function getStorageValue(key as Application.PropertyKeyType, dflt as Application.PropertyValueType ) as Application.PropertyValueType {
      try {
        var val = Toybox.Application.Storage.getValue(key);
        if (val != null) { return val; }
      } catch (e) {
        return dflt;
      }
      return dflt;
  }

  hidden function setProperty(key as PropertyKeyType, value as PropertyValueType) as Void {
    Application.Properties.setValue(key, value);
  }

  hidden function getWeekNumber(time as Time.Moment) as Number {
    var day = Gregorian.info(time, Time.FORMAT_SHORT);

    var options = {
        :year   => day.year - 1,
        :month  => 12,
        :day    => 31,
        :hour   => 0,
        :minute => 0
    };
    var firstDayOfYear = Gregorian.moment(options);
    var seconds = time.compare(firstDayOfYear);
    return (Math.round(seconds / (86400 * 7)) + 1) as Number;    
  }
}