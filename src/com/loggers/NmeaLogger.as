package com.loggers {

import com.common.AppProperties;
import com.harbor.CloudHandler;


import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import nochump.util.zip.*;

import starling.events.Event;

import starling.events.EventDispatcher;

public class NmeaLogger extends EventDispatcher {

    private static var _instance:NmeaLogger;
    private var _file:File;

    public function NmeaLogger() {
        if (_instance != null) {

        } else {
            _instance = this;
//				var formatter:DateTimeFormatter = new DateTimeFormatter(flash.globalization.LocaleID.DEFAULT, DateTimeStyle.CUSTOM);
//                formatter.dateTimePattern("yyyy dd hmmss")
            var now:Date = new Date();

            _file = File.applicationStorageDirectory.resolvePath("edo_nmea.nmea");
            writeLog("-----------------"+ new Date().time)

//				_file = _file.resolvePath("Edo instruments/")
//                if(!_file.exists){
//                    _file.createDirectory();
//                }
//				_file = _file.resolvePath("nmea/");
//                if(!_file.exists){
//                    _file.createDirectory();
//                }
            //TODO insert mark
        }
    }

    public static function get instance():NmeaLogger {
        if (_instance == null) {
            _instance = new NmeaLogger();
        }
        return _instance;
    }

    public function getNativePath():String {
        return _file.nativePath;
    }

    public function getLogFile():File {
        if (!_file.exists) {
            writeLog("");
        }
        return _file;
    }

    public function writeLog(message:String):void {
        if(!AppProperties.saveLogFileEnabled){
            return;
        }

        if (!_file.exists || _file.size < 1024 * 1024 * 100) {
            var fs:FileStream = new FileStream();
            fs.open(_file, FileMode.APPEND);
            fs.writeUTFBytes(message);
            fs.close();
            dispatchEvent(new Event("fileSizeChanged"));
        }
    }

    public function uploadToServer():void{
        var fileStream:FileStream = new FileStream();
        fileStream.open(_file, FileMode.READ);
        var bytes:ByteArray = new ByteArray
        fileStream.readBytes(bytes);
        fileStream.close();
        bytes.deflate();
        bytes.position = 0;
        var file2:File = File.applicationStorageDirectory.resolvePath("edo_nmea.edoz");
        var fs:FileStream = new FileStream();
        fs.open(file2, FileMode.WRITE);
        fs.writeBytes(bytes,0,bytes.length);
        fs.close();

        CloudHandler.instance.saveLogFile("", file2);
    }

    public function deleteLogFile():void{
        var zipFile:File = File.applicationStorageDirectory.resolvePath("edo_nmea.edoz");
        if(zipFile.exists){
            zipFile.deleteFile();
        }
        _file.deleteFile();
        _file = File.applicationStorageDirectory.resolvePath("edo_nmea.nmea");
        dispatchEvent(new Event("fileSizeChanged"));
    }


}
}