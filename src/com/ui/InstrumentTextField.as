/**
 * Created by seamantec on 05/11/14.
 */
package com.ui {
import flash.text.TextFormat;

import starling.core.Starling;

import starling.text.TextField;

public class InstrumentTextField extends TextField {

    public function InstrumentTextField(width:int, height:int, text:String, fontName:String="Amble Bold", fontSize:Number=12, color:uint=0x0, bold:Boolean=true) {
        super(width,height, text, fontName, fontSize, color, bold);
    }

    protected override function formatText(textField:flash.text.TextField, textFormat:TextFormat):void {
        textField.setTextFormat(textFormat);
    }
}
}
