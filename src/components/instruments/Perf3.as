/**
 * Created by seamantec on 29/01/15.
 */
package components.instruments {
import com.common.SpeedToUse;
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.Performance;
import com.sailing.instruments.BaseInstrument;
import com.utils.Assets;
import com.utils.Blinker;

import starling.events.Event;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class Perf3 extends BaseInstrument {

    private var _lastPerformance:Performance;

    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function Perf3() {
        super(Assets.getInstrument("perf3"));

        SpeedToUse.instance.addEventListener("speedToUseChange", speedChangeHandler);

        speedChange();

        setInvalid();

        uchange();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var perf:Texture = Assets.getAtlas("perf_common");

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(perf, "digital.instance2");
        _instrumentAtlas.getComponentAsImageWithParent(perf, "digital.instance5", digitalBackground);
        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.speed_type_up", digitalBackground, VAlign.TOP,HAlign.LEFT);
        digitalBackground.speed_type_up.width *= 1.2;
        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.speed_type_down", digitalBackground, VAlign.TOP,HAlign.LEFT);
        digitalBackground.speed_type_down.width *= 1.2;

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi1", digital,digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi2", digital,digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi3", digital,digitalBackground);
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.digi4", digital,digitalBackground);

        digitalBackgroundBatch = new InstrumentQuadBatcher(digitalBackground.width,digitalBackground.height, "perf3DigitalBackground");
        digitalBackgroundBatch.addDisplayObject(digitalBackground);
        this.addChild(digitalBackgroundBatch.quadBatch);

        this.addChild(digital);
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas.performance.isValid()) {
            removeBlinker();

            _lastPerformance = datas.performance;

            if(datas.performance.beatAngle!=null && datas.performance.beatAngle.isValidValue()) {
                digital.digi1.digi_a.text = Splitter.withValue(datas.performance.beatAngle.value).a03;
                digital.digi1.digi_b.text = "0";
            } else {
                digital.digi1.digi_a.text = "---";
                digital.digi1.digi_b.text = "-";
            }
            if(datas.performance.beatVmg!=null && datas.performance.beatVmg.isValidValue()) {
                digital.digi2.digi_a.text = Splitter.withValue(datas.performance.beatVmg.value).a2;
                digital.digi2.digi_b.text = Splitter.instance.b1;
            } else {
                digital.digi2.digi_a.text = "--";
                digital.digi2.digi_b.text = "-";
            }

            if(datas.performance.runAngle!=null && datas.performance.runAngle.isValidValue()) {
                digital.digi3.digi_a.text = Splitter.withValue(datas.performance.runAngle.value).a03;
                digital.digi3.digi_b.text = "0";
            } else {
                digital.digi3.digi_a.text = "---";
                digital.digi3.digi_b.text = "-";
            }
            if(datas.performance.runVmg!=null && datas.performance.runVmg.isValidValue()) {
                digital.digi4.digi_a.text = Splitter.withValue(datas.performance.runVmg.value).a2;
                digital.digi4.digi_b.text = Splitter.instance.b1;
            } else {
                digital.digi4.digi_a.text = "--";
                digital.digi4.digi_b.text = "-";
            }
        }
    }

    public override function updateState(stateType:String):void {
    }

    public override function dataInvalidated(key:String):void {
        if(key == "performance") {
            setInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key == "performance") {
            if(digital.digi1.digi_a.text!="---") {
                Blinker.addObject(digital.digi1.digi_a);
                Blinker.addObject(digital.digi1.digi_b);
            }
            if(digital.digi2.digi_a.text!="--") {
                Blinker.addObject(digital.digi2.digi_a);
                Blinker.addObject(digital.digi2.digi_b);
            }

            if(digital.digi3.digi_a.text!="---") {
                Blinker.addObject(digital.digi3.digi_a);
                Blinker.addObject(digital.digi3.digi_b);
            }
            if(digital.digi4.digi_a.text!="--") {
                Blinker.addObject(digital.digi4.digi_a);
                Blinker.addObject(digital.digi4.digi_b);
            }
        }
    }

    public override function unitChanged():void {
        uchange();
    }

    public override function minMaxChanged():void {
    }

    private function uchange():void {
        if(digital.digi2.digi_a.text!="--" && _lastPerformance!=null) {
            digital.digi2.digi_a.text = Splitter.withValue(_lastPerformance.beatVmg.value).a2;
            digital.digi2.digi_b.text = Splitter.instance.b1;
        }
        if(digital.digi4.digi_a.text!="--") {
            digital.digi4.digi_a.text = Splitter.withValue(_lastPerformance.runVmg.value).a2;
            digital.digi4.digi_b.text = Splitter.instance.b1;
        }
    }

    private function setInvalid():void {
        removeBlinker();

        _lastPerformance = null;

        digital.digi1.digi_a.text = "---";
        digital.digi1.digi_b.text = "-";

        digital.digi2.digi_a.text = "--";
        digital.digi2.digi_b.text = "-";

        digital.digi3.digi_a.text = "---";
        digital.digi3.digi_b.text = "-";

        digital.digi4.digi_a.text = "--";
        digital.digi4.digi_b.text = "-";
    }

    private function removeBlinker():void {
        Blinker.removeObject(digital.digi1.digi_a);
        Blinker.removeObject(digital.digi1.digi_b);

        Blinker.removeObject(digital.digi2.digi_a);
        Blinker.removeObject(digital.digi2.digi_b);

        Blinker.removeObject(digital.digi3.digi_a);
        Blinker.removeObject(digital.digi3.digi_b);

        Blinker.removeObject(digital.digi4.digi_a);
        Blinker.removeObject(digital.digi4.digi_b);
    }

    private function speedChangeHandler(e:Event):void {
        speedChange();
    }

    private function speedChange():void {
        digitalBackground.speed_type_up.text = (SpeedToUse.instance.selected==SpeedToUse.SOG) ? "(SOG)" : "(STW)";
        digitalBackground.speed_type_down.text = (SpeedToUse.instance.selected==SpeedToUse.SOG) ? "(SOG)" : "(STW)";

        digitalBackgroundBatch.render();
    }
}
}
