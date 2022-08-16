/**
 * Created by pepusz on 2014.09.04..
 */
package com.sailing {
import com.alarm.AlarmHandler;
import com.inAppPurchase.CommonStore;
import com.polar.PolarContainer;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.minMax.MinMaxHandler;
import com.store.Statuses;
import com.utils.Blinker;
import com.utils.TimestampCalculator;

import components.InstrumentHandler;
import components.MessagesHandler;

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import starling.events.Event;

public class ParserNotifier {
    private static var _instance:ParserNotifier
    private var tempTimestamp:Number = 0;
    private var timestampCalculator:TimestampCalculator;
    private var listeners:Vector.<IParserListener> = new <IParserListener>[];
    private var _isValidTimer:Timer;

    public function ParserNotifier() {
        if (_instance == null) {
            listeners.push(MinMaxHandler.instance);
//            listeners.push(CombinedDataHandler.instance);
            _isValidTimer = new Timer(1000);
            _isValidTimer.addEventListener(TimerEvent.TIMER, isValidTimer_timerHandler, false, 0, true);
            listeners.push(MessagesHandler.instance);
            listeners.push(InstrumentHandler.instance);
            reset();

            CommonStore.instance.addEventListener("instruments-enabled", onEnabled);
            CommonStore.instance.addEventListener("polar-enabled", onEnabled);
        }
    }

    public function reset():void {
        SailData.actualSailData = new SailData();
        timestampCalculator = new TimestampCalculator();
        _isValidTimer.reset();
        //TODO invalidate datas, notify listeners etc
        var keys:Array = SailData.ownProperties;
        var length:int = keys.length;
        for (var i:int = 0; i < length; i++) {
            notifyListenersInvalidated(keys[i]);
        }
    }

    public function stop():void {
        reset();
    }

    public function start():void {
        _isValidTimer.start();
    }

    public function updateSailDatas(data:Object):void {
        var key:String = data.key;
        var newData = data.data;
        if (data == null || key == null || newData == null) return;
        if (key === "vdm" || key === "vdo") {
            return;
        } //AIS data handled in other area

        if (tempTimestamp == 0) {
            tempTimestamp = -1//new Date().time;
        }
        //        trace(new Date(SailData.actualSailData.sailDataTimestamp).toString())
        if (TimestampCalculator.isKeyHasTimestamp(key)) {
            if (key == "zda") {
                tempTimestamp = timestampCalculator.dateFromNmeaTimestamp(newData.hour, newData.min, newData.sec, newData.utc);
            } else {
                tempTimestamp = timestampCalculator.dateFromNmeaTimestamp(newData.hour, newData.min, newData.sec); //new Date().time
            }
            if (tempTimestamp == -1) {
                tempTimestamp = timestampCalculator.actualTimestamp;
            }
            PolarContainer.instance.timestampChange(tempTimestamp);

        }

        updateListeners(key, newData);
//        SailData.actualSailData.sailDataTimestamp = tempTimestamp;
//        newData.lastTimestamp = getTimer();
//        SailData.actualSailData[key] = newData;
//        CombinedDataHandler.instance.sailDataChanged(key);
//        notifyListenersSailDataChanged(key);
//        AlarmHandler.instance.sailDataChanged(key, newData);
//        if (key === "truewindc" || key === "positionandspeed" || key === "vhw") {
//            PolarContainer.instance.addLiveData(newData);
//        }
    }

    public function updateListeners(key:String, data:BaseSailData):void {
        data.lastTimestamp = getTimer();
        SailData.actualSailData[key] = data;
        CombinedDataHandler.instance.sailDataChanged(key);
        notifyListenersSailDataChanged(key);
        AlarmHandler.instance.sailDataChanged(key, data);
        if (key === "truewindc" || key === "positionandspeed" || key === "vhw") {
            PolarContainer.instance.addLiveData(data);
        }
    }

    private function notifyListenersSailDataChanged(key:String):void {
        for (var i:int = 0; i < listeners.length; i++) {
            listeners[i].sailDataChanged(key);
        }
    }

    private function notifyListenersPreInvalidated(key:String):void {
        for (var i:int = 0; i < listeners.length; i++) {
//            if (listeners[i] is InstrumentHandler && !CommonStore.instance.isInstrumentsEnabled) {
//                continue;
//            }
            listeners[i].sailDataPreInvalidated(key);
        }
    }

    private function notifyListenersInvalidated(key:String):void {
        for (var i:int = 0; i < listeners.length; i++) {
//            if (listeners[i] is InstrumentHandler && !CommonStore.instance.isInstrumentsEnabled) {
//                continue;
//            }
            listeners[i].sailDataInvalidated(key);
        }
    }

    public static function get instance():ParserNotifier {
        if (_instance == null) {
            _instance = new ParserNotifier();
        }
        return _instance;
    }


    private function isValidTimer_timerHandler(event:TimerEvent):void {
        var keys:Array = SailData.ownProperties;
        var length:int = keys.length;
        var key:String;
        for (var i:int = 0; i < length; i++) {
            key = keys[i];
            if (SailData.actualSailData[key].isInPreValid && !(SailData.actualSailData[key] as BaseSailData).isPreValid()) {
                SailData.actualSailData[key].isInPreValid = false;
                notifyListenersPreInvalidated(key)
            }
            if (SailData.actualSailData[key].isInValid && !(SailData.actualSailData[key] as BaseSailData).isValid()) {
                SailData.actualSailData[key].isInValid = false;
                notifyListenersInvalidated(key)
            }
        }
    }

    public function checkValidations():void {
        var keys:Array = SailData.ownProperties;
        var length:int = keys.length;
        var key:String;
        for (var i:int = 0; i < length; i++) {
            key = keys[i];
            if (!SailData.actualSailData[key].isInPreValid) {
                notifyListenersPreInvalidated(key)
            }
            if (!SailData.actualSailData[key].isInValid) {
                notifyListenersInvalidated(key)
            }
        }
    }

    public function activate():void {
        if (Statuses.instance.socketStatus || _isValidTimer.running) {
            var listener:IParserListener;
            var length:int = listeners.length;
            var keys:Array = SailData.ownProperties;
            var keysLength:int = keys.length;
            for (var i:int = 0; i < length; i++) {
                listener = listeners[i];
                if (listener is InstrumentHandler) {
                    listener.sailDataChanged(null);
                }
                if (listener is MinMaxHandler) {
                    for (var j:int = 0; j < keysLength; j++) {
                        listener.sailDataChanged(keys[j]);
                    }
                }
            }
        }

        checkValidations();
//        if (CommonStore.instance.isInstrumentsEnabled) {
//            checkValidations();
//        } else {
//            checkPreviewStatus();
//        }
    }

//    public function deactivate():void {
//        Blinker.clear();
//
//        var keys:Array = SailData.ownProperties;
//        var length:int = keys.length;
//        for (var i:int = 0; i < listeners.length; i++) {
//            if (listeners[i] is InstrumentHandler) {
//                for (var j:int = 0; j < length; j++) {
//                    listeners[i].sailDataInvalidated(keys[j]);
//                }
//                break;
//            }
//        }
//    }

//    private function checkPreviewStatus():void {
//        var keys:Array = SailData.ownProperties;
//        var length:int = keys.length;
//        var key:String;
//        for (var i:int = 0; i < listeners.length; i++) {
//            if (listeners[i] is InstrumentHandler) {
//                for (var j:int = 0; j < length; j++) {
//                    (Statuses.instance.socketStatus || _isValidTimer.running) ? listeners[i].sailDataPreInvalidated(keys[j]) : listeners[i].sailDataInvalidated(keys[j]);
//                }
//                break;
//            }
//        }
//    }

    private function onEnabled(event:Event):void {
        activate();
    }
}
}
