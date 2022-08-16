/**
 * Created by seamantec on 22/09/14.
 */
package components.stages.instruments {

import com.common.AppProperties;
import com.sailing.ParserNotifier;
import com.sailing.instruments.BaseInstrument;

import components.EdoStage;
import components.InstrumentHandler;
import components.TopBar;
import components.instruments.DbtDepth;
import components.instruments.SpeedVessel;
import components.instruments.Tacticomp;
import components.instruments.digital.DigitalA;

public class SpeedStage extends EdoStage {

    public static const ID:String = "instrument_stage";

    private var _instrument:BaseInstrument;

    public function SpeedStage() {
        super(ID, "DigitalA");

        _instrument = new DigitalA();
        _instrument.width = AppProperties.screenWidth;
        _instrument.height = AppProperties.screenWidth/2;
        _instrument.y = 50;
        addInstrument(_instrument);
    }
}
}
