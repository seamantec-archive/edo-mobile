/**
 * Created by seamantec on 11/11/14.
 */
package components.instruments.digital {

import com.dynamicInstruments.DynamicSprite;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.utils.Assets;

import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class DigitalB extends BaseDigital {

    public function DigitalB() {
        super(Assets.getInstrument("digital_b"));
    }

    protected override function buildComponents():void {
        var digi:Texture = Assets.getAtlas("digital_common");

        background = _instrumentAtlas.getComponentAsDynamicSprite(digi, "digital.instance2");

        _instrumentAtlas.getComponentAsImageWithParent(digi, "digital.instance14", background);

        _instrumentAtlas.getComponentAsImageWithParent(digi, "digital.selector", background);

        digital = new DynamicSprite();
        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.label1", digital, VAlign.CENTER, HAlign.LEFT);

        digital["label1"].height = int(background["selector"].height);

        _instrumentAtlas.getTextFieldComponentWithParent(digi, "digital.digimin1", digital, background);
        _instrumentAtlas.getTextFieldComponentWithParent(digi, "digital.digimax1", digital, background);
        _instrumentAtlas.getTextFieldComponentWithParent(digi, "digital.digi1", digital, background);

        _instrumentAtlas.getComponentAsImageWithParent(digi, "digital.degree", digital);
        _instrumentAtlas.getComponentAsImageWithParent(digi, "digital.degree_s", digital);
        _instrumentAtlas.getComponentAsImageWithParent(digi, "digital.degree_p", digital);

        _instrumentAtlas.getComponentAsTextFieldWithParent("digital.unit", digital);

        backgroundBatch = new InstrumentQuadBatcher(background.width,background.height, "digitalBackgroundB");
        backgroundBatch.addDisplayObject(background);
        this.addChild(backgroundBatch.quadBatch);

        this.addChild(digital);
    }
}
}
