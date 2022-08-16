/**
 * Created by seamantec on 04/09/14.
 */
package components.lists {

import com.common.AppProperties;

import flash.geom.Point;

import starling.display.DisplayObject;
import starling.display.Quad;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class DynamicListItem extends ListItem {

    protected var _content:Sprite;
    protected var _button:ListButton;
    protected var _touchPoint:Point;
    protected var _list:List;

    protected var _distanceX:Number = 0;
    protected var _distanceY:Number = 0;

    public function DynamicListItem(width:Number, height:Number, list:List, color:uint = uint.MAX_VALUE, alpha:Number = 1) {
        super(width, height, color, alpha);

        _list = list;

        _content = new Sprite();
        _content.y = height;
        _content.visible = false;
        this.addChild(_content);

        _touchPoint = new Point();
        initButton();

        this.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public function addContentChild(sprite:Sprite):void {
        _content.addChild(sprite);
        if (!this.contains(_button) && _content.height > 0) {
            this.addChild(_button);
        }
    }

    protected function initButton():void {
        _button = new ListButton();
        _button.x = this.width - 30;
        _button.y = (this.height-_button.height)/2;

        _button.addEventListener(TouchEvent.TOUCH, onButtonTouch);
    }

    private function onTouch(event:TouchEvent):void {
//        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
//        var moved:Touch = event.getTouch(this, TouchPhase.MOVED);
//        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
//        var p:Point;
//        if (began) {
//            _touchPoint = new Point(began.globalX, began.globalY);
//        } else if(moved) {
//            p = new Point(moved.globalX, moved.globalY);
//            _distanceX += Math.abs(_touchPoint.x-p.x);
//            _distanceY += Math.abs(_touchPoint.y-p.y);
//        } else if (ended) {
//            p = new Point(ended.globalX, ended.globalY);
//            _distanceX += Math.abs(_touchPoint.x-p.x);
//            _distanceY += Math.abs(_touchPoint.y-p.y);
//            var target:DisplayObject = e.target as DisplayObject;
//            if (_distanceX<=(_height/2) && _distanceY<=(_height/2) && (isLabel(target) || !isContent(target))) {
//                changeState();
//            }
//            _distanceX = 0;
//            _distanceY = 0;
//        }
        if(touchIsEnd(event) && (isLabel(event.target as DisplayObject) || !isContent(event.target as DisplayObject))) {
            if(EdoMobile.stageContainer.active.list.onFLing) {
                EdoMobile.stageContainer.active.list.onFLing = false;
            } else {
                changeState();
            }
        }
    }

    private function onButtonTouch(e:TouchEvent):void {
        var ended:Touch = e.getTouch(this, TouchPhase.ENDED);
        if (ended) {
            var p:Point = new Point(ended.globalX, ended.globalY);
            if (Math.abs(_touchPoint.x-p.x)<=(_button.height/2) && Math.abs(_touchPoint.y-p.y)<=(_button.height/2)) {
                if(EdoMobile.stageContainer.active.list.onFLing) {
                    EdoMobile.stageContainer.active.list.onFLing = false;
                } else {
                    changeState();
                }
            }
        }
    }

    private function isContent(target:DisplayObject):Boolean {
        while(target!=this) {
            if(target==_content || target==_button) {
                return true;
            }
            target = target.parent;
        }
        return false;
    }

    private function isLabel(target:DisplayObject):Boolean {
        var l:Boolean = false;
        var length:int = _labels.length;
        for(var i:int=0; i<length; i++) {
            l = l || (target==_labels[i]);
        }
        return l;
    }

//    protected function openContent():void {
//        _button.isOpen = !_button.isOpen;
//        stateChange();
//        _list.filter(_list.getFilters());
//        _list.scrollBox(0);
//    }

    public function changeState():void {
        if(_content.visible) {
            close();
        } else {
            open();
        }
        _list.redraw();
        _list.scrollBox(0);
    }

    public function open():void {
        if(!_content.visible) {
            _height += _content.height;
        }
        _content.visible = true;
        _button.open = true;
    }

    public function close():void {
        if(_content.visible) {
            _height -= _content.height;
        }
        _content.visible = false;
        _button.open = false;
    }

    public function set content(content:Sprite):void {
        _content = content;
    }

    public function get content():Sprite {
        return _content;
    }
}
}
