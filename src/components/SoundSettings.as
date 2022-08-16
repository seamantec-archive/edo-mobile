/**
 * Created by seamantec on 22/09/14.
 */
package components {

import com.ui.CheckBox;
import com.utils.FontFactory;
import com.utils.SoundHandler;

import starling.display.Sprite;

import starling.events.Event;
import starling.text.TextField;
import starling.utils.VAlign;

public class SoundSettings extends Sprite {

    private static var _label:TextField;
    private static var _checkbox:CheckBox;

    public function SoundSettings() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    private function addedToStageHandler(event:Event):void {
        if(_checkbox==null) {
            _checkbox = new CheckBox();
            _checkbox.isSelected = SoundHandler.enable;
            _checkbox.addEventListener(Event.CHANGE, onChange);
            this.addChild(_checkbox);
        }
        if (_label == null) {
            _label = FontFactory.getWhiteLeftFont(EdoMobile.menu.width - _checkbox.width - 10, _checkbox.height*2, 16, VAlign.TOP);
            _label.text = "Play sound when a new message is received";
            _label.x = _checkbox.width + 10;
            _label.y = 0;
            this.addChild(_label);
        }
    }

    private function onChange(event:Event):void {
        SoundHandler.enable = !SoundHandler.enable;
        SoundHandler.save();
    }
}
}
