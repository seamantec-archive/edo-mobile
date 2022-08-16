/**
 * Created by pepusz on 2014.09.03..
 */
package com.ui {
import com.utils.Assets;

import starling.display.Button;
import starling.display.Sprite;

public class MenuBtn extends Sprite {
    private var disconnectedMode:Button = new Button(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("menu_btn01"), "", Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("menu_btn02"))
    private var connectedMode:Button = new Button(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("menu_connected_btn01"), "", Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("menu_connected_btn02"))

    public function MenuBtn() {
        connectedMode.visible = false
        this.addChild(disconnectedMode);
        this.addChild(connectedMode);
    }

    public function turnConnected():void {
        connectedMode.visible = true;
        disconnectedMode.visible = false;
        trace("connected mode in menu")
    }

    public function turnDisconnected():void {
        connectedMode.visible = false;
        disconnectedMode.visible = true;
        trace("disconnected mode in menu")
    }
}
}
