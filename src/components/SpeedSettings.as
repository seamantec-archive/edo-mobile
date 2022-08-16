/**
 * Created by seamantec on 23/02/15.
 */
package components {
import com.common.SpeedToUse;
import com.ui.RadioButtonBar;
import com.utils.FontFactory;



import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class SpeedSettings extends Sprite {

    private static var _speedLabel:TextField;
    private static var _speedType:RadioButtonBar;


    public function SpeedSettings() {
        if(_speedLabel==null) {
            _speedLabel = FontFactory.getWhiteCenterFont(UnitSettings.WIDTH,72, 16);
            _speedLabel.text = "Vessel speed source\nfor\nperformance calculations";
            _speedLabel.x = UnitSettings.PADDING;
        }
        this.addChild(_speedLabel);

        if(_speedType==null) {
            _speedType = new RadioButtonBar(0,0, ["SOG", "STW"]);
            _speedType.x = UnitSettings.PADDING;
            _speedType.y = 75;
        }
        _speedType.selected = SpeedToUse.instance.selected;
        _speedType.addEventListener(Event.CHANGE, speedType_changeHandler);
        this.addChild(_speedType);
    }



    private function speedType_changeHandler(event:Event):void {
        SpeedToUse.instance.setSelectedAndContainer(_speedType.selected, null);

    }
}
}
