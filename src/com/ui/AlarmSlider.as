/**
 * Created by seamantec on 13/10/14.
 */
package com.ui {

import com.alarm.AisAlarm;
import com.alarm.Alarm;
import com.common.AppProperties;
import com.utils.Assets;
import com.utils.FontFactory;

import flash.geom.Rectangle;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class AlarmSlider extends Sprite {

    public static const LOW_LIMIT:int = 0;
    public static const HIGH_LIMIT:int = 1;

    private const DEF_HEIGHT:int = 18;

    private var _minValue:Number;
    private var _maxValue:Number;
    private var _stepInterval:Number;
    private var _initWidth:int;
    private var _defaultWidth:int;
    private var _sliderType:int;
    private var _alarm:Alarm;

    private var _distance:Number;
    private var _pixelResolution:Number;
    private var _labelNumberOfSteps:int = 6;
    private var _stepInValue:Number = 0;
    private var _stepInPixel:int;
    private var _labelStepInValue:Number = 0;
    private var _labelStepInPixel:int = 0;
    private var _numberOfSteps:Number;
    private var _roundTo:Number;

    private var _bg:Image;
    private var _tickRuler:Sprite;

    private var _infoLimitArea:Sprite;
    private var _alertLimitArea:Sprite;
    private var _limitAreaOffset:int = 10;
    private var _actualAlertLimit:Number;
    private var _actualInfoLimit:Number;

    private var _actualAlarmValue:Number;

    public function AlarmSlider(minValue:Number, maxValue:Number, stepInterval:Number, initWidth:int, sliderType:int, alarm:Alarm) {
        _minValue = minValue;
        _maxValue = maxValue;
        _stepInterval = stepInterval;
        _initWidth = initWidth;
        _defaultWidth = initWidth;
        _sliderType = sliderType;
        _alarm = alarm;
        initVisualComponents();
    }

    private function initVisualComponents():void {
        calculateInitValues();
        createBackground();
        drawTicks();
        drawInfoLimitArea();
        drawAlertLimitArea();
    }

    private function calculateInitValues():void {
        _distance = _maxValue - _minValue;
        _pixelResolution = _distance / _defaultWidth;
        while (_distance % _labelNumberOfSteps != 0) {
            _labelNumberOfSteps--;
        }
        _stepInValue = _distance / _labelNumberOfSteps;
        _labelStepInPixel = _defaultWidth / _labelNumberOfSteps;
        _labelStepInValue = _distance / _labelNumberOfSteps;
        var oszto:int = 5;
        var _minStepInPixel:int = 60;
        while (oszto > 0 && (_labelStepInPixel / oszto) < _minStepInPixel) {
            oszto--;
        }
        //inner small steps
        _numberOfSteps = oszto;
        _stepInPixel = _labelStepInPixel / oszto;

        _roundTo = 1;
        if (_distance < 4) {
            _roundTo = 0.1;
        }
        if (_stepInterval != _roundTo) {
            _roundTo = _stepInterval;
            if (_roundTo < 1 && _distance > 1000) {
                _roundTo = 1;
            }
        }

    }

    private function createBackground():void {
        if (_bg != null) return;

        _bg = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("slider_bg"));
        _bg.width = _defaultWidth+20
        _bg.x = -10;
        _bg.y = (DEF_HEIGHT - _bg.height) / 2;
        this.addChild(_bg);
    }

    public function getSliderY():Number {
        return _bg.y + (_bg.height / 2);
    }

    private function drawTicks():void {
        if (_tickRuler == null) {
            _tickRuler = new Sprite();
            _tickRuler.x = 0;
            _tickRuler.y = DEF_HEIGHT;
            this.addChild(_tickRuler)
        }
        if (this._distance == 0) {
            return;
        }
        if (_tickRuler.numChildren > 0) {
            _tickRuler.removeChildren(0, _tickRuler.numChildren - 1);
        }

        var tickHeight:int = (int)(DEF_HEIGHT / 4);
        for (var i:int = 0; i < _labelNumberOfSteps + 1; i++) {
            drawSingleBigTick(i, tickHeight);
            for (var j:int = 0; j < _numberOfSteps; j++) {
                drawSingleTick(i, j, tickHeight);
            }
            drawLabels(i, tickHeight);
        }
    }

    private function drawSingleTick(i:int, j:int, tickHeight:int):void {
        var tick:Quad = new Quad(1, tickHeight, 0xffffff);
        tick.x = (i * _labelStepInPixel) + (j * _stepInPixel);
        tick.y = 20;
        _tickRuler.addChild(tick);
    }

    private function drawSingleBigTick(i:int, tickHeight:int):void {
        var tick:Quad = new Quad(1, tickHeight, 0xffffff);
        tick.x = i * _labelStepInPixel;
        tick.y = 20;
        _tickRuler.addChild(tick);
    }

    private function drawLabels(index:int, tickHeight:int):void {
        var field:TextField = FontFactory.getWhiteCenterFont(30, 16, 12);
        field.text = Math.round(_minValue + (_labelStepInValue * index)) + "";
        field.x = (_labelStepInPixel * index) - (field.width / 2);
        field.y = tickHeight + 20;
        _tickRuler.addChild(field);
    }

    private function drawInfoLimitArea():void {
        if (_infoLimitArea == null) {
            _infoLimitArea = new Sprite();
            var bg:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("slider_wh"));
            bg.width = _defaultWidth+20
//            bg.scaleX = _initWidth/240;
//            bg.scaleY = bg.scaleX;
            _infoLimitArea.addChild(bg);
            _infoLimitArea.clipRect = new Rectangle(0, 0, _infoLimitArea.width, DEF_HEIGHT);
        }

        _infoLimitArea.x = -_limitAreaOffset;
        _infoLimitArea.y = (DEF_HEIGHT - _infoLimitArea.height) / 2;
        this.addChild(_infoLimitArea);
    }

    private function drawAlertLimitArea():void {
        if (_alertLimitArea == null) {
            _alertLimitArea = new Sprite();
            var bg:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("slider_red"));
            bg.width = _defaultWidth+20
//            bg.scaleX = _initWidth/240;
//            bg.scaleY = bg.scaleX;
            _alertLimitArea.addChild(bg);
            _alertLimitArea.clipRect = new Rectangle(0, 0, _alertLimitArea.width, DEF_HEIGHT);
        }

        _alertLimitArea.x = -_limitAreaOffset;
        _alertLimitArea.y = (DEF_HEIGHT - _alertLimitArea.height) / 2;
        addChild(_alertLimitArea)
    }

    public function get actualAlertLimit():Number {
        return _actualAlertLimit;
    }

    public function set actualAlertLimit(value:Number):void {
        _actualAlertLimit = value;
        setAlertLimitPosition();
        this.dispatchEvent(new Event("actualAlarmValueChanged"));
    }

    private function setAlertLimitPosition():void {
        var calcX:Number = calculateActualAlertX();
        var rect:Rectangle = _alertLimitArea.clipRect;
        if (_sliderType === LOW_LIMIT) {
            rect.x = 0;
            rect.width = calcX + _limitAreaOffset;
        } else if (_sliderType === HIGH_LIMIT) {
            rect.x = calcX + _limitAreaOffset + 1;
            rect.width = this.width - (calcX + _limitAreaOffset + 1);
        }
        _alertLimitArea.clipRect = rect;
        if (_alarm is AisAlarm) {
            _infoLimitArea.clipRect = rect;
        }
    }

    public function calculateActualAlertX():Number {
        return (_actualAlertLimit - _minValue) / _pixelResolution;
    }

    public function get actualInfoLimit():Number {
        return _actualInfoLimit;
    }

    public function set actualInfoLimit(value:Number):void {
        _actualInfoLimit = _alarm.getPossibleInfoLimit(value);
//        _actualInfoLimit = value;
        setInfoLimitPosition();
        this.dispatchEvent(new Event("actualInfoValueChanged"));
    }

    private function setInfoLimitPosition():void {
        var calcX:Number = calculateActualInfoX();
        var rect:Rectangle = _infoLimitArea.clipRect;
        if (_sliderType === LOW_LIMIT) {
            rect.x = 0;
            rect.width = calcX + _limitAreaOffset + 1;
        } else if (_sliderType === HIGH_LIMIT) {
            rect.x = calcX + _limitAreaOffset;
            rect.width = this.width - (calcX + _limitAreaOffset);
        }
        _infoLimitArea.clipRect = rect;
    }

    public function calculateActualInfoX():Number {
        return (_actualInfoLimit - _minValue) / _pixelResolution;
    }

    public function get actualAlarmValue():Number {
        return _actualAlarmValue;
    }

    public function set actualAlarmValue(value:Number):void {
        _actualAlarmValue = value;
    }

    public function get pixelResolution():Number {
        return _pixelResolution;
    }

    public function get minValue():Number {
        return _minValue;
    }

    public function get maxValue():Number {
        return _maxValue;
    }

    public function get limitAreaOffset():Number {
        return _limitAreaOffset;
    }

    public function moveKnobAlertTo(x:Number):void {
        if (x < 0) {
            x = 0
        } else if (x > _defaultWidth) {
            x = _defaultWidth;
        }
        if (_roundTo >= 1) {
            actualAlertLimit = Math.round((x * _pixelResolution + _minValue) * _roundTo) / _roundTo;
        } else {
            actualAlertLimit = Math.round((x * _pixelResolution + _minValue) / _roundTo) * _roundTo;
        }
    }

    public function moveKnobInfoTo(x:Number):void {
        if (x < 0) {
            x = 0
        } else if (x > _defaultWidth) {
            x = _defaultWidth;
        }

        if (_roundTo >= 1) {
            actualInfoLimit = Math.round((x * _pixelResolution + _minValue) * _roundTo) / _roundTo;
        } else {
            actualInfoLimit = Math.round((x * _pixelResolution + _minValue) / _roundTo) * _roundTo;
        }
    }

    public function setActualInfoLimitWithoutChange(value:Number):void {
        _actualInfoLimit = value;
        setInfoLimitPosition();
    }

    public function setActualAlertLimitWithoutChange(value:Number):void {
        _actualAlertLimit = value;
        setAlertLimitPosition();
    }

    public function unitChanged():void {
        _actualInfoLimit = _alarm.actualInfoLimit;
        setInfoLimitPosition();
        _actualAlertLimit = _alarm.actualAlertLimit;
        setAlertLimitPosition();
    }

    public function setMinMax(min:Number, max:Number):void {
        _minValue = min;
        _maxValue = max;
        initVisualComponents()
    }

}
}
