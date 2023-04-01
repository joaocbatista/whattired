import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.StringUtil;

//! Show the text the user picked
class NumericInputView extends WatchUi.View {
  private var _delegate as DistanceMenuDelegate;
  private var _currentValue as Float = 0.0f;
  private var _prompt as String = "";
  private var _cursorPos as Number = -1;
  private var _insert as Boolean = true;
  private var _nrOfItemsInRow as Number = 4;

  // private var _clickType as WatchUi.ClickType?;

  private var _keyPressed as String = "";
  private var _coord as Lang.Array<Lang.Number> =
    [0, 0] as Lang.Array<Lang.Number>;
  private var _keyCoord as Lang.Array<Lang.Array<Lang.Number> > =
    [[]] as Lang.Array<Lang.Array<Lang.Number> >;
  private var _controlCoord as Lang.Array<Lang.Array<Lang.Number> > =
    [[]] as Lang.Array<Lang.Array<Lang.Number> >;

  private var _keys as Array<String> =
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."] as Array<String>;
  private var _controls as Array<String> =
    ["<", "BCK", "DEL", ">", "INS", "CLR", "OK"] as Array<String>;
  private var _valueFormat as String = "%.2f";
  private var _editData as Array<Char> = [] as Array<Char>;
  private var _lineHeight as Number = 20;
  private var _fontHeightMedium as Number = 20;
  private var _keyWidth as Number = 0;
  private var _margin as Number = 0;
  private var _redrawKeyPad as Boolean = true;

  //! Constructor
  public function initialize(
    delegate as DistanceMenuDelegate,
    prompt as String,
    value as Float?
  ) {
    WatchUi.View.initialize();
    _delegate = delegate;
    _prompt = prompt;
    if (value != null) {
      _currentValue = value;
      _cursorPos = _currentValue.format(_valueFormat).length();
      _editData = buildEditedValue(_currentValue, _valueFormat);
    }
    _keyCoord = _keyCoord.slice(0, 0);
    _controlCoord = _controlCoord.slice(0, 0);
  }

  //! Load your resources here
  //! @param dc Device context
  public function onLayout(dc as Dc) as Void {
    _lineHeight = dc.getFontHeight(Graphics.FONT_SMALL);
    _fontHeightMedium = dc.getFontHeight(Graphics.FONT_MEDIUM);

    if (dc.getHeight() < 400) {
      _nrOfItemsInRow = 6;
    }
    // Size of key squares
    _keyWidth = (dc.getWidth() / _nrOfItemsInRow) as Number;
  
    _margin = ((dc.getWidth() - _keyWidth * _nrOfItemsInRow) / 2) as Number;
  }

  //! Restore the state of the app and prepare the view to be shown
  public function onShow() as Void {}

  // rectangle keypad 123 456 789 0. DEL OK

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Dc) as Void {
    var y = 1;
    var fullScreenRefresh = _keyCoord.size() == 0;
    if (fullScreenRefresh) {
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.clear();
    }

    drawTopInfo(dc, y);
    y = (y + 3 * _lineHeight).toNumber();

    if (fullScreenRefresh or _redrawKeyPad) {
      drawKeyPad(dc, y, _keys, _controls);
      _redrawKeyPad = false;
    }

    // @@ debug
    // drawInfoPanel(dc);
  }
  private function buildEditedValue(
    value as Float,
    format as String
  ) as Array<Char> {
    var stringValue = value.format(format);
    return stringValue.toCharArray();
  }

  private function buildCurrentValue(data as Array<Char>) as Float {
    try {
      var stringValue = StringUtil.charArrayToString(data);
      var value = stringValue.toFloat();
      if (value != null) {
        return value;
      }
      return _currentValue;
    } catch (ex) {
      ex.printStackTrace();
    }
    return _currentValue;
  }

  private function drawTopInfo(dc as Dc, yStart as Number) as Void {
    var y = yStart;
    var x = 1;
    var width = dc.getWidth();
    var height = 2.5 * _lineHeight;

    dc.setClip(x, y, width, height);
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      dc.getWidth() / 2,
      y,
      Graphics.FONT_SMALL,
      _prompt,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    y = y + _lineHeight;
    drawEditedValue(dc, y, _editData, _insert);
    dc.clearClip();
  }

  private function drawEditedValue(
    dc as Dc,
    y as Number,
    data as Array<Char>,
    insert as Boolean
  ) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var x = _margin;

    var cursor = "";
    var first = _editData.slice(0, _cursorPos);
    var last = _editData.slice(_cursorPos, null);
    if (last.size() > 0) {
      // cursor is first character of last part
      cursor = StringUtil.charArrayToString(last.slice(0, 1));
      last = last.slice(1, null);
    }

    var textFirst = StringUtil.charArrayToString(first);
    var textLast = StringUtil.charArrayToString(last);

    dc.drawText(
      x,
      y,
      Graphics.FONT_MEDIUM,
      textFirst,
      Graphics.TEXT_JUSTIFY_LEFT
    );
    x = x + dc.getTextWidthInPixels(textFirst, Graphics.FONT_MEDIUM);
    var widthCursor = 0;
    if (cursor.length() > 0) {
      widthCursor = dc.getTextWidthInPixels(cursor, Graphics.FONT_MEDIUM);
      dc.drawText(
        x,
        y,
        Graphics.FONT_MEDIUM,
        cursor,
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }
    // always draw cursor line (can be also at start / end of text)
    if (insert) {
      // insert, show | after cursor pos
      dc.drawLine(x, y, x, y + _fontHeightMedium);
    } else {
      // overwrite, show a bar under key
      dc.fillRectangle(x, y + _fontHeightMedium, widthCursor, 3);
    }
    x = x + widthCursor;

    dc.drawText(
      x,
      y,
      Graphics.FONT_MEDIUM,
      textLast,
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }

  private function drawInfoPanel(dc as Dc) as Void {
    var x = 1;
    var width = dc.getWidth();
    var height = 2 * _lineHeight;
    var y = dc.getHeight() - height;
    dc.setClip(x, y, width, height);

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    var coordInfo = Lang.format("Coord[$1$,$2$] Key:[$3$]", [
      _coord[0],
      _coord[1],
      _keyPressed,
    ]);

    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() - _lineHeight,
      Graphics.FONT_SMALL,
      coordInfo,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.clearClip();
  }

  //! Called when this View is removed from the screen. Save the
  //! state of your app here.
  public function onHide() as Void {}

  public function setCoord(coord as Lang.Array<Lang.Number>) as Void {
    _coord = coord;
  }

  public function onKeyPressed(coord as Lang.Array<Lang.Number>) as Void {
    _keyPressed = getKeyPressed(coord);

    // Controls
    if (_keyPressed.equals("<")) {
      if (_cursorPos > 0) {
        _cursorPos = _cursorPos - 1;
      }
    } else if (_keyPressed.equals(">")) {
      var maxCursorPos = _currentValue.format(_valueFormat).length();
      if (_cursorPos < maxCursorPos) {
        _cursorPos = _cursorPos + 1;
      }
    } else if (_keyPressed.equals("INS")) {
      _insert = !_insert;
      _redrawKeyPad = true;
    } else if (_keyPressed.equals("OK")) {
      _delegate.onAcceptNumericinput(_currentValue);
      WatchUi.popView(WatchUi.SLIDE_RIGHT);
    } else if (_keyPressed.equals("CLR")) {
      _editData = _editData.slice(0, 0);
      _cursorPos = 0;
    } else if (_keyPressed.equals("DEL")) {
      removeKey(true);
    } else if (_keyPressed.equals("BCK")) {
      removeKey(false);
    } else {
      addKey(_keyPressed, _insert);
    }

    _currentValue = buildCurrentValue(_editData);
  }

  private function addKey(key as String, insert as Boolean) as Void {
    if (_editData.size() == 0 || _cursorPos >= _editData.size()) {
      // nothing, or cursor at the end
      _editData.addAll(key.toCharArray());
    } else {
      var first = _editData.slice(0, _cursorPos);
      var last = _editData.slice(_cursorPos, null);
      if (insert) {
        _editData = first.addAll(key.toCharArray()).addAll(last);
      } else {
        // overwrite at cursor position, remove first element from last part
        _editData = first.addAll(key.toCharArray()).addAll(last.slice(1, null));
      }
    }
    _cursorPos = _cursorPos + 1;
  }
  // delete = cursor stays same, remove from right
  private function removeKey(isDelete as Boolean) as Void {
    if (_editData.size() == 0) {
      return;
    }

    var first = _editData.slice(0, _cursorPos);
    var last = _editData.slice(_cursorPos, null);
    if (isDelete) {
      if (last.size() > 0) {
        _editData = first.addAll(last.slice(1, null));
      }
    } else {
      if (first.size() > 0) {
        _editData = first.slice(0, -1).addAll(last);
      } else {
        _editData = last;
      }
      _cursorPos = _cursorPos - 1;
    }
  }

  // public function setClickType(clickType as WatchUi.ClickType) as Void {
  //   _clickType = clickType;
  // }

  public function getKeyPressed(coord as Lang.Array<Lang.Number>) as String {
    try {
      var x = coord[0] as Number;
      var y = coord[1] as Number;
      for (var idxKey = 0; idxKey < _keyCoord.size(); idxKey++) {
        var range = _keyCoord[idxKey] as Lang.Array<Lang.Number>;
        if (
          (range[0] as Number) < x &&
          x < (range[1] as Number) &&
          (range[2] as Number) < y &&
          y < range[3]
        ) {
          return _keys[idxKey];
        }
      }
      for (var idxCtrl = 0; idxCtrl < _controlCoord.size(); idxCtrl++) {
        var range = _controlCoord[idxCtrl] as Lang.Array<Lang.Number>;
        if (
          (range[0] as Number) < x &&
          x < (range[1] as Number) &&
          (range[2] as Number) < y &&
          y < (range[3] as Number)
        ) {
          return _controls[idxCtrl];
        }
      }
    } catch (ex) {
      ex.printStackTrace();
    }
    return "";
  }

  private function drawKeyPad(
    dc as Dc,
    yStart as Number,
    keys as Array<String>,
    controls as Array<String>
  ) as Void {
    var y = yStart;
    var x = _margin;
    var margin = _margin;
    var width = _keyWidth;
    var halfWidth = width / 2;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    _keyCoord = _keyCoord.slice(0, 0);
    _controlCoord = _controlCoord.slice(0, 0);

    // keys
    var idxKey = 0;
    for (idxKey = 0; idxKey < keys.size() && idxKey < 12; idxKey++) {
      if (idxKey > 0) {
        if (idxKey % _nrOfItemsInRow == 0) {
          x = margin;
          y = y + width;
        } else {
          x = x + width;
        }
      }
      dc.drawRectangle(x, y, width, width);
      dc.drawText(
        x + halfWidth,
        y + halfWidth,
        Graphics.FONT_MEDIUM,
        keys[idxKey],
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
      // }
      _keyCoord.add([x, x + width, y, y + width] as Lang.Array<Number>);
    }

    x = margin;
    y = y + width + 2;
    // control keys
    for (var idxCtrl = 0; idxCtrl < controls.size() && idxCtrl < 8; idxCtrl++) {
      if (idxCtrl > 0) {
        if (idxCtrl % _nrOfItemsInRow == 0) {
          x = margin;
          y = y + width;
        } else {
          x = x + width;
        }
      }
      // QND
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      if (controls[idxCtrl].equals("INS")) {
        if (_insert) {
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }
      }
      dc.drawRectangle(x, y, width, width);
      dc.drawText(
        x + halfWidth,
        y + halfWidth,
        Graphics.FONT_MEDIUM,
        controls[idxCtrl],
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
      _controlCoord.add([x, x + width, y, y + width] as Lang.Array<Number>);
    }
  }
}
