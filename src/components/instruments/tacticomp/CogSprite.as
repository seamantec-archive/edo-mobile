/**
 * Created by pepusz on 2014.09.23..
 */
package components.instruments.tacticomp {
import starling.display.Image;
import starling.display.Sprite;

public class CogSprite extends Sprite {
    private var _cog2:Image;
    public function CogSprite() {
        super();
    }


    public function get cog2():Image {
        return _cog2;
    }

    public function set cog2(value:Image):void {
        _cog2 = value;
        this.addChild(_cog2)
    }
}
}
