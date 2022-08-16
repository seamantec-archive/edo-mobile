/**
 * Created by seamantec on 04/12/14.
 */
package com.utils {

import com.polar.PolarContainer;
import com.sailing.socket.SocketDispatcher;
import com.store.Statuses;

import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.Timer;

public class SaveHandler {

    private static var _instance:SaveHandler;

    private var _instruments:Object;
    private var _timer:Timer;

    public function SaveHandler() {
        _instruments = new Object();
        _timer = new Timer(30000);
        _timer.addEventListener(TimerEvent.TIMER, onTimer);
    }

    public static function get instance():SaveHandler {
        if(_instance==null) {
            _instance = new SaveHandler();
        }

        return _instance;
    }

    public function setState(uid:String, value:String):void {
        _instruments[uid] = value;

        start();
    }

    public function hasState(uid:String):Boolean {
        return (_instruments!=null) ? _instruments.hasOwnProperty(uid) : false;
    }

    public function getState(uid:String):String {
        return _instruments[uid];
    }

    private function onTimer(event:TimerEvent):void {
//        _timer.stop();
        save();
    }

    public function load():void {
        var array:ByteArray = EdoLocalStore.getItem("instrumentStates");
        if(array!=null) {
            _instruments = array.readObject();
        }
    }

    public function start():void {
        if(_timer.running) {
            _timer.reset();
        }
        _timer.start();
    }

    public function save():void {
        var array:ByteArray;
        if(Statuses.instance.socketStatus && !SocketDispatcher.instance.isDemoConnected) {
            var stream:FileStream = new FileStream();
            stream.open(File.applicationStorageDirectory.resolvePath("configs/cloud.flh"), FileMode.WRITE);
            array = new ByteArray();
            PolarContainer.instance.dataContainer.fillUpByteArray(array);
            stream.writeBytes(array, 0, array.length);
            stream.close();
        } else if(_timer.running) {
            _timer.stop();
        }

        array = new ByteArray();
        array.writeObject(_instruments);
        EdoLocalStore.setItem("instrumentStates", array);
    }

    public function clear(uids:Array):void {
        if(uids!=null && uids.length>0) {
            var prefix:String = uids[0].substring(0, uids[0].indexOf("_"));
            for each(var uid:String in _instruments) {
                if(uid.indexOf(prefix)==0 && uids.indexOf(uid)==-1) {
                    delete _instruments[uid];
                }
            }
        }
    }
}
}
