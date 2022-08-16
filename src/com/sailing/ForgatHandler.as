package com.sailing
{
import com.sailing.instruments.BaseInstrument;
import com.utils.Blinker;

import starling.animation.Tween;
import starling.core.Starling;

import starling.display.DisplayObject;
import flash.events.EventDispatcher;

import starling.utils.deg2rad;

public class ForgatHandler extends EventDispatcher {

    private static var _enableTween:Boolean = true;

    private var _mutato:DisplayObject;
    private var _control:BaseInstrument;
    private var _options:Object;
    private var _min:Number;
    private var _max:Number;
    private var _offsetToZero:Number;
    private var _duration:Number;
    private var _blinker:Boolean;
    private var _length:Number;

    private var _relativeAngle:Number;

    private var _tween:Tween;

    public function ForgatHandler(mutato:DisplayObject, control:BaseInstrument, options:Object = null) {
        _mutato = mutato;
        _control = control;
        _options = options;
        _offsetToZero = 0;
        _min = 0;
        _max = 360;
        _duration = 0.5;
        _blinker = false;
        if(options!=null) {
            _offsetToZero = (options.hasOwnProperty("offsetToZero")) ? options["offsetToZero"] : 0;
            _min = (options.hasOwnProperty("min")) ? options["min"] : 0;
            _max = (options.hasOwnProperty("max")) ? options["max"] : 360;
            _blinker = (options.hasOwnProperty("blinker")) ? options["blinker"] : false;
            _duration = (options.hasOwnProperty("duration")) ? options["duration"] : 0.5;
        }
        _length = (_min<_max) ? _max-_min : 360-_min+_max;

        _mutato.rotation = deg2rad(_offsetToZero);
        _tween = new Tween(_mutato, _duration);
        _tween.onComplete = dispatch;
    }

    public function forgat(angle:Number, options:Object = null):void {
        _mutato.visible = true;

        var needTween:Boolean = true;
        var speedRatio:Number = 1;
        if(options!=null) {
            needTween = (options.hasOwnProperty("needTween")) ? options["needTween"] : true;
            speedRatio = (options.hasOwnProperty("speedRatio")) ? options["speedRatio"] : 1;
        }
        if(!_enableTween) {
            needTween = false;
        }

        if(_length==360) {
            angle %= 360;
            if(angle<-180) {
                angle += 360;
            } else if(angle>180) {
                angle -= 360;
            }

            rotate(angle, needTween, speedRatio);
        } else {
            if(angle>_length) {
                addOut();
                angle = _length;
            } else if(angle<0) {
                addOut();
                angle = 0;
            } else {
                removeOut();
            }

            rotate(angle + _offsetToZero, needTween, speedRatio);
        }
    }

    private function rotate(angle:Number, needTween:Boolean, speedRatio:Number):void {
        if(_mutato.rotation<0 && angle>90) {
            angle -= 360;
        } else if(_mutato.rotation>0 && angle<-90) {
            angle += 360;
        }

        if(needTween) {
            _tween.reset(_mutato, _duration/speedRatio);
            _tween.animate("rotation", deg2rad(angle));
            Starling.juggler.add(_tween);
        } else {
            Starling.juggler.removeTweens(_mutato);
            _mutato.rotation = deg2rad(angle);
            dispatch();
        }
    }

    private function addOut():void {
        if(_blinker) {
            Blinker.addDoubleObject(_mutato);
        } else {
            _mutato.alpha = 0.5;
        }
    }

    private function removeOut():void {
        if(_blinker) {
            Blinker.removeDoubleObject(_mutato);
        } else {
            _mutato.alpha = 1.0;
        }
    }

        private function dispatch():void {
//            dispatchEvent(new ForgatEvent(_mutato, _control));
        }

        private function withoutTween():void {
//            TweenLite.killTweensOf(_mutato);
            Starling.juggler.removeTweens(_mutato);
            _mutato.rotation = _relativeAngle;
            dispatch();
        }

        public function get min():Number {
            return _min;
        }

        public function get max():Number {
            return _max;
        }

        public function get offsetToZero():Number {
            return _offsetToZero;
        }

        public function get duration():Number {
            return _duration;
        }

        public static function get enableTween():Boolean {
            return _enableTween;
        }

        public static function set enableTween(value:Boolean):void {
            _enableTween = value;
        }

        public function get mutato():DisplayObject {
            return _mutato;
        }

    }
}

