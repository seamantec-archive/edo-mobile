/**
 * Created by seamantec on 03/11/14.
 */
package components.instruments {

import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.ApparentWind;
import com.sailing.datas.TrueWindC;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.sailing.units.WindSpeed;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SaveHandler;

import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class TrueWindAngle extends BaseInstrument {

    private var _lastMwvr:ApparentWind;
    private var _lastMwvt:TrueWindC;

    private var value1:String;
    private var value2:String;

    public var actualState:String = "";
    public var actualState1:String = "";

    private var forgatHandler_mutato:ForgatHandler;
    private var forgatHandler_mutato1:ForgatHandler;

    private var vanzoom:Boolean = false;
    private var apparent:Boolean = true;

    private const AUTOZOOM:Boolean = false;

    private const ZOOMCHANGE:uint = 10;
    private const ZOOMDURATION:Number = 0.8;
    private var _zoomCounter:uint;

    private var _zoomBtnOver:Boolean;
    private var _zoomIcoOver:Boolean;

    private var analogBackgroundBatch:InstrumentQuadBatcher;
    private var analogBackground:DynamicSprite;
    private var analog:DynamicSprite;
    private var analogi:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var center:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function TrueWindAngle() {
        super(Assets.getInstrument("true_wind"));

        minMaxVars["truewindc.windSpeed"] = new MinMax(undefined, undefined, this);

        forgatHandler_mutato = new ForgatHandler(analog["mutato"], this);
        forgatHandler_mutato1 = new ForgatHandler(analog["mutato1"], this);

        analogi["ico_zoomin"].visible = true;
        analogi["ico_zoomout"].visible = false;
        vanzoom = false;

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        analogi["zoom_btn"].addEventListener(TouchEvent.TOUCH, zoomBtnHandler);
        analogi["ico_zoomin"].addEventListener(TouchEvent.TOUCH, zoomBtnHandler);
        analogi["ico_zoomout"].addEventListener(TouchEvent.TOUCH, zoomBtnHandler);

        setInState();
        setMwvrInvalid();
        setMwvtInvalid();

        _zoomCounter = 0;

        _zoomBtnOver = false;
        _zoomIcoOver = false;

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var wind:Texture = Assets.getAtlas("wind_common");

        analogBackground = _instrumentAtlas.getComponentAsDynamicSprite(wind, "analog.instance2");
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance11", analogBackground);
        analogBackgroundBatch = new InstrumentQuadBatcher(analogBackground.width,analogBackground.height, "trueWindAnalogBackground");
        analogBackgroundBatch.addDisplayObject(analogBackground);
        this.addChild(analogBackgroundBatch.quadBatch);

        analog = new DynamicSprite();
        _instrumentAtlas.getComponentAsAnimatedSpriteWithParent(wind, "analog.anim", analog);
        analog["anim"].currentFrame = 0;
        analog["anim"].duration = ZOOMDURATION;

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato", analog);
        _instrumentAtlas.getComponentAsImageWithParent(wind, "analog.mutato1", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(wind, "analog.instance7", center);
        _instrumentAtlas.getComponentAsTextFieldWithParent("analog.ulabel", center, VAlign.CENTER,HAlign.CENTER);

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi", analogi, center, VAlign.TOP,HAlign.RIGHT, 0.9);
        analogi["digi"]["digi_a"].y += 2;
        analogi["digi"]["digi_b"].y += 2;

        _instrumentAtlas.getComponentAsImageWithParent(wind, "analog.zoom_btn", analogi);
        analogi["zoom_btn"].scaleX = -1;
        _instrumentAtlas.getComponentAsImageWithParent(wind, "analog.ico_zoomin", analogi);
        _instrumentAtlas.getComponentAsImageWithParent(wind, "analog.ico_zoomout", analogi);

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min", analog);

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(center.width,center.height, "windAnalogCenter");
        var fit:Object = fitSpriteInPivot(center);
        centerBatch.addDisplayObject(center);
        centerBatch.quadBatch.x = fit.position.x;
        centerBatch.quadBatch.y = fit.position.y;
        centerBatch.quadBatch.pivotX = fit.pivot.x;
        centerBatch.quadBatch.pivotY = fit.pivot.y;
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(wind, "digital.instance12");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.sidelabel", digitalBackground, VAlign.BOTTOM,HAlign.CENTER, .85);
        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.ulabel", digitalBackground, VAlign.CENTER,HAlign.CENTER);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "trueWindDigitalBackground");
        digitalBackgroundBatch.addDisplayObject(digitalBackground);
        this.addChild(digitalBackgroundBatch.quadBatch);

        this.addChild(digital);
    }

    private function setAnalog():void {
        analog.visible = true;
        analogi.visible = true;
        centerBatch.quadBatch.visible = true;

        digitalBackgroundBatch.quadBatch.visible = false;
        digital.visible = false;
    }

    private function setDigital():void {
        analog.visible = false;
        analogi.visible = false;
        centerBatch.quadBatch.visible = false;

        digitalBackgroundBatch.quadBatch.visible = true;
        digital.visible = true;
    }

    private function digitalis(event:TouchEvent):void {
        if (touchIsEnd(event)) {
            if (event.target!=analogi["zoom_btn"] && event.target!=analogi["ico_zoomin"] && event.target!=analogi["ico_zoomout"]) {
                if (analog.visible) {
                    setDigital();
                } else {
                    setAnalog();
                }
                setInState();
            }
        }
    }

    private function setState(value:String):void {
        actualState = value;
        if(value.match("digital")) {
            setDigital();
        } else if (value.match("analog")) {
            setAnalog();
        }

        if(value.match("vanzoom")) {
            vanzoom = true;
            analogi["ico_zoomin"].visible = false;
            analogi["ico_zoomout"].visible = true;
            analog["anim"].currentFrame = 14;
        } else if(value.match("nincszoom")) {
            vanzoom = false;
            analogi["ico_zoomin"].visible = true;
            analogi["ico_zoomout"].visible = false;
            analog["anim"].currentFrame = 0;
        }
    }

    private function setInState():void {
        value1 = apparent ? "apparentw" : "truew";
        value2 = vanzoom ? "vanzoom" : "nincszoom";
        if(analog.visible) {
            actualState = "analog_" + value1 + "_" + value2;
        } else {
            actualState = "digital_" + value1 + "_" + value2;
        }

        SaveHandler.instance.setState(_id, actualState);
    }

    public override function unitChanged():void {
        this.uchange();
    }

    private function uchange():void {
        if(_lastMwvt!=null) {
            analogi["digi"]["digi_a"].text = Splitter.withValue(_lastMwvt.windSpeed.value).a3;
            analogi["digi"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.instance.a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;
        }

        var label:String = (new WindSpeed()).getUnitShortString();
        digitalBackground["ulabel"].text = label;
        center["ulabel"].text = label;

        digitalBackgroundBatch.render();
        centerBatch.render();
    }

    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    private function zoom():void {
        if(vanzoom) {
            analog["anim"].playTo(0);
        } else {
            analog["anim"].playTo(14);
        }

        vanzoom = !vanzoom;
        analogi["ico_zoomin"].visible = !analogi["ico_zoomin"].visible;
        analogi["ico_zoomout"].visible = !analogi["ico_zoomout"].visible;

        setInState();
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.truewindc.isValid()) {
            removeMwvtBlinker();
            _lastMwvt = datas.truewindc;

            var value:Number = datas.truewindc.windAngle.value;

            analog["mutato"].visible = true;

            if (value > 0) {
                if(digitalBackground["sidelabel"].text!="STBD") {
                    digitalBackground["sidelabel"].text = "STBD";
                    digitalBackgroundBatch.render();
                }
            }
            else {
                if(digitalBackground["sidelabel"].text!="PORT") {
                    digitalBackground["sidelabel"].text = "PORT";
                    digitalBackgroundBatch.render();
                }
            }

            if(AUTOZOOM) {
                if(Math.abs(value)>=10 && Math.abs(value)<=70) {
                    _zoomCounter += 1;
                } else {
                    _zoomCounter = 0;
                }
            }

            rotate(forgatHandler_mutato, value, needTween);

            analogi["digi"]["digi_a"].text = Splitter.withValue(datas.truewindc.windSpeed.value).a3;
            analogi["digi"]["digi_b"].text = Splitter.instance.b1;

            digital["digi1"]["digi_a"].text = Splitter.withValue(Math.abs(value)).a3;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.withValue(datas.truewindc.windSpeed.value).a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;

            if(value<0) {
                value += 360;
            }

            var chunk:Number = getChunk(value);
            if(_prevChunk==-1) {
                _chunks[chunk].value = 1;
                _chunks[chunk].min = value;
                _chunks[chunk].max = value;
            } else {
                fillPath(_prevChunk, chunk, value);
            }

            _prevChunk = chunk;

            var obj:Object = getMinMax();
            _intMin = obj.min;
            _intMax = obj.max;

            if(!isNaN(_intMin)) {
                analog["min"].rotation = deg2rad(_intMin);
                analog["min"].visible = true;
                digital["digimin1"]["digi_a"].text = Splitter.withValue((_intMin<0) ? (360 + _intMin) : _intMin).a3;
                digital["digimin1"]["digi_b"].text = Splitter.instance.b1;
            }
            if(!isNaN(_intMax)) {
                analog["max"].rotation = deg2rad(_intMax);
                analog["max"].visible = true;
                digital["digimax1"]["digi_a"].text = Splitter.withValue((_intMax<0) ? (360 + _intMax) : _intMax).a3;
                digital["digimax1"]["digi_b"].text = Splitter.instance.b1;
            }

            minMaxRotate();
        }

        if(datas!=null && datas.apparentwind.isValid()) {
            Blinker.removeObject(analog["mutato1"]);
            _lastMwvr = datas.apparentwind;

            analog["mutato1"].visible = true;

            rotate(forgatHandler_mutato1, datas.apparentwind.windAngle.value, needTween, false);
        }
    }

    public override function dataInvalidated(key:String):void {
        if(key === "truewindc") {
            removeMwvtBlinker();
            (minMaxVars["truewindc.windSpeed"] as MinMax).reset((minMaxVars["truewindc.windSpeed"] as MinMax).unitClass);
            setMwvtInvalid();
        }

        if(key == "apparentwind") {
            Blinker.removeObject(analog.mutato1);
            analog["mutato1"].visible = false;
            setMwvrInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "truewindc") {
            Blinker.addObject(analog["mutato"]);
            Blinker.addObject(analogi["digi"]["digi_a"]);
            Blinker.addObject(analogi["digi"]["digi_b"]);
            Blinker.addObject(digital["digi1"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_b"]);
            Blinker.addObject(digital["digi2"]["digi_a"]);
            Blinker.addObject(digital["digi2"]["digi_b"]);
        }

        if(key == "apparentwind") {
            Blinker.addObject(analog["mutato1"]);
        }
    }

    private function setMwvtInvalid():void {
        _lastMwvt = null;

        analog["mutato"].visible = false;

        _intMin = NaN;
        _intMax = NaN;
        _chunks = new Vector.<Object>(CHUNKS);
        fillChunks();
        _prevChunk = -1;

        analog["min"].visible = false;
        analog["max"].visible = false;

        digital["digimin1"]["digi_a"].text = "---";
        digital["digimin1"]["digi_b"].text = "-";
        digital["digimax1"]["digi_a"].text = "---";
        digital["digimax1"]["digi_b"].text = "-";

        digital["digimin2"]["digi_a"].text = "---";
        digital["digimin2"]["digi_b"].text = "-";
        digital["digimax2"]["digi_a"].text = "---";
        digital["digimax2"]["digi_b"].text = "-";

        analogi["digi"]["digi_a"].text = "---";
        analogi["digi"]["digi_b"].text = "-";
        digital["digi1"]["digi_a"].text = "---";
        digital["digi1"]["digi_b"].text = "-";
        digital["digi2"]["digi_a"].text = "---";
        digital["digi2"]["digi_b"].text = "-";

        digitalBackground["sidelabel"].text = "";

        digitalBackgroundBatch.render();
    }

    private function setMwvrInvalid():void {
        _lastMwvr = null;

        analog["mutato1"].visible = false;
    }

    private function removeMwvtBlinker():void {
        Blinker.removeObject(analog["mutato"]);
        Blinker.removeObject(analogi["digi"]["digi_a"]);
        Blinker.removeObject(analogi["digi"]["digi_b"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }

    private function zoomBtnHandler(event:TouchEvent):void {
        if(touchIsEnd(event)) {
            zoom();
            _zoomCounter = 0;
            if (_lastMwvr != null) {
                rotate(forgatHandler_mutato, _lastMwvt.windAngle.value, true);
            }
            if (_lastMwvt != null) {
                rotate(forgatHandler_mutato1, _lastMwvr.windAngle.value, true, false);
            }
        }
    }

    private function rotate(handler:ForgatHandler, value:Number, needTween:Boolean, hasMinMax:Boolean = true):void {
        if(AUTOZOOM) {
            if(_zoomCounter>=ZOOMCHANGE) {
                if(!vanzoom) {
                    zoom();
                }
                if(value<0) {
                    handler.forgat(value*3 + 30, { needTween: needTween });
                } else {
                    handler.forgat(value*3 - 30, { needTween: needTween });
                }

            } else {
                if(vanzoom) {
                    zoom();
                }
                handler.forgat(value, { needTween: needTween });
            }
        } else {
            if(vanzoom) {
                var abs:Number = Math.abs(value);
                if(abs>=10 && abs<=70) {
                    if(value<0) {
                        handler.forgat(value*3 + 30, { needTween: needTween });
                    } else {
                        handler.forgat(value*3 - 30, { needTween: needTween });
                    }
                    if(handler.mutato==analog["mutato"]) {
                        analog["mutato"].alpha = 1;
                    }
                } else if(abs<10) {
                    handler.forgat(0, { needTween: needTween });
                    if(handler.mutato==analog["mutato"]) {
                        analog["mutato"].alpha = 0.5;
                    }
                } else {
                    handler.forgat(180, { needTween: needTween });
                    if(handler.mutato==analog["mutato"]) {
                        analog["mutato"].alpha = 0.5;
                    }
                }
            } else {
                handler.forgat(value, { needTween: needTween });
                if(handler.mutato==analog["mutato"]) {
                    analog["mutato"].alpha = 1;
                }
            }
        }

        if(hasMinMax) {
            minMaxRotate();
        }
    }

    private function minMaxRotate():void {
        if(vanzoom) {
            var min:Number = (_intMin==0) ? -180 : ((_intMin>180) ? (_intMin - 360) : _intMin);
            var max:Number = (_intMax==360) ? 180 : ((_intMax>180) ? (_intMax - 360) : _intMax);
            if(Math.abs(min)<10 || Math.abs(min)>70) {
                analog["min"].visible = false;
            } else {
                analog["min"].visible = true;
            }
            if(Math.abs(max)<10 || Math.abs(max)>70) {
                analog["max"].visible = false;
            } else {
                analog["max"].visible = true;
            }

            if(analog.min.visible) {
                if(min<0) {
                    analog["min"].rotation = deg2rad(min*3 + 30);
                } else {
                    analog["min"].rotation = deg2rad(min*3 - 30);
                }
            }
            if(analog.max.visible) {
                if(max<0) {
                    analog["max"].rotation = deg2rad(max*3 + 30);
                } else {
                    analog["max"].rotation = deg2rad(max*3 - 30);
                }
            }
        } else {
            if(!isNaN(_intMin)) {
                analog["min"].visible = true;
            }
            if(!isNaN(_intMax)) {
                analog["max"].visible = true;
            }

            analog["min"].rotation = deg2rad((_intMin==0) ? -180 : _intMin);
            analog["max"].rotation = deg2rad((_intMax==360) ? 180 : _intMax);
        }
    }

    public override function minMaxChanged():void {
        var min:Number = (minMaxVars["truewindc.windSpeed"] as MinMax).min;
        var max:Number = (minMaxVars["truewindc.windSpeed"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital["digimin2"]["digi_a"].text = Splitter.withValue(min).a3;
            digital["digimin2"]["digi_b"].text = Splitter.instance.b1;
            digital["digimax2"]["digi_a"].text = Splitter.withValue(max).a3;
            digital["digimax2"]["digi_b"].text = Splitter.instance.b1;
        } else {
            digital["digimin2"]["digi_a"].text = "---";
            digital["digimin2"]["digi_b"].text = "-";
            digital["digimax2"]["digi_a"].text = "---";
            digital["digimax2"]["digi_b"].text = "-";
        }
    }
}
}
