/**
 * Created by seamantec on 03/07/14.
 */
package com.notification {

import com.ui.StageBtn;
import com.utils.Assets;

import starling.events.Touch;

import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class WarningWindow extends NotificationWindow {

    public function WarningWindow(type:int, msg:String, priority:int, options:Object) {
        super(type, msg, priority, (options!=null && options.hasOwnProperty("title")) ? options["title"] : "Warning", Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("exclamation_yellow"));

        var okBtn:StageBtn = new StageBtn("OK");
        okBtn.addEventListener(TouchEvent.TOUCH, closeBtnHandler);
        this.addButton(okBtn);
    }

    private function closeBtnHandler(e:TouchEvent):void {
        var touch:Touch = e.getTouch(this.stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                NotificationHandler.close(this);
                this.close();
            }
        }
    }
}
}
