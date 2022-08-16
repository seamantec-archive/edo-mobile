/**
 * Created by seamantec on 16/07/14.
 */
package com.notification {

import com.common.AppProperties;
import com.ui.StageBtn;
import com.utils.FontFactory;
import com.utils.QuadBatcher;

import components.EdoStage;

import components.EdoStage;
import components.StageContainer;

import components.TopBar;

import starling.display.Image;

import starling.display.Quad;
import starling.display.QuadBatch;

import starling.display.Sprite;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.VAlign;

public class NotificationWindow extends Sprite {

    private var _type:int;
    private var _priority:int;

    private var _w:Number;
    private var _h:Number;

    private var _buttons:Vector.<StageBtn>;
    private var _bottom:Sprite;

    private var _quadBatcher:QuadBatcher;

    public function NotificationWindow(type:int, msg:String, priority:int, title:String, icon:Texture) {
        _type = type;
        _priority = priority;

        _w = AppProperties.screenWidth - 32;
        _h = AppProperties.screenHeight*0.33;

        drawHeader(title);
        drawContent(msg, icon);
    }

    private function drawHeader(title:String):void {
        var header:Quad = new Quad(_w, TopBar.HEIGHT, 0x7b7b7b);
        header.alpha = 1;
        this.addChild(header);

        var titleField:TextField = FontFactory.getWhiteCenterFont(_w, TopBar.HEIGHT);
        titleField.text = title;
        this.addChild(titleField);
    }

    private function drawContent(msg:String, icon:Texture):void {
        var content:Sprite = new Sprite();
        content.y = TopBar.HEIGHT;

        content.addChild(new Quad(_w, _h - (TopBar.HEIGHT + EdoStage.BOTTOM_HEIGHT), 0xffffff));

        var img:Image = new Image(icon);
        img.x = (_w/8) - (img.width/2);
        img.y = (content.height/2) - (img.height/2);
        content.addChild(img);

        var textField:TextField = FontFactory.getBlackLeftFont(((_w/4)*3) - 4, content.height - 8, content.height/4, VAlign.TOP);
        textField.autoScale = true;
        textField.x = _w/4;
        textField.y = 4;
        textField.text = msg;
        content.addChild(textField);

        this.addChild(content);
    }

    public function getType():int {
        return _type;
    }

    public function getPriority():int {
        return _priority;
    }

    public function close():void {
        this.removeFromParent(true);
    }

    public function get bottom():Sprite {
        return _bottom;
    }

    public function addButton(button:StageBtn):void {
        if(_buttons==null) {
            _buttons = new Vector.<StageBtn>();
            _bottom = new Sprite();
            _bottom.y = _h - EdoStage.BOTTOM_HEIGHT;
            _bottom.addChild(new Quad(_w, EdoStage.BOTTOM_HEIGHT, 0x7b7b7b));
            this.addChild(_bottom);
        }

        button.y = (_bottom.height/2) - (button.height/2);
        _buttons.push(button);
        _bottom.addChild(button);

        var length:int = _buttons.length;
        var item:StageBtn;
        var w:Number = _w/3;
        for(var i:int=0; i<length; i++) {
            item = _buttons[i];
            item.x = ((3-length)*w) + (i*w) + (w/2) - (item.width/2);
        }
    }
}
}
