/**
 * Created by seamantec on 04/09/14.
 */
package components.stages.messages {

import com.common.AppProperties;
import com.utils.Assets;
import com.utils.FontFactory;

import components.lists.DynamicListItem;
import components.lists.List;

import flash.geom.Point;

import starling.display.Image;
import starling.textures.Texture;

public class MessagesListItem extends DynamicListItem {

    public static const HEIGHT:int = EdoMobile.FINGER_SIZE;

    private const TIMER_LIMIT:int = 16;

//    private var _changeTimer:Timer;
    private var _activated:Boolean;
    private var _timerCounter:int;

    private var _ledOn:Image;
    private var _ledOff:Image;
    private var _ledMiddle:Image;

    private var _key:String;

    private var _details:MessagesListDetails;

    public function MessagesListItem(key:String, displayName:String, list:List = null) {
        super(AppProperties.screenWidth, HEIGHT, list);
        var texture:Texture = Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("closedlist_element_bg");
        var img:Image = new Image(texture);

        img.width = AppProperties.screenWidth;
        img.height = HEIGHT;
        this.addChild(img);

        this.addLabel(displayName, FontFactory.getBlackLeftFont(img.width - 66, img.height - 2, 14 / AppProperties.screenScaleRatio), 36, 2);


        _key = key;
        _details = new MessagesListDetails();

        _ledOff = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("led_off"));
        _ledOff.x = 0;
        _ledOff.y = (HEIGHT - _ledOff.height) / 2;
        _ledMiddle = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("led_m"));
        _ledMiddle.x = 0;
        _ledMiddle.y = (HEIGHT - _ledMiddle.height) / 2;
        _ledMiddle.visible = false;
        _ledOn = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("led_on"));
        _ledOn.x = 0;
        _ledOn.y = (HEIGHT - _ledMiddle.height) / 2;
        _ledOn.alpha = 0;

//        _changeTimer = new Timer(33, 16);
//        _changeTimer.addEventListener(TimerEvent.TIMER, changeTimerHandler, false, 0, true);
        activated = false;
        MessagesDataChangeTimer.instance.addItem(this);
    }

    public function addItem(key:Object):void {
        if (_content.height == 0) {
            this.addChild(_ledOff);
            this.addChild(_ledMiddle);
//            _quadBatcher.addDisplayObject(_ledOn);
            this.addChild(_ledOn);
        }
        if (key != null) {
            _details.add(key.key, key.displayName, "---");
        }
    }

    public function allItemAdded():void {
        if (!_content.contains(_details)) {
            _details.initQuadButcher();
            addContentChild(_details);
        }
    }

    public function dataChanged():void {
        if (!_ledMiddle.visible && (_list.parent as MessagesStage).validIsActual()) {
            _list.redraw();
            _list.scrollBox(0);
        }

//        _changeTimer.reset();
//        if (!_changeTimer.running) {
//            _changeTimer.start();
//        }
        activated = true;
        if (_content.visible) {
            _details.update(_key);
        }
    }

    public function dataInvalidated():void {
//        _changeTimer.stop();
        activated = false;
        _ledMiddle.visible = false;
        _ledOn.alpha = 0;
        _details.invalidate();

        if ((_list.parent as MessagesStage).validIsActual()) {
            _list.redraw();
            _list.scrollBox(0);
        }
    }

    public function dataPreInvalidated():void {
//        _changeTimer.stop();
        activated = false;
        _ledMiddle.visible = true;
        _ledOn.alpha = 0;
    }

    public function timerChanged():void {
        if (!_ledMiddle.visible) {
            _ledMiddle.visible = true;
        }

//        if (_changeTimer.currentCount <= 11) {
//            _ledOn.alpha = 1;
//        } else {
//            _ledOn.alpha = 1 - (_changeTimer.currentCount / _changeTimer.repeatCount);
//        }
        if (_timerCounter <= 11) {
            _ledOn.alpha = 1;
        } else {
            _ledOn.alpha = 1 - (_timerCounter / TIMER_LIMIT);
        }
        _timerCounter++;
//        _quadBatcher.render();
    }

    public function get key():String {
        return _key;
    }

    public function isInValid():Boolean {
        return _ledMiddle.visible;
    }

    public function get activated():Boolean {
        return _activated;
    }

    public function set activated(value:Boolean):void {
        _activated = value;
        _timerCounter = 0;
        if (_activated) {
            MessagesDataChangeTimer.instance.activate();
        }
    }

    public override function changeState():void {
        super.changeState();
        _details.update(_key);
    }

//
//    public function setValid():void {
//        if (!_changeTimer.running) {
////            _changeTimer.stop();
//
//
////            _ledOff.visible = false;
//            _ledOn.alpha = 0;
//        }
//        _ledOff.visible = false;
//        _ledMiddle.visible = true;
//
//    }
//
//    public function setInvalid():void {
//        _changeTimer.reset();
//        _ledOff.visible = true;
//        _ledMiddle.visible = false;
//        _ledOn.alpha = 0;
//        for (var i:int = 0; i < _details.details.length; i++) {
//            setValue(_details.details[i].key.text, null);
//        }
//    }
}
}
