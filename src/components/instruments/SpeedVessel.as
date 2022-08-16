﻿package components.instruments {import com.dynamicInstruments.DynamicSprite;import com.dynamicInstruments.InstrumentQuadBatcher;import com.sailing.ForgatHandler;import com.sailing.Splitter;import com.utils.Assets;import com.sailing.SailData;import com.sailing.datas.*;import com.sailing.instruments.BaseInstrument;import com.sailing.minMax.MinMax;import com.sailing.units.*;import com.utils.Blinker;import com.utils.SaveHandler;import starling.events.TouchEvent;import starling.textures.Texture;import starling.utils.HAlign;import starling.utils.VAlign;import starling.utils.deg2rad;public class SpeedVessel extends BaseInstrument {	private const BEGIN:uint = 30;    private var _lastVhw:Vhw;    private var _lastPAS:PositionAndSpeed;	public var actualState:String = "";    private var forgatHandler:ForgatHandler;	private var forgatHandler1:ForgatHandler;			private var oneUnit:Number = 300/20;    private var analog:DynamicSprite;    private var analogi:DynamicSprite;    private var centerBatch:InstrumentQuadBatcher;    private var center:DynamicSprite;    private var digitalBackgroundBatch:InstrumentQuadBatcher;    private var digitalBackground:DynamicSprite;    private var digital:DynamicSprite;	public function SpeedVessel() {		super(Assets.getInstrument("speed"));		minMaxVars["vhw.waterSpeed"] = new MinMax(undefined, undefined, this);		minMaxVars["positionandspeed.sog"]  = new MinMax(undefined, undefined, this);        forgatHandler = new ForgatHandler(analog["mutato1"], this, { offsetToZero: BEGIN , min: 210, max: 150 });        forgatHandler1 = new ForgatHandler(analog["mutato2"], this, { offsetToZero: BEGIN , min: 210, max: 150 });		setAnalog();		this.addEventListener(TouchEvent.TOUCH, digitalis);        setVhwInvalid();        setPositionAndSpeedInvalid();        uchange();	}    protected override function buildComponents():void {        var basic:Texture = Assets.getAtlas("basic_common");        var speed:Texture = Assets.getAtlas("speed_common");        analog = _instrumentAtlas.getComponentAsDynamicSprite(speed, "analog.instance2");        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_kts", analog);        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_mph", analog);        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_mps", analog);        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.szlap_kmph", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato2", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato1", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max1", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min1", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.max2", analog);        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.min2", analog);        center = new DynamicSprite();        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance16", center);        _instrumentAtlas.getComponentAsImageWithParent(speed, "analog.instance13", center);        analogi = new DynamicSprite();        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi1", analogi, center);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi2", analogi, center);        this.addChild(analog);        centerBatch = new InstrumentQuadBatcher(analog.width,analog.height, "speedAnalogCenter");        centerBatch.addDisplayObject(center);        this.addChild(centerBatch.quadBatch);        this.addChild(analogi);        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(speed, "digital.instance17");        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_kts", digitalBackground);        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_kmph", digitalBackground);        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_mph", digitalBackground);        _instrumentAtlas.getComponentAsImageWithParent(speed, "digital.unit_mps", digitalBackground);        digital = new DynamicSprite();        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "speedDigitalBackground");        digitalBackgroundBatch.addDisplayObject(digitalBackground);        this.addChild(digitalBackgroundBatch.quadBatch);        this.addChild(digital);    }    private function setAnalog():void {        analog.visible = true;        analogi.visible = true;        centerBatch.quadBatch.visible = true;        digitalBackgroundBatch.quadBatch.visible = false;        digital.visible = false;    }    private function setDigital():void {        analog.visible = false;        analogi.visible = false;        centerBatch.quadBatch.visible = false;        digitalBackgroundBatch.quadBatch.visible = true;        digital.visible = true;    }		private function digitalis(event:TouchEvent):void {        if (touchIsEnd(event)) {            if (analog.visible) {                setDigital();                actualState = "digital";            } else {                setAnalog();                actualState = "analog";            }            SaveHandler.instance.setState(_id, actualState);        }	}				private function setState(value:String):void {		actualState = value;		if(value == "digital") {            setDigital();		} else if(value == "analog") {            setAnalog();		}	}		public override function updateState(stateType:String):void {		setState(stateType);	}		public override function updateDatas(datas:SailData, needTween:Boolean = true):void {        if(datas!=null && datas.vhw.isValid()) {            removeVhwBlinker();            _lastVhw = datas.vhw;            analog["mutato2"].visible = true;            if(!isNaN((minMaxVars["vhw.waterSpeed"] as MinMax).min)) {                analog["min1"].visible = true;            }            if(!isNaN((minMaxVars["vhw.waterSpeed"] as MinMax).max)) {                analog["max1"].visible = true;            }            forgatHandler1.forgat(datas.vhw.waterSpeed.value*oneUnit, { needTween: needTween });            analogi["digi1"]["digi_a"].text = Splitter.withValue(datas.vhw.waterSpeed.value).a2;            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;            digital["digi1"]["digi_a"].text = Splitter.withValue(datas.vhw.waterSpeed.value).a3;            digital["digi1"]["digi_b"].text = Splitter.instance.b1;        }        if(datas!=null && datas.positionandspeed.isValid()) {            removePositionAndSpeedBlinker();            _lastPAS = datas.positionandspeed;            analog["mutato2"].visible = true;            if(!isNaN((minMaxVars["positionandspeed.sog"] as MinMax).min)) {                analog["min2"].visible = true;            }            if(!isNaN((minMaxVars["positionandspeed.sog"] as MinMax).max)) {                analog["max2"].visible = true;            }            forgatHandler.forgat(datas.positionandspeed.sog.value*oneUnit, { needTween: needTween });            analogi["digi2"]["digi_a"].text = Splitter.withValue(datas.positionandspeed.sog.value).a2;            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;            digital["digi2"]["digi_a"].text = Splitter.withValue(datas.positionandspeed.sog.value).a3;            digital["digi2"]["digi_b"].text = Splitter.instance.b1;        }    }    public override function dataInvalidated(key:String):void{        if(key === "vhw") {            removeVhwBlinker();            analog["mutato2"].alpha = 1.0;            (minMaxVars["vhw.waterSpeed"] as MinMax).reset((minMaxVars["vhw.waterSpeed"] as MinMax).unitClass);            setVhwInvalid();        }        if(key === "positionandspeed") {            removePositionAndSpeedBlinker();            analog["mutato1"].alpha = 1.0;            (minMaxVars["positionandspeed.sog"] as MinMax).reset((minMaxVars["positionandspeed.sog"] as MinMax).unitClass);            setPositionAndSpeedInvalid();        }    }    public override function dataPreInvalidated(key:String):void {        if(key === "vhw") {            analog["mutato2"].alpha = 1.0;            Blinker.addObject(analog["mutato2"]);            Blinker.addObject(analogi["digi1"]["digi_a"]);            Blinker.addObject(analogi["digi1"]["digi_b"]);            Blinker.addObject(digital["digi1"]["digi_a"]);            Blinker.addObject(digital["digi1"]["digi_b"]);        }        if(key === "positionandspeed") {            analog["mutato1"].alpha = 1.0;            Blinker.addObject(analog["mutato1"]);            Blinker.addObject(analogi["digi2"]["digi_a"]);            Blinker.addObject(analogi["digi2"]["digi_b"]);            Blinker.addObject(digital["digi2"]["digi_a"]);            Blinker.addObject(digital["digi2"]["digi_b"]);        }    }    private function removeVhwBlinker():void {        Blinker.removeObject(analog["mutato2"]);        Blinker.removeObject(analogi["digi1"]["digi_a"]);        Blinker.removeObject(analogi["digi1"]["digi_b"]);        Blinker.removeObject(digital["digi1"]["digi_a"]);        Blinker.removeObject(digital["digi1"]["digi_b"]);    }    private function removePositionAndSpeedBlinker():void {        Blinker.removeObject(analog["mutato1"]);        Blinker.removeObject(analogi["digi2"]["digi_a"]);        Blinker.removeObject(analogi["digi2"]["digi_b"]);        Blinker.removeObject(digital["digi2"]["digi_a"]);        Blinker.removeObject(digital["digi2"]["digi_b"]);    }    private function setVhwInvalid():void {        _lastVhw = null;        analog["mutato2"].visible = false;        if(!(minMaxVars["vhw.waterSpeed"] as MinMax).reseted) {            analog["min1"].visible = true;            analog["max1"].visible = true;        } else {            analog["min1"].visible = false;            analog["max1"].visible = false;            digital["digimin1"]["digi_a"].text = "---";            digital["digimin1"]["digi_b"].text = "-";            digital["digimax1"]["digi_a"].text = "---";            digital["digimax1"]["digi_b"].text = "-";        }        analogi["digi1"]["digi_a"].text = "--";        analogi["digi1"]["digi_b"].text = "-";        digital["digi1"]["digi_a"].text = "---";        digital["digi1"]["digi_b"].text = "-";    }    private function setPositionAndSpeedInvalid():void {        _lastPAS = null;        analog["mutato1"].visible = false;        if(!(minMaxVars["positionandspeed.sog"] as MinMax).reseted) {            analog["min2"].visible = true;            analog["max2"].visible = true;        } else {            analog["min2"].visible = false;            analog["max2"].visible = false;            digital["digimin2"]["digi_a"].text = "---";            digital["digimin2"]["digi_b"].text = "-";            digital["digimax2"]["digi_a"].text = "---";            digital["digimax2"]["digi_b"].text = "-";        }        analogi["digi2"]["digi_a"].text = "--";        analogi["digi2"]["digi_b"].text = "-";        digital["digi2"]["digi_a"].text = "---";        digital["digi2"]["digi_b"].text = "-";    }			public override function minMaxChanged():void {        var min:Number = (minMaxVars["vhw.waterSpeed"] as MinMax).min;        var max:Number = (minMaxVars["vhw.waterSpeed"] as MinMax).max;        if(!isNaN(min) && !isNaN(max)) {            digital["digimin1"]["digi_a"].text = Splitter.withValue(min).a3;            digital["digimin1"]["digi_b"].text = Splitter.instance.b1;            digital["digimax1"]["digi_a"].text = Splitter.withValue(max).a3;            digital["digimax1"]["digi_b"].text = Splitter.instance.b1;            min *= oneUnit;            if(min<BEGIN) {                analog["min1"].rotation = deg2rad(BEGIN);            } else if(min>180+forgatHandler.max) {                analog["min1"].rotation = deg2rad(180 + forgatHandler.max);            } else {                analog["min1"].rotation = deg2rad(min + BEGIN);            }            max *= oneUnit;            if(max<BEGIN) {                analog["max1"].rotation = deg2rad(BEGIN);            } else if(max>180+forgatHandler.max) {                analog["max1"].rotation = deg2rad(180 + forgatHandler.max);            } else {                analog["max1"].rotation = deg2rad(max + BEGIN);            }        } else {            analog["min1"].visible = false;            analog["max1"].visible = false;            digital["digimin1"]["digi_a"].text = "---";            digital["digimin1"]["digi_b"].text = "-";            digital["digimax1"]["digi_a"].text = "---";            digital["digimax1"]["digi_b"].text = "-";        }        min = (minMaxVars["positionandspeed.sog"] as MinMax).min;        max = (minMaxVars["positionandspeed.sog"] as MinMax).max;        if(!isNaN(min) && !isNaN(max)) {            digital["digimin2"]["digi_a"].text = Splitter.withValue(min).a3;            digital["digimin2"]["digi_b"].text = Splitter.instance.b1;            digital["digimax2"]["digi_a"].text = Splitter.withValue(max).a3;            digital["digimax2"]["digi_b"].text = Splitter.instance.b1;            min *= oneUnit;            if(min<BEGIN) {                analog["min2"].rotation = deg2rad(BEGIN);            } else if(min>180+forgatHandler.max) {                analog["min2"].rotation = deg2rad(180 + forgatHandler.max);            } else {                analog["min2"].rotation = deg2rad(min + BEGIN);            }            max *= oneUnit;            if(max<BEGIN) {                analog["max2"].rotation = deg2rad(BEGIN);            } else if(max>180+forgatHandler.max) {                analog["max2"].rotation = deg2rad(180 + forgatHandler.max);            } else {                analog["max2"].rotation = deg2rad(max + BEGIN);            }        } else {            analog["min2"].visible = false;            analog["max2"].visible = false;            digital["digimin2"]["digi_a"].text = "---";            digital["digimin2"]["digi_b"].text = "-";            digital["digimax2"]["digi_a"].text = "---";            digital["digimax2"]["digi_b"].text = "-";        }    }			public override function unitChanged():void{		uchange();	}	private function uchange():void{        if(_lastVhw!=null) {            analogi["digi1"]["digi_a"].text = Splitter.withValue(_lastVhw.waterSpeed.value).a2;            analogi["digi1"]["digi_b"].text = Splitter.instance.b1;            digital["digi1"]["digi_a"].text = Splitter.instance.a3;            digital["digi1"]["digi_b"].text = Splitter.instance.b1;        }        if(_lastPAS!=null) {            analogi["digi2"]["digi_a"].text = Splitter.withValue(_lastPAS.sog.value).a2;            analogi["digi2"]["digi_b"].text = Splitter.instance.b1;            digital["digi2"]["digi_a"].text = Splitter.instance.a3;            digital["digi2"]["digi_b"].text = Splitter.instance.b1;        }	    analog["szlap_kts"].visible=false;	    analog["szlap_mph"].visible=false;	    analog["szlap_mps"].visible=false;	    analog["szlap_kmph"].visible=false;        digitalBackground["unit_kts"].visible=false;        digitalBackground["unit_mph"].visible=false;        digitalBackground["unit_mps"].visible=false;        digitalBackground["unit_kmph"].visible=false;		switch(UnitHandler.instance.speed){			case Speed.KTS:                analog["szlap_kts"].visible= true;                digitalBackground["unit_kts"].visible= true;				oneUnit = 300/20;			    break;			case Speed.MPH:                analog["szlap_mph"].visible= true;                digitalBackground["unit_mph"].visible= true;				oneUnit = (300/20);			    break;			case Speed.KMH:                analog["szlap_kmph"].visible= true;                digitalBackground["unit_kmph"].visible= true;				oneUnit = (300/30);			    break;			case Speed.MS:                analog["szlap_mps"].visible= true;                digitalBackground["unit_mps"].visible= true;				oneUnit = (300/10);			    break;			default:                analog["szlap_kts"].visible = true;                digitalBackground["unit_kts"].visible= true;				oneUnit = 300/20;			    break;		}        digitalBackgroundBatch.render();    }}}