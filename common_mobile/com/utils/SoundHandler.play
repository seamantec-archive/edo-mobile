/**
 * Created by seamantec on 19/09/14.
 */
package com.utils {
import com.alarm.AlarmHandler;
import com.alarm.speech.SpeechHandler;

import flash.events.Event;
import flash.media.SoundChannel;
import flash.utils.ByteArray;
import flash.utils.getTimer;

public class SoundHandler {

//    private static const THRESHOLD:int = 1000;
//    private static var _lastPlayTime:int = 0;
//    private static var _isOnPlay:Boolean = false;
    private static var _enable:Boolean = false;

    public function SoundHandler() {
    }

    public static function playSound():void {
//        if(_enable) && !_isOnPlay && (getTimer()-_lastPlayTime)>THRESHOLD) {
//            var channel:SoundChannel = Assets.assets.playSound("s_bainer2");
//            channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
//            _isOnPlay = true;
//        }
        if(_enable && !SpeechHandler.instance.nowPlaying && !AlarmHandler.instance.hasAlert() && !SpeechHandler.instance.hasSpeech()) {
            var channel:SoundChannel = Assets.assets.playSound("s_bainer2");
        }
    }

//    private static function onComplete(e:Event):void {
//        _lastPlayTime = getTimer();
//        _isOnPlay = false;
//    }

    public static function get enable():Boolean {
        return _enable;
    }

    public static function  set enable(value:Boolean):void {
        _enable = value;
    }

    public static function save():void {
        var data:ByteArray = new ByteArray();
        data.writeBoolean(_enable);
        EdoLocalStore.setItem('soundEnable', data);
    }

    public static function load():void {
        var data:ByteArray = EdoLocalStore.getItem("soundEnable");
        if(data!=null) {
            _enable = data.readBoolean();
        }
    }
}
}
