/**
 * Created by seamantec on 12/11/14.
 */
package components.stages.instruments {
import com.common.AppProperties;
import com.dynamicInstruments.DynamicSprite;
import com.sailing.ForgatHandler;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMax;
import com.utils.Assets;

import components.EdoStage;
import components.instruments.ApparentWindAngle;
import components.instruments.Tacticomp;

import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.getTimer;

public class SerializedStage extends EdoStage {

    public static const ID:String = "serialized_stage";

    private var _instrument:BaseInstrument;

    private var _serializedInstrument:ByteArray;

    public function SerializedStage() {
        super(ID, "New instrument");

        serialize();
//        Assets.appWindAssets = null;
//        Assets.assets.removeTexture("app_wind");
//        Assets.assets.removeXml("app_wind");
        _instrument = deserialize();
        _instrument.initMinMax();
        _instrument.width = AppProperties.screenWidth;
        _instrument.height = AppProperties.screenWidth;
        addInstrument(_instrument);
    }

    private function serialize():void {
        var t:int = getTimer();
        registerClassAlias("components.instruments", ApparentWindAngle);
        var instrument:BaseInstrument = new ApparentWindAngle();
        _serializedInstrument = new ByteArray();
        _serializedInstrument.writeObject(instrument);
        _serializedInstrument.position = 0;
        trace("serialize:", getTimer() - t, "ms", _serializedInstrument.length, "bytes");
    }

    private function deserialize():BaseInstrument {
        var t:int = getTimer();
        var instrument:Object = _serializedInstrument.readObject();
        trace("deserialize:", getTimer() - t, "ms", instrument);

        return instrument as BaseInstrument;
    }
}
}
