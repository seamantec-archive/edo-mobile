/**
 * Created by seamantec on 02/03/15.
 */
package components {
import com.common.WindCorrection;
import com.ui.Slider;
import com.utils.FontFactory;

import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class WindCorrectionSetting extends Sprite {

    public static const SLIDER_WIDTH:Number = Menu.WIDTH*0.8;

    private static var _windLabel:TextField;
    private static var _windSlider:Slider;

    public function WindCorrectionSetting() {
        addWind();
    }

    private function addWind():void {
        if(_windLabel==null) {
            _windLabel = FontFactory.getWhiteCenterFont(UnitSettings.WIDTH,24, 16);
            _windLabel.text = "True wind angle correction";
            _windLabel.x = UnitSettings.PADDING;
            _windLabel.y = 0;
        }
        this.addChild(_windLabel);

        if(_windSlider==null) {
            _windSlider = new Slider(-45, 45, 1, SLIDER_WIDTH, Slider._100, 0xeeeeee);
            _windSlider.x =  (Menu.WIDTH/2) - (SLIDER_WIDTH/2);
            _windSlider.y = 50;
            _windSlider.addEventListener("actualValueChanged", onActualValueChange);
        }
        _windSlider.actualValue = WindCorrection.instance.windCorrection;
        this.addChild(_windSlider);
    }

    private function onActualValueChange(event:Event):void {
        WindCorrection.instance.windCorrection = (event.currentTarget as Slider).actualValue;
    }
}
}
