/**
 * Created by seamantec on 23/09/14.
 */
package components.stages.instruments {
import com.common.AppProperties;
import com.sailing.instruments.BaseInstrument;

import components.EdoStage;
import components.InstrumentHandler;
import components.instruments.Tacticomp;

public class TacticompStage extends EdoStage {

    public static const ID:String = "tacticomp_stage";

    private var _instrument:BaseInstrument;

    public function TacticompStage() {
        super(ID, "Tacticomp");

        _instrument = new Tacticomp();
        _instrument.width = AppProperties.screenWidth;
        _instrument.height = _instrument.width;
        addInstrument(_instrument);
    }
}
}
