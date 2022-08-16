/**
 * Created by seamantec on 03/12/14.
 */
package com.ui {
import com.common.AppProperties;
import com.utils.FontFactory;

import components.lists.ListItem;

public class MenuDropdownListItem extends ListItem {

    public static const ITEM_HEIGHT:Number = EdoMobile.FINGER_SIZE/AppProperties.screenScaleRatio;

    private var _label:String;
    private var _data:Number;

    public function MenuDropdownListItem(label:String, data:Number, width:Number) {
        super(width,ITEM_HEIGHT, 0xc9c9c9, 1);

        addLabel(label, FontFactory.getBlackLeftFont(width - 3,ITEM_HEIGHT, (ITEM_HEIGHT/2) - 4), 3);
        _label = label;
        _data = data;
    }

    public function get label():String {
        return _label;
    }

    public function get data():Number {
        return _data;
    }
}
}
