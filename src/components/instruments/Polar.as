/**
 * Created by seamantec on 26/01/15.
 */
package components.instruments {
import com.common.AppProperties;
import com.common.SpeedToUse;
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.polar.PolarContainer;
import com.polar.PolarDataWindLayer;
import com.polar.PolarEvent;
import com.polar.PolarLayer;
import com.polar.PolarTable;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.instruments.BaseInstrument;
import com.utils.Assets;
import com.utils.Blinker;

import flash.display.BitmapData;
import flash.geom.Rectangle;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class Polar extends BaseInstrument {

    public static const GHOST_MODE:int = 0;
    public static const AUTO_MODE:int = 1;

    private var _mode:int = GHOST_MODE;
    private var _maxBoatSpeed:Number;
    private var _windSpeed:Number;
    private var _prevWindSpeed:Number;
    private var _hasData:Boolean;
    private var _vhw:Number;
    private var _sog:Number;
    private var _speed:Number;
    private var _direction:Number;

    private var analogBackgroundBatch:InstrumentQuadBatcher;
    private var analogBackground:DynamicSprite;
    private var analog:DynamicSprite;

    private var _polar:DynamicSprite;
    private var _ghost:Image;
    private var _ghostCircles:Image;
    private var _layers:Vector.<PolarLayer>;

    private var _pointer:Sprite;

    private var _colorCodes:Vector.<uint>;

    public function Polar() {
        super(Assets.getInstrument("polar"));

        analog.switch_btn3.addEventListener(TouchEvent.TOUCH, onChange);
        analog.ico_ghost.addEventListener(TouchEvent.TOUCH, onChange);
        analog.ico_auto.addEventListener(TouchEvent.TOUCH, onChange);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_EVENT, handleLiveData);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_LOADED, onFileLoaded);
        _windSpeed = -1;
        _prevWindSpeed = -1;
        _hasData = false;
        trace("fill colors ")
        fillColorCodes();
        trace("init layers")
        initLayers();
        trace("drawmode")
        drawMode();
        setPolarName(PolarContainer.instance.polarTableName);
    }

    protected override function buildComponents():void {
        var polar:Texture = Assets.getAtlas("polar");

        analogBackground = _instrumentAtlas.getComponentAsDynamicSprite(polar, "analog.instance2");
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.instance3", analogBackground);
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.instance4", analogBackground);
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.instance10", analogBackground);

        analog = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(polar, "analog.maxWind", analog, analogBackground);
        _instrumentAtlas.getComponentAsTextFieldWithParent("analog.polar_name", analog, VAlign.TOP, HAlign.LEFT);
        analog.polar_name.autoScale = true;
//        _polar = _instrumentAtlas.getComponentAsDynamicSpriteWithParent(polar, "analog.instance11", analog, false, false);
        _polar = new DynamicSprite();
        _polar.x = 36/AppProperties.screenScaleRatio;
        _polar.y = 10/AppProperties.screenScaleRatio;
        analog.addChild(_polar);
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.bigyo", _polar);

        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.switch_btn3", analog);
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.ico_ghost", analog);
        _instrumentAtlas.getComponentAsImageWithParent(polar, "analog.ico_auto", analog);

        analogBackgroundBatch = new InstrumentQuadBatcher(analogBackground.width, analogBackground.height, "polarAnalogBackground");
        analogBackgroundBatch.addDisplayObject(analogBackground);
        trace("polar analogquad")
        this.addChild(analogBackgroundBatch.quadBatch);

        this.addChild(analog);
    }

    private function initLayers():void {
        setMaxBoatSpeed();
        _layers = new Vector.<PolarLayer>();
        var layer:PolarLayer;
        var ghostData:BitmapData = new BitmapData(PolarLayer.DIAMETER * 2, PolarLayer.DIAMETER * 2, true, 0x0);
        for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {
            layer = new PolarLayer(i, _maxBoatSpeed, _colorCodes[i]);
            _layers.push(layer);
            if (layer.exists) {
                _polar.addChild(layer);
            }
        }

        if (ghostData != null) {
            initGhost(ghostData);
        }

        redrawGhostLayers();
    }

    private function reInitLayersAfterFileLoaded():void {
        var length:int = _layers.length;
        var layer:PolarLayer;
        var ghostData:BitmapData = new BitmapData(PolarLayer.DIAMETER * 2, PolarLayer.DIAMETER * 2, true, 0x0);
        var ghostCirclesData:BitmapData = new BitmapData(PolarLayer.DIAMETER * 2, PolarLayer.DIAMETER * 2, true, 0x0);
        for (var i:int = 0; i < length; i++) {
            layer = _layers[i];
            if (layer.exists) {
                layer.reInit();
                if (AppProperties.isJunkIpad) {
                    layer.redrawGhost(_maxBoatSpeed);
                }
                ghostData.draw(layer.ghostBitmap);
                layer.emptyGhost();
            }
        }
        addCirclesToGhostBitmap(ghostCirclesData);
        reAddTextureForGhost(ghostData, ghostCirclesData);
    }

    private function redrawGhostLayers():void {
        var length:int = _layers.length;
        var layer:PolarLayer;
        var ghostData:BitmapData = new BitmapData(PolarLayer.DIAMETER * 2, PolarLayer.DIAMETER * 2, true, 0x0);
        var ghostCirclesData:BitmapData = new BitmapData(PolarLayer.DIAMETER * 2, PolarLayer.DIAMETER * 2, true, 0x0);
        for (var i:int = 0; i < length; i++) {
            layer = _layers[i];
            if (layer.exists) {
                layer.redrawGhost(_maxBoatSpeed);
                ghostData.draw(layer.ghostBitmap);
                layer.emptyGhost();
            }
        }
        addCirclesToGhostBitmap(ghostCirclesData);
        reAddTextureForGhost(ghostData, ghostCirclesData);

    }

    private function reAddTextureForGhost(ghostData:BitmapData, ghostCirclesData:BitmapData):void {
        if (ghostData != null && _ghost != null) {
            _ghost.texture = Texture.fromBitmapData(ghostData, false);
            _ghostCircles.texture = Texture.fromBitmapData(ghostCirclesData, false);
            setGhostScaleAndAlpha();
        }
    }

    private function addCirclesToGhostBitmap(bitmap:BitmapData):void {
        var maxWindLayerIndex:int = 0;
        var tempDotsMax:Number = 0;
        var tempPolarMax:Number = 0;
        var tempAbsoluteMaxSpeed:Number = 0;
        var prevAbsoluteMaxSpeed:Number = 0;
        for (var i:int = _layers.length - 1; i >= 0; i--) {
            if (_layers[i].exists) {
                tempDotsMax = getMaxBoatSpeedFromDotsLayer(i);
                tempPolarMax = PolarContainer.instance.polarTableFromFile.findMaxForWind(i).maxSpeed;
                prevAbsoluteMaxSpeed = tempAbsoluteMaxSpeed;
                tempAbsoluteMaxSpeed = tempDotsMax > tempPolarMax ? tempDotsMax : tempPolarMax
                if (tempAbsoluteMaxSpeed >= prevAbsoluteMaxSpeed) {
                    maxWindLayerIndex = i;
                }
            }
        }
        if (_layers.length > 0) {
            if (AppProperties.isJunkIpad) {
                _layers[maxWindLayerIndex].redrawGhost(_maxBoatSpeed)
            }
            bitmap.draw(_layers[maxWindLayerIndex].ghostLayer.circlesBitmap)
            if (AppProperties.isJunkIpad) {
                _layers[maxWindLayerIndex].ghostLayer.deactivate();
            }
        }

    }

    private function initGhost(ghostData:BitmapData):void {
        _ghost = new Image(Texture.fromBitmapData(ghostData, false));
        _ghostCircles = new Image(Texture.fromBitmapData(ghostData, false));
        setGhostScaleAndAlpha();
        _polar.addChild(_ghostCircles);
        _polar.addChild(_ghost);
    }

    private function setGhostScaleAndAlpha():void {
        _ghost.scaleX = 1 / AppProperties.screenScaleRatio;
        _ghost.scaleY = 1 / AppProperties.screenScaleRatio;
        _ghostCircles.scaleX = 1 / AppProperties.screenScaleRatio;
        _ghostCircles.scaleY = 1 / AppProperties.screenScaleRatio;
        _ghost.alpha = PolarLayer.ALPHA;

    }

    private function fullResetLayers():void {
        var length:int = _layers.length;
        var layer:PolarLayer;
        for (var i:int = 0; i < length; i++) {
            layer = _layers[i];
            layer.reset(_maxBoatSpeed);
        }
    }

    //TODO refactor
    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        _hasData = datas.truewindc.isValid() && datas.truewindc.isPreValid() && ((SpeedToUse.instance.selected == SpeedToUse.STW) ? (datas.vhw.isValid() && datas.vhw.isPreValid()) : (datas.positionandspeed.isValid() && datas.positionandspeed.isPreValid()));
        if (_hasData) {
            Blinker.removeObject(_pointer);
            Blinker.removeObject(_polar.bigyo);

            _prevWindSpeed = _windSpeed;
            _windSpeed = Math.round(datas.truewindc.windSpeed.getPureData());

            if (datas.vhw != null) {
                _vhw = datas.vhw.waterSpeed.getPureData();
            }
            if (datas.positionandspeed != null) {
                _sog = datas.positionandspeed.sog.getPureData();
            }
            _speed = (SpeedToUse.instance.selected == SpeedToUse.STW) ? _vhw : _sog;
            _direction = datas.truewindc.windDirection.getPureData();
            lineToCurrent();

            setFilter();
        }

        analog.maxWind.digi_a.text = (_windSpeed == -1) ? "--" : Splitter.withValue(_windSpeed).a02;
    }

    public override function updateState(stateType:String):void {
    }

    //TODO refactor
    public override function dataInvalidated(key:String):void {
        if (key == "mwvt" || key == ((SpeedToUse.instance.selected == SpeedToUse.STW) ? "vhw" : "positionandspeed")) {
            if (_pointer != null) {
                Blinker.removeObject(_pointer);
                _pointer.visible = false;
            }

            Blinker.removeObject(analog.bigyo);
            setBigyo(false);
            analog.maxWind.digi_a.text = "--";

            _hasData = false;
            _prevWindSpeed = -1;
            _windSpeed = -1;

            if (_layers != null) {
                var length:int = _layers.length;
                for (var i:int = 0; i < length; i++) {
                    _layers[i].activate(_mode, false);
                }
            }
        }
    }

    //TODO refactor
    public override function dataPreInvalidated(key:String):void {
        if ((key == "mwvt" || key == ((SpeedToUse.instance.selected == SpeedToUse.STW) ? "vhw" : "positionandspeed")) && !Blinker.containsObject(_pointer) && _windSpeed > 0) {
            if (_pointer != null && _pointer.visible) {
                Blinker.addObject(_pointer);
            }
            if (_polar.bigyo.visible) {
                Blinker.addObject(_polar.bigyo);
            }
        }
    }

    public override function unitChanged():void {
    }

    public override function minMaxChanged():void {
    }

    private function setMaxBoatSpeed(fromAbsoluteMax:Boolean = true):Number {
        if (fromAbsoluteMax) {
            _maxBoatSpeed = PolarContainer.instance.polarTableFromFile.getAbsoluteMax();
        }
        var maxPolarSpeed:Number = _maxBoatSpeed;
        var maxDotSpeed:Number;
        for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {
            maxDotSpeed = getMaxBoatSpeedFromDotsLayer(i);
            if (_maxBoatSpeed < maxDotSpeed) {
                _maxBoatSpeed = maxDotSpeed;
            }
        }

        return maxPolarSpeed;
    }

    private function getMaxBoatSpeedFromDotsLayer(wind:int):Number {
        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(wind);
        if (dots == null) {
            return 0;
        }

        return dots.maxSpeed;
    }

    //TODO refactor
    private function lineTo(speed:Number, direction:Number):void {
        var halfGhostHeight:Number = ( PolarLayer.DIAMETER ) / AppProperties.screenScaleRatio;

        if (_pointer == null) {
            _pointer = new Sprite();
            _pointer.addChild(new Quad(2 / AppProperties.screenScaleRatio, halfGhostHeight, 0xffd200));
            _pointer.x = _ghost.x + (_ghost.width / 2);
            _pointer.y = halfGhostHeight;
            _pointer.pivotX = _pointer.width / 2;
            _pointer.pivotY = _pointer.height;
            _polar.addChild(_pointer);
        }

        if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED && _layers.length > 0 && _layers[_windSpeed].exists) {
            _pointer.visible = true;
            var layer:PolarLayer = _layers[_windSpeed];
            var pixelperspeed:Number = _mode == GHOST_MODE ? layer.ghostLayer.pixelPerSpeed : layer.autoLayer.pixelPerSpeed;
            var v:Number = speed * pixelperspeed * (halfGhostHeight / PolarLayer.DIAMETER);
            if (v > halfGhostHeight) {
                v = halfGhostHeight;
                setBigyo(true, direction);
            } else {
                setBigyo(false);
            }

            _pointer.rotation = deg2rad(direction);
            _pointer.clipRect = new Rectangle(0, halfGhostHeight - v, 2 / AppProperties.screenScaleRatio, v);
        } else {
            _pointer.visible = false;
            setBigyo(false);
        }
    }

    private function lineToCurrent():void {
        lineTo(_speed, _direction);
    }

    private function setBigyo(enable:Boolean, direction:Number = 0) {
        if (enable) {
            _polar.bigyo.visible = true;
            _polar.bigyo.x = (PolarLayer.DIAMETER + (PolarLayer.DIAMETER * Math.cos(deg2rad(direction - 90)))) / AppProperties.screenScaleRatio;
            _polar.bigyo.y = (PolarLayer.DIAMETER + (PolarLayer.DIAMETER * Math.sin(deg2rad(direction - 90)))) / AppProperties.screenScaleRatio;
            _polar.bigyo.rotation = deg2rad(direction);
        } else {
            _polar.bigyo.visible = false;
        }
    }

    private function setFilter():void {
        if (_windSpeed != _prevWindSpeed) {
            if (_prevWindSpeed >= 0 && _prevWindSpeed < PolarTable.MAX_WINDSPEED) {
                _layers[_prevWindSpeed].activate(_mode, false);
            }
            activateLayerForWindSpeed();
        }
    }

    private function activateLayerForWindSpeed():void {
        if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED) {
            _layers[_windSpeed].activate(_mode, true);
        }
    }


    private function drawMode():void {
        var length:int = _layers.length;
        for (var i:int = 0; i < length; i++) {
            _layers[i].activate(_mode, i == _windSpeed);
        }

        if (_mode == GHOST_MODE) {
            _ghost.visible = true;
            _ghostCircles.visible = true;
            analog.ico_ghost.visible = true;
            analog.ico_auto.visible = false;
        } else {
            _ghost.visible = false;
            _ghostCircles.visible = false;
            analog.ico_ghost.visible = false;
            analog.ico_auto.visible = true;
        }
    }


    private function onChange(event:TouchEvent):void {
        if (touchIsEnd(event)) {
            _mode = (_mode == GHOST_MODE) ? AUTO_MODE : GHOST_MODE;
            drawMode();
            if (_hasData) {
                setFilter();
                lineToCurrent();
            }
        }
    }

    private function handleLiveData(event:PolarEvent):void {
        var wind:int = event.polarData.windSpeed;
        if (wind >= 0 && wind < PolarTable.MAX_WINDSPEED && _layers != null && _layers[wind].exists) {
            var prevMaxBoatSpeed:Number = _maxBoatSpeed;
            setMaxBoatSpeed()
            if (prevMaxBoatSpeed < _maxBoatSpeed) {
                redrawGhostLayers();
                activateLayerForWindSpeed();
            } else {
                _layers[wind].drawAllDots();
            }
        }
    }

    private function onFileLoaded(event:PolarEvent):void {
        trace("POLAR FILE LOADED")
        setMaxBoatSpeed();
        fullResetLayers();
        reInitLayersAfterFileLoaded();
        drawMode();
        setPolarName(PolarContainer.instance.polarTableName);
        activateLayerForWindSpeed();
    }

    private function setPolarName(text:String):void {
        analog.polar_name.text = "";
        var width:Number = 0;
        for (var i:int = 1; i <= text.length; i++) {
            analog.polar_name.text = text.substr(0, i);
            if (analog.polar_name.textBounds.width <= width) {
                analog.polar_name.text = text.substr(0, i - 4) + "...";
                return;
            }
            width = analog.polar_name.textBounds.width;
        }
    }

    private function fillColorCodes():void {
        _colorCodes = new <uint>[];
        _colorCodes[0] = 0x0042ff;
        _colorCodes[1] = 0x0059ff;
        _colorCodes[2] = 0x0074ff;
        _colorCodes[3] = 0x0094ff;
        _colorCodes[4] = 0x00b1ff;
        _colorCodes[5] = 0x00ceff;
        _colorCodes[6] = 0x00e7ff;
        _colorCodes[7] = 0x00fcfb;
        _colorCodes[8] = 0x00ffcb;
        _colorCodes[9] = 0x00ffaf;
        _colorCodes[10] = 0x00ff8f;
        _colorCodes[11] = 0x00ff50;
        _colorCodes[12] = 0x00ff00;
        _colorCodes[13] = 0x70ff00;
        _colorCodes[14] = 0x91ff00;
        _colorCodes[15] = 0xb0ff00;
        _colorCodes[16] = 0xcdff00;
        _colorCodes[17] = 0xe6ff00;
        _colorCodes[18] = 0xfcfa00;
        _colorCodes[19] = 0xffdc00;
        _colorCodes[20] = 0xffb900;
        _colorCodes[21] = 0xff9300;
        _colorCodes[22] = 0xff6c00;
        _colorCodes[23] = 0xff4600;
        _colorCodes[24] = 0xff2200;
        _colorCodes[25] = 0xff0504;
        _colorCodes[26] = 0xff0044;
        _colorCodes[27] = 0xff0093;
        _colorCodes[28] = 0xff00bb;
        _colorCodes[29] = 0xff00dd;
        _colorCodes[30] = 0xfd00f9;
    }
}
}
