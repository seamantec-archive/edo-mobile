/**
 * Created by seamantec on 19/12/14.
 */
package components {
import com.common.AppProperties;
import com.utils.Assets;
import com.utils.FontFactory;

import flash.geom.Point;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import starling.display.Image;

import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.VAlign;

public class AboutSettings extends Sprite {

    private var _touchPoint:Point;

    public function AboutSettings() {
        var img:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("about"));
        this.addChild(img);
        this.x = (Menu.WIDTH/2) - (img.width/2);

        var version:TextField = FontFactory.getWhiteCenterFont(img.width,120, 14, VAlign.TOP);
        version.text = "version " + AppProperties.getVersionNumber();
        version.y = 67;
        this.addChild(version);

        this.addEventListener(TouchEvent.TOUCH, onAbout);
    }

    private function onAbout(event:TouchEvent):void {
        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
        if (began) {
            _touchPoint = new Point(began.globalX, began.globalY);
        } else if(ended && Math.abs(_touchPoint.x-ended.globalX)<EdoMobile.FINGER_SIZE && Math.abs(_touchPoint.y-ended.globalY)<EdoMobile.FINGER_SIZE) {
            navigateToURL(new URLRequest("http://www.seamantec.com"));
        }
    }
}
}
