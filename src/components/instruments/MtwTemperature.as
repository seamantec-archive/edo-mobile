/**
 * Created by seamantec on 06/11/14.
 */
package components.instruments {
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.Mda;
import com.sailing.datas.Mtw;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.sailing.units.Temperature;
import com.sailing.units.UnitHandler;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SaveHandler;

import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class MtwTemperature extends BaseInstrument {

    private const BEGIN:Number = 45;

    private var _lastMtw:Mtw;
    private var _lastMda:Mda;

    public var actualState:String = "";

    private var _forgatHandler1:ForgatHandler;
    private var _forgatHandler2:ForgatHandler;

    private var _unit:Number;
    private var _offset:Number;

    private var analog:DynamicSprite;
    private var center:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var analogi:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function MtwTemperature() {
        super(Assets.getInstrument("temperature"));

        minMaxVars["mda.airTemp"]  = new MinMax(undefined, undefined, this);
        minMaxVars["mtw.temperature"] = new MinMax(undefined, undefined, this);

        _forgatHandler1 = new ForgatHandler(analog["mutato1"], this, { offsetToZero: BEGIN , min: 225, max: 135 });
        _forgatHandler2 = new ForgatHandler(analog["mutato2"], this, { offsetToZero: BEGIN , min: 225, max: 135 });

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        setMdaInvalid();
        setMtwInvalid();
        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var temperature:Texture = Assets.getAtlas("temperature");

        analog = _instrumentAtlas.getComponentAsDynamicSprite(Assets.getAtlas("speed_common"), "analog.instance2");

        _instrumentAtlas.getComponentAsImageWithParent(temperature, "analog.szlap_C", analog);
        _instrumentAtlas.getComponentAsImageWithParent(temperature, "analog.szlap_F", analog);

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato2", analog);

        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min2", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max2", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance19", center);
        _instrumentAtlas.getComponentAsImageWithParent(temperature, "analog.instance9", center);

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi1", analogi, center, VAlign.CENTER,HAlign.RIGHT, .9);
        analogi["digi1"]["digi_a"].y -= 1;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi2", analogi, center, VAlign.CENTER,HAlign.RIGHT, .9);
        analogi["digi2"]["digi_a"].y -= 1;

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(analog.width,analog.height);
        centerBatch.addDisplayObject(center);
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(temperature, "digital.instance20");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);

        _instrumentAtlas.getComponentAsImageWithParent(temperature, "digital.unit_C", digitalBackground);
        _instrumentAtlas.getComponentAsImageWithParent(temperature, "digital.unit_F", digitalBackground);

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
            if(analog.visible) {
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

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.mda.isValid()) {
            removeMdaBlinker();

            _lastMda = datas.mda;

            analog["mutato1"].visible = true;

            if(!isNaN((minMaxVars["mda.airTemp"] as MinMax).min)) {
                analog["min1"].visible = true;
            }
            if(!isNaN((minMaxVars["mda.airTemp"] as MinMax).max)) {
                analog["max1"].visible = true;
            }

            _forgatHandler1.forgat((_offset + datas.mda.airTemp.value)*_unit, { needTween: needTween });

            analogi["digi1"]["digi_a"].text = Splitter.withValue(datas.mda.airTemp.value).a3;
            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi1"]["digi_a"].text = Splitter.instance.a3;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;
        }

        if(datas!=null && datas.mtw.isValid()) {
            removeMtwBlinker();

            _lastMtw = datas.mtw;

            analog["mutato2"].visible = true;

            if(!isNaN((minMaxVars["mtw.temperature"] as MinMax).min)) {
                analog["min2"].visible = true;
            }
            if(!isNaN((minMaxVars["mtw.temperature"] as MinMax).max)) {
                analog["max2"].visible = true;
            }

            _forgatHandler2.forgat((_offset + datas.mtw.temperature.value)*_unit, { needTween: needTween });

            analogi["digi2"]["digi_a"].text = Splitter.withValue(datas.mtw.temperature.value).a3;
            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.instance.a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;
        }
    }

    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    public override function dataInvalidated(key:String):void {
        if(key === "mda") {
            removeMdaBlinker();
            analog["mutato1"].alpha = 1.0;
            (minMaxVars["mda.airTemp"] as MinMax).reset((minMaxVars["mda.airTemp"] as MinMax).unitClass);
            setMdaInvalid();
        }
        if(key === "mtw") {
            removeMtwBlinker();
            analog["mutato2"].alpha = 1.0;
            (minMaxVars["mtw.temperature"] as MinMax).reset((minMaxVars["mtw.temperature"] as MinMax).unitClass);
            setMtwInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "mda") {
            analog["mutato1"].alpha = 1.0;

            Blinker.addObject(analog["mutato1"]);
            Blinker.addObject(analogi["digi1"]["digi_a"]);
            Blinker.addObject(analogi["digi1"]["digi_b"]);
            Blinker.addObject(digital["digi1"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_b"]);
        }
        if(key === "mtw") {
            analog["mutato2"].alpha = 1.0;

            Blinker.addObject(analog["mutato2"]);
            Blinker.addObject(analogi["digi2"]["digi_a"]);
            Blinker.addObject(analogi["digi2"]["digi_b"]);
            Blinker.addObject(digital["digi2"]["digi_a"]);
            Blinker.addObject(digital["digi2"]["digi_b"]);
        }
    }

    private function removeMdaBlinker():void {
        Blinker.removeObject(analog["mutato1"]);
        Blinker.removeObject(analogi["digi1"]["digi_a"]);
        Blinker.removeObject(analogi["digi1"]["digi_b"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
    }

    private function removeMtwBlinker():void {
        Blinker.removeObject(analog["mutato2"]);
        Blinker.removeObject(analogi["digi2"]["digi_a"]);
        Blinker.removeObject(analogi["digi2"]["digi_b"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }

    private function setMdaInvalid():void {
        _lastMda = null;

        analog["mutato1"].visible = false;
        if(!(minMaxVars["mda.airTemp"] as MinMax).reseted) {
            analog["min1"].visible = true;
            analog["max1"].visible = true;
        } else {
            analog["min1"].visible = false;
            analog["max1"].visible = false;

            digital["digimin1"]["digi_a"].text = "---";
            digital["digimin1"]["digi_b"].text = "-";
            digital["digimax1"]["digi_a"].text = "---";
            digital["digimax1"]["digi_b"].text = "-";
        }

        analogi["digi1"]["digi_a"].text = "---";
        analogi["digi1"]["digi_b"].text = "-";
        digital["digi1"]["digi_a"].text = "---";
        digital["digi1"]["digi_b"].text = "-";
    }

    private function setMtwInvalid():void {
        _lastMtw = null;

        analog["mutato2"].visible = false;
        if(!(minMaxVars["mtw.temperature"] as MinMax).reseted) {
            analog["min2"].visible = true;
            analog["max2"].visible = true;
        } else {
            analog["min2"].visible = false;
            analog["max2"].visible = false;

            digital["digimin2"]["digi_a"].text = "---";
            digital["digimin2"]["digi_b"].text = "-";
            digital["digimax2"]["digi_a"].text = "---";
            digital["digimax2"]["digi_b"].text = "-";
        }

        analogi["digi2"]["digi_a"].text = "---";
        analogi["digi2"]["digi_b"].text = "-";
        digital["digi2"]["digi_a"].text = "---";
        digital["digi2"]["digi_b"].text = "-";
    }

    public override function unitChanged():void {
        uchange();
    }

    private function uchange():void{
        if(_lastMda!=null) {
            analogi["digi1"]["digi_a"].text = Splitter.withValue(_lastMda.waterTemp.value).a2;
            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi1"]["digi_a"].text = Splitter.instance.a3;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;
        }
        if(_lastMtw!=null) {
            analogi["digi2"]["digi_a"].text = Splitter.withValue(_lastMtw.temperature.value).a2;
            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.instance.a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;
        }

        analog["szlap_C"].visible = false;
        analog["szlap_F"].visible = false;

        digitalBackground["unit_C"].visible=false;
        digitalBackground["unit_F"].visible=false;

        switch(UnitHandler.instance.temperature) {
            case Temperature.CELSIUS:
                analog["szlap_C"].visible= true;
                digitalBackground["unit_C"].visible= true;
                _unit = 270/60;
                _offset = 20;
                break;
            case Temperature.FAHRENHEIT:
                analog["szlap_F"].visible= true;
                digitalBackground["unit_F"].visible= true;
                _unit = 270/120;
                _offset = 10;
                break;
            default:
                analog["szlap_C"].visible = true;
                digitalBackground["unit_C"].visible= true;
                _unit = 270/60;
                _offset = 20;
                break;
        }

        digitalBackgroundBatch.render();
    }

    public override function minMaxChanged():void {
        var min:Number = (minMaxVars["mda.airTemp"] as MinMax).min;
        var max:Number = (minMaxVars["mda.airTemp"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital["digimin1"]["digi_a"].text = Splitter.withValue(min).a3;
            digital["digimin1"]["digi_b"].text = Splitter.instance.b1;
            digital["digimax1"]["digi_a"].text = Splitter.withValue(max).a3;
            digital["digimax1"]["digi_b"].text = Splitter.instance.b1;

            min = (_offset + min)*_unit;
            if(min<BEGIN) {
                analog["min1"].rotation = deg2rad(BEGIN);
            } else if(min>180+_forgatHandler1.max) {
                analog["min1"].rotation = deg2rad(180 + _forgatHandler1.max);
            } else {
                analog["min1"].rotation = deg2rad(min + BEGIN);
            }
            max = (_offset + max)*_unit;
            if(max<BEGIN) {
                analog["max1"].rotation = deg2rad(BEGIN);
            } else if(max>180+_forgatHandler1.max) {
                analog["max1"].rotation = deg2rad(180 + _forgatHandler1.max);
            } else {
                analog["max1"].rotation = deg2rad(max + BEGIN);
            }
        } else {
            analog["min1"].visible = false;
            analog["max1"].visible = false;

            digital["digimin1"]["digi_a"].text = "---";
            digital["digimin1"]["digi_b"].text = "-";
            digital["digimax1"]["digi_a"].text = "---";
            digital["digimax1"]["digi_b"].text = "-";
        }

        min = (minMaxVars["mtw.temperature"] as MinMax).min;
        max = (minMaxVars["mtw.temperature"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital["digimin2"]["digi_a"].text = Splitter.withValue(min).a3;
            digital["digimin2"]["digi_b"].text = Splitter.instance.b1;
            digital["digimax2"]["digi_a"].text = Splitter.withValue(max).a3;
            digital["digimax2"]["digi_b"].text = Splitter.instance.b1;

            min = (_offset + min)*_unit;
            if(min<BEGIN) {
                analog["min2"].rotation = deg2rad(BEGIN);
            } else if(min>180+_forgatHandler2.max) {
                analog["min2"].rotation = deg2rad(180 + _forgatHandler2.max);
            } else {
                analog["min2"].rotation = deg2rad(min + BEGIN);
            }
            max = (_offset + max)*_unit;
            if(max<BEGIN) {
                analog["max2"].rotation = deg2rad(BEGIN);
            } else if(max>180+_forgatHandler2.max) {
                analog["max2"].rotation = deg2rad(180 + _forgatHandler2.max);
            } else {
                analog["max2"].rotation = deg2rad(max + BEGIN);
            }
        } else {
            analog["min2"].visible = false;
            analog["max2"].visible = false;

            digital["digimin2"]["digi_a"].text = "---";
            digital["digimin2"]["digi_b"].text = "-";
            digital["digimax2"]["digi_a"].text = "---";
            digital["digimax2"]["digi_b"].text = "-";
        }
    }
}
}
