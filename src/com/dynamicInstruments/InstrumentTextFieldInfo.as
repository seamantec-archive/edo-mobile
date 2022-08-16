/**
 * Created by seamantec on 30/09/14.
 */
package com.dynamicInstruments {
import flash.geom.Point;
import flash.geom.Rectangle;

public class InstrumentTextFieldInfo {

    public var font:String;
    public var region:Rectangle;
    public var pivot:Point;
    public var size:Number;
    public var bold:Boolean;
    public var italic:Boolean;
    public var color:uint;
    public var defaultText:String;

    public function InstrumentTextFieldInfo(font:String, region:Rectangle, pivot:Point, size:Number, bold:Boolean, italic:Boolean, color:uint, defaultText:String) {
        this.font = font;
        this.region = region;
        this.pivot = pivot;
        this.size = size;
        this.bold = bold;
        this.italic = italic;
        this.color = color;
        this.defaultText = defaultText;
    }
}
}
