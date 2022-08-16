/**
 * Created by pepusz on 2014.09.23..
 */
package components.instruments.tacticomp {
import starling.display.Image;
import starling.display.Sprite;

public class LlnSprite extends Sprite {
    private var _LLN1:Image;
    private var _LLN2:Image;
    public function LlnSprite() {
        super();
    }

    public function set LLN1(value:Image):void {
        _LLN1 = value;
        this.addChild(_LLN1)
    }

    public function set LLN2(value:Image):void {
        _LLN2 = value;
        this.addChild(_LLN2)
    }

    public function get LLN1():Image {
        return _LLN1;
    }

    public function get LLN2():Image {
        return _LLN2;
    }
}
}
