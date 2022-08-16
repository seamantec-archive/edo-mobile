/**
 * Created by seamantec on 10/11/14.
 */
package components.instruments {
import com.dynamicInstruments.DynamicSprite;
import com.sailing.ForgatHandler;
import com.sailing.SailData;
import com.sailing.Splitter;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.WaterDepth;
import com.sailing.instruments.BaseInstrument;
import com.sailing.units.Depth;
import com.sailing.units.Speed;
import com.sailing.units.Unit;
import com.utils.Assets;
import com.utils.Blinker;
import com.utils.CoordinateSystemUtils;

import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class DigilecAllo extends BaseInstrument {

    private var _lastPAS:PositionAndSpeed;
    private var _lastDepth:WaterDepth;

    private var hour;
    private var minute;
    private var second;

    private var forgatHandler_cog:ForgatHandler;
    private var forgatHandler_ora:ForgatHandler;
    private var forgatHandler_perc:ForgatHandler;

    private var cog_analog:DynamicSprite;
    private var utc_analog:DynamicSprite;
    private var sog:DynamicSprite;
    private var NS:TextField;
    private var EW:TextField;
    private var cog:TextField;
    private var lat_deg:TextField;
    private var lat_min_a:TextField;
    private var lat_min_b:TextField;
    private var lon_deg:TextField;
    private var lon_min_a:TextField;
    private var lon_min_b:TextField;
    private var water_depth_a:TextField;
    private var water_depth_b:TextField;
    private var utc_a:TextField;
    private var utc_b:TextField;
    private var utc_c:TextField;
    private var sog_unit:TextField;
    private var depth_unit:TextField;

    public function DigilecAllo() {
        super(Assets.digilecAlloAssets);
        buildComponents();

        forgatHandler_cog = new ForgatHandler(cog_analog.cog_mutato, this);
        forgatHandler_ora = new ForgatHandler(utc_analog.ora_mutato, this);
        forgatHandler_perc = new ForgatHandler(utc_analog.perc_mutato, this);

        setPositionAndSpeedInvalid();
        setGgaInvalid();
        setDbtInvalid();

        uchange();
    }

    private function buildComponents():void {
        this.addChild(textureAtlas.getComponentAsImage("instance2"));
        this.addChild(textureAtlas.getComponentAsImage("instance3"));
        this.addChild(textureAtlas.getComponentAsImage("instance4"));
        this.addChild(textureAtlas.getComponentAsImage("instance5"));
        this.addChild(textureAtlas.getComponentAsImage("instance6"));
        this.addChild(textureAtlas.getComponentAsImage("instance7"));
        this.addChild(textureAtlas.getComponentAsImage("instance8"));
        this.addChild(textureAtlas.getComponentAsImage("instance10"));

        sog_unit = textureAtlas.getComponentAsTextField("sog_unit");
        depth_unit = textureAtlas.getComponentAsTextField("depth_unit");
        cog = textureAtlas.getComponentAsTextField("cog", VAlign.CENTER,HAlign.RIGHT, .9);
//        cog.x += 1;
        cog.y -= 1;

        this.addChild(sog_unit);
        this.addChild(depth_unit);
        this.addChild(cog);

        sog = textureAtlas.getComponentAsDynamicSprite("sog", false, false);
        textureAtlas.getComponentAsTextFieldWithParent("sog._a", sog, VAlign.CENTER,HAlign.RIGHT, 1.1);
//        sog["_a"].x += 1;
        sog["_a"].y += 1;
        textureAtlas.getComponentAsTextFieldWithParent("sog._b", sog, VAlign.CENTER,HAlign.RIGHT, 1.1);
        sog["_b"].y += 1;

        this.addChild(sog);

        utc_a = textureAtlas.getComponentAsTextField("utc_a", VAlign.CENTER,HAlign.RIGHT, 1.2);
        utc_a.y += 1;
        utc_b = textureAtlas.getComponentAsTextField("utc_b", VAlign.CENTER,HAlign.RIGHT, 1.2);
        utc_b.y += 1;
        utc_c = textureAtlas.getComponentAsTextField("utc_c", VAlign.CENTER,HAlign.RIGHT, 1.2);
        utc_c.y += 1;
        NS = textureAtlas.getComponentAsTextField("NS");
        EW = textureAtlas.getComponentAsTextField("EW");
        lat_deg = textureAtlas.getComponentAsTextField("lat_deg", VAlign.CENTER,HAlign.RIGHT, 1.2);
        lat_deg.y += 1;
        lat_min_a = textureAtlas.getComponentAsTextField("lat_min_a", VAlign.CENTER,HAlign.RIGHT, 1.2);
        lat_min_a.y += 1;
        lat_min_b = textureAtlas.getComponentAsTextField("lat_min_b", VAlign.CENTER,HAlign.RIGHT, 1.2);
        lat_min_b.y += 1;
        lon_deg = textureAtlas.getComponentAsTextField("lon_deg", VAlign.CENTER,HAlign.RIGHT, 1.2);
        lon_deg.y += 1;
        lon_min_a = textureAtlas.getComponentAsTextField("lon_min_a", VAlign.CENTER,HAlign.RIGHT, .7);
        lon_min_a.y -= 3;
        lon_min_b = textureAtlas.getComponentAsTextField("lon_min_b", VAlign.CENTER,HAlign.RIGHT, .75);
        lon_min_b.y -= 2;
        water_depth_a = textureAtlas.getComponentAsTextField("water_depth_a", VAlign.CENTER,HAlign.RIGHT, 1.1);
//        water_depth_a.x += 1;
        water_depth_a.y += 1;
        water_depth_b = textureAtlas.getComponentAsTextField("water_depth_b", VAlign.CENTER,HAlign.RIGHT, 1.1);
        water_depth_b.y += 1;

        this.addChild(utc_a);
        this.addChild(utc_b);
        this.addChild(utc_c);
        this.addChild(NS);
        this.addChild(EW);
        this.addChild(lat_deg);
        this.addChild(lat_min_a);
        this.addChild(lat_min_b);
        this.addChild(lon_deg);
        this.addChild(lon_min_a);
        this.addChild(lon_min_b);
        this.addChild(water_depth_a);
        this.addChild(water_depth_b);

        cog_analog = textureAtlas.getComponentAsDynamicSprite("cog_analog", false, false);
        textureAtlas.getComponentAsImageWithParent("cog_analog.instance11", cog_analog);
        textureAtlas.getComponentAsImageWithParent("cog_analog.cog_mutato", cog_analog);
        this.addChild(cog_analog);

        utc_analog = textureAtlas.getComponentAsDynamicSprite("utc_analog", false, false);
        textureAtlas.getComponentAsImageWithParent("utc_analog.instance13", utc_analog);
        textureAtlas.getComponentAsImageWithParent("utc_analog.ora_mutato", utc_analog);
        textureAtlas.getComponentAsImageWithParent("utc_analog.perc_mutato", utc_analog);
        this.addChild(utc_analog);
    }

    public override function minMaxChanged():void {
    }

    public override function unitChanged():void {
        uchange();
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
        var lat:Object = CoordinateSystemUtils.latLonDecToDDMM(datas.positionandspeed.lat);
        var lon:Object = CoordinateSystemUtils.latLonDecToDDMM(datas.positionandspeed.lon);

        if(datas.positionandspeed.isValid() && datas.positionandspeed.isPreValid()) {
            removePositionAndSpeedBlinker();

            _lastPAS = datas.positionandspeed;

            if(!NS.visible) {
                NS.visible = true;
            }
            if(!EW.visible) {
                EW.visible = true;
            }

            sog._a.text = Splitter.withValue(datas.positionandspeed.sog.value).a2;
            sog._b.text = Splitter.instance.b1;

            if(datas.positionandspeed.cog.value!=Unit.INVALID_VALUE) {
                cog.text = Splitter.withValue(datas.positionandspeed.cog.value).a03;

                cog_analog.cog_mutato.visible = true;
                forgatHandler_cog.forgat(datas.positionandspeed.cog.value);
            } else {
                cog.text = "---";
                cog_analog.cog_mutato.visible = false;
            }

            if (datas.positionandspeed.lat<0){
                NS.text = "S";
            } else {
                NS.text = "N";
            }

            lat_deg.text = Splitter.withValue(Math.abs(lat.deg)).a02;
            lat_min_a.text = Splitter.withValue(lat.min).a02;
            lat_min_b.text = Splitter.instance.b3;

            if (datas.positionandspeed.lon<0){
                EW.text = "W";
            } else {
                EW.text = "E";
            }

            lon_deg.text = Splitter.withValue(Math.abs(lon.deg)).a03;
            lon_min_a.text = Splitter.withValue(lon.min).a02;
            lon_min_b.text = Splitter.instance.b3;

            removeGgaBlinker();

            if(!utc_analog.ora_mutato.visible) {
                utc_analog.ora_mutato.visible = true;
            }
            if(!utc_analog.perc_mutato.visible) {
                utc_analog.perc_mutato.visible = true;
            }

            if(!isNaN(datas.sailDataTimestamp)) {
                setClock(datas.sailDataTimestamp);
            } else {
                setGgaInvalid();
            }
        }

        if(datas.waterdepth.isValid() && datas.waterdepth.isPreValid()) {
            removeDbtBlinker();

            _lastDepth = datas.waterdepth;

            water_depth_a.text = Splitter.withValue(datas.waterdepth.waterDepthWithOffset.value).a3;
            water_depth_b.text = Splitter.instance.b1;
        }
    }

    private function setClock(ms:Number):void {
        var date:Date = new Date(ms);

        hour = date.getUTCHours();
        minute = date.getUTCMinutes();
        second = date.getUTCSeconds();

        forgatHandler_ora.forgat(((hour%12)*(360/12))+(minute*(360/720)));
        forgatHandler_perc.forgat(minute*(360/60));

        utc_a.text = toHour(hour);
        utc_b.text = toMinute(minute);
        utc_c.text = toSecond(second);
    }

    public override function updateState(stateType:String):void { }

    public override function dataInvalidated(key:String):void{
        if(key === "positionandspeed") {
            removePositionAndSpeedBlinker();
            setPositionAndSpeedInvalid();
            removeGgaBlinker();
            setGgaInvalid();
        }
        if(key === "waterdepth") {
            removeDbtBlinker();
            setDbtInvalid();
        }
    }

    public override function dataPreInvalidated(key:String):void {
        if(key === "positionandspeed") {
            Blinker.addObject(cog_analog.cog_mutato);

            Blinker.addObject(sog._a);
            Blinker.addObject(sog._b);
            Blinker.addObject(cog);
            Blinker.addObject(lat_deg);
            Blinker.addObject(lat_min_a);
            Blinker.addObject(lat_min_b);
            Blinker.addObject(lon_deg);
            Blinker.addObject(lon_min_a);
            Blinker.addObject(lon_min_b);

            Blinker.addObject(utc_analog.ora_mutato);
            Blinker.addObject(utc_analog.perc_mutato);

            Blinker.addObject(utc_a);
            Blinker.addObject(utc_b);
            Blinker.addObject(utc_c);
        }
        if(key === "waterdepth") {
            Blinker.addObject(water_depth_a);
            Blinker.addObject(water_depth_b);
        }
    }

    private function removePositionAndSpeedBlinker():void {
        Blinker.removeObject(cog_analog.cog_mutato);

        Blinker.removeObject(sog._a);
        Blinker.removeObject(sog._b);
        Blinker.removeObject(cog);
        Blinker.removeObject(lat_deg);
        Blinker.removeObject(lat_min_a);
        Blinker.removeObject(lat_min_b);
        Blinker.removeObject(lon_deg);
        Blinker.removeObject(lon_min_a);
        Blinker.removeObject(lon_min_b);
    }

    private function removeGgaBlinker():void {
        Blinker.removeObject(utc_analog.ora_mutato);
        Blinker.removeObject(utc_analog.perc_mutato);

        Blinker.removeObject(utc_a);
        Blinker.removeObject(utc_b);
        Blinker.removeObject(utc_c);
    }

    private function removeDbtBlinker():void {
        Blinker.removeObject(water_depth_a);
        Blinker.removeObject(water_depth_b);
    }

    private function setPositionAndSpeedInvalid():void {
        _lastPAS = null;

        cog_analog.cog_mutato.visible = false;

        sog._a.text = "--";
        sog._b.text = "-";
        cog.text = "---";
        lat_deg.text = "--";
        lat_min_a.text = "--";
        lat_min_b.text = "---";
        lon_deg.text = "---";
        lon_min_a.text = "--";
        lon_min_b.text = "---";

        NS.visible = false;
        EW.visible = false;
    }

    private function setGgaInvalid():void {
        utc_analog.ora_mutato.visible = false;
        utc_analog.perc_mutato.visible = false;

        utc_a.text = "--";
        utc_b.text = "--";
        utc_c.text = "--";
    }

    private function setDbtInvalid():void {
        _lastDepth = null;

        water_depth_a.text = "---";
        water_depth_b.text = "-";
    }

    private function uchange():void{
        if(_lastPAS!=null) {
            sog._a.text = Splitter.withValue(_lastPAS.sog.value).a2;
            sog._b.text = Splitter.instance.b1;
        }
        if(_lastDepth!=null) {
            water_depth_a.text = Splitter.withValue(_lastDepth.waterDepthWithOffset.value).a3;
            water_depth_b.text = Splitter.instance.b1;
        }

        sog_unit.text = (new Speed()).getUnitShortString();
        depth_unit.text = (new Depth()).getUnitShortString();
    }

    private function toHour(hour:Number):String {
        hour -= ((hour/24) >> 0)*24;
        if(hour<0) {
            hour += 24;
        }
        return Splitter.withValue(hour).a02;
    }

    private function toMinute(minute:Number):String {
        minute -= ((minute/60) >> 0)*60;
        if(minute<0) {
            minute += 60;
        }
        return Splitter.withValue(minute).a02;
    }

    private function toSecond(second:Number):String {
        second -= ((second/60) >> 0)*60;
        if(second<0) {
            second += 60;
        }
        return Splitter.withValue(second).a02;
    }
}
}
