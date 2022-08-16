package com.store {
import com.sailing.socket.ScannerPort;
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

//import com.logbook.LogBookDataHandlerEvent;
//import com.logbook.LogBookDataHandler;
[Bindable]
public class SettingsConfigs extends EventDispatcher {
    private static var _instance:SettingsConfigs = new SettingsConfigs();
    private var _host:String = "192.168.1.100";
    private var _port:int = 3331;
    private var _ownUDPPort:int = 33331;
    private var _logging:Boolean = false;
    private var _isSerialPort:Boolean = false;
    private var _connectionType:int = 0;
//    private var _portName:String;
//    private var _portBaud:int = 9600;
    private var _isLogBookOn:Boolean = true;
    private var _logBookEventInterval:Number = 60 * 60 * 1000;
    private var _isEconomicMode:Boolean = false;

    public function SettingsConfigs() {
        if (_instance != null) {
            //throw new Error("Singleton can only be accessed through Singleton.instance");
        } else {
//            if (Statuses.instance.isMac()) {
//                portName = "/dev/ptys5"
//            } else {
//                portName = "COM1"
//            }
            _instance = this;

        }
    }


    public function get logging():Boolean {
        return _logging;
    }

    public function set logging(value:Boolean):void {
        _logging = value;
    }

    public function get host():String {
        return _host;
    }

    public function set host(value:String):void {
        this._host = value;
    }

    public function get port():Number {
        return _port;
    }

    public function set port(value:Number):void {
        _port = value;
    }


    public function get ownUDPPort():int {
        return _ownUDPPort;
    }


    public function set ownUDPPort(value:int):void {
        _ownUDPPort = value;
    }

    public function get isLogBookOn():Boolean {
        return _isLogBookOn;
    }

    public function get logBookEventInterval():Number {
        return _logBookEventInterval;
    }


    public function set isLogBookOn(value:Boolean):void {
        _isLogBookOn = value;
//        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.ON_OFF_LOGBOOK))
    }

    public function set logBookEventInterval(value:Number):void {
        if (_logBookEventInterval != value) {
            _logBookEventInterval = value;
//            dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.EVENT_INTERVAL_CHANGED))
        }
    }

    public function get isEconomicMode():Boolean {
        return _isEconomicMode;
    }

    public function set isEconomicMode(value:Boolean):void {
        _isEconomicMode = value;
    }

    public static function get instance():SettingsConfigs {
        if (_instance == null)  _instance = new SettingsConfigs();

        return _instance;
    }

    public static function loadBackInstance():void {
        var tempInstance:Object = EdoLocalStore.getItem("settings");
        if (tempInstance != null) {
            var o:Object = tempInstance.readObject();
            _instance.host = o.host;
            _instance.port = o.port;
            if (o.ownUDPPort != null) _instance.ownUDPPort = o.ownUDPPort;
            if (o.connectionType != null) _instance.connectionType = o.connectionType;
            _instance.logging = o.logging;
            _instance.isSerialPort = o.isSerialPort;
            _instance.isLogBookOn = o.isLogBookOn;
            _instance.logBookEventInterval = o.logBookEventInterval;
            _instance.isEconomicMode = o.isEconomicMode;
        }
//        UnitHandler.instance.loadUnits();
//        LLNAngle.instance.load();
//        WindCorrection.instance.load();
        //SpeedToUse.instance.container = GraphHandler.instance.containers;
    }

    public static function saveInstance():void {
        var data:ByteArray = new ByteArray();
        data.writeObject(_instance);
        data.position = 0;
        EdoLocalStore.setItem('settings', data);
//        UnitHandler.instance.saveUnits();
//        LLNAngle.instance.save();
//        WindCorrection.instance.save();
    }

    public function get isSerialPort():Boolean {
        return _isSerialPort;
    }

    public function set isSerialPort(value:Boolean):void {
        _isSerialPort = value;
    }

//
//
//    public function get portName():String {
//        return _portName;
//    }
//
//    public function set portName(value:String):void {
//        _portName = value;
//    }
//
//    public function get portBaud():int {
//        return _portBaud;
//    }
//
//    public function set portBaud(value:int):void {
//        _portBaud = value;
//    }

    public function setPort(port:ScannerPort):void {
        if (port.type == "TCP") {
            _host = port.ip;
            _port = port.port;
            _isSerialPort = false;
        } else {
//            _portName = port.name;
//            _portBaud = port.baud;
            _isSerialPort = true;
        }
        dispatchEvent(new Event("setConnection"));
    }

    public function get connectionType():int {
        return _connectionType;
    }

    public function set connectionType(value:int):void {
        _connectionType = value;
    }
}
}