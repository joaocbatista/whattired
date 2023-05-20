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
  hidden var mLabelWidthFocused as Number = 5;
  hidden var mLineHeight as Number = 10;
  hidden var mHeight as Number = 100;
  hidden var mWidth as Number = 100;

  hidden var mTotals as Totals;
  hidden var mFontFitted as Graphics.FontDefinition = Graphics.FONT_SMALL;
  hidden var mFonts as Array = [
    Graphics.FONT_XTINY,
    Graphics.FONT_TINY,
    Graphics.FONT_SYSTEM_SMALL,
    Graphics.FONT_SYSTEM_MEDIUM,
    Graphics.FONT_SYSTEM_LARGE,
    Graphics.FONT_NUMBER_MILD,
    Graphics.FONT_NUMBER_HOT,
    Graphics.FONT_NUMBER_THAI_HOT,
  ];

  var mNightMode as Boolean = false;
  var mColor as ColorType = Graphics.COLOR_BLACK;
  var mColorTextNoFocus as ColorType = Graphics.COLOR_DK_GRAY;
  var mColorValues as ColorType = Graphics.COLOR_BLACK;
  var mColorValues20 as ColorType = Graphics.COLOR_BLACK;
  var mColorPerc100 as ColorType = Graphics.COLOR_WHITE;
  var mBackgroundColor as ColorType = Graphics.COLOR_WHITE;
  var mShowValues as Boolean = true;
  var mShowColors as Boolean = true;
  var mFocus as Types.EnumFocus = Types.FocusNothing;
  var mSmallField as Boolean = false;
  var mShowFBCircles as Boolean = false;

  function initialize() {
    DataField.initialize();
    mTotals = getApp().mTotals;
    checkFeatures();
  }

  function checkFeatures() as Void {
    $.gCreateColors = Graphics has :createColor;
    try {
      $.gUseSetFillStroke = Graphics.Dc has :setStroke;
      if ($.gUseSetFillStroke) {
        $.gUseSetFillStroke = Graphics.Dc has :setFill;
      }
    } catch (ex) {
      ex.printStackTrace();
    }
  }

  function onLayout(dc as Dc) as Void {
    mHeight = dc.getHeight();
    mWidth = dc.getWidth();
    mShowFBCircles = false;

    if (mHeight <= 100) {
      mFontText = Graphics.FONT_XTINY;
      mShowValues = $.gShowValuesSmallField;
      mShowColors = $.gShowColorsSmallField;
      mFocus = $.gShowFocusSmallField;
      mSmallField = true;
    } else {
      mFontText = Graphics.FONT_SMALL;
      mShowValues = $.gShowValues;
      mShowColors = $.gShowColors;
      mFocus = Types.FocusNothing;
      mSmallField = false;
    }

    mLabelWidth = dc.getTextWidthInPixels("Month", mFontText) + 2;
    mLabelWidthFocused = dc.getTextWidthInPixels("M", mFontText) + 2;
    mLineHeight = dc.getFontHeight(mFontText) - 1;

    var nrOfFields = $.gNrOfDefaultFields;
    // Minus line if small field and focus 1 item
    if (mSmallField && mFocus != Types.FocusNothing) {
      nrOfFields = nrOfFields - 1;
    }

    if (nrOfFields < 4) {
      if (mHeight <= 100) {
        mFontText = Graphics.FONT_SMALL;
      } else {
        mFontText = Graphics.FONT_MEDIUM;
      }
      mLabelWidth = dc.getTextWidthInPixels("Month", mFontText) + 2;
      mLabelWidthFocused = dc.getTextWidthInPixels("M", mFontText) + 2;
      mLineHeight = dc.getFontHeight(mFontText) - 1;
    }
    // Add extra line if front/back enabled
    if (mTotals.HasFrontTyre() || mTotals.HasBackTyre()) {
      nrOfFields = nrOfFields + 1;
      if (!mSmallField) {
        // Room for F B Circles?
        var h = mLineHeight * (nrOfFields - 1);
        if (mHeight - h > 50) {
          mShowFBCircles = true;
        }
      }
    }

    var totalHeight = nrOfFields * (mLineHeight + 1);
    if (totalHeight > mHeight) {
      var corr = Math.round((totalHeight - mHeight) / nrOfFields).toNumber() + 1;
      mLineHeight = mLineHeight - corr;
    }
  }

  // function onTimerPause() {
  //   mTotals.save(false);
  // }

  function onTimerReset() {
    mTotals.save(true);
  }

  // function onTimerStop() {
  //   mTotals.save(false);
  // }

  function compute(info as Activity.Info) as Void {
    mTotals.compute(info);
  }

  function onUpdate(dc as Dc) as Void {
    mBackgroundColor = getBackgroundColor();
    mNightMode = mBackgroundColor == Graphics.COLOR_BLACK;
    dc.setColor(mBackgroundColor, mBackgroundColor);
    dc.clear();

    if (mNightMode) {
      mColor = Graphics.COLOR_WHITE;
      mColorValues = Graphics.COLOR_WHITE;
      mColorValues20 = Graphics.COLOR_LT_GRAY;
      mColorTextNoFocus = Graphics.COLOR_LT_GRAY;
    } else {
      mColor = Graphics.COLOR_BLACK;
      mColorValues = Graphics.COLOR_BLACK;
      mColorValues20 = Graphics.COLOR_BLACK;
      mColorTextNoFocus = Graphics.COLOR_DK_GRAY;
    }

    drawData(dc, mFocus);
  }

  function drawData(dc as Dc, focus as Types.EnumFocus) as Void {
    var line = 0;
    var nothingHasFocus = focus == Types.FocusNothing;

    if (mTotals.HasOdo() && focus != Types.FocusOdo) {
      DrawDistanceLine(
        dc,
        line,
        "Odo",
        "O",
        mTotals.GetTotalDistance(),
        mTotals.GetMaxDistance(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }
    if (mTotals.HasRide() && focus != Types.FocusRide) {
      DrawDistanceLine(
        dc,
        line,
        "Ride",
        "R",
        mTotals.GetTotalDistanceRide(),
        mTotals.GetTotalDistanceLastRide(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }
    if (mTotals.HasWeek() && focus != Types.FocusWeek) {
      DrawDistanceLine(
        dc,
        line,
        "Week",
        "W",
        mTotals.GetTotalDistanceWeek(),
        mTotals.GetTotalDistanceLastWeek(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }
    if (mTotals.HasMonth() && focus != Types.FocusMonth) {
      DrawDistanceLine(
        dc,
        line,
        "Month",
        "M",
        mTotals.GetTotalDistanceMonth(),
        mTotals.GetTotalDistanceLastMonth(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }
    if (mTotals.HasYear() && focus != Types.FocusYear) {
      DrawDistanceLine(
        dc,
        line,
        "Year",
        "Y",
        mTotals.GetTotalDistanceYear(),
        mTotals.GetTotalDistanceLastYear(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }

    if (mShowFBCircles && focus != Types.FocusFront && focus != Types.FocusBack) {
      DrawDistanceCirclesFrontBackTyre(dc, line, mShowValues, mShowColors, nothingHasFocus);
    } else if (
      focus != Types.FocusFront &&
      focus != Types.FocusBack &&
      mTotals.HasFrontTyre() &&
      mTotals.HasBackTyre()
    ) {
      DrawDistanceFrontBackTyre(dc, line, mShowValues, mShowColors, nothingHasFocus);
      line = line + 1;
    } else if (focus != Types.FocusFront && mTotals.HasFrontTyre()) {
      DrawDistanceLine(
        dc,
        line,
        "Front",
        "F",
        mTotals.GetTotalDistanceFrontTyre(),
        mTotals.GetMaxDistanceFrontTyre(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    } else if (focus != Types.FocusBack && mTotals.HasBackTyre()) {
      DrawDistanceLine(
        dc,
        line,
        "Back",
        "B",
        mTotals.GetTotalDistanceBackTyre(),
        mTotals.GetMaxDistanceBackTyre(),
        mShowValues,
        mShowColors,
        nothingHasFocus
      );
      line = line + 1;
    }

    // @@ should be in background, alpha color
    // if (mTotals.IsCourseActive() && focus != Types.FocusCourse) {
    //   DrawDistanceLine(
    //     dc,
    //     line,
    //     "Crse",
    //     "C",
    //     mTotals.GetDistanceToDestination(),
    //     mTotals.GetElapsedDistanceToDestination(),
    //     mShowValues,
    //     mShowColors,
    //     nothingHasFocus
    //   );
    //   line = line + 1;
    // }

    switch (focus) {
      case Types.FocusOdo:
        drawDistanceCircle(dc, "Odo", mTotals.GetTotalDistance(), mTotals.GetMaxDistance(), true, true);
        break;
      case Types.FocusYear:
        drawDistanceCircle(dc, "Year", mTotals.GetTotalDistanceYear(), mTotals.GetTotalDistanceLastYear(), true, true);
        break;
      case Types.FocusMonth:
        drawDistanceCircle(
          dc,
          "Month",
          mTotals.GetTotalDistanceMonth(),
          mTotals.GetTotalDistanceLastMonth(),
          true,
          true
        );
        break;
      case Types.FocusWeek:
        drawDistanceCircle(dc, "Week", mTotals.GetTotalDistanceWeek(), mTotals.GetTotalDistanceLastWeek(), true, true);
        break;
      case Types.FocusRide:
        drawDistanceCircle(dc, "Ride", mTotals.GetTotalDistanceRide(), mTotals.GetTotalDistanceLastRide(), true, true);

        break;
      case Types.FocusFront:
        drawDistanceCircle(
          dc,
          "Front",
          mTotals.GetTotalDistanceFrontTyre(),
          mTotals.GetMaxDistanceFrontTyre(),
          true,
          true
        );
        break;
      case Types.FocusBack:
        drawDistanceCircle(
          dc,
          "Back",
          mTotals.GetTotalDistanceBackTyre(),
          mTotals.GetMaxDistanceBackTyre(),
          true,
          true
        );
        break;
      case Types.FocusCourse:
        if (mTotals.IsCourseActive()) {
          drawDistanceCircle(
            dc,
            "Course",
            mTotals.GetDistanceToDestination(),
            mTotals.GetElapsedDistanceToDestination(),
            true,
            true
          );
        } else {
          drawDistanceCircle(
            dc,
            "Ride",
            mTotals.GetTotalDistanceRide(),
            mTotals.GetTotalDistanceLastRide(),
            true,
            true
          );
        }
        break;
    }
  }

  function DrawDistanceLine(
    dc as Dc,
    line as Number,
    label as String,
    abbreviated as String,
    distanceInMeters as Float,
    lastDistanceInMeters as Float,
    showValues as Boolean,
    showColors as Boolean,
    nothingHasFocus as Boolean
  ) as Void {
    var x = 1;
    var y = mLineHeight * line;

    if (nothingHasFocus) {
      dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, mFontText, label, Graphics.TEXT_JUSTIFY_LEFT);
      x = x + mLabelWidth;
    } else {
      dc.setColor(mColorTextNoFocus, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, mFontText, abbreviated, Graphics.TEXT_JUSTIFY_LEFT);
      x = x + mLabelWidthFocused;
      showValues = false;
      showColors = true;
    }

    var units = getUnits(distanceInMeters);
    var value = getDistanceInMeterOrKm(distanceInMeters);
    var formattedValue = getNumberString(value, distanceInMeters);

    var perc = -1;
    if (lastDistanceInMeters > 0) {
      perc = percentageOf(distanceInMeters, lastDistanceInMeters);
      if (showColors) {
        drawPercentageLine(dc, x, y + 1, mWidth - x - 1, perc, mLineHeight - 1, percentageToColor(perc));
      }
    }
    if (showValues) {
      if (perc > -1 && perc <= 20) {
        dc.setColor(mColorValues20, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(mColorValues, Graphics.COLOR_TRANSPARENT);
      }
      if (perc >= 130 && showColors) {
        dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT);
      }
      dc.drawText(x, y, mFontText, formattedValue + " " + units, Graphics.TEXT_JUSTIFY_LEFT);
      // draw perc right
      if (perc > -1) {
        if (perc >= 130 && showColors) {
          dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(mWidth - 1, y, mFontText, perc.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
      }
    }
  }

  function DrawDistanceFrontBackTyre(
    dc as Dc,
    line as Number,
    showValues as Boolean,
    showColors as Boolean,
    nothingHasFocus as Boolean
  ) as Void {
    var x = 1;
    var y = mLineHeight * line;
    var x2 = x + mWidth / 2;

    if (nothingHasFocus) {
      dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, mFontText, "Front", Graphics.TEXT_JUSTIFY_LEFT);
      dc.drawText(x2, y, mFontText, "Back", Graphics.TEXT_JUSTIFY_LEFT);
      x = x + mLabelWidth;
      x2 = x2 + mLabelWidth;
    } else {
      dc.setColor(mColorTextNoFocus, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, mFontText, "F", Graphics.TEXT_JUSTIFY_LEFT);
      dc.drawText(x2, y, mFontText, "B", Graphics.TEXT_JUSTIFY_LEFT);
      x = x + mLabelWidthFocused;
      x2 = x2 + mLabelWidthFocused;
      showValues = false;
      showColors = true;
    }

    var halfWidth = mWidth / 2;
    var meters_front = mTotals.GetTotalDistanceFrontTyre();
    var maxMeters_front = mTotals.GetMaxDistanceFrontTyre();

    var perc_front = -1;
    if (maxMeters_front > 0) {
      perc_front = percentageOf(meters_front, maxMeters_front);
      if (showColors) {
        drawPercentageLine(dc, x, y + 1, halfWidth - x - 1, perc_front, mLineHeight - 1, percentageToColor(perc_front));
      }
    }
    if (showValues) {
      if (perc_front > -1 && perc_front <= 20) {
        dc.setColor(mColorValues20, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(mColorValues, Graphics.COLOR_TRANSPARENT);
      }
      if (perc_front > -1) {
        if (perc_front >= 130 && showColors) {
          dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(halfWidth - 1, y, mFontText, perc_front.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
      }
    }

    var meters_back = mTotals.GetTotalDistanceBackTyre();
    var maxMeters_back = mTotals.GetMaxDistanceBackTyre();

    var perc_back = -1;
    if (maxMeters_back > 0) {
      perc_back = percentageOf(meters_back, maxMeters_back);
      if (showColors) {
        drawPercentageLine(dc, x2, y + 1, mWidth - x2 - 1, perc_back, mLineHeight - 1, percentageToColor(perc_back));
      }
    }

    if (showValues) {
      if (perc_back > -1 && perc_back <= 20) {
        dc.setColor(mColorValues20, Graphics.COLOR_TRANSPARENT);
      } else {
        dc.setColor(mColorValues, Graphics.COLOR_TRANSPARENT);
      }
      if (perc_back > -1) {
        if (perc_back >= 130 && showColors) {
          dc.setColor(mColorPerc100, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(mWidth - 1, y, mFontText, perc_back.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
      }
    }
  }

  function DrawDistanceCirclesFrontBackTyre(
    dc as Dc,
    line as Number,
    showValues as Boolean,
    showColors as Boolean,
    nothingHasFocus as Boolean
  ) as Void {
    var mr = mHeight;
    if (mHeight > mWidth) {
      mr = mWidth;
    }
    var y = mLineHeight * line;
    var radius = (mr - y) / 2;
    var circleWidth = 10;
    y = y + radius;
    var x = mWidth / 4;
    var x2 = 3 * x;
    radius = radius - circleWidth;
    var yLabel = y - radius;
    var yValue = y;

    if (mTotals.HasFrontTyre()) {
      var meters_front = mTotals.GetTotalDistanceFrontTyre();
      var maxMeters_front = mTotals.GetMaxDistanceFrontTyre();
      var perc_front = -1;
      if (maxMeters_front > 0) {
        perc_front = percentageOf(meters_front, maxMeters_front);
        if (showColors) {
          drawPercentageCircleTarget(dc, x, y, radius, perc_front, circleWidth);
          // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          // dc.drawCircle(x, y, radius);

          // setColorByPerc(dc, perc_front);
          // drawPercentageCircle(dc, x, y, radius, perc_front, circleWidth);

          dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
          dc.drawText(x, yLabel, mFontText, "Front", Graphics.TEXT_JUSTIFY_CENTER);

          var units_front = getUnits(meters_front);
          var value_front = getDistanceInMeterOrKm(meters_front);
          var formattedValue_front = getNumberString(value_front, meters_front);
          dc.drawText(x, yValue, mFontText, formattedValue_front + " " + units_front, Graphics.TEXT_JUSTIFY_CENTER);
        }
      }
    }

    if (mTotals.HasBackTyre()) {
      var meters_back = mTotals.GetTotalDistanceBackTyre();
      var maxMeters_back = mTotals.GetMaxDistanceBackTyre();

      var perc_back = -1;
      if (maxMeters_back > 0) {
        perc_back = percentageOf(meters_back, maxMeters_back);
        if (showColors) {
          drawPercentageCircleTarget(dc, x2, y, radius, perc_back, circleWidth);
          // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          // dc.drawCircle(x2, y, radius);

          // setColorByPerc(dc, perc_back);
          // drawPercentageCircle(dc, x2, y, radius, perc_back, circleWidth);

          dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
          dc.drawText(x2, yLabel, mFontText, "Back", Graphics.TEXT_JUSTIFY_CENTER);

          var units_back = getUnits(meters_back);
          var value_back = getDistanceInMeterOrKm(meters_back);
          var formattedValue_back = getNumberString(value_back, meters_back);
          dc.drawText(x2, yValue, mFontText, formattedValue_back + " " + units_back, Graphics.TEXT_JUSTIFY_CENTER);
        }
      }
    }
  }

  function drawDistanceCircle(
    dc as Dc,
    label as String,
    distanceInMeters as Float,
    lastDistanceInMeters as Float,
    showValues as Boolean,
    showColors as Boolean
  ) as Void {
    var units = getUnits(distanceInMeters);
    var value = getDistanceInMeterOrKm(distanceInMeters);
    var formattedValue = value.format(getFormatString(distanceInMeters));
    var x = mWidth / 2;
    var y = mHeight / 2;
    var radius = x - 5;
    var circleWidth = 8;
    if (x > y) {
      radius = y - 5;
    }

    var perc = -1;
    if (lastDistanceInMeters > 0) {
      perc = percentageOf(distanceInMeters, lastDistanceInMeters);
      if (showColors) {
        drawPercentageCircleTarget(dc, x, y, radius, perc, circleWidth);
      }
    }

    if (showValues) {
      var mFontFitted = getMatchingFont(dc, mFonts, dc.getWidth(), formattedValue, mFonts.size() - 1) as FontType;

      dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, mFontFitted, formattedValue, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

      dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, mHeight - mLineHeight - 2, mFontText, label + " in " + units, Graphics.TEXT_JUSTIFY_CENTER);
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

  // @@ number only fonts doesnt contain spaces ..
  hidden function getNumberString(distanceInKmOrMiles as Float, distanceInMeters as Float) as String {
    var formatted = distanceInKmOrMiles.format(getFormatString(distanceInMeters));

    if (distanceInKmOrMiles < 1000 || formatted == "") {
      return formatted;
    }

    var wholesPart = formatted.toCharArray();
    var decimalSize = 3; //.00
    var chunkSize = 3;
    var chunks = [];
    var start = (wholesPart.size() - decimalSize) % chunkSize;
    if (start != 0) {
      chunks.add(StringUtil.charArrayToString(wholesPart.slice(0, start)));
    }
    for (var i = start; i < wholesPart.size(); i += chunkSize) {
      chunks.add(StringUtil.charArrayToString(wholesPart.slice(i, i + chunkSize)));
    }

    var numberString = "" as String;
    for (var j = 0; j < chunks.size(); j++) {
      if (numberString == "") {
        numberString = chunks[j] as String;
      } else if (j == chunks.size() - 1) {
        numberString = numberString + (chunks[j] as String);
      } else {
        numberString = numberString + " " + (chunks[j] as String);
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
