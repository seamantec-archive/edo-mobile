/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.21.
 * Time: 15:11
 * To change this template use File | Settings | File Templates.
 */
package com.common {

import com.utils.EdoLocalStore;

import flash.desktop.NativeApplication;
import flash.utils.ByteArray;

[Bindable]
public class AppProperties {
    public static var screenWidth:int;
    public static var screenHeight:int;
    public static var fullScreenWidth:int;
    public static var fullScreenHeight:int;
    public static var screenScaleRatio:Number;
    public static var screenScaleRatioName:String;
    public static var screenDiagonalInInch:Number;
    public static var screenScaleRatioTo320:Number;
    public static var appAddedToStage:Boolean = false;
    private static var _saveLogFileEnabled:Boolean = EdoLocalStore.getBoolean("saveLogFileEnabled");
    public static var isJunkIpad:Boolean = false;
    public static var isIOS:Boolean = false;
    private static var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
    private static var versionLabel:String = "";
    private static var versionNumber:String = "";
    private static var copyright:String = "";

    DS::prod{
        public static const serverEndpoint:String = "https://seamantec.com";
        public static const websocketEndpoint:String = "wss://seamantec.com/websocket";
    }
    DS::dev{
        public static const serverEndpoint:String = "http://localhost:3000";
        public static const websocketEndpoint:String = "ws://localhost:3001/websocket";
//        public static const serverEndpoint:String = "http://localhost:3000";
//        public static const websocketEndpoint:String = "ws://localhost:3000/websocket";
    }


    public static function getVersionLabel():String {
        if (versionLabel === "") {
            var ns:Namespace = appXml.namespace();
            versionLabel = appXml.ns::versionLabel
        }
        return versionLabel;
    }

    public static function getVersionNumber():String {
        if (versionNumber === "") {
            var ns:Namespace = appXml.namespace();
            versionNumber = appXml.ns::versionNumber
        }
        return versionNumber;
    }


    public static function getCopyright():String {
        if (copyright === "") {
            var ns:Namespace = appXml.namespace();
            copyright = appXml.ns::copyright
        }
        return copyright;
    }


    public static function get saveLogFileEnabled():Boolean {
        return _saveLogFileEnabled;
    }

    public static function set saveLogFileEnabled(value:Boolean):void {
        _saveLogFileEnabled = value;
        var data:ByteArray = new ByteArray();
        data.writeBoolean(_saveLogFileEnabled);
        EdoLocalStore.setItem("saveLogFileEnabled", data);
    }
}
}
