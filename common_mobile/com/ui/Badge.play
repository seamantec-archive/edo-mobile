/**
 * Created by seamantec on 09/09/14.
 */
package com.ui {
import com.utils.Assets;
import com.utils.FontFactory;

import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;
import starling.textures.Texture;

public class Badge extends Sprite {

    protected var _label:TextField;

    public function Badge(x:Number, y:Number, texture:Texture = null) {
        this.x = x;
        this.y = y;
        this.addChild(new Image((texture==null) ? Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("badge_bg") : texture));

        _label = FontFactory.getWhiteCenterFont(this.width,this.height, 14);
        this.addChild(_label);
    }

    public function set text(text:String):void {
        _label.text = text;
    }

    public function get text():String {
        return _label.text;
    }

    public function set textColor(color:uint):void {
        _label.color = color;
    }
}
}
