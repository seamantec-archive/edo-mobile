/**
 * Created by seamantec on 15/10/14.
 */
package com.ui {
import starling.display.Sprite;

public class ToggleButtonBar extends Sprite{

    private var _buttons:Vector.<ToggleButton>;
    private var _selectedIndex:int;

    public function ToggleButtonBar(x:Number, y:Number, labels:Array) {
        this.x = x;
        this.y = y;

        _buttons = new Vector.<ToggleButton>();

        var button:ToggleButton;
        var length:int = labels.length;
        for(var i:int=0; i<length; i++) {
            button = new ToggleButton(labels[i]);
            button.x = i*(button.width + 5);
            button.y = 0;
            _buttons.push(button);
            this.addChild(button);
        }
    }

    public function get selectedIndex():int {
        return _selectedIndex;
    }

    public function set selectedIndex(value:int):void {
        var length:int = _buttons.length;
        for(var i:int=0; i<length; i++) {
            if(i==value) {
                _buttons[i].selected = true;
                _selectedIndex = i;
            } else {
                _buttons[i].selected = false;
            }
        }
    }

    public override function addEventListener(type:String, listener:Function):void {
        var length:int = _buttons.length;
        for(var i:int=0; i<length; i++) {
            _buttons[i].addEventListener(type, listener);
        }
    }

    public function getButtonIndex(button:ToggleButton):int {
        var length:int = _buttons.length;
        for(var i:int=0; i<length; i++) {
            if(button==_buttons[i]) {
                return i;
            }
        }
        return -1;
    }
}
}
