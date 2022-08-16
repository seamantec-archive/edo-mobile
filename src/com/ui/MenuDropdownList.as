/**
 * Created by seamantec on 03/12/14.
 */
package com.ui {
import com.common.AppProperties;
import com.events.MenuDropdownListEvent;
import com.utils.Assets;
import com.utils.FontFactory;

import components.Menu;

import components.UnitSettings;
import components.lists.List;

import flash.geom.Point;

import flash.geom.Rectangle;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.textures.Texture;

public class MenuDropdownList extends DisplayObjectContainer {

    private var _list:List;
    private var _label:TextField;
    private var _elemCount:int;

    private var _height:Number;

    private var _touhPoint:Point;

    public function MenuDropdownList(elemCount:int) {
        var texture:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("dropdown"));
        this.addChild(texture);

        _height = texture.height;

        _elemCount = elemCount;

        _list = new List(0,0, texture.width, _elemCount*MenuDropdownListItem.ITEM_HEIGHT, 0xc9c9c9, 1);
        _list.visible = false;
        _list.addScrollBar();
        _list.y = texture.height;
        this.addChild(_list);

        this.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public function set label(label:String):void {
        if (_label == null) {
            _label = FontFactory.getWhiteCenterFont(this.width*0.9, _height - 4);
            _label.autoScale = true;
            _label.y = 2;
            this.addChild(_label);
        }

        _label.text = label;
    }

    public function set color(color:uint):void {
        if (_label != null) {
            _label.color = color;
        }
    }

    public function get list():List {
        return _list;
    }

    public function addElement(label:String, data:Number):void {
        var item:MenuDropdownListItem = new MenuDropdownListItem(label, data, AppProperties.screenWidth*0.7);
        item.addEventListener(TouchEvent.TOUCH, selectHandler);
        _list.addItem(item);
    }

    private function onTouch(event:TouchEvent):void {
        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
        if(began) {
            _touhPoint = new Point(began.globalX,began.globalY);
        } else if(ended) {
            if (Math.abs(_touhPoint.x-ended.globalX)<=(EdoMobile.FINGER_SIZE/2) && Math.abs(_touhPoint.y-ended.globalY)<=(EdoMobile.FINGER_SIZE/2) && !EdoMobile.onMove) {
                (this.parent as UnitSettings).hide(this);
                this.parent.setChildIndex(this, this.parent.numChildren-1);
                _list.visible = !_list.visible;
            }
        }
    }

    private function selectHandler(event:TouchEvent):void {
        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
        if(began) {
            _touhPoint = new Point(began.globalX,began.globalY);
        } else if(ended) {
            if (Math.abs(_touhPoint.x-ended.globalX)<=(EdoMobile.FINGER_SIZE/2) && Math.abs(_touhPoint.y-ended.globalY)<=(EdoMobile.FINGER_SIZE/2) && !EdoMobile.onMove) {
                var item:MenuDropdownListItem = event.currentTarget as MenuDropdownListItem;
                dispatchEvent(new MenuDropdownListEvent(item.data));
            }
        }
    }
}
}
