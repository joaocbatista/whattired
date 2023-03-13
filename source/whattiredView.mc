import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

class whattiredView extends WatchUi.DataField {
    hidden var mDevSettings as System.DeviceSettings = System.getDeviceSettings();
    hidden var mFontText as Graphics.FontDefinition = Graphics.FONT_SMALL;    
    hidden var mLabelWidth as Number = 10;
    hidden var mLineHeight as Number = 10;
    hidden var mHeight as Number = 100;
    hidden var mWidth as Number = 100;

    hidden var mTotals as Totals;

    var mNightMode as Boolean = false;
    var mColor as ColorType = Graphics.COLOR_BLACK;
    var mColorValues as ColorType = Graphics.COLOR_BLACK;
    var mColorValues20 as ColorType = Graphics.COLOR_BLACK;
    var mColorPerc100 as ColorType = Graphics.COLOR_WHITE;
    var mBackgroundColor as ColorType = Graphics.COLOR_WHITE;

    function initialize() {
        DataField.initialize();
        mTotals = getApp().mTotals;        
    }
   
    function onLayout(dc as Dc) as Void {
        mHeight = dc.getHeight();
        mWidth = dc.getWidth();
        if (mHeight < 92) {
          mFontText = Graphics.FONT_XTINY;
        } else {
          mFontText = Graphics.FONT_SMALL;
        }
        mLabelWidth = dc.getTextWidthInPixels("Month", mFontText) + 5;
        mLineHeight = dc.getFontHeight(mFontText);

        var nrOfFields = 5.0f;
        var totalHeight = nrOfFields * mLineHeight;
        if (totalHeight > mHeight) {
          var corr = Math.round((totalHeight - mHeight) / nrOfFields).toNumber() + 1;
          mLineHeight = mLineHeight - corr;
        }        
    }
   
    function onTimerReset() {
      mTotals.save();      
    }        

    function compute(info as Activity.Info) as Void {
        mTotals.compute(info);        
    }

    function onUpdate(dc as Dc) as Void {

        mBackgroundColor = getBackgroundColor();
        mNightMode = (mBackgroundColor == Graphics.COLOR_BLACK);
        dc.setColor(mBackgroundColor, mBackgroundColor);    
        dc.clear();

        if (mNightMode) {      
            mColor = Graphics.COLOR_WHITE;
            mColorValues = Graphics.COLOR_WHITE;      
            mColorValues20 = Graphics.COLOR_LT_GRAY;      
        } else {
            mColor = Graphics.COLOR_BLACK;
            mColorValues = Graphics.COLOR_BLACK;
            mColorValues20 = Graphics.COLOR_BLACK;
        }
    
        dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);

        var showValues = $.gShowValues;
        var showColors = $.gShowColors;
        DrawDistanceLine(dc, 0, "Odo", mTotals.GetTotalDistance(), 0.0f, true, true);
        DrawDistanceLine(dc, 1, "Ride", mTotals.GetTotalDistanceRide(), mTotals.GetTotalDistanceLastRide(), showValues, showColors);
        DrawDistanceLine(dc, 2, "Week", mTotals.GetTotalDistanceWeek(), mTotals.GetTotalDistanceLastWeek(), showValues, showColors);
        DrawDistanceLine(dc, 3, "Month", mTotals.GetTotalDistanceMonth(), mTotals.GetTotalDistanceLastMonth(), showValues, showColors);
        DrawDistanceLine(dc, 4, "Year", mTotals.GetTotalDistanceYear(), mTotals.GetTotalDistanceLastYear(), showValues, showColors);        
    }

    function DrawDistanceLine(dc as Dc, line as Number, label as String, distanceInMeters as Float, 
      lastDistanceInMeters as Float, showValues as Boolean, showColors as Boolean ) as Void {
        var x = 1;
        var y = 1 + (mLineHeight * line);
        
        dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, mFontText, label, Graphics.TEXT_JUSTIFY_LEFT);
        
        x = x + mLabelWidth;
        var units = getUnits(distanceInMeters);
        var value = getDistanceInMeterOrKm(distanceInMeters);
        var formattedValue = getNumberString(value, distanceInMeters);
       
        var perc = -1;
        if (lastDistanceInMeters > 0) {
          perc = percentageOf(distanceInMeters, lastDistanceInMeters);
          if (showColors) {
            drawPercentageLine(dc, x, y + 1, mWidth - x - 1, perc, mLineHeight - 2, percentageToColor(perc));
          }
        }
        if (perc > -1 && perc <= 20) {
          dc.setColor(mColorValues20, Graphics.COLOR_TRANSPARENT);
        } else {
          dc.setColor(mColorValues, Graphics.COLOR_TRANSPARENT);
        }
        if (showValues) {
          if (perc >= 130 && showColors) { dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT); }
          dc.drawText(x, y, mFontText, formattedValue + " " + units, Graphics.TEXT_JUSTIFY_LEFT);     
        }
        // draw perc right   
        if (perc > -1) {
          if (perc >= 130 && showColors) { dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT); }
          dc.drawText(mWidth -1, y, mFontText, perc.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);     
        }
    }

    hidden function getDistanceInMeterOrKm(distanceInMeters as Float) as Float {
      var value = distanceInMeters;
      if (value < 1000) {
        if (mDevSettings.distanceUnits == System.UNIT_STATUTE) {
          value = meterToFeet(value);
        }
      } else {
        if (mDevSettings.distanceUnits == System.UNIT_STATUTE) {
          value = kilometerToMile(value / 1000.0f);
        } else {
          value = value / 1000.0f;
        }
      } 
      return value;
    }

    hidden function getNumberString(distanceInKmOrMiles as Float, distanceInMeters as Float) as String {
      var formatted = distanceInKmOrMiles.format(getFormatString(distanceInMeters));     

      if ((distanceInKmOrMiles < 1000) || (formatted == "")) { return formatted; }

      var wholesPart = formatted.toCharArray();
      var decimalSize = 3; //.00
      var chunkSize = 3;
      var chunks = [];
      var start = (wholesPart.size() - decimalSize) % chunkSize;
      if(start != 0) {
          chunks.add(StringUtil.charArrayToString(wholesPart.slice(0, start)));
      }
      for(var i = start; i < wholesPart.size(); i+= chunkSize) {
          chunks.add(StringUtil.charArrayToString(wholesPart.slice(i, i + chunkSize)));
      }
      
      var numberString = "" as String;
      for (var j = 0; j < chunks.size(); j++) {
        if (numberString == "") {
          numberString = chunks[j] as String;
        } else if (j == chunks.size() - 1) {
          numberString = numberString + chunks[j] as String;
        } else {
          numberString = numberString + " " + chunks[j] as String;
        }
      }
      return numberString;
    }
        
    hidden function getUnits(distanceInMeters as Float) as String {
      // < 1 km -> feet or meters, above miles or kilometers
      if (mDevSettings.distanceUnits == System.UNIT_STATUTE) {
        if (distanceInMeters < 1000) {
          return "f";
        }
        return "mi";
      } else {
        if (distanceInMeters < 1000) {
          return "m";
        }
        return "km";
      }
    }
  
    hidden function getFormatString(distanceInMeters as Float) as String {
      if (distanceInMeters < 1000) {
        return "%.0f";
      }
      if (distanceInMeters < 10000) {
        return "%.2f";
      }
      return "%.2f";
    }
}
// font / 
// color / day/night
// odo # 
// ride perc
// wk # + perc
// month string # + perc
// year  # + perc

// display km / miles
// colors perc