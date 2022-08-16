/**
 * Created by seamantec on 13/10/14.
 */
package com.ui {
import com.utils.Assets;

import feathers.controls.Check;

import starling.display.Image;

public class CheckBox extends Check {

    public function CheckBox() {
        super();
        selectedUpSkin = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("pipa_on"));
        selectedHoverSkin = selectedUpSkin;
        defaultSkin = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("pipa_off"));
        width = selectedUpSkin.width;
        height = selectedUpSkin.height;
    }
}
}
