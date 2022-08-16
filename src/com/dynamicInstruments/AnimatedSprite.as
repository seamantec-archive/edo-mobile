/**
 * Created by seamantec on 09/10/14.
 */
package com.dynamicInstruments {
import flash.events.TimerEvent;
import flash.utils.Timer;

public class AnimatedSprite extends DynamicSprite {

    private var _currentFrame:int;
    private var _toFrame:int;
    private var _duration:Number;

    private var _timer:Timer;

    public function AnimatedSprite() {
        currentFrame = 0;
        _toFrame = 0;
        _duration = 1000;

        _timer = new Timer(_duration);
        _timer.addEventListener(TimerEvent.TIMER, onTime, false, 0, true);
    }

    public function get currentFrame():int {
        return _currentFrame;
    }

    public function set currentFrame(value:int):void {
        for(var i:int=0; i<totalFrames; i++) {
            if(i==value) {
                _currentFrame = i;
                getChildAt(i).visible = true;
            } else {
                getChildAt(i).visible = false;
            }
        }
    }

    public function get totalFrames():int {
        return numChildren;
    }

    public function get duration():Number {
        return _duration;
    }

    public  function set duration(value:Number):void {
        _duration = value*1000;
    }

    public function playTo(value:int):void {
        _toFrame = (value<0) ? 0 : ((value>(totalFrames-1) ? (totalFrames - 1) : value));
        if(_toFrame!=_currentFrame) {
            _timer.reset();
            _timer.delay = _duration / Math.abs(_toFrame - _currentFrame);
            _timer.start();
        }
    }

    private function onTime(event:TimerEvent):void {
        if(_toFrame==_currentFrame) {
            _timer.reset();
        } else {
            getChildAt(_currentFrame).visible = false;
            if (_toFrame > _currentFrame) {
                _currentFrame++;
            } else if (_toFrame < _currentFrame) {
                _currentFrame--;
            }
            getChildAt(_currentFrame).visible = true;
        }
    }
}
}
