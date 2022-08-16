/**
 * Created by seamantec on 26/11/14.
 */
package components {
import com.ui.CheckBox;
import com.utils.EdoLocalStore;
import com.utils.FontFactory;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.utils.ByteArray;

import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class ScreenSettings extends Sprite {

    private static var _label:TextField;
    private static var _checkbox:CheckBox;

    public function ScreenSettings() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    private function addedToStageHandler(event:Event):void {
        if (_checkbox == null) {
            _checkbox = new CheckBox();
            _checkbox.isSelected = NativeApplication.nativeApplication.systemIdleMode == SystemIdleMode.KEEP_AWAKE;
            _checkbox.addEventListener(Event.CHANGE, onChange);
            this.addChild(_checkbox);
        }
        if (_label == null) {
            _label = FontFactory.getWhiteLeftFont(EdoMobile.menu.width - _checkbox.width - 10, _checkbox.height, 16);
            _label.text = "Keep screen always on";
            _label.x = _checkbox.width + 10;
            _label.y = 0;
            this.addChild(_label);
        }
    }

    private function onChange(event:Event):void {
        NativeApplication.nativeApplication.systemIdleMode = (NativeApplication.nativeApplication.systemIdleMode == SystemIdleMode.KEEP_AWAKE) ? SystemIdleMode.NORMAL : SystemIdleMode.KEEP_AWAKE;
        save();
    }

    public static function save():void {
        var data:ByteArray = new ByteArray();
        data.writeBoolean(NativeApplication.nativeApplication.systemIdleMode == SystemIdleMode.KEEP_AWAKE);
        EdoLocalStore.setItem('alwaysOn', data);
    }

    public static function load():void {
        var data:ByteArray = EdoLocalStore.getItem("alwaysOn");
        NativeApplication.nativeApplication.systemIdleMode = (data != null && data.readBoolean()) ? SystemIdleMode.NORMAL : SystemIdleMode.KEEP_AWAKE;
    }
}
}
