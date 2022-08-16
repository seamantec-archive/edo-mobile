/**
 * Created by seamantec on 04/09/14.
 */
package components.lists {
import com.common.AppProperties;
import com.utils.Assets;

import starling.display.Image;
import starling.display.Sprite;

public class ListButtonLg extends Sprite {



    private var _close:Image;
    private var _open:Image;

    public function ListButtonLg() {
        _close = new Image(Assets.assets.getTexture("closeState_lg"));
        this.addChild(_close);

        _open = new Image(Assets.assets.getTexture("openState_lg"));
        this.addChild(_open);

        _open.visible = false;
        resetStates();
    }

    public function get open():Boolean {
        return _open.visible;
    }

    public function set open(value:Boolean):void {
        _open.visible = value;
        resetStates();
    }

    private function resetStates():void {
        if(_open.visible) {
            _close.visible = false;
        } else {
            _close.visible = true;
        }
    }
}
}
