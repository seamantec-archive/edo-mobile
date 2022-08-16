/**
 * Created by seamantec on 06/11/14.
 */
package components.instruments {
import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.instruments.BaseInstrument;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.SunCalculator;

import starling.textures.Texture;

import starling.utils.HAlign;

import starling.utils.VAlign;

public class Moon extends BaseInstrument {

    private var _lat:Number;
    private var _lon:Number;
    private var _date:Date;

    private const DAYS:Array = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

    private var digitalBackgroundBatch:InstrumentQuadBatcher;
    private var digitalBackground:DynamicSprite;
    private var digital:DynamicSprite;

    public function Moon() {
        super(Assets.getInstrument("moon"));

        _lat = 0;
        _lon = 0;
        _date = null;

        setSunInvalid();
        setMoonInvalid();
    }

    protected override function buildComponents():void {
        var basic:Texture = Assets.getAtlas("basic_common");
        var moon:Texture = Assets.getAtlas("moon");

        digitalBackground = _instrumentAtlas.getComponentAsDynamicSprite(moon, "digital.instance2");

        digital = new DynamicSprite();
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.sun_digi1_a", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["sun_digi1_a"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.sun_digi1_b", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["sun_digi1_b"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.sun_digi2_a", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["sun_digi2_a"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.sun_digi2_b", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["sun_digi2_b"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.moon_digi1_a", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["moon_digi1_a"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.moon_digi1_b", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["moon_digi1_b"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.moon_digi2_a", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["moon_digi2_a"]["a"].y -= 2;
        _instrumentAtlas.getTextFieldComponentWithParent(basic, "digital.moon_digi2_b", digital, digitalBackground, VAlign.CENTER,HAlign.RIGHT, .88);
        digital["moon_digi2_b"]["a"].y -= 2;

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.date", digital);
        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.day", digital);

        _instrumentAtlas.getComponentAsAnimatedSpriteWithParent(moon, "digital.moon", digital);

        digitalBackgroundBatch = new InstrumentQuadBatcher();
        digitalBackgroundBatch.addDisplayObject(digitalBackground);
        this.addChild(digitalBackgroundBatch.quadBatch);

        this.addChild(digital);
    }


    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        if(datas!=null && datas.positionandspeed.isValid()) {
            removeBlinker();

            _lat = datas.positionandspeed.lat;
            _lon = datas.positionandspeed.lon;

            if(datas.zda.isValid()) {
                if(_date==null) {
                    _date = datas.zda.utc;
                } else {
                    if(datas.zda.utc.getTime()>=(_date.getTime()-86400000)) {
                        _date = datas.zda.utc;
                    }
                }
            }
            if(_date!=null) {
                digital["moon"].visible = true;

                var sun:Object = SunCalculator.instance.getSunTimes(_date, _lat, _lon);
                //A Hold ideje UTC-ben van!!!!!!
                var moon:Object = SunCalculator.instance.getMoonTimes(_date, _lat, _lon);

                digital["sun_digi1_a"].a.text = toTime(sun.rise.getUTCHours());
                digital["sun_digi1_b"].a.text = toTime(sun.rise.getUTCMinutes());
                digital["sun_digi2_a"].a.text = toTime(sun.set.getUTCHours());
                digital["sun_digi2_b"].a.text = toTime(sun.set.getUTCMinutes());

                digital["date"].text = toTime(_date.getUTCDate()) + ". " + toTime(_date.getUTCMonth()+1) + ". " + _date.getUTCFullYear() + ".";
                digital["day"].text = DAYS[_date.getUTCDay()];

                if(moon.rise!=null) {
                    digital["moon_digi1_a"].a.text = toTime(moon.rise.getUTCHours());
                    digital["moon_digi1_b"].a.text = toTime(moon.rise.getUTCMinutes());
                } else {
                    digital["moon_digi1_a"].a.text = "--";
                    digital["moon_digi1_b"].a.text = "--";
                }
                if(moon.set!=null) {
                    digital["moon_digi2_a"].a.text = toTime(moon.set.getUTCHours());
                    digital["moon_digi2_b"].a.text = toTime(moon.set.getUTCMinutes());
                }
                else {
                    digital["moon_digi2_a"].a.text = "--";
                    digital["moon_digi2_b"].a.text = "--";
                }

                var phase:Number = SunCalculator.instance.getMoonFraction(_date);
                var now:Date = new Date(_date.getTime() + SunCalculator.dayMs);
                //now.setDate(_date.getDate()+1);
                var isNorthern:Boolean = _lat>=0;
                if(phase<=SunCalculator.instance.getMoonFraction(now)) {
                    if(isNorthern) {
                        digital["moon"].currentFrame = Math.round(200 - (100*phase));
                    } else {
                        digital["moon"].currentFrame = Math.round(100*phase);
                    }
                } else {
                    if(isNorthern) {
                        digital["moon"].currentFrame = Math.round(100*phase);
                    } else {
                        digital["moon"].currentFrame = Math.round(200 - (100*phase));
                    }
                }
            }
        }
    }

    public override function updateState(stateType:String):void {
    }

    public override function dataInvalidated(key:String):void {
        if(key==="positionandspeed") {
            _date = null;

            removeBlinker();
            setSunInvalid();
            setMoonInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key==="positionandspeed") {
            Blinker.addObject(digital["date"]);
            Blinker.addObject(digital["day"]);
            Blinker.addObject(digital["sun_digi1_a"].a);
            Blinker.addObject(digital["sun_digi1_b"].a);
            Blinker.addObject(digital["sun_digi2_a"].a);
            Blinker.addObject(digital["sun_digi2_b"].a);

            Blinker.addObject(digital["moon"]);
            Blinker.addObject(digital["moon_digi1_a"].a);
            Blinker.addObject(digital["moon_digi1_b"].a);
            Blinker.addObject(digital["moon_digi2_a"].a);
            Blinker.addObject(digital["moon_digi2_b"].a);
        }
    }

    public override function unitChanged():void {
    }

    public override function minMaxChanged():void {
    }

    private function toTime(hour:Number){
        return Splitter.withValue(hour).a02;
    }

    private function removeBlinker():void {
        Blinker.removeObject(digital["date"]);
        Blinker.removeObject(digital["day"]);
        Blinker.removeObject(digital["sun_digi1_a"].a);
        Blinker.removeObject(digital["sun_digi1_b"].a);
        Blinker.removeObject(digital["sun_digi2_a"].a);
        Blinker.removeObject(digital["sun_digi2_b"].a);

        Blinker.removeObject(digital["moon"]);
        Blinker.removeObject(digital["moon_digi1_a"].a);
        Blinker.removeObject(digital["moon_digi1_b"].a);
        Blinker.removeObject(digital["moon_digi2_a"].a);
        Blinker.removeObject(digital["moon_digi2_b"].a);
    }

    private function setSunInvalid():void {
        digital["sun_digi1_a"].a.text = "--";
        digital["sun_digi1_b"].a.text = "--";
        digital["sun_digi2_a"].a.text = "--";
        digital["sun_digi2_b"].a.text = "--";
        digital["date"].text = "";
        digital["day"].text = "";
    }

    private function setMoonInvalid():void {
        digital["moon"].visible = false;
        digital["moon_digi1_a"].a.text = "--";
        digital["moon_digi1_b"].a.text = "--";
        digital["moon_digi2_a"].a.text = "--";
        digital["moon_digi2_b"].a.text = "--";
    }
}
}
