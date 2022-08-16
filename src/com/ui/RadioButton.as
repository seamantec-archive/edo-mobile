/**
 * Created by seamantec on 23/02/15.
 */
package com.ui {
import com.utils.Assets;
import com.utils.FontFactory;

import components.Menu;

import flash.geom.Point;

import starling.display.Image;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

public class RadioButton extends Sprite {

    private var _index:int;
    private var _defaultImage:Image;
    private var _selectedImage:Image;
    private var _selected:Boolean;


    public function RadioButton(index:int, text:String, fontSize:int) {
        _index = index;

        _defaultImage = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("Radio_btn_off"));
        _selectedImage = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("Radio_btn_on"));
        _selectedImage.visible = false;

        this.addChild(_defaultImage);
        this.addChild(_selectedImage);

        var label:TextField = FontFactory.getWhiteLeftFont((Menu.WIDTH*0.45) - _defaultImage.width - 5,_defaultImage.height);
        label.autoScale = true;
        label.fontSize = fontSize;
        label.text = text;
        label.x = _defaultImage.width + 5;
        this.addChild(label);
    }

    public function get index():int {
        return _index;
    }

    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(value:Boolean):void {
        _selected = value;
        if(_selected) {
            _defaultImage.visible = false;
            _selectedImage.visible = true;
        } else {
            _defaultImage.visible = true;
            _selectedImage.visible = false;
        }
    }
}
}
