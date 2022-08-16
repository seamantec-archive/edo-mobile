package com.dynamicInstruments {
import flash.geom.Point;
import flash.geom.Rectangle;

public class TextureInfo {
    public var region:Rectangle;
    public var frame:Rectangle;
    public var rotated:Boolean;
    public var pivot:Point;
    public var parent:String;
    public var originLocation:Point;
    public var zIndex:int;
    public var visible:Boolean;

    public function TextureInfo(region:Rectangle, frame:Rectangle, rotated:Boolean, pivot:Point, parent:String, originLocation:Point, zIndex:int, visible:Boolean) {
        this.region = region;
        this.frame = frame;
        this.rotated = rotated;
        this.pivot = pivot;
        this.originLocation = originLocation;
        this.parent = parent;
        this.zIndex = zIndex;
        this.visible = visible;
    }
}
}