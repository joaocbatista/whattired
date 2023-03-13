import Toybox.System;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;
import Toybox.Application;

const MILE = 1.609344;
const FEET = 3.281;

function getApplicationProperty(key as Application.PropertyKeyType, dflt as Application.PropertyValueType ) as Application.PropertyValueType {
    try {
      var val = Toybox.Application.Properties.getValue(key);
      if (val != null) { return val; }
    } catch (e) {
      return dflt;
    }
    return dflt;
}

function percentageOf(value as Numeric?, max as Numeric?) as Numeric{
    if (value == null || max == null) {
    return 0.0f;
    }
    if (max <= 0) { return 0.0f; }
    return value / (max / 100.0);
}

function drawPercentageLine(dc as Dc, x as Number, y as Number, maxwidth as Number, percentage as Numeric, height as Number,
                            color as ColorType) as Void {
    var wPercentage = maxwidth / 100.0 * percentage;
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    dc.fillRectangle(x, y, wPercentage, height);
    dc.drawPoint(x + maxwidth, y);
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

 function percentageToColor(percentage as Numeric?) as ColorType {
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

module Colors {
    // color scale
    const COLOR_WHITE_1 = 0xFBEEE6;
    const COLOR_WHITE_2 = 0xFBFCFC;
    const COLOR_WHITE_3 = 0xF7F9F9;
    const COLOR_WHITE_4 = 0xF4F6F7;

    const COLOR_WHITE_GRAY_1 = 0xF2F4F4;
    const COLOR_WHITE_GRAY_2 = 0xE5E8E8;
    const COLOR_WHITE_GRAY_3 = 0xCCD1D1;
    const COLOR_WHITE_GRAY_4 = 0xBFC9CA;

    const COLOR_WHITE_BLUE_1 = 0xEBF5FB;
    const COLOR_WHITE_BLUE_2 = 0xD6EAF8;
    const COLOR_WHITE_BLUE_3 = 0xAED6F1;
    const COLOR_WHITE_BLUE_4 = 0x85C1E9;

    const COLOR_WHITE_DK_BLUE_1 = 0xEAF2F8;
    const COLOR_WHITE_DK_BLUE_2 = 0xD4E6F1;
    const COLOR_WHITE_DK_BLUE_3 = 0xA9CCE3;
    const COLOR_WHITE_DK_BLUE_4 = 0x7FB3D5;

    const COLOR_WHITE_LT_GREEN_1 = 0xE8F8F5;
    const COLOR_WHITE_LT_GREEN_2 = 0xD1F2EB;
    const COLOR_WHITE_LT_GREEN_3 = 0xA3E4D7;
    const COLOR_WHITE_LT_GREEN_4 = 0x76D7C4;

    const COLOR_WHITE_GREEN_1 = 0xE9F7EF;
    const COLOR_WHITE_GREEN_2 = 0xD4EFDF;
    const COLOR_WHITE_GREEN_3 = 0xA9DFBF;
    const COLOR_WHITE_GREEN_4 = 0x7DCEA0;

    const COLOR_WHITE_YELLOW_1 = 0xFEF9E7;
    const COLOR_WHITE_YELLOW_2 = 0xFCF3CF;
    const COLOR_WHITE_YELLOW_3 = 0xF9E79F;
    const COLOR_WHITE_YELLOW_4 = 0xF7DC6F;

    const COLOR_WHITE_ORANGE_1 = 0xFEF5E7;
    const COLOR_WHITE_ORANGE_2 = 0xFDEBD0;
    const COLOR_WHITE_ORANGE_3 = 0xFAD7A0;
    const COLOR_WHITE_ORANGE_4 = 0xF8C471;

    const COLOR_WHITE_ORANGERED_1 = 0xFDF2E9;
    const COLOR_WHITE_ORANGERED_2 = 0xFAE5D3;
    const COLOR_WHITE_ORANGERED_3 = 0xF5CBA7;
    const COLOR_WHITE_ORANGERED_4 = 0xF0B27A;

    const COLOR_WHITE_ORANGERED2_1 = 0xFBEEE6;
    const COLOR_WHITE_ORANGERED2_2 = 0xF6DDCC;
    const COLOR_WHITE_ORANGERED2_3 = 0xEDBB99;
    const COLOR_WHITE_ORANGERED2_4 = 0xE59866;

    const COLOR_WHITE_RED_1 = 0xFDEDEC;
    const COLOR_WHITE_RED_2 = 0xFADBD8;
    const COLOR_WHITE_RED_3 = 0xF5B7B1;
    const COLOR_WHITE_RED_4 = 0xF1948A;

    const COLOR_WHITE_DK_RED_1 = 0xF9EBEA;
    const COLOR_WHITE_DK_RED_2 = 0xF2D7D5;
    const COLOR_WHITE_DK_RED_3 = 0xE6B0AA;
    const COLOR_WHITE_DK_RED_4 = 0xD98880;

    const COLOR_WHITE_PURPLE_1 = 0xF5EEF8;
    const COLOR_WHITE_PURPLE_2 = 0xE8DAEF;
    const COLOR_WHITE_PURPLE_3 = 0xD7BDE2;
    const COLOR_WHITE_PURPLE_4 = 0xC39BD3;

    const COLOR_WHITE_DK_PURPLE_1 = 0xF4ECF7;
    const COLOR_WHITE_DK_PURPLE_2 = 0xE8DAEF;
    const COLOR_WHITE_DK_PURPLE_3 = 0xD2B4DE;
    const COLOR_WHITE_DK_PURPLE_4 = 0xBB8FCE;

    const COLOR_WHITE_BLACK_1 = 0xEAECEE;
    const COLOR_WHITE_BLACK_2 = 0xD5D8DC;
    const COLOR_WHITE_BLACK_3 = 0xABB2B9;
    const COLOR_WHITE_BLACK_4 = 0x808B96;
  }