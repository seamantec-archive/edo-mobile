﻿package com.sailing.datas {import com.sailing.units.Direction;import com.sailing.units.Distance;import com.sailing.units.SmallDistance;import flash.utils.getTimer;public class Bwc extends BaseSailData {    public var waypointId:String = "";    public var waypointDistance:SmallDistance = new SmallDistance();    public var waypointBearing:Direction = new Direction();    public var waypointLat:Number = 0;    public var waypointLon:Number = 0;    public var timeOfFixUtcMs:Number = 0;    public function Bwc() {        super();        _paramsDisplayName["waypointId"] = { displayName: "Waypoint ID", order: 5 };        _paramsDisplayName["waypointDistance"] = { displayName: "Distance", order: 4 };        _paramsDisplayName["waypointBearing"] = { displayName: "Bearing", order: 3 };        _paramsDisplayName["waypointLat"] = { displayName: "Waypoint latitude", order: 1 };        _paramsDisplayName["waypointLon"] = { displayName: "Waypoint longitude", order: 2 };        _paramsDisplayName["timeOfFixUtcMs"] = { displayName: "UTC in ms", order: 0 };    }    public override function get displayName():String {        return "Bearing & Distance to Waypoint (BWC)";    }    public override function isValid():Boolean {//        if (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < VALID_THRESHOLD && waypointId != null && waypointId != "") {//            isInValid = true;//            return true;//        }//        isInValid = false;//        return false;        return (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < VALID_THRESHOLD && waypointId != null && waypointId != "");    }    public override function isPreValid():Boolean {//        if (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < PRE_VALID_THRESHOLD && waypointId != null && waypointId != "") {//            isInPreValid = true;//            return true;//        }//        isInPreValid = false;//        return false;        return (_lastTimestamp > 0 && (getTimer() - _lastTimestamp) < PRE_VALID_THRESHOLD && waypointId != null && waypointId != "");    }    public override function set lastTimestamp(value:Number):void {        _lastTimestamp = value;        if(waypointId!="") {            isInPreValid = true;            isInValid = true;        }    }}}