/**
 * Created by seamantec on 04/11/14.
 */
package components.instruments {

import com.common.AppProperties;
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.instruments.BaseInstrument;
import com.sailing.units.Unit;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SaveHandler;

import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class Heading extends BaseInstrument {

    private var value1:String;
    public var actualState:String = "";

    private var forgatHandler:ForgatHandler;
    private var forgatHandler_mutato:ForgatHandler;
    private var magnetic:Boolean = true;

    private var _isHeading:Boolean;
    private var _isCog:Boolean;

    private var analogBackgroundBatch:InstrumentQuadBatcher;
    private var analogBackground:DynamicSprite;
    private var analog:DynamicSprite;
    private var center:DynamicSprite;
    private var centerBatch:InstrumentQuadBatcher;
    private var analogi:DynamicSprite;
    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function Heading() {
        super(Assets.getInstrument("heading"));

        forgatHandler = new ForgatHandler(analog["forgo"], this);
        forgatHandler_mutato = new ForgatHandler(analog["mutato"], this);

        setAnalog();
        this.addEventListener(TouchEvent.TOUCH, digitalis);

        setInState();

        setVhwInvalid();
        setPositionAndSpeedInvalid();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var compass:Texture = Assets.getAtlas("compass_common");

        analogBackground = _instrumentAtlas.getComponentAsDynamicSprite(compass, "analog.instance2");
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.instance7", analogBackground);
        analogBackgroundBatch = new InstrumentQuadBatcher(analogBackground.width,analogBackground.height, "headingAnalogBackground");
        analogBackgroundBatch.addDisplayObject(analogBackground);
        this.addChild(analogBackgroundBatch.quadBatch);

        analog = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(compass, "analog.forgo", analog);
        _instrumentAtlas.getComponentAsImageWithParent(basic, "analog.mutato", analog);

        center = new DynamicSprite();
        _instrumentAtlas.getComponentAsImageWithParent(compass, "analog.instance5", center);
        center["instance5"].pivotY = 76/AppProperties.screenScaleRatio;

        analogi = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "analog.digi", analogi, center);

        this.addChild(analog);

        centerBatch = new InstrumentQuadBatcher(center.width,center.height, "compassAnalogCenter");
        var fit:Object = fitSpriteInPosition(center);
        centerBatch.addDisplayObject(center);
        centerBatch.quadBatch.x = fit.position.x;
        centerBatch.quadBatch.y = fit.position.y;
        centerBatch.quadBatch.pivotX = fit.pivot.x;
        centerBatch.quadBatch.pivotY = fit.pivot.y;
        this.addChild(centerBatch.quadBatch);

        this.addChild(analogi);

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(compass, "digital.instance8");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin1", digitalBackground, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax1", digitalBackground, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimin2", digitalBackground, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digimax2", digitalBackground, digitalBackground, VAlign.CENTER,HAlign.RIGHT, 1, 0xffeea3);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital, digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital, digitalBackground);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "compassDigitalBackground");
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
                setInState();
            } else {
                setAnalog();
                setInState();
            }
        }
    }

    private function setInState():void {
        value1 = magnetic ? "magnetic" : "true";
        if (analog.visible) {
            actualState = "analog_" + value1;
        } else {
            actualState = "digital_"+value1;
        }

        SaveHandler.instance.setState(_id, actualState);
    }

    private function setState(value:String):void {
        actualState = value;
        if (value.match("digital")) {
            setDigital();
        } else if (value.match("analog")) {
            setAnalog();
        }
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.heading.isValid()) {
            removeVhwBlinker();

            analog["forgo"].visible = true;

            analogi["digi"]["digi_a"].text =  Splitter.withValue(datas.heading.heading.value).a03;
            forgatHandler.forgat(0 - datas.heading.heading.value, { needTween: needTween });

            digital["digi1"]["digi_a"].text = Splitter.withValue(datas.heading.heading.value).a03;
            digital["digi1"]["digi_b"].text = Splitter.instance.b1;

            _isHeading = true;
        }

        if(datas!=null && datas.positionandspeed.isValid()) {
            removePositionAndSpeedBlinker();

            if(datas.positionandspeed.cog.value!=Unit.INVALID_VALUE) {
                digital["digi2"]["digi_a"].text = Splitter.withValue(datas.positionandspeed.cog.value).a03;
                digital["digi2"]["digi_b"].text = Splitter.instance.b1;
                _isCog = true;
            } else {
                digital["digi2"]["digi_a"].text = "---";
                digital["digi2"]["digi_b"].text = "-";
                analog["mutato"].visible = false;
            }
        }

        if(datas!=null && datas.heading.isValid() && datas.positionandspeed.isValid() && datas.positionandspeed.cog.value!=Unit.INVALID_VALUE) {
            analog["mutato"].visible = true;

            forgatHandler_mutato.forgat(datas.positionandspeed.cog.value - datas.heading.heading.value, { needTween: needTween });
        }
    }

    public override function updateState(stateType:String):void {
        setState(stateType);
    }

    public override function dataInvalidated(key:String):void {
        if(key === "heading") {
            removeVhwBlinker();
            setVhwInvalid();
        }
        if(key === "positionandspeed") {
            removePositionAndSpeedBlinker();
            setPositionAndSpeedInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "heading") {
            _isHeading = false;
            Blinker.addObject(analog["forgo"]);
            if(_isCog) {
                Blinker.addObject(analog["mutato"]);
            }
            Blinker.addObject(analogi["digi"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_a"]);
            Blinker.addObject(digital["digi1"]["digi_b"]);
        }
        if(key === "positionandspeed") {
            _isCog = false;
            if(_isHeading) {
                Blinker.addObject(analog["mutato"]);
            }
            Blinker.addObject(digital["digi2"]["digi_a"]);
            Blinker.addObject(digital["digi2"]["digi_b"]);
        }
    }

    private function removeVhwBlinker():void {
        Blinker.removeObject(analog["forgo"]);
        if(_isCog) {
            Blinker.removeObject(analog["mutato"]);
        }
        Blinker.removeObject(analogi["digi"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_a"]);
        Blinker.removeObject(digital["digi1"]["digi_b"]);
    }

    private function removePositionAndSpeedBlinker():void {
        Blinker.removeObject(analog["mutato"]);
        Blinker.removeObject(digital["digi2"]["digi_a"]);
        Blinker.removeObject(digital["digi2"]["digi_b"]);
    }

    private function setVhwInvalid():void {
        _isHeading = false;

        analog["forgo"].visible = false;
        analog["mutato"].visible = false;

        analogi["digi"]["digi_a"].text = "---";
        digital["digi1"]["digi_a"].text = "---";
        digital["digi1"]["digi_b"].text = "-";
    }

    private function setPositionAndSpeedInvalid():void {
        _isCog = false;

        analog["mutato"].visible = false;

        digital["digi2"]["digi_a"].text = "---";
        digital["digi2"]["digi_b"].text = "-";
    }

    public override function unitChanged():void {
    }

    public override function minMaxChanged():void {
    }
}
}
