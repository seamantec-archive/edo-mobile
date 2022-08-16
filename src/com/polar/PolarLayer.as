/**
 * Created by seamantec on 26/01/15.
 */
package com.polar {
import com.common.AppProperties;

import components.instruments.Polar;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.StageQuality;

import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

public class PolarLayer extends Sprite {

    public static const MARGIN:Number = 18;
    public static const DIAMETER:Number = 200 - 36;

    public static const ALPHA:Number = 0.2;

    private var _mode:int;

    private var _windSpeed:Number;
    private var _maxBoatSpeed:Number;
    private var _maxPolarSpeed:Number;
    private var _color:uint;

    private var _vmgTexture:Texture;
    private var _windDotTexture:Texture;

    private var _exists:Boolean;

    private var _ghostLayer:GhostPolarLayer;
    private var _autoLayer:AutoPolarLayer;

    public function PolarLayer(wind:Number, maxBoatSpeed:Number, color:uint) {
        this.visible = false;
        _mode = Polar.GHOST_MODE;

        _windSpeed = wind;
        _maxBoatSpeed = maxBoatSpeed;
        _color = color;
        createWindTexture();
        createVmgTexture();
        _ghostLayer = new GhostPolarLayer(this);
        _autoLayer = new AutoPolarLayer(this);
        this.addChild(_ghostLayer);
        this.addChild(_autoLayer);

        init();
        drawPolars();
        if (!AppProperties.isJunkIpad) {
            drawAllDots();
        }
    }

    //Always run reset before call this method!
    public function reInit():void {
        init();
        drawPolars();
        drawAllDots();
    }

    private function init():void {
        var max:Object = PolarContainer.instance.polarTableFromFile.findMaxForWind(_windSpeed);
        if (max == null || (max.maxSpeed == 0 || max.maxSpeed == Infinity || isNaN(max.maxSpeed))) {
            _exists = false;
        } else {
            _exists = true;
            calculatePixelDimensions(max);
        }
    }

    private function calculatePixelDimensions(max:Object):void {
        _maxPolarSpeed = max.maxSpeed;
    }

    public function activate(mode:int, active:Boolean = true):void {
        if (_exists) {
            _mode = mode;
            this.visible = active;
            _ghostLayer.deactivate();
            _autoLayer.deactivate();

            if (active) {
                if (_mode == Polar.GHOST_MODE) {
                    _ghostLayer.activate();
                } else if (_mode == Polar.AUTO_MODE) {
                    _autoLayer.activate();
                }
            }
        }
    }

    public function get exists():Boolean {
        return _exists;
    }

    public function get maxPolarSpeed():Number {
        return _maxPolarSpeed;
    }


    public function get windSpeed():Number {
        return _windSpeed;
    }


    public function drawAllDots():void {
        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
        if (dots != null) {
            var index:int = 0;
            for (var angle:int = 0; angle < 360; angle++) {
                for (var boatSpeed:int = 0; boatSpeed <= PolarDataWindLayer.MAX_BOAT_SPEED * 10; boatSpeed++) {
                    if (dots.container[angle][boatSpeed] != 0) {
                        _ghostLayer.addWind(index++, boatSpeed / 10, angle, dots.container[angle][boatSpeed] * 0.1);
                        _autoLayer.addWind(index++, boatSpeed / 10, angle, dots.container[angle][boatSpeed] * 0.1);
                    }
                }
            }

        }
    }

    public function reset(maxBoatSpeed:Number):void {
        _maxBoatSpeed = maxBoatSpeed;
        init();
        _ghostLayer.reset();
        _autoLayer.reset();
    }

    public function redrawGhost(maxBoatSpeed:Number):void {
        _maxBoatSpeed = maxBoatSpeed;
        _ghostLayer.reset();
        _ghostLayer.draw(true);
    }

    public function emptyGhost():void {
        if (AppProperties.isJunkIpad) {
            _ghostLayer.deactivate();
        }
    }


    private function drawPolars():void {
        if (_exists) {
            _ghostLayer.draw();
            _autoLayer.draw();
        }
    }


    internal function isPolarValid():Boolean {
        return _exists && _windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED
    }


    private static function clearFromIndex(index:int, container:Vector.<Image>):void {
        index++;
        if (index < container.length) {
            container.splice(index, container.length - index);
        }

    }

    private function createVmgTexture():void {
        if (_vmgTexture == null) {
            var shape:Shape = new Shape();
            shape.graphics.lineStyle(2, _color);
            shape.graphics.beginFill(0xffffff);
            shape.graphics.drawCircle(4, 4, 4);
            shape.graphics.endFill();

            var data:BitmapData = new BitmapData(shape.width, shape.height, true, 0x0);
            data.drawWithQuality(shape, null, null, null, null, true, StageQuality.BEST);
            _vmgTexture = Texture.fromBitmapData(data, false, false, 2);
        }
    }


    private function createWindTexture():void {
        if (_windDotTexture == null) {
            var shape:Shape = new Shape();
            shape.graphics.beginFill(_color);
            shape.graphics.drawCircle(2, 2, 2);
            shape.graphics.endFill();
            var data:BitmapData = new BitmapData(shape.width, shape.height, true, 0x0);
            data.drawWithQuality(shape, null, null, null, null, true, StageQuality.BEST);
            _windDotTexture = Texture.fromBitmapData(data, false, false, 2);
        }
    }


    public function get ghostBitmap():BitmapData {
        return _ghostLayer.polarBitmapData;
    }


    public function get ghostLayer():GhostPolarLayer {
        return _ghostLayer;
    }

    public function get autoLayer():AutoPolarLayer {
        return _autoLayer;
    }

    public function get maxBoatSpeed():Number {
        return _maxBoatSpeed;
    }


    public function get color():uint {
        return _color;
    }


    public function get vmgTexture():Texture {
        return _vmgTexture;
    }

    public function get windDotTexture():Texture {
        return _windDotTexture;
    }
}
}
