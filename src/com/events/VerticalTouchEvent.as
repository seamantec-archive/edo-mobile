/**
 * Created by seamantec on 20/10/14.
 */
package com.events {
import starling.events.Event;

public class VerticalTouchEvent extends Event {

    public static const BEGIN:String = "beginVerticalEvent";
    public static const PUSH:String = "pushVerticalEvent";
    public static const MOVE:String = "moveVerticalEvent";
    public static const END:String = "endVerticalEvent";
    public static const MENU_BEGIN:String = "menuBeginVerticalEvent";
    public static const MENU_MOVE:String = "menuMoveVerticalEvent";
    public static const MENU_END:String = "menuEndVerticalEvent";

    public function VerticalTouchEvent(type:String, data:Object = null) {
        super(type, false, data);
    }
}
}
