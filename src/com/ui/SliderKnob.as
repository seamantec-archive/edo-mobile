/**
 * Created by seamantec on 02/03/15.
 */
package com.ui {
import com.utils.Assets;

import starling.display.Image;

public class SliderKnob extends Image {

    public function SliderKnob() {
        super(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("slider_knob"));
    }
}
}
