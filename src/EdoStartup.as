package {


import com.alarm.AlarmHandler;
import com.common.AppProperties;
import com.harbor.CloudHandler;
import com.harbor.WebsocketHandler;
import com.utils.SaveHandler;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import starling.core.Starling;

[SWF(frameRate="30", backgroundColor="#07578e")]
public class EdoStartup extends Sprite {

    private const iOSRatios:Array = new Array(
            {w: 320, h: 480, ratio: 2 / 3, name: "2_3"},
            {w: 320, h: 568, ratio: 9 / 16, name: "9_16"},
            {w: 768, h: 1024, ratio: 3 / 4, name: "3_4"}
    );
    private const androidRatios:Array = new Array(
            {w: 320, h: 480, ratio: 2 / 3, name: "2_3"},
            {w: 512, h: 682, ratio: 3 / 4, name: "3_4"},
            {w: 360, h: 640, ratio: 9 / 16, name: "9_16"},
            {w: 320, h: 533, ratio: 240 / 400, name: "3_5"}
    );

    private var _starling:Starling;

    public function EdoStartup() {

        Starling.multitouchEnabled = true;
        NativeApplication.nativeApplication.executeInBackground = true;
        DS::device{
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onAppActivate);
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onAppDeactivate);
        }
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        AppProperties.fullScreenWidth = stage.fullScreenWidth;
        AppProperties.fullScreenHeight = stage.fullScreenHeight;
        _starling = new Starling(EdoMobile, stage, new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),null,"auto", "auto");

        setScreenWidthHeight();
        scaleDownIfScreenToBig();
        _starling.simulateMultitouch = true;
        _starling.start();
//        _starling.showStats = false;
//        _starling.showStatsAt("left", "bottom");

        trace(stage.fullScreenWidth, stage.fullScreenHeight, AppProperties.screenWidth, AppProperties.screenHeight);
        trace("scale factor", _starling.contentScaleFactor, AppProperties.screenScaleRatio, "||", Capabilities.manufacturer, "||", Capabilities.os, "||", Capabilities.pixelAspectRatio, "||", Capabilities.screenDPI);
    }

    private function scaleDownIfScreenToBig():void {
        if ((stage.fullScreenWidth > 2048 || stage.fullScreenHeight > 2048) && !AppProperties.isIOS) {
            Context3DProfile.BASELINE_EXTENDED;
//            AppProperties.screenScaleRatio--;
//            var dimension:Object = getAspectRatioByName(AppProperties.screenScaleRatioName);
//            var newRectW:int = dimension.w * AppProperties.screenScaleRatio;
//            var newRectH:int = dimension.h * AppProperties.screenScaleRatio
//            _starling.viewPort = new Rectangle((stage.fullScreenWidth - newRectW) / 2, (stage.fullScreenHeight - newRectH) / 2, newRectW, newRectH);
//            setScreenWidthHeight();
        }
    }

    private function setScreenWidthHeight():void {

        var dimension:Object = getAspectRatio();
        AppProperties.screenWidth = dimension.w;
        AppProperties.screenHeight = dimension.h;
        trace("Dimensions", dimension.w, dimension.h)
        _starling.stage.stageWidth = AppProperties.screenWidth;
        _starling.stage.stageHeight = AppProperties.screenHeight;
        AppProperties.screenScaleRatio = round(_starling.contentScaleFactor);
        AppProperties.screenScaleRatioName = dimension.name;
        AppProperties.screenDiagonalInInch = getDiagonalInInch();

    }

    private function getAspectRatio():Object {
        var os:String = Capabilities.os.toLowerCase();
        if (os.indexOf("iphone") >= 0 || os.indexOf("ipad") >= 0) {
            AppProperties.isIOS = true;
            AppProperties.isJunkIpad = os.match("ipad2,5")
            return getDimension(iOSRatios);
        } else if (os.indexOf("linux") >= 0) {
            AppProperties.isIOS = false;
            return getDimension(androidRatios);
        } else {
//            return getDimension(iOSRatios);
            return getDimension(androidRatios);
        }
    }

    private function getAspectRatioByName(name:String):Object {
        var os:String = Capabilities.os.toLowerCase();
        if (os.indexOf("iphone") >= 0 || os.indexOf("ipad") >= 0) {
            AppProperties.isIOS = true;
            return getDimensionByName(name, iOSRatios);
        } else if (os.indexOf("linux") >= 0) {
            AppProperties.isIOS = false;
            return getDimensionByName(name, androidRatios);
        } else {
            //            return getDimension(iOSRatios);
            return getDimensionByName(name, androidRatios);
        }
    }

    private function getDimension(values:Array):Object {
        var w:Number = stage.fullScreenWidth;
        var h:Number = stage.fullScreenHeight;
        var ratio:Number = w / h;
        var result:Object = values[0];
        var min:Number = Math.abs(ratio - (values[0].w / values[0].h));
        var length:int = values.length;
        var item:Object;
        for (var i:int = 1; i < length; i++) {
            item = values[i];
            if ((w == item.w && h == item.h) || (w % item.w == 0 && h % item.h == 0)) {
                result = item;
                break;
            } else if (Math.abs(ratio - (item.w / item.h)) < min) {
                var result:Object = item;
                var min:Number = Math.abs(ratio - (item.w / item.h));
            }
        }

        return result;
    }

    private function getDimensionByName(name:String, values:Array):Object {
        for (var i:int = 0; i < values.length; i++) {
            if (values[i].name == name) {
                return values[i];
            }
        }
        return null;
    }

    private function getDiagonalInInch():Number {
        return Math.round(Math.sqrt(Math.pow(stage.fullScreenWidth / Capabilities.screenDPI, 2) + Math.pow(stage.fullScreenHeight / Capabilities.screenDPI, 2)) * 10) / 10;
    }

    private function round(value:Number):Number {
//        var result:Number = Math.round(value);
//        return (result < value) ? (result + 0.5) : result;
        var integer:Number = Math.floor(value);
        return (integer == value) ? value : (((value - integer) <= 0.5) ? (integer + 0.5) : (integer + 1));
    }

    private function onAppActivate(event:Event):void {
        trace("APP ACTIVATED");
        Starling.current.start();

        CloudHandler.instance.getPolars();
        WebsocketHandler.instance.connect();
    }

    private function onAppDeactivate(event:Event):void {
        trace("APP DEACTIVATED");
        AlarmHandler.instance.exportAlarms();
        SaveHandler.instance.save();
        Starling.current.stop(true);
    }
}
}
