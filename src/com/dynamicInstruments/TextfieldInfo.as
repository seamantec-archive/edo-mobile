/**
 * Created by pepusz on 2014.09.23..
 */
package com.dynamicInstruments {
public class TextfieldInfo {
    public var name:String;
    public var fontFace:String;
    public var defaultText:String;
    public var fontSize:Number;
    public var x:Number;
    public var y:Number;
    public var width:Number;
    public var height:Number;
    public var color:Number;
    public var zIndex:int;

    public function TextfieldInfo(name:String, fontFace:String, defaultText:String, fontSize:Number, x:Number, y:Number, width:Number, height:Number, color:Number, zIndex:int) {
        this.name = name;
        this.fontFace = fontFace;
        this.defaultText = defaultText;
        this.fontSize = fontSize;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.color = color;
        this.zIndex = zIndex;
    }
}
}
