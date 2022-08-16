/**
 * Created by seamantec on 03/12/14.
 */
package com.events {
import components.lists.List;

import starling.events.Event;

public class MenuDropdownListEvent extends Event {

    public static const SELECT:String = "selectItem";

    public function MenuDropdownListEvent(data:Number) {
        super(SELECT, false, { data: data });
    }
}
}
