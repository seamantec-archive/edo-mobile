/**
 * Created by seamantec on 08/10/14.
 */
package components.stages.instruments {
import com.common.AppProperties;
import com.sailing.instruments.BaseInstrument;

import components.EdoStage;
import components.InstrumentHandler;
import components.instruments.Compass;

public class CompassStage extends EdoStage {

    public static const ID:String = "compass_stage";

    private var _instrument:BaseInstrument;

    public function CompassStage() {
        super(ID, "Compass");

        _instrument = new Compass();
        _instrument.width = AppProperties.screenWidth;
        _instrument.height = AppProperties.screenWidth;
        addInstrument(_instrument);
    }
}
}
