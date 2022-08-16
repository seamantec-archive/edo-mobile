/**
 * Created by seamantec on 04/11/14.
 */
package components.instruments {
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.VmgWaypoint;
import com.sailing.datas.VmgWind;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.sailing.units.Speed;
import com.sailing.units.UnitHandler;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SaveHandler;

import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class VmgSpeed extends BaseInstrument {

    private const BEGIN:uint = 30;

    private var _lastWind:VmgWind;
    private var _lastWaypoint:VmgWaypoint;

    public var actualState:String = "";
    var forgatHandler_1:ForgatHandler;
    var forgatHandler_2:ForgatHandler;

    private var oneUnit:Number = 300/20;

    private var analog:DynamicSprite;
    private var analogi:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var center:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function VmgSpeed() {
        super(Assets.getInstrument("vmg"));

        minMaxVars["vmgwind.wind"] = new MinMax(undefined, undefined, this);
        minMaxVars["vmgwaypoint.waypoint"]  = new MinMax(undefined, undefined, this);

        forgatHandler_1 = new ForgatHandler(analog["mutato1"], this, { offsetToZero: BEGIN , min: 210, max: 150 });
        forgatHandler_2 = new ForgatHandler(analog["mutato2"], this, { offsetToZero: BEGIN , min: 210, max: 150 });

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        setVmgWindInvalid();
        setVmgWaypointInvalid();

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var speed:Texture = Assets.getAtlas("speed_common");

        analog = _instrumentAtlas.getComponentAsDynamicSprite(speed, "analog.instance2");

        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_kts", analog);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_mph", analog);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_mps", analog);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_kmph", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato2", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max2", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min2", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance18", center);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.instance15", center);

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi1", analogi, center, VAlign.CENTER,HAlign.RIGHT, 0.875);
        analogi["digi1"]["digi_a"].x -= 1;
        analogi["digi1"]["digi_a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi2", analogi, center, VAlign.CENTER,HAlign.RIGHT, 0.875);
        analogi["digi2"]["digi_a"].x -= 2;
        analogi["digi2"]["digi_a"].y -= 2;

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(analog.width,analog.height, "vmgAnalogCenter");
        centerBatch.addDisplayObject(center);
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(speed, "digital.instance19");

        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_kts", digitalBackground);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_kmph", digitalBackground);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_mph", digitalBackground);
        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_mps", digitalBackground);

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width, digitalBackground.height, "vmgDigitalBackground");
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


    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        var value:Number;

        if(datas!=null && datas.vmgwind.isValid()) {
            removeVmgWindBlinker();

            _lastWind = datas.vmgwind;

            analog["mutato2"].visible = true;

            if(!isNaN((minMaxVars["vmgwind.wind"] as MinMax).min)) {
                analog["min1"].visible = true;
            }
            if(!isNaN((minMaxVars["vmgwind.wind"] as MinMax).max)) {
                analog["max1"].visible = true;
            }

            value = datas.vmgwind.wind.value;

            forgatHandler_2.forgat(value*oneUnit, { needTween: needTween });

            analogi["digi1"]["digi_a"].text = Splitter.withValue(value).a3;
            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi1"]["digi_a"].text = Splitter.instance.a3;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;
        }

        if(datas!=null && datas.vmgwaypoint.isValid()) {
            removeVmgWaypointBlinker();

            _lastWaypoint = datas.vmgwaypoint;

            analog["mutato2"].visible = true;

            if(!isNaN((minMaxVars["vmgwaypoint.waypoint"] as MinMax).min)) {
                analog["min2"].visible = true;
            }
            if(!isNaN((minMaxVars["vmgwaypoint.waypoint"] as MinMax).max)) {
                analog["max2"].visible = true;
            }

            value = datas.vmgwaypoint.waypoint.value;

            forgatHandler_1.forgat(value*oneUnit, { needTween: needTween });

            analogi["digi2"]["digi_a"].text = Splitter.withValue(value).a3;
            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.instance.a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;
        }
    }

    public override function dataInvalidated(key:String):void{
        if(key === "vmgwind") {
            removeVmgWindBlinker();
            analog["mutato2"].alpha = 1.0;
            (minMaxVars["vmgwind.wind"] as MinMax).reset((minMaxVars["vmgwind.wind"] as MinMax).unitClass);
            setVmgWindInvalid();
        }
        if(key === "vmgwaypoint") {
            removeVmgWaypointBlinker();
            analog["mutato1"].alpha = 1.0;
            (minMaxVars["vmgwaypoint.waypoint"] as MinMax).reset((minMaxVars["vmgwaypoint.waypoint"] as MinMax).unitClass);
            setVmgWaypointInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "vmgwind") {
            analog["mutato2"].alpha = 1.0;

            Blinker.addObject(analog["mutato2"]);
            Blinker.addObject(analogi["digi1"]["digi_a"]);
            Blinker.addObject(analogi["digi1"]["digi_b"]);
            Blinker.addObject(digital["digi1"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_b"]);
        }
        if(key === "vmgwaypoint") {
            analog["mutato1"].alpha = 1.0;

            Blinker.addObject(analog["mutato1"]);
            Blinker.addObject(analogi["digi2"]["digi_a"]);
            Blinker.addObject(analogi["digi2"]["digi_b"]);
            Blinker.addObject(digital["digi2"]["digi_a"]);
            Blinker.addObject(digital["digi2"]["digi_b"]);
        }
    }

    private function removeVmgWindBlinker():void {
        Blinker.removeObject(analog["mutato2"]);
        Blinker.removeObject(analogi["digi1"]["digi_a"]);
        Blinker.removeObject(analogi["digi1"]["digi_b"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
    }

    private function removeVmgWaypointBlinker():void {
        Blinker.removeObject(analog["mutato1"]);
        Blinker.removeObject(analogi["digi2"]["digi_a"]);
        Blinker.removeObject(analogi["digi2"]["digi_b"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }

    private function setVmgWindInvalid():void {
        _lastWind = null;

        analog["mutato2"].visible = false;
        if(!(minMaxVars["vmgwind.wind"] as MinMax).reseted) {
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

    private function setVmgWaypointInvalid():void {
        _lastWaypoint = null;

        analog["mutato1"].visible = false;
        if(!(minMaxVars["vmgwaypoint.waypoint"] as MinMax).reseted) {
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

    public override function minMaxChanged():void {
        var min:Number = (minMaxVars["vmgwind.wind"] as MinMax).min;
        var max:Number = (minMaxVars["vmgwind.wind"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital["digimin1"]["digi_a"].text = Splitter.withValue(min).a3;
            digital["digimin1"]["digi_b"].text = Splitter.instance.b1;
            digital["digimax1"]["digi_a"].text = Splitter.withValue(max).a3;
            digital["digimax1"]["digi_b"].text = Splitter.instance.b1;

            min *= oneUnit;
            if(min<BEGIN) {
                analog["min1"].rotation = deg2rad(BEGIN);
            } else if(min>180+forgatHandler_2.max) {
                analog["min1"].rotation = deg2rad(180 + forgatHandler_2.max);
            } else {
                analog["min1"].rotation = deg2rad(min + BEGIN);
            }
            max *= oneUnit;
            if(max<BEGIN) {
                analog["max1"].rotation = deg2rad(BEGIN);
            } else if(max>180+forgatHandler_2.max) {
                analog["max1"].rotation = deg2rad(180 + forgatHandler_2.max);
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

        min = (minMaxVars["vmgwaypoint.waypoint"] as MinMax).min;
        max = (minMaxVars["vmgwaypoint.waypoint"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital["digimin2"]["digi_a"].text = Splitter.withValue(min).a3;
            digital["digimin2"]["digi_b"].text = Splitter.instance.b1;
            digital["digimax2"]["digi_a"].text = Splitter.withValue(max).a3;
            digital["digimax2"]["digi_b"].text = Splitter.instance.b1;

            min *= oneUnit;
            if(min<BEGIN) {
                analog["min2"].rotation = deg2rad(BEGIN);
            } else if(min>180+forgatHandler_1.max) {
                analog["min2"].rotation = deg2rad(180 + forgatHandler_1.max);
            } else {
                analog["min2"].rotation = deg2rad(min + BEGIN);
            }
            max *= oneUnit;
            if(max<BEGIN) {
                analog["max2"].rotation = deg2rad(BEGIN);
            } else if(max>180+forgatHandler_1.max) {
                analog["max2"].rotation = deg2rad(180 + forgatHandler_1.max);
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

    public override function unitChanged():void{
        uchange();
    }

    private function uchange():void{
        if(_lastWind!=null) {
            analogi["digi1"]["digi_a"].text = Splitter.withValue(_lastWind.wind .value).a2;
            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;

            digital["digi1"]["digi_a"].text = Splitter.instance.a3;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;
        }
        if(_lastWaypoint!=null) {
            analogi["digi2"]["digi_a"].text = Splitter.withValue(_lastWaypoint.waypoint.value).a2;
            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;

            digital["digi2"]["digi_a"].text = Splitter.instance.a3;
            digital["digi2"]["digi_b"].text = Splitter.instance.b1;
        }

        analog["szlap_kts"].visible=false;
        analog["szlap_mph"].visible=false;
        analog["szlap_mps"].visible=false;
        analog["szlap_kmph"].visible=false;

        digitalBackground["unit_kts"].visible=false;
        digitalBackground["unit_mph"].visible=false;
        digitalBackground["unit_mps"].visible=false;
        digitalBackground["unit_kmph"].visible=false;

        switch(UnitHandler.instance.speed){
            case Speed.KTS:
                analog["szlap_kts"].visible= true;
                digitalBackground["unit_kts"].visible= true;
                oneUnit = 300/20;
                break;
            case Speed.MPH:
                analog["szlap_mph"].visible= true;
                digitalBackground["unit_mph"].visible= true;
                oneUnit = (300/20);
                break;
            case Speed.KMH:
                analog["szlap_kmph"].visible= true;
                digitalBackground["unit_kmph"].visible= true;
                oneUnit = (300/30);
                break;
            case Speed.MS:
                analog["szlap_mps"].visible= true;
                digitalBackground["unit_mps"].visible= true;
                oneUnit = (300/10);
                break;
            default:
                analog["szlap_kts"].visible = true;
                digitalBackground["unit_kts"].visible= true;
                oneUnit = 300/20;
                break;
        }

        digitalBackgroundBatch.render();
    }

}
}
