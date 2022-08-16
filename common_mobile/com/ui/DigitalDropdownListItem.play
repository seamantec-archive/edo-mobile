/**
 * Created by seamantec on 11/11/14.
 */
package com.ui {
import com.common.AppProperties;
import com.sailing.units.Unit;
import com.utils.FontFactory;

import components.lists.ListItem;

public class DigitalDropdownListItem {

    private var _label:String;
    private var _key:String;
    private var _data:String;
    private var _value:Unit;
    private var _hasMinMax:Boolean;

    public function DigitalDropdownListItem(key:String, data:String, label:String, hasMinMax:Boolean = true) {
        _label = label;
        _key = key;
        _data = data;
        _value = new Unit();
        _hasMinMax = hasMinMax;
    }

    public function get label():String {
        return _label;
    }

    public function get key():String {
        return _key;
    }

    public function get data():String {
        return _data;
    }

    public function get value():Unit {
        return _value;
    }

    public function set value(value:Unit):void {
        _value = value;
    }

    public function get hasMinMax():Boolean {
        return _hasMinMax;
    }
}
}
