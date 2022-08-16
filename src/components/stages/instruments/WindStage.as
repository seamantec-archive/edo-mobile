/**
 * Created by seamantec on 09/10/14.
 */
package components.stages.instruments {

import com.common.AppProperties;
import com.sailing.instruments.BaseInstrument;

import components.EdoStage;
import components.InstrumentHandler;
import components.instruments.ApparentWindAngle;
import components.instruments.TrueWindAngle;

public class WindStage extends EdoStage {

    public static const ID:String = "wind_stage";

    private var _instrument:BaseInstrument;
    private var _instrument2:BaseInstrument;

    public function WindStage() {
        super(ID, "Wind");

        _instrument = new ApparentWindAngle();
        _instrument.width = AppProperties.screenWidth/2;
        _instrument.height = AppProperties.screenWidth/2;
        addInstrument(_instrument);
        _instrument2 = new TrueWindAngle();
        _instrument2.width = AppProperties.screenWidth/2;
        _instrument2.height = AppProperties.screenWidth/2;
        _instrument2.x = _instrument.width;
        addInstrument(_instrument2);
    }
}
}
