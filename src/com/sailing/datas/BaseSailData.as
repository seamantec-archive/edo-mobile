/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 13:55
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.utils.ObjectUtils;

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import flash.utils.getTimer;

public class BaseSailData {
    public static const VALID_THRESHOLD:uint = 60000; //in ms
    public static const PRE_VALID_THRESHOLD:uint = 30000; //in ms
    protected var _lastTimestamp:Number = -1;
    private var _isInPreValid:Boolean = false;
    private var _isInValid:Boolean = false;
    private var _ownProperties:Array;

    protected var _paramsDisplayName:Object;
    private var _displayNames:Array;

    public function BaseSailData() {
        _paramsDisplayName = new Object();
        _ownProperties = ObjectUtils.getProperties(this);
    }

    public function get displayName():String {
        return getQualifiedClassName(this).split("::")[1].toUpperCase();
    }

    public function isValid():Boolean {
//        if (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < VALID_THRESHOLD) {
//            _isInValid = true;
//            return true;
//        }
//        _isInValid = false;
//        return false;
        return (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < VALID_THRESHOLD);
    }

    public function isPreValid():Boolean {
//        if (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < PRE_VALID_THRESHOLD) {
//            _isInPreValid = true;
//            return true;
//        }
//        _isInPreValid = false;
//        return false;
        return (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < PRE_VALID_THRESHOLD);
    }

    public function get lastTimestamp():Number {
        return _lastTimestamp;
    }

    public function set lastTimestamp(value:Number):void {
        _lastTimestamp = value;
        if (_lastTimestamp != -1) {
            _isInPreValid = true;
            _isInValid = true;
        } else {
            _isInPreValid = false;
            _isInValid = false;
        }
    }


    public function get isInPreValid():Boolean {
        return _isInPreValid;
    }

    public function get isInValid():Boolean {
        return _isInValid;
    }

    public function get ownProperties():Array {
        return _ownProperties;
    }

    public function get displayNames():Array {
        if(_displayNames==null) {
            setDisplayNames();
        }

        return _displayNames;
    }

    private function setDisplayNames():void {
        _displayNames = new Array();

        var length:int = _ownProperties.length;
        var property:String;
        var item:Object;
        for(var i:int=0; i<length; i++) {
            property = _ownProperties[i];
            if(_paramsDisplayName.hasOwnProperty(property)) {
                item = _paramsDisplayName[property];
                _displayNames.push({
                    key: property,
                    displayName: item.displayName,
                    order: (item.hasOwnProperty("order")) ? item.order : int.MAX_VALUE
                });
            }
        }

        _displayNames.sort(function(a:Object, b:Object):int {
            return (a.order<b.order) ? -1 : ((a.order>b.order) ? 1 : 0);
        });
    }

    public function set isInPreValid(value:Boolean):void {
        _isInPreValid = value;
    }

    public function set isInValid(value:Boolean):void {
        _isInValid = value;
    }
}
}
