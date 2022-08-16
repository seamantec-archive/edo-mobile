/**
 * Created by seamantec on 12/03/15.
 */
package com.ui {
import com.utils.Assets;

import flash.geom.Point;

import starling.display.Button;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

public class RestoreBtn extends Button {

    private var _touchPoint:Point;

    public function RestoreBtn() {
        var upState:Texture = Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("rest_purchased_up");
        var downState:Texture = Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("rest_purchased_down");
        super(upState, "", downState);
    }

    public function touchIsEnd(event:TouchEvent):Touch {
        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
        if (event.touches.length > 1) {
            return null;
        }
        if (began) {
            _touchPoint = new Point(began.globalX, began.globalY);
        } else if (ended && Math.abs(_touchPoint.x - ended.globalX) < EdoMobile.FINGER_SIZE && Math.abs(_touchPoint.y - ended.globalY) < EdoMobile.FINGER_SIZE) {
            return ended;
        }
        return null;
    }
}
}
