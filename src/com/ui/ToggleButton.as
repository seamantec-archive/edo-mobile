/**
 * Created by seamantec on 15/10/14.
 */
package com.ui {
import com.common.AppProperties;
import com.utils.Assets;

import starling.display.Button;
import starling.textures.Texture;

public class ToggleButton extends Button {

    private var _defaultSkin:Texture;
    private var _selectedSkin:Texture;
    private var _selected:Boolean;

    public function ToggleButton(label:String) {
        _defaultSkin = Assets.assets.getTexture("alarm_tolerance_off");
        _selectedSkin = Assets.assets.getTexture("alarm_tolerance_on");
        super(_defaultSkin, label, _defaultSkin);
        this.scaleX = AppProperties.screenScaleRatio;
        this.scaleY = AppProperties.screenScaleRatio;
        this.fontSize = 10*this.scaleY;
        this.fontColor = 0xffffff;
        this.fontBold = true;
    }

//    public override function get width():Number {
//        return _defaultSkin.width*this.scaleX;
//    }

    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(value:Boolean):void {
        _selected = value;
        if(_selected) {
            this.upState = _selectedSkin;
            this.downState = _selectedSkin;
        } else {
            this.upState = _defaultSkin;
            this.downState = _defaultSkin;
        }
    }
}
}
