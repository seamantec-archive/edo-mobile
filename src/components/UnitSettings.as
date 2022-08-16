/**
 * Created by seamantec on 03/12/14.
 */
package components {

import com.events.MenuDropdownListEvent;
import com.sailing.units.Depth;
import com.sailing.units.Direction;
import com.sailing.units.Distance;
import com.sailing.units.SmallDistance;
import com.sailing.units.Speed;
import com.sailing.units.Temperature;
import com.sailing.units.UnitHandler;
import com.sailing.units.WindSpeed;
import com.ui.MenuDropdownList;
import com.utils.FontFactory;

import starling.display.Sprite;
import starling.text.TextField;

public class UnitSettings extends Sprite {

    public static var WIDTH:Number = Menu.WIDTH*0.9;
    public static var PADDING:Number = Menu.WIDTH*0.05;

    private static var _unitLabel:TextField;
    private static var _distanceLabel:TextField;
    private static var _distanceDropDown:MenuDropdownList;
    private static var _smallDistanceLabel:TextField;
    private static var _smallDistanceDropDown:MenuDropdownList;
    private static var _depthLabel:TextField;
    private static var _depthDropDown:MenuDropdownList;
    private static var _speedLabel:TextField;
    private static var _speedDropDown:MenuDropdownList;
    private static var _windLabel:TextField;
    private static var _windDropDown:MenuDropdownList;
    private static var _temperatureLabel:TextField;
    private static var _temperatureDropDown:MenuDropdownList;
    private static var _directionLabel:TextField;
    private static var _directionDropDown:MenuDropdownList;
    private static var _directionInfoLabel:TextField;

    public function UnitSettings() {
        if (_unitLabel == null) {
            _unitLabel = FontFactory.getWhiteCenterFont(WIDTH,24, 16);
            _unitLabel.x = PADDING;
            _unitLabel.y = 0;
            _unitLabel.text = "Unit settings";
        }
        this.addChild(_unitLabel);

        addDistance();
        setDistanceUnit();
        addSmallDistance();
        setSmallDistanceUnit();
        addWaterDepth();
        setWaterDepthUnit();
        addBoatSpeed();
        setBoatSpeedUnit();
        addWindSpeed();
        setWindSpeedUnit();
        addTemperature();
        setTemperatureUnit();
        addDirection();
        setDirectionUnit();
    }

    public function hide(list:MenuDropdownList):void {
        if(list!=_distanceDropDown) {
            _distanceDropDown.list.visible = false;
        }
        if(list!=_smallDistanceDropDown) {
            _smallDistanceDropDown.list.visible = false;
        }
        if(list!=_depthDropDown) {
            _depthDropDown.list.visible = false;
        }
        if(list!=_speedDropDown) {
            _speedDropDown.list.visible = false;
        }
        if(list!=_windDropDown) {
            _windDropDown.list.visible = false;
        }
        if(list!=_temperatureDropDown) {
            _temperatureDropDown.list.visible = false;
        }
        if(list!=_directionDropDown) {
            _directionDropDown.list.visible = false;
        }
    }

    private function addDistance():void {
        if (_distanceLabel == null) {
            _distanceLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _distanceLabel.x = PADDING;
            _distanceLabel.y = 25;
            _distanceLabel.text = "Distance";
        }
        this.addChild(_distanceLabel);

        if (_distanceDropDown == null) {
            _distanceDropDown = new MenuDropdownList(4);
            _distanceDropDown.x = (Menu.WIDTH/2) - (_distanceDropDown.width/2);
            _distanceDropDown.y = 45;
            _distanceDropDown.addElement("nautical mile (nm)", Distance.NM);
            _distanceDropDown.addElement("statue mile (mi)", Distance.MILE);
            _distanceDropDown.addElement("kilometer (km)", Distance.KM);
            _distanceDropDown.addElement("meter (m)", Distance.METER);
            _distanceDropDown.addEventListener(MenuDropdownListEvent.SELECT, distanceHandler);
        }
        this.addChild(_distanceDropDown);
    }

    private function distanceHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.distance = event.data.data;
        setDistanceUnit();
    }

    private function setDistanceUnit():void {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                _distanceDropDown.label = "nautical mile (nm)";
                break;
            case Distance.MILE:
                _distanceDropDown.label = "statue mile (mi)";
                break;
            case Distance.KM:
                _distanceDropDown.label = "kilometer (km)";
                break;
            case Distance.METER:
                _distanceDropDown.label = "meter (m)";
                break;
            default:
                UnitHandler.instance.distance = Distance.NM;
                _distanceDropDown.label = "nautical mile (nm)";
                break;
        }
    }

    private function addSmallDistance():void {
        if (_smallDistanceLabel == null) {
            _smallDistanceLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _smallDistanceLabel.x = PADDING;
            _smallDistanceLabel.y = 85;
            _smallDistanceLabel.text = "Small distance";
        }
        this.addChild(_smallDistanceLabel);

        if (_smallDistanceDropDown == null) {
            _smallDistanceDropDown = new MenuDropdownList(2);
            _smallDistanceDropDown.x = (Menu.WIDTH/2) - (_smallDistanceDropDown.width/2);
            _smallDistanceDropDown.y = 105;
            _smallDistanceDropDown.addElement("meter (m)", SmallDistance.METER);
            _smallDistanceDropDown.addElement("foot (ft)", SmallDistance.FEET);
            _smallDistanceDropDown.addEventListener(MenuDropdownListEvent.SELECT, smallDistanceHandler);
        }
        this.addChild(_smallDistanceDropDown);
    }

    private function smallDistanceHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.smallDistance = event.data.data;
        setSmallDistanceUnit();
    }

    private function setSmallDistanceUnit():void {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                _smallDistanceDropDown.label = "meter (m)";
                break;
            case SmallDistance.FEET:
                _smallDistanceDropDown.label = "foot (ft)";
                break;
            default:
                UnitHandler.instance.smallDistance = Distance.METER;
                _smallDistanceDropDown.label = "meter (m)";
                break;
        }
    }

    private function addWaterDepth():void {
        if (_depthLabel == null) {
            _depthLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _depthLabel.x = PADDING;
            _depthLabel.y = 145;
            _depthLabel.text = "Water depth";
        }
        this.addChild(_depthLabel);

        if (_depthDropDown == null) {
            _depthDropDown = new MenuDropdownList(3);
            _depthDropDown.x = (Menu.WIDTH/2) - (_depthDropDown.width/2);
            _depthDropDown.y = 165;
            _depthDropDown.addElement("meter (m)", Depth.METER);
            _depthDropDown.addElement("foot (ft)", Depth.FEET);
            _depthDropDown.addElement("fathom (ftm)", Depth.FATHOM);
            _depthDropDown.addEventListener(MenuDropdownListEvent.SELECT, waterDepthHandler);
        }
        this.addChild(_depthDropDown);
    }

    private function waterDepthHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.depth = event.data.data;
        setWaterDepthUnit();
    }

    private function setWaterDepthUnit():void {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                _depthDropDown.label = "meter (m)";
                break;
            case Depth.FEET:
                _depthDropDown.label = "foot (ft)";
                break;
            case Depth.FATHOM:
                _depthDropDown.label = "fathom (ftm)";
                break;
            default:
                UnitHandler.instance.depth = Distance.METER;
                _depthDropDown.label = "meter (m)";
                break;
        }
    }

    private function addBoatSpeed():void {
        if (_speedLabel == null) {
            _speedLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _speedLabel.x = PADDING;
            _speedLabel.y = 205;
            _speedLabel.text = "Boat speed";
        }
        this.addChild(_speedLabel);

        if (_speedDropDown == null) {
            _speedDropDown = new MenuDropdownList(4);
            _speedDropDown.x = (Menu.WIDTH/2) - (_speedDropDown.width/2);
            _speedDropDown.y = 225;
            _speedDropDown.addElement("knot (kn)", Speed.KTS);
            _speedDropDown.addElement("miles per hour (mph)", Speed.MPH);
            _speedDropDown.addElement("kilometers per hour (km/h)", Speed.KMH);
            _speedDropDown.addElement("meter per second (m/s)", Speed.MS);
            _speedDropDown.addEventListener(MenuDropdownListEvent.SELECT, boatSpeedHandler);
        }
        this.addChild(_speedDropDown);
    }

    private function boatSpeedHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.speed = event.data.data;
        setBoatSpeedUnit();
    }

    private function setBoatSpeedUnit():void {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                _speedDropDown.label = "knot (kn)";
                break;
            case Speed.MPH:
                _speedDropDown.label = "miles per hour (mph)";
                break;
            case Speed.KMH:
                _speedDropDown.label = "kilometers per hour (km/h)";
                break;
            case Speed.MS:
                _speedDropDown.label = "meter per second (m/s)";
                break;
            default:
                UnitHandler.instance.speed = Speed.KTS;
                _speedDropDown.label = "knot (kn)";
                break;
        }
    }

    private function addWindSpeed():void {
        if (_windLabel == null) {
            _windLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _windLabel.x = PADDING;
            _windLabel.y = 265;
            _windLabel.text = "Wind speed";
        }
        this.addChild(_windLabel);

        if (_windDropDown == null) {
            _windDropDown = new MenuDropdownList(5);
            _windDropDown.x = (Menu.WIDTH/2) - (_windDropDown.width/2);
            _windDropDown.y = 285;
            _windDropDown.addElement("knot (kn)", Speed.KTS);
            _windDropDown.addElement("miles per hour (mph)", Speed.MPH);
            _windDropDown.addElement("kilometers per hour (km/h)", Speed.KMH);
            _windDropDown.addElement("meter per second (m/s)", Speed.MS);
            _windDropDown.addElement("beaufort (bft)", WindSpeed.BF);
            _windDropDown.addEventListener(MenuDropdownListEvent.SELECT, windSpeedHandler);
        }
        this.addChild(_windDropDown);
    }

    private function windSpeedHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.windSpeed = event.data.data;
        setWindSpeedUnit();
    }

    private function setWindSpeedUnit():void {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                _windDropDown.label = "knot (kn)";
                break;
            case WindSpeed.MPH:
                _windDropDown.label = "miles per hour (mph)";
                break;
            case WindSpeed.KMH:
                _windDropDown.label = "kilometers per hour (km/h)";
                break;
            case WindSpeed.MS:
                _windDropDown.label = "meter per second (m/s)";
                break;
            case WindSpeed.BF:
                _windDropDown.label = "Beaufort (bft)";
                break;
            default:
                UnitHandler.instance.windSpeed = WindSpeed.KTS;
                _windDropDown.label = "knot (kn)";
                break;
        }
    }

    private function addTemperature():void {
        if (_temperatureLabel == null) {
            _temperatureLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _temperatureLabel.x = PADDING;
            _temperatureLabel.y = 325;
            _temperatureLabel.text = "Temperature";
        }
        this.addChild(_temperatureLabel);

        if (_temperatureDropDown == null) {
            _temperatureDropDown = new MenuDropdownList(2);
            _temperatureDropDown.x = (Menu.WIDTH/2) - (_temperatureDropDown.width/2);
            _temperatureDropDown.y = 345;
            _temperatureDropDown.addElement("Celsius (°C)", Temperature.CELSIUS);
            _temperatureDropDown.addElement("Fahrenheit (°F)", Temperature.FAHRENHEIT);
            _temperatureDropDown.addEventListener(MenuDropdownListEvent.SELECT, temperatureHandler);
        }
        this.addChild(_temperatureDropDown);
    }

    private function temperatureHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.temperature = event.data.data;
        setTemperatureUnit();
    }

    private function setTemperatureUnit():void {
        switch (UnitHandler.instance.temperature) {
            case Temperature.CELSIUS:
                _temperatureDropDown.label = "Celsius (°C)";
                break;
            case Temperature.FAHRENHEIT:
                _temperatureDropDown.label = "Fahrenheit (°F)";
                break;
            default:
                UnitHandler.instance.temperature = Temperature.CELSIUS;
                _temperatureDropDown.label = "Celsius (°C)";
                break;
        }
    }

    private function addDirection():void {
        if (_directionLabel == null) {
            _directionLabel = FontFactory.getWhiteLeftFont(WIDTH,20, 14);
            _directionLabel.x = PADDING;
            _directionLabel.y = 385;
            _directionLabel.text = "North reference";
        }
        this.addChild(_directionLabel);

        if (_directionDropDown == null) {
            _directionDropDown = new MenuDropdownList(2);
            _directionDropDown.x = (Menu.WIDTH/2) - (_directionDropDown.width/2);
            _directionDropDown.y = 405;
            _directionDropDown.addElement("True", Direction.TRUE);
            _directionDropDown.addElement("Magnetic", Direction.MAGNETIC);
            _directionDropDown.addEventListener(MenuDropdownListEvent.SELECT, directionHandler);
        }
        this.addChild(_directionDropDown);

//        if (_directionInfoLabel == null) {
//            _directionInfoLabel = FontFactory.getCustomFont({ color: 0xff0000, size: 12, bold: true });
//            _directionInfoLabel.x = 40;
//            _directionInfoLabel.y = 230;
//            _directionInfoLabel.height = 20;
//            _directionInfoLabel.text = "";
//        }
//        _directionInfoLabel.visible = (UnitHandler.instance.direction == Direction.FORCED_MAGNETIC);
//        this.addChild(_directionInfoLabel);
    }

    private function directionHandler(event:MenuDropdownListEvent):void {
        UnitHandler.instance.direction = event.data.data;
        Direction.checkVariation();
        setDirectionUnit();
    }

    private function setDirectionUnit():void {
        switch (UnitHandler.instance.direction) {
            case Direction.TRUE:
                _directionDropDown.label = "True";
                _directionDropDown.color = 0xffffff;
//                _directionInfoLabel.visible = false;
                break;
            case Direction.MAGNETIC:
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xffffff;
//                _directionInfoLabel.visible = false;
                break;
            case Direction.FORCED_MAGNETIC:
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xff0000;
//                _directionInfoLabel.visible = true;
                break;
            default:
                UnitHandler.instance.direction = Direction.MAGNETIC;
                _directionDropDown.label = "Magnetic";
                _directionDropDown.color = 0xffffff;
//                _directionInfoLabel.visible = false;
                break;
        }
    }

}
}
