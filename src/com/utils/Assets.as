/**
 * Created by pepusz on 2014.09.15..
 */
package com.utils {
import com.common.AppProperties;
import com.dynamicInstruments.InstrumentAtlas;
import com.polar.PolarContainer;
import com.polar.PolarEvent;

import components.LoadingScreen;

import components.instruments.ApparentWindAngle;

import components.instruments.Barometer;

import components.instruments.Clock;

import components.instruments.Compass;
import components.instruments.DbtDepth;
import components.instruments.GroundWind;
import components.instruments.Heading;
import components.instruments.Moon;
import components.instruments.MtwTemperature;
import components.instruments.Perf1;
import components.instruments.Perf3;
import components.instruments.Polar;
import components.instruments.PolarControl;
import components.instruments.Rudder;
import components.instruments.SetAndDrift;
import components.instruments.SpeedVessel;
import components.instruments.Tacticomp;
import components.instruments.TrueWindAngle;
import components.instruments.VmgSpeed;
import components.instruments.WaypointCU;
import components.instruments.WaypointHU;
import components.instruments.digital.DigitalA;
import components.instruments.digital.DigitalB;
import components.instruments.digital.DigitalC;
import components.instruments.digital.DigitalD;
import components.instruments.digital.DigitalE;

import flash.filesystem.File;
import flash.net.registerClassAlias;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import starling.core.Starling;
import starling.events.EnterFrameEvent;

import starling.textures.Texture;

import starling.utils.AssetManager;

public class Assets {
    private static var _assets:AssetManager = new AssetManager(AppProperties.screenScaleRatio);
    private static var _uiAssets:AssetManager = new AssetManager(2);
    assets.verbose = true;

    private static var _textureAtlases:Dictionary;
    private static var _instruments:Dictionary;
    static var uiReady:Boolean = false;
    static var instrumentsReady:Boolean = false;

    private static var _callback:Function;

    public static function loadAssets(callback:Function):void {
        _callback = callback;

//        _assets.scaleFactor = 1
        _assets.keepAtlasXmls = true;
        var path:String = File.applicationDirectory.resolvePath("assets/textures/2").url;
        trace("loading assets from " + path);
        _uiAssets.keepAtlasXmls = true;
        _uiAssets.enqueue(path + "/ui_elements.png");
        _uiAssets.enqueue(path + "/ui_elements.xml");

        // Instruments
        _assets.enqueue(File.applicationDirectory.resolvePath("assets/instruments"));

        // FXes
        _assets.enqueue(File.applicationDirectory.resolvePath("assets/fxes"));

        // Speeches
        _assets.enqueue(File.applicationDirectory.resolvePath("assets/speech"));


        _uiAssets.loadQueue(function (ratio:Number):void {
            if (ratio == 1.0) {
                Assets.uiReady = true;
                if (Assets.instrumentsReady && Assets.uiReady) {
                    (Starling.current.root as EdoMobile).removeProgress();
                    _callback.call();
                }
            }
        });
        _assets.loadQueue(function (ratio:Number):void {
//            trace("Loading assets, progress:", ratio);

            if (ratio == 1.0) {
                EdoMobile.loadingScreen.status = LoadingScreen.STATUS_BEGIN_POLAR;
            }
        })
    }

    public static function loadPolar():void {
        PolarContainer.instance.load();
    }

    public static function loadInstruments():void {
        addInstrument("compass");
        registerClassAlias("components.instruments.Compass", Compass);
        addInstrument("heading");
        registerClassAlias("components.instruments.Heading", Heading);
//                addInstrument("rudder");
//                registerClassAlias("components.instruments.Rudder", Rudder);
        addInstrument("app_wind");
        registerClassAlias("components.instruments.ApparentWindAngle", ApparentWindAngle);
        addInstrument("true_wind");
        registerClassAlias("components.instruments.TrueWindAngle", TrueWindAngle);
        addInstrument("digital_a");
        registerClassAlias("components.instruments.digital.DigitalA", DigitalA);
        addInstrument("digital_b");
        registerClassAlias("components.instruments.digital.DigitalB", DigitalB);
        addInstrument("digital_c");
        registerClassAlias("components.instruments.digital.DigitalC", DigitalC);
        addInstrument("digital_d");
        registerClassAlias("components.instruments.digital.DigitalD", DigitalD);
        addInstrument("digital_e");
        registerClassAlias("components.instruments.digital.DigitalE", DigitalE);
//                addInstrument("moon");
//                registerClassAlias("components.instruments.Moon", Moon);
        addInstrument("waypoint_hu");
        registerClassAlias("components.instruments.WaypointHU", WaypointHU);
//                addInstrument("waypoint_cu");
//                registerClassAlias("components.instruments.WaypointCU", WaypointCU);
        addInstrument("speed");
        registerClassAlias("components.instruments.SpeedVessel", SpeedVessel);
        addInstrument("vmg");
        registerClassAlias("components.instruments.VmgSpeed", VmgSpeed);
        addInstrument("tacticomp");
        registerClassAlias("components.instruments.Tacticomp", Tacticomp);
        addInstrument("depth");
        registerClassAlias("components.instruments.DbtDepth", DbtDepth);
//                addInstrument("barometer");
//                registerClassAlias("components.instruments.Barometer", Barometer);
//                addInstrument("clock");
//                registerClassAlias("components.instruments.Clock", Clock);
        addInstrument("temperature");
        registerClassAlias("components.instruments.MtwTemperature", MtwTemperature);
        addInstrument("ground_wind");
        registerClassAlias("components.instruments.GroundWind", GroundWind);
//                addInstrument("setanddrift");
//                registerClassAlias("components.instruments.SetAndDrift", SetAndDrift);
        addInstrument("perf1");
        registerClassAlias("components.instruments.Perf1", Perf1);
        addInstrument("perf3");
        registerClassAlias("components.instruments.Perf3", Perf3);
        addInstrument("polar");
        registerClassAlias("components.instruments.Polar", Polar);

        registerClassAlias("components.instruments.PolarControl", PolarControl);

        fillInstruments();
//               trace("FILL READY")
        Assets.instrumentsReady = true;
        if (Assets.instrumentsReady && Assets.uiReady) {
            (Starling.current.root as EdoMobile).removeProgress();
            _callback.call();
        }
    }

    public static function get assets():AssetManager {
        return _assets;
    }

    public static function get uiAssets():AssetManager {
        return _uiAssets;
    }

    public static function getInstrument(name:String):InstrumentAtlas {
        return _instruments[name];
    }

    public static function getAtlas(name:String):Texture {
        return _textureAtlases[name];
    }

    private static function addInstrument(name:String):void {
        if (_instruments == null) {
            _instruments = new Dictionary();
        }
        if (!_instruments.hasOwnProperty(name)) {
            _instruments[name] = new InstrumentAtlas(_assets.getXml(name));
            _assets.removeXml(name);
        }
    }

    private static function fillInstruments():void {
        var memoryUsage:int = 0;

        _textureAtlases = new Dictionary();
        var file:File = File.applicationDirectory.resolvePath("assets/instruments");
        var files:Array = file.getDirectoryListing();
        var length:int = files.length;
        var name:String;
        for(var i:int=0; i<length; i++) {
            file = files[i];
            if(file.extension=="png" || file.extension=="atf") {
                name = getFilename(file);
                _textureAtlases[name] = _assets.getTexture(name);
                memoryUsage += _textureAtlases[name].width*_textureAtlases[name].height*4;
            }
        }

        trace("Instrument videomemory usage (MB):", memoryUsage/1048576);
    }

    private static function getFilename(file:File):String {
        return file.name.substring(0, file.name.lastIndexOf("."));
    }
}
}
