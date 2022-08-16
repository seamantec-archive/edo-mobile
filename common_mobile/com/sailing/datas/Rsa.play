package com.sailing.datas {
import com.sailing.interfaces.IMinMax;

public class Rsa extends BaseSailData implements IMinMax {

    public var rudderSensorStarboard:Number = 0;
    public var rudderSensorStarboardValid:int = 0;
    public var rudderSensorPort:Number = 0;
    public var rudderSensorPortValid:int = 0;

    public function Rsa() {
        super();
        _paramsDisplayName["rudderSensorStarboard"] = { displayName: "Starboard sensor", order: 0 };
        _paramsDisplayName["rudderSensorStarboardValid"] = { displayName: "Starboard sensor status", order: 2 };
        _paramsDisplayName["rudderSensorPort"] = { displayName: "Port sensor", order: 3 };
        _paramsDisplayName["rudderSensorPortValid"] = { displayName: "Port sensor status", order: 4 };
    }

    public override function get displayName():String {
        return "Rudder Sensor Angle (RSA)";
    }
}
}