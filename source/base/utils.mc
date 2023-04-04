import Toybox.System;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;
import Toybox.Application;

const MILE = 1.609344;
const FEET = 3.281;

function getStorageValue(
  key as Application.PropertyKeyType,
  dflt as Application.PropertyValueType
) as Application.PropertyValueType {
  try {
    var val = Toybox.Application.Storage.getValue(key);
    if (val != null) {
      return val;
    }
  } catch (ex) {
    return dflt;
  }
  return dflt;
}

function getApplicationProperty(
  key as Application.PropertyKeyType,
  dflt as Application.PropertyValueType
) as Application.PropertyValueType {
  try {
    var val = Toybox.Application.Properties.getValue(key);
    if (val != null) {
      return val;
    }
  } catch (e) {
    return dflt;
  }
  return dflt;
}

// Same field in properties and storage
// For booleans, and enums
function getStorageElseApplicationProperty(
  key as Application.PropertyKeyType,
  dflt as Application.PropertyValueType
) as Application.PropertyValueType {
  try {
    var overrule = getStorageValue(key, null);
    if (overrule == null) {
      return getApplicationProperty(key, dflt);
    }

    Application.Properties.setValue(key, overrule);
    Toybox.Application.Storage.deleteValue(key);
    return overrule;
  } catch (ex) {
    ex.printStackTrace();
    return dflt;
  }
}

function percentageOf(value as Numeric?, max as Numeric?) as Numeric {
  if (value == null || max == null) {
    return 0.0f;
  }
  if (max <= 0) {
    return 0.0f;
  }
  return value / (max / 100.0);
}

function drawPercentageLine(
  dc as Dc,
  x as Number,
  y as Number,
  maxwidth as Number,
  percentage as Numeric,
  height as Number,
  color as ColorType
) as Void {
  var wPercentage = (maxwidth / 100.0) * percentage;
  dc.setColor(color, Graphics.COLOR_TRANSPARENT);

  dc.fillRectangle(x, y, wPercentage, height);
  dc.drawPoint(x + maxwidth, y);
}

function drawPercentageCircle(
  dc as Dc,
  x as Number,
  y as Number,
  radius as Number,
  perc as Numeric,
  penWidth as Number
) as Void {
  if (perc == null || perc == 0) {
    return;
  }

  if (perc > 100) {
    perc = 100;
  }
  var degrees = 3.6 * perc;

  var degreeStart = 180; // 180deg == 9 o-clock
  var degreeEnd = degreeStart - degrees; // 90deg == 12 o-clock

  dc.setPenWidth(penWidth);
  dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, degreeStart, degreeEnd);
  dc.setPenWidth(1.0);
}

function meterToFeet(meter as Numeric?) as Float {
  if (meter == null) {
    return 0.0f;
  }
  return (meter * FEET) as Float;
}

function kilometerToMile(km as Numeric?) as Float {
  if (km == null) {
    return 0.0f;
  }
  return (km / MILE) as Float;
}

function getMatchingFont(
  dc as Dc,
  fontList as Array,
  maxwidth as Number,
  text as String,
  startIndex as Number
) as FontType {
  var index = startIndex;
  var font = fontList[index] as FontType;
  var widthValue = dc.getTextWidthInPixels(text, font);

  while (widthValue > maxwidth && index > 0) {
    index = index - 1;
    font = fontList[index] as FontType;
    widthValue = dc.getTextWidthInPixels(text, font);
  }
  // System.println("font index: " + index);
  return font;
}

/* TODO
var percentColors = [
    { pct: 0.0, color: { r: 0xff, g: 0x00, b: 0 } },
    { pct: 0.5, color: { r: 0xff, g: 0xff, b: 0 } },
    { pct: 1.0, color: { r: 0x00, g: 0xff, b: 0 } } ];

var getColorForPercentage = function(pct) {
    for (var i = 1; i < percentColors.length - 1; i++) {
        if (pct < percentColors[i].pct) {
            break;
        }
    }
    var lower = percentColors[i - 1];
    var upper = percentColors[i];
    var range = upper.pct - lower.pct;
    var rangePct = (pct - lower.pct) / range;
    var pctLower = 1 - rangePct;
    var pctUpper = rangePct;
    var color = {
        r: Math.floor(lower.color.r * pctLower + upper.color.r * pctUpper),
        g: Math.floor(lower.color.g * pctLower + upper.color.g * pctUpper),
        b: Math.floor(lower.color.b * pctLower + upper.color.b * pctUpper)
    };
    return 'rgb(' + [color.r, color.g, color.b].join(',') + ')';
    // or output as hex if preferred
};
*/
function percentageToColor(percentage as Numeric?) as ColorType {
  // if (Graphics has :createColor) {

  // }
  if (percentage == null || percentage == 0) {
    return Graphics.COLOR_WHITE;
  }
  if (percentage < 45) {
    return Colors.COLOR_WHITE_GRAY_2;
  }
  if (percentage < 55) {
    return Colors.COLOR_WHITE_GRAY_3;
  }
  if (percentage < 65) {
    return Colors.COLOR_WHITE_BLUE_3;
  }
  if (percentage < 70) {
    return Colors.COLOR_WHITE_DK_BLUE_3;
  }
  if (percentage < 75) {
    return Colors.COLOR_WHITE_LT_GREEN_3;
  }
  if (percentage < 80) {
    return Colors.COLOR_WHITE_GREEN_3;
  }
  if (percentage < 85) {
    return Colors.COLOR_WHITE_YELLOW_3;
  }
  if (percentage < 95) {
    return Colors.COLOR_WHITE_ORANGE_3;
  }
  if (percentage == 100) {
    return Colors.COLOR_WHITE_ORANGERED_2;
  }
  if (percentage < 105) {
    return Colors.COLOR_WHITE_ORANGERED_3;
  }
  if (percentage < 115) {
    return Colors.COLOR_WHITE_ORANGERED2_3;
  }
  if (percentage < 125) {
    return Colors.COLOR_WHITE_RED_3;
  }

  if (percentage < 135) {
    return Colors.COLOR_WHITE_DK_RED_3;
  }

  if (percentage < 145) {
    return Colors.COLOR_WHITE_PURPLE_3;
  }

  if (percentage < 155) {
    return Colors.COLOR_WHITE_DK_PURPLE_3;
  }
  return Colors.COLOR_WHITE_DK_PURPLE_4;
}

  // https://htmlcolorcodes.com/  -> use tint 3
module Colors {
  // color scale
  const COLOR_WHITE_1 = 0xfbeee6;
  const COLOR_WHITE_2 = 0xfbfcfc;
  const COLOR_WHITE_3 = 0xf7f9f9;
  const COLOR_WHITE_4 = 0xf4f6f7;

  const COLOR_WHITE_GRAY_1 = 0xf2f4f4;
  const COLOR_WHITE_GRAY_2 = 0xe5e8e8;
  const COLOR_WHITE_GRAY_3 = 0xccd1d1;
  const COLOR_WHITE_GRAY_4 = 0xbfc9ca;

  const COLOR_WHITE_BLUE_1 = 0xebf5fb;
  const COLOR_WHITE_BLUE_2 = 0xd6eaf8;
  const COLOR_WHITE_BLUE_3 = 0xaed6f1;
  const COLOR_WHITE_BLUE_4 = 0x85c1e9;

  const COLOR_WHITE_DK_BLUE_1 = 0xeaf2f8;
  const COLOR_WHITE_DK_BLUE_2 = 0xd4e6f1;
  const COLOR_WHITE_DK_BLUE_3 = 0xa9cce3;
  const COLOR_WHITE_DK_BLUE_4 = 0x7fb3d5;

  const COLOR_WHITE_LT_GREEN_1 = 0xe8f8f5;
  const COLOR_WHITE_LT_GREEN_2 = 0xd1f2eb;
  const COLOR_WHITE_LT_GREEN_3 = 0xa3e4d7;
  const COLOR_WHITE_LT_GREEN_4 = 0x76d7c4;

  const COLOR_WHITE_GREEN_1 = 0xe9f7ef;
  const COLOR_WHITE_GREEN_2 = 0xd4efdf;
  const COLOR_WHITE_GREEN_3 = 0xa9dfbf;
  const COLOR_WHITE_GREEN_4 = 0x7dcea0;

  const COLOR_WHITE_YELLOW_1 = 0xfef9e7;
  const COLOR_WHITE_YELLOW_2 = 0xfcf3cf;
  const COLOR_WHITE_YELLOW_3 = 0xf9e79f;
  const COLOR_WHITE_YELLOW_4 = 0xf7dc6f;

  const COLOR_WHITE_ORANGE_1 = 0xfef5e7;
  const COLOR_WHITE_ORANGE_2 = 0xfdebd0;
  const COLOR_WHITE_ORANGE_3 = 0xfad7a0;
  const COLOR_WHITE_ORANGE_4 = 0xf8c471;

  const COLOR_WHITE_ORANGERED_1 = 0xfdf2e9;
  const COLOR_WHITE_ORANGERED_2 = 0xfae5d3;
  const COLOR_WHITE_ORANGERED_3 = 0xf5cba7;
  const COLOR_WHITE_ORANGERED_4 = 0xf0b27a;

  const COLOR_WHITE_ORANGERED2_1 = 0xfbeee6;
  const COLOR_WHITE_ORANGERED2_2 = 0xf6ddcc;
  const COLOR_WHITE_ORANGERED2_3 = 0xedbb99;
  const COLOR_WHITE_ORANGERED2_4 = 0xe59866;

  const COLOR_WHITE_RED_1 = 0xfdedec;
  const COLOR_WHITE_RED_2 = 0xfadbd8;
  const COLOR_WHITE_RED_3 = 0xf5b7b1;
  const COLOR_WHITE_RED_4 = 0xf1948a;

  const COLOR_WHITE_DK_RED_1 = 0xf9ebea;
  const COLOR_WHITE_DK_RED_2 = 0xf2d7d5;
  const COLOR_WHITE_DK_RED_3 = 0xe6b0aa;
  const COLOR_WHITE_DK_RED_4 = 0xd98880;

  const COLOR_WHITE_PURPLE_1 = 0xf5eef8;
  const COLOR_WHITE_PURPLE_2 = 0xe8daef;
  const COLOR_WHITE_PURPLE_3 = 0xd7bde2;
  const COLOR_WHITE_PURPLE_4 = 0xc39bd3;

  const COLOR_WHITE_DK_PURPLE_1 = 0xf4ecf7;
  const COLOR_WHITE_DK_PURPLE_2 = 0xe8daef;
  const COLOR_WHITE_DK_PURPLE_3 = 0xd2b4de;
  const COLOR_WHITE_DK_PURPLE_4 = 0xbb8fce;

  const COLOR_WHITE_BLACK_1 = 0xeaecee;
  const COLOR_WHITE_BLACK_2 = 0xd5d8dc;
  const COLOR_WHITE_BLACK_3 = 0xabb2b9;
  const COLOR_WHITE_BLACK_4 = 0x808b96;
}
