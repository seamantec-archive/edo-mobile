/**
 * Created by seamantec on 04/11/14.
 */
package components.stages.instruments {

import com.common.AppProperties;
import com.sailing.instruments.BaseInstrument;

import components.EdoStage;
import components.InstrumentHandler;
import components.instruments.Barometer;
import components.instruments.Clock;
import components.instruments.Compass;
import components.instruments.DbtDepth;
import components.instruments.DigilecAllo;
import components.instruments.GroundWind;
import components.instruments.Heading;
import components.instruments.Moon;
import components.instruments.MtwTemperature;
import components.instruments.Rudder;
import components.instruments.SetAndDrift;
import components.instruments.SpeedVessel;
import components.instruments.Tacticomp;
import components.instruments.VmgSpeed;
import components.instruments.WaypointCU;
import components.instruments.WaypointHU;
import components.instruments.digital.DigitalA;
import components.instruments.digital.DigitalB;
import components.instruments.digital.DigitalC;
import components.instruments.digital.DigitalD;
import components.instruments.digital.DigitalE;

public class NewInstrumentStage extends EdoStage {

    public static const ID:String = "new_instrument_stage";

    private var _instrument:BaseInstrument;
    private var _instrument2:BaseInstrument;
    private var _instrument3:BaseInstrument;
    private var _instrument4:BaseInstrument;

    public function NewInstrumentStage() {
        super(ID, "New instrument");

//        _instrument = new Compass();
//        _instrument.width = AppProperties.screenWidth/2;
//        _instrument.height = AppProperties.screenWidth/2;
//        addInstrument(_instrument);
//
//        _instrument2 = new Heading();
//        _instrument2.x = _instrument.width;
//        _instrument2.width = AppProperties.screenWidth/2;
//        _instrument2.height = AppProperties.screenWidth/2;
//        addInstrument(_instrument2);
//
//        _instrument3 = new Rudder();
//        _instrument3.y = _instrument.height;
//        _instrument3.width = AppProperties.screenWidth/2;
//        _instrument3.height = AppProperties.screenWidth/2;
//        addInstrument(_instrument3);

//        _instrument = new DigitalA();
//        var ratio:Number = _instrument.height/_instrument.width;
//
//        _instrument.width = AppProperties.screenWidth;
//        _instrument.height = _instrument.width*ratio;
//        addInstrument(_instrument);
//
//        _instrument2 = new DigitalB();
//        _instrument2.y = _instrument.height;
//        _instrument2.width = AppProperties.screenWidth;
//        _instrument2.height = _instrument2.width*ratio;
//        addInstrument(_instrument2);
//
//        _instrument3 = new DigitalC();
//        _instrument3.y = _instrument2.y + _instrument2.height;
//        _instrument3.width = AppProperties.screenWidth/2;
//        _instrument3.height = _instrument3.width*ratio;
//        addInstrument(_instrument3);
//        _instrument4 = new DigitalD();
//        _instrument4.x = _instrument3.width;
//        _instrument4.y = _instrument2.y + _instrument2.height;
//        _instrument4.width = AppProperties.screenWidth/2;
//        _instrument4.height = _instrument4.width*ratio;
//        addInstrument(_instrument4);

        _instrument = new VmgSpeed();
        _instrument.width = AppProperties.screenWidth;
        _instrument.height = AppProperties.screenWidth;
        addInstrument(_instrument);
    }
}
}
