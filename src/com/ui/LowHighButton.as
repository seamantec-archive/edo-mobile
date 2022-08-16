/**
 * Created by seamantec on 03/12/14.
 */
package com.ui {
import com.utils.Assets;

import starling.display.Button;

public class LowHighButton extends Button {

    private var _selectedIndex:int;

    public function LowHighButton(x:Number, y:Number) {
        super(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("lh_btn"), "");

        this.x = x;
        this.y = y;
        this.fontColor = 0xffffff;
        this.fontSize = 10;
    }

    public function set selectedIndex(index:int):void {
        _selectedIndex = index;
        this.text = (_selectedIndex==0) ? "high" : "low";
    }

    public function get selectedIndex():int {
        return _selectedIndex;
    }
}
}
