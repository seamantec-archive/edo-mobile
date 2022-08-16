/**
 * Created by seamantec on 04/11/14.
 */
package components.instruments {

import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.Mwd;
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

public class GroundWind extends BaseInstrument {

    private var _lastMwd:Mwd;

    public var actualState:String = "";
    var forgatHandler:ForgatHandler;

    private var analogBackgroundBatch:InstrumentQuadBatcher;
    private var analogBackground:DynamicSprite;
    private var analog:DynamicSprite;
    private var analogi:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var center:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function GroundWind() {
        super(Assets.getInstrument("ground_wind"));

        minMaxVars["mwd.windSpeed"] = new MinMax(undefined, undefined, this);
        forgatHandler = new ForgatHandler(analog["mutato"], this);

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        setMwdInvalid();

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var wind:Texture = Assets.getAtlas("ground_wind");

        analogBackground = _instrumentAtlas.getComponentAsDynamicSprite(wind, "analog.instance2");
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance8", analogBackground);
        analogBackgroundBatch = new InstrumentQuadBatcher(analogBackground.width,analogBackground.height, "groundWindAnalogBackground");
        analogBackgroundBatch.addDisplayObject(analogBackground);
        this.addChild(analogBackgroundBatch.quadBatch);

        analog = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance6", center);
        _instrumentAtlas.getComponentAsTextFieldWithParent("analog.ulabel", center, VAlign.CENTER,HAlign.CENTER);

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.minidigi", analogi, center, VAlign.TOP,HAlign.RIGHT, 0.9);
        analogi["minidigi"]["digi_a"].y += 2;
        analogi["minidigi"]["digi_b"].y += 2;

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min", analog);

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(center.width,center.height, "windAnalogCenter");
        var fit:Object = fitSpriteInPosition(center);
        centerBatch.addDisplayObject(center);
        centerBatch.quadBatch.x = fit.position.x;
        centerBatch.quadBatch.y = fit.position.y;
        centerBatch.quadBatch.pivotX = fit.pivot.x;
        centerBatch.quadBatch.pivotY = fit.pivot.y;
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(wind, "digital.instance9");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.ulabel", digitalBackground, VAlign.CENTER,HAlign.CENTER);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "groundWindDigitalBackground");
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
            if (analog.visible) {
                setDigital();
                actualState = "digital";
            } else {
                setAnalog();
                actualState = "analog";
            }

            SaveHandler.instance.setState(_id, actualState);
        }
    }

    private function setState(value:String):void {
        actualState = value;
        if(value == "digital") {
            setDigital();
        } else if(value == "analog") {
            setAnalog();
        }
    }

    private function uchange():void {
        if(_lastMwd!=null) {
            analogi["minidigi"]["digi_a"].text =  Splitter.withValue(_lastMwd.windSpeed.value).a3;
            analogi["minidigi"]["digi_b"].text =  Splitter.instance.b1;

            digital["digi2"]["digi_a"].text =  Splitter.instance.a3;
            digital["digi2"]["digi_b"].text =  Splitter.instance.b1;
        }

        center["ulabel"].text = (new WindSpeed()).getUnitShortString();
        digitalBackground["ulabel"].text = (new WindSpeed()).getUnitShortString();

        centerBatch.render();
        digitalBackgroundBatch.render();
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.mwd.isValid()) {
            removeMwdBlinker();

            _lastMwd = datas.mwd;

            analog["mutato"].visible = true;

            var value:Number = datas.mwd.windDirection.value;

            forgatHandler.forgat(value, { needTween: needTween });

            digital["digi1"]["digi_a"].text = Splitter.withValue(value).a03;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text =  Splitter.withValue(datas.mwd.windSpeed.value).a3;
            digital["digi2"]["digi_b"].text =  Splitter.instance.b1;

            analogi["minidigi"]["digi_a"].text =  Splitter.instance.a3;
            analogi["minidigi"]["digi_b"].text =  Splitter.instance.b1;

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
                digital["digimin1"]["digi_a"].text = Splitter.withValue((_intMin<0) ? (360 + _intMin) : _intMin).a03;
                digital["digimin1"]["digi_b"].text = Splitter.instance.b1;
            }
            if(!isNaN(_intMax)) {
                analog["max"].rotation = deg2rad(_intMax);
                analog["max"].visible = true;
                digital["digimax1"]["digi_a"].text = Splitter.withValue((_intMax<0) ? (360 + _intMax) : _intMax).a03;
                digital["digimax1"]["digi_b"].text = Splitter.instance.b1;
            }
        }
    }

    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    public override function dataInvalidated(key:String):void {
        if(key === "mwd") {
            removeMwdBlinker();
            (minMaxVars["mwd.windSpeed"] as MinMax).reset((minMaxVars["mwd.windSpeed"] as MinMax).unitClass);
            setMwdInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "mwd") {
            Blinker.addObject(analog["mutato"]);
            Blinker.addObject(analogi["minidigi"]["digi_a"]);
            Blinker.addObject(analogi["minidigi"]["digi_b"]);
            Blinker.addObject(digital["digi1"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_b"]);
            Blinker.addObject(digital["digi2"]["digi_a"]);
            Blinker.addObject(digital["digi2"]["digi_b"]);
        }
    }

    public override function unitChanged():void {
        uchange();
    }

    public override function minMaxChanged():void {
        var min:Number = (minMaxVars["mwd.windSpeed"] as MinMax).min;
        var max:Number = (minMaxVars["mwd.windSpeed"] as MinMax).max;
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

    private function setMwdInvalid():void {
        _lastMwd = null;

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

        if(minMaxVars["mwd.windSpeed"].reseted) {
            digital["digimin2"]["digi_a"].text = "---";
            digital["digimin2"]["digi_b"].text = "-";
            digital["digimax2"]["digi_a"].text = "---";
            digital["digimax2"]["digi_b"].text = "-";
        }

        analogi["minidigi"]["digi_a"].text = "---";
        analogi["minidigi"]["digi_b"].text = "-";
        digital["digi1"]["digi_a"].text = "---";
        digital["digi1"]["digi_b"].text = "-";
        digital["digi2"]["digi_a"].text = "---";
        digital["digi2"]["digi_b"].text = "-";
    }

    private function removeMwdBlinker():void {
        Blinker.removeObject(analog["mutato"]);
        Blinker.removeObject(analogi["minidigi"]["digi_a"]);
        Blinker.removeObject(analogi["minidigi"]["digi_b"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }
}
}
