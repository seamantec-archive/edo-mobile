/**
 * Created by seamantec on 05/11/14.
 */
package components.instruments {

import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.Setanddrift;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.sailing.units.Speed;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SaveHandler;

import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class SetAndDrift extends BaseInstrument {

    private var _lastSad:Setanddrift;

    public var actualState:String = "";

    private var forgatHandler:ForgatHandler;

    private var analog:DynamicSprite;
    private var center:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var analogi:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function SetAndDrift() {
        super(Assets.getInstrument("setanddrift"));

        minMaxVars["setanddrift.drift"] = new MinMax(undefined, undefined, this);
        forgatHandler = new ForgatHandler(analog["mutato"], this, { offsetToZero: 180 });

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        setSetanddriftInvalid();

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var setanddrift:Texture = Assets.getAtlas("setanddrift");

        analog = _instrumentAtlas.getComponentAsDynamicSprite(setanddrift, "analog.instance2");

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max", analog);
        _instrumentAtlas.getComponentAsImageWithParent(setanddrift, "analog.mutato", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance9", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(setanddrift, "analog.instance5", center);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance11", center);

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.minidigi", analogi, center, VAlign.CENTER,HAlign.RIGHT, .9);
        analogi["minidigi"]["digi_a"].y -= 2;
        _instrumentAtlas.getComponentAsTextFieldWithParent("analog.ulabel", center);

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(analog.width,analog.height);
        centerBatch.addDisplayObject(center);
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(setanddrift, "digital.instance12");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .98);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .78);
        digital["digi2"]["digi_a"].y -= 8;
        digital["digi2"]["digi_b"].x -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.ulabel", digitalBackground);

        digitalBackgroundBatch = new InstrumentQuadBatcher();
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
        if (value == "digital") {
            setDigital();
        } else if (value == "analog") {
            setAnalog();
        }
    }

    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.setanddrift.isValid()) {
            removeSetanddriftBlinker();

            _lastSad = datas.setanddrift;

            var angleset:Number = datas.setanddrift.angleset.value;
            var drift:Number = datas.setanddrift.drift.value;

            analog["mutato"].visible = true;

            digital["digi1"]["digi_a"].text = Splitter.withValue(angleset).a03;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text =  Splitter.withValue(drift).a3;
            digital["digi2"]["digi_b"].text =  Splitter.instance.b1;

            analogi["minidigi"]["digi_a"].text =  Splitter.withValue(drift).a3;
            analogi["minidigi"]["digi_b"].text =  Splitter.instance.b1;

            forgatHandler.forgat(angleset + 180, { needTween: needTween });

            var chunk:Number = getChunk(angleset);
            if(_prevChunk==-1) {
                _chunks[chunk].value = 1;
                _chunks[chunk].min = angleset;
                _chunks[chunk].max = angleset;
            } else {
                fillPath(_prevChunk, chunk, angleset);
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

    public override function dataInvalidated(key:String):void {
        if(key === "setanddrift") {
            removeSetanddriftBlinker();
            (minMaxVars["setanddrift.drift"] as MinMax).reset((minMaxVars["setanddrift.drift"] as MinMax).unitClass);
            setSetanddriftInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "setanddrift") {
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
        var min:Number = (minMaxVars["setanddrift.drift"] as MinMax).min;
        var max:Number = (minMaxVars["setanddrift.drift"] as MinMax).max;
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

    private function removeSetanddriftBlinker():void {
        Blinker.removeObject(analog["mutato"]);
        Blinker.removeObject(analogi["minidigi"]["digi_a"]);
        Blinker.removeObject(analogi["minidigi"]["digi_b"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }

    private function setSetanddriftInvalid():void {
        _lastSad = null;

        analog["mutato"].visible = false;

        analog["min"].visible = false;
        analog["max"].visible = false;

        _intMin = NaN;
        _intMax = NaN;
        _chunks = new Vector.<Object>(CHUNKS);
        fillChunks();
        _prevChunk = -1;

        digital["digimin1"]["digi_a"].text = "---";
        digital["digimin1"]["digi_b"].text = "-";
        digital["digimax1"]["digi_a"].text = "---";
        digital["digimax1"]["digi_b"].text = "-";

        if((minMaxVars["setanddrift.drift"] as MinMax).reseted) {
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

    private function uchange():void {
        if(_lastSad!=null) {
            digital["digi2"]["digi_a"].text =  Splitter.withValue(_lastSad.drift.value).a3;
            digital["digi2"]["digi_b"].text =  Splitter.instance.b1;

            analogi["minidigi"]["digi_a"].text =  Splitter.instance.a3;
            analogi["minidigi"]["digi_b"].text =  Splitter.instance.b1;
        }

        center["ulabel"].text = (new Speed()).getUnitShortString();
        digitalBackground["ulabel"].text = (new Speed()).getUnitShortString();

        centerBatch.render();
        digitalBackgroundBatch.render();
    }

}
}
