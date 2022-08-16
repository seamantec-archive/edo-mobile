/**
 * Created by seamantec on 10/09/14.
 */
package components {
import com.sailing.socket.SocketDispatcher;
import com.ui.StageBtn;
import com.utils.FontFactory;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class SimulationSettings extends Sprite {

    private static var _label:TextField;
    private static var _button:StageBtn;

    public function SimulationSettings() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    public static function set enable(value:Boolean):void {
        _button.enabled = value;
        if(!value) {
            _button.text = "Start";
        }
    }

    private function addedToStageHandler(event:Event):void {
        if (_label == null) {
            _label = FontFactory.getWhiteLeftFont(EdoMobile.menu.width, 20, 14);
            _label.hAlign = HAlign.CENTER;
            _label.vAlign = VAlign.CENTER;
            _label.text = "Simulation";
            _label.x = 0;
            _label.y = 0;
            this.addChild(_label);
        }
        if(_button==null) {
            _button = new StageBtn("Start");
            _button.x = 0;
            _button.y = 22;
            _button.addEventListener(TouchEvent.TOUCH, onTouch);
            this.addChild(_button);
        }
    }

    private function onTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stage);
        if (touch && _button.enabled) {
            if (touch.phase == TouchPhase.ENDED) {
                if(SocketDispatcher.instance.isDemoConnected) {
                    SocketDispatcher.instance.stopDemoConnect();
                    _button.text = "Start";
                } else {
                    SocketDispatcher.instance.connectDemo();
                    _button.text = "Stop";
                }
            }
        }
    }
}
}
