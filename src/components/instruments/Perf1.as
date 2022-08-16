/**
 * Created by seamantec on 22/01/15.
 */
package components.instruments {
import com.common.SpeedToUse;
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.polar.PolarBoatSpeed;
import com.polar.PolarContainer;
import com.polar.PolarEvent;
import com.polar.PolarTable;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.Performance;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.Vhw;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.sailing.units.Speed;
import com.sailing.units.UnitHandler;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.ImageMask;
import com.utils.ImageMask;
import com.utils.ImageMaskHandler;
import com.utils.SaveHandler;

import flash.events.TimerEvent;

import flash.geom.Point;
import flash.utils.Timer;

import starling.events.Event;

import starling.events.TouchEvent;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.deg2rad;

public class Perf1 extends BaseInstrument {

    private var _lastVhw:Vhw;
    private var _lastPAS:PositionAndSpeed;
    private var _lastPerformance:Performance;

    private const BEGIN:uint = 30;

    public var actualState:String = "";
    var forgatHandler:ForgatHandler;
    var maskHandler:ImageMaskHandler;

    private var oneUnit:Number = 300/20;

    private var _currentSpeed:Number;
    private var _vhw:Number;
    private var _sog:Number;
    private var _minmax:String;
    private var _hasData:Boolean;
    private var _hasPerformance:Boolean;

    private var analog:DynamicSprite;
    private var analogi:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var center:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function Perf1() {
        super(Assets.getInstrument("perf1"));

        minMaxVars["vhw.waterSpeed"] = new MinMax(undefined, undefined, this);
        minMaxVars["positionandspeed.sog"] = new MinMax(undefined, undefined, this);
        minMaxVars["performance.polarSpeed"] = new MinMax(undefined, undefined, this);

        forgatHandler = new ForgatHandler(analog.mutato1, this, { offsetToZero: BEGIN , min: 210, max: 150 });

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_RESET_EVENT, polarResetHandler);
        SpeedToUse.instance.addEventListener("speedToUseChange", speedToUseChangeHandler);

        setVhwInvalid();
        setPerformanceInvalid();

        setSpeedType();

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var speed:Texture = Assets.getAtlas("speed_common");
        var perf:Texture = Assets.getAtlas("perf_common");

        analog = _instrumentAtlas.getComponentAsDynamicSprite(perf, "analog.instance2");
        _instrumentAtlas.getComponentAsSpriteWithParent(perf, "analog.mutato1", analog, false, false);
        analog.mutato1.addChild(_instrumentAtlas.getComponentAsImage(perf, "analog.mutato1.instance8", analog.mutato1));
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min1", analog);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.max2", analog);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.min2", analog);

        maskHandler = new ImageMaskHandler(_instrumentAtlas.getComponentAsImage(perf, "analog.masked_mc").texture, _instrumentAtlas.getTextureInfo("analog.masked_mc"), { min: 210, max: 150 });
        analog.masked_mc = maskHandler;
        analog.addChild(maskHandler);

        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.szlap_kts", analog);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.szlap_mph", analog);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.szlap_mps", analog);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.szlap_kmph", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance13", center);
        _instrumentAtlas.getComponentAsImageWithParent(perf, "analog.instance15", center);
        _instrumentAtlas.getComponentAsTextFieldWithParent("analog.speed_type", center);
        (center.speed_type as TextField).autoScale = true;

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(perf, "analog.digi1", analogi, center, VAlign.CENTER,HAlign.RIGHT, 1.05);

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(analog.width,analog.height, "perf1AnalogCenter");
        centerBatch.addDisplayObject(center);
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(perf, "digital.instance16");

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

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.speed_type", digitalBackground, VAlign.CENTER,HAlign.LEFT);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "perf1DigitalBackground");
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
        _hasData = (SpeedToUse.instance.selected == SpeedToUse.STW) ? (datas.vhw.isValid() && datas.vhw.isPreValid()) : (datas.positionandspeed.isValid() && datas.positionandspeed.isPreValid());
        if(_hasData) {
            removeVhwBlinker();

            _lastVhw = datas.vhw;
            _lastPAS = datas.positionandspeed;

            if(!analog.mutato1.visible) {
                analog.mutato1.visible = true;
            }
            if(!isNaN((minMaxVars["vhw.waterSpeed"] as MinMax).min)) {
                analog.min1.visible = true;
            }
            if(!isNaN((minMaxVars["vhw.waterSpeed"] as MinMax).max)) {
                analog.max1.visible = true;
            }

            if(datas.vhw!=null) {
                _vhw = datas.vhw.waterSpeed.value;
            }
            if(datas.positionandspeed!=null) {
                _sog = datas.positionandspeed.sog.value;
            }

            setData(needTween);
        }

        _hasPerformance = datas.performance.isValid() && datas.performance.isPreValid();
        if(_hasPerformance) {
            removePerformanceBlinker();

            if((datas.performance.performance==null || !datas.performance.performance.isValidValue()) && (datas.performance.polarSpeed!=null || !datas.performance.polarSpeed.isValidValue())) {
                _lastPerformance = null;

                maskHandler.clear();
                analogi.digi1.digi_a.text = "---";
                digital.digi2.digi_a.text = "---";
                digital.digi2.digi_b.text = "-";
            } else {
                _lastPerformance = datas.performance;

                maskHandler.forgat(datas.performance.polarSpeed.value * oneUnit, { needTween: needTween });
                digital.digi2.digi_a.text = Splitter.withValue(datas.performance.polarSpeed.value).a3;
                digital.digi2.digi_b.text = Splitter.instance.b1;

                if (datas.performance.polarSpeed.value == 0 || _currentSpeed == -1) {
                    analogi.digi1.digi_a.text = "---";
                } else if (_hasData) {
                    if (datas.performance.performance.value > 999) {
                        Blinker.addObject(analogi.digi1.digi_a);
                        analogi.digi1.digi_a.text = "999";
                    } else {
                        Blinker.removeObject(analogi.digi1.digi_a);
                        analogi.digi1.digi_a.text = Splitter.withValue(datas.performance.performance.value).x;
                    }
                }
            }
        }
    }

    public override function dataInvalidated(key:String):void{
        if(key == ((SpeedToUse.instance.selected==SpeedToUse.STW) ? "vhw" : "positionandspeed")) {
            removeVhwBlinker();
            analog.mutato1.alpha = 1.0;
            (minMaxVars["vhw.waterSpeed"] as MinMax).reset((minMaxVars["vhw.waterSpeed"] as MinMax).unitClass);
            (minMaxVars["positionandspeed.sog"] as MinMax).reset((minMaxVars["positionandspeed.sog"] as MinMax).unitClass);
            setVhwInvalid();
        }
        if(key === "performance") {
            removePerformanceBlinker();
            (minMaxVars["performance.polarSpeed"] as MinMax).reset((minMaxVars["performance.polarSpeed"] as MinMax).unitClass);
            setPerformanceInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key == ((SpeedToUse.instance.selected==SpeedToUse.STW) ? "vhw" : "positionandspeed")) {
            analog.mutato1.alpha = 1.0;

            Blinker.addObject(analog.mutato1);
            if(_hasPerformance) {
                Blinker.addObject(analogi.digi1.digi_a);
            }
            Blinker.addObject(digital.digi1.digi_a);
            Blinker.addObject(digital.digi1.digi_b);
        }
        if(key === "performance") {
            Blinker.addObject(analog.masked_mc);
            if(_hasData) {
                Blinker.addObject(analogi.digi1.digi_a);
            }
            Blinker.addObject(digital.digi2.digi_a);
            Blinker.addObject(digital.digi2.digi_b);
        }
    }

    private function setData(needTween:Boolean = false):void {
        _currentSpeed = (SpeedToUse.instance.selected==SpeedToUse.STW) ? _vhw : _sog;
        forgatHandler.forgat(_currentSpeed*oneUnit, { needTween: needTween });

        digital.digi1.digi_a.text = Splitter.withValue(_currentSpeed).a3;
        digital.digi1.digi_b.text = Splitter.instance.b1;
    }

    private function removeVhwBlinker():void {
        Blinker.removeObject(analog.mutato1);
        if(_hasPerformance) {
            Blinker.removeObject(analogi.digi1.digi_a);
        }
        Blinker.removeObject(digital.digi1.digi_a);
        Blinker.removeObject(digital.digi1.digi_b);
    }

    private function removePerformanceBlinker():void {
        Blinker.removeObject(analog.masked_mc);
        if(_hasData) {
            Blinker.removeObject(analogi.digi1.digi_a);
        }
        Blinker.removeObject(digital.digi2.digi_a);
        Blinker.removeObject(digital.digi2.digi_b);
    }

    private function setVhwInvalid():void {
        Blinker.removeObject(analogi.digi1.digi_a);

        _lastVhw = null;
        _lastPAS = null;

        _currentSpeed = -1;

        analog.mutato1.visible = false;
        if(!(minMaxVars["vhw.waterSpeed"] as MinMax).reseted) {
            analog.min1.visible = true;
            analog.max1.visible = true;
        } else {
            analog.min1.visible = false;
            analog.max1.visible = false;

            digital.digimin1.digi_a.text = "---";
            digital.digimin1.digi_b.text = "-";
            digital.digimax1.digi_a.text = "---";
            digital.digimax1.digi_b.text = "-";
        }

        analogi.digi1.digi_a.text = "---";
        digital.digi1.digi_a.text = "---";
        digital.digi1.digi_b.text = "-";

        _hasData = false;
    }

    private function setPerformanceInvalid():void {
        Blinker.removeObject(analogi.digi1.digi_a);

        _lastPerformance = null;

        maskHandler.clear();

        analog.min2.visible = false;
        analog.max2.visible = false;

        digital.digimin2.digi_a.text = "---";
        digital.digimin2.digi_b.text = "-";
        digital.digimax2.digi_a.text = "---";
        digital.digimax2.digi_b.text = "-";

        analogi.digi1.digi_a.text = "---";
        digital.digi2.digi_a.text = "---";
        digital.digi2.digi_b.text = "-";

        _hasPerformance = false;
    }

    public override function minMaxChanged():void {
        var min:Number = (minMaxVars[_minmax] as MinMax).min;
        var max:Number = (minMaxVars[_minmax] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital.digimin1.digi_a.text = Splitter.withValue(min).a3;
            digital.digimin1.digi_b.text = Splitter.instance.b1;
            digital.digimax1.digi_a.text = Splitter.withValue(max).a3;
            digital.digimax1.digi_b.text = Splitter.instance.b1;

            min = BEGIN + min*oneUnit;
            if(min<BEGIN) {
                analog.min1.rotation = deg2rad(BEGIN);
            } else if(min>180+forgatHandler.max) {
                analog.min1.rotation = deg2rad(180 + forgatHandler.max);
            } else {
                analog.min1.rotation = deg2rad(min);
            }
            max = BEGIN + max*oneUnit;
            if(max<BEGIN) {
                analog.max1.rotation = deg2rad(BEGIN);
            } else if(max>180+forgatHandler.max) {
                analog.max1.rotation = deg2rad(180 + forgatHandler.max);
            } else {
                analog.max1.rotation = deg2rad(max);
            }
        } else {
            analog.min1.visible = false;
            analog.max1.visible = false;

            digital.digimin1.digi_a.text = "---";
            digital.digimin1.digi_b.text = "-";
            digital.digimax1.digi_a.text = "---";
            digital.digimax1.digi_b.text = "-";
        }

        min = (minMaxVars["performance.polarSpeed"] as MinMax).min;
        max = (minMaxVars["performance.polarSpeed"] as MinMax).max;
        if(!isNaN(min) && !isNaN(max)) {
            digital.digimin2.digi_a.text = Splitter.withValue(min).a3;
            digital.digimin2.digi_b.text = Splitter.instance.b1;
            digital.digimax2.digi_a.text = Splitter.withValue(max).a3;
            digital.digimax2.digi_b.text = Splitter.instance.b1;

            min = BEGIN + min*oneUnit;
            if(min<BEGIN) {
                analog.min2.rotation = deg2rad(BEGIN);
            } else if(min>180+maskHandler.max) {
                analog.min2.rotation = deg2rad(180 + forgatHandler.max);
            } else {
                analog.min2.rotation = deg2rad(min);
            }
            max = BEGIN + max*oneUnit;
            if(max<BEGIN) {
                analog.max2.rotation = deg2rad(BEGIN);
            } else if(max>180+maskHandler.max) {
                analog.max2.rotation = deg2rad(180 + forgatHandler.max);
            } else {
                analog.max2.rotation = deg2rad(max);
            }
        } else {
            analog.min2.visible = false;
            analog.max2.visible = false;

            digital.digimin2.digi_a.text = "---";
            digital.digimin2.digi_b.text = "-";
            digital.digimax2.digi_a.text = "---";
            digital.digimax2.digi_b.text = "-";
        }
    }

    public override function unitChanged():void {
        uchange();
    }

    private function polarResetHandler(e:PolarEvent):void {
        removePerformanceBlinker();
        setPerformanceInvalid();
    }

    private function speedToUseChangeHandler(e:Event):void {
        setSpeedType();
        if(_hasData) {
            setData();
        }
    }

    private function setSpeedType():void {
        if(SpeedToUse.instance.selected==SpeedToUse.STW) {
            _minmax = "vhw.waterSpeed";
            center.speed_type.text = "(STW)";
            digitalBackground.speed_type.text = "(STW)";
        } else {
            _minmax = "positionandspeed.sog";
            center.speed_type.text = "(SOG)";
            digitalBackground.speed_type.text = "(SOG)";
        }

        centerBatch.render();
        digitalBackgroundBatch.render();
    }

    private function uchange():void {
        if((SpeedToUse.instance.selected==SpeedToUse.STW &&_lastVhw!=null) || (SpeedToUse.instance.selected==SpeedToUse.SOG && _lastPAS!=null)) {
            digital.digi1.digi_a.text = Splitter.withValue((SpeedToUse.instance.selected==SpeedToUse.STW) ? _lastVhw.waterSpeed.value : _lastPAS.sog.value).a3;
            digital.digi1.digi_b.text = Splitter.instance.b1;
        }
        if(_lastPerformance!=null) {
            digital.digi2.digi_a.text = Splitter.withValue(_lastPerformance.polarSpeed.value).a3;
            digital.digi2.digi_b.text = Splitter.instance.b1;
        }

        analog.szlap_kts.visible = false;
        analog.szlap_mph.visible = false;
        analog.szlap_mps.visible = false;
        analog.szlap_kmph.visible = false;

        digitalBackground.unit_kts.visible = false;
        digitalBackground.unit_mph.visible = false;
        digitalBackground.unit_mps.visible = false;
        digitalBackground.unit_kmph.visible = false;

        switch(UnitHandler.instance.speed){
            case Speed.KTS:
                analog.szlap_kts.visible = true;
                digitalBackground.unit_kts.visible = true;
                oneUnit = 300/20;
                break;
            case Speed.MPH:
                analog.szlap_mph.visible = true;
                digitalBackground.unit_mph.visible = true;
                oneUnit = 300/20;
                break;
            case Speed.KMH:
                analog.szlap_kmph.visible = true;
                digitalBackground.unit_kmph.visible = true;
                oneUnit = 300/30;
                break;
            case Speed.MS:
                analog.szlap_mps.visible = true;
                digitalBackground.unit_mps.visible = true;
                oneUnit = 300/10;
                break;
            default:
                analog.szlap_kts.visible = true;
                digitalBackground.unit_kts.visible = true;
                oneUnit = 300/20;
                break;
        }

        digitalBackgroundBatch.render();
    }
}
}
