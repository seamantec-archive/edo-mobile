/**
 * Created by pepusz on 2014.09.03..
 */
package components {
import com.common.AppProperties;
import com.events.HorizontalTouchEvent;
import com.sailing.instruments.BaseInstrument;

import components.stages.alarms.AlarmsStage;
import components.stages.instruments.Stage1;
import components.stages.instruments.Stage2;
import components.stages.instruments.Stage3;
import components.stages.instruments.Stage4;
import components.stages.instruments.Stage5;
import components.stages.instruments.Stage6;
import components.stages.messages.MessagesStage;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;

import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.Color;

public class StageContainer extends Sprite {

    public static const BOTTOM_HEIGHT:int = 16;

    private var _bg:Quad;

    private var _container:Vector.<EdoStage> = new <EdoStage>[];

    private var _active:EdoStage;
    private var _prevStage:EdoStage;
    private var _next:EdoStage;

    private static var _messagesStage:MessagesStage;
    private static var _alarmsStage:AlarmsStage;
//    private static var _storeStage:StoreStage;

    public function StageContainer() {
        super();

        drawBg();
        this.clipRect = new Rectangle(0, 0, AppProperties.screenWidth, AppProperties.screenHeight);

        Starling.current.root.addEventListener(HorizontalTouchEvent.STAGE_MOVE, onTouchMove);
        Starling.current.root.addEventListener(HorizontalTouchEvent.STAGE_END, onTouchEnd);

        _messagesStage = new MessagesStage();
        _alarmsStage = new AlarmsStage();


        addStage(_messagesStage);
        addStage(_alarmsStage);
        addStage(new Stage1());
        System.pauseForGCIfCollectionImminent(0.15);
        System.gc();
        addStage(new Stage2());
        System.pauseForGCIfCollectionImminent(0.15);
        addStage(new Stage3());
        System.pauseForGCIfCollectionImminent(0.15);
        if (!AppProperties.isJunkIpad) {
            addStage(new Stage4());
            System.pauseForGCIfCollectionImminent(0.15);
        }
        System.gc();
        addStage(new Stage5());
        System.pauseForGCIfCollectionImminent(0.15);
        if (!AppProperties.isJunkIpad) {
            addStage(new Stage6());
            System.pauseForGCIfCollectionImminent(0.15);
        }
        System.gc();

        activateStage(_messagesStage.id);
//        activateStage(AlarmsStage.ID);
    }

    public function activateStage(stageId:String, withPosition:Boolean = true):void {
        var length:int = _container.length;

        if (length > 0) {
            var item:EdoStage;
            for (var i:int = 0; i < length; i++) {
                item = _container[i];
                if (item.id == stageId) {
                    if (_active != null && item.id != _active.id) {
                        _prevStage = _active
                        if (withPosition) deactivatePrevStage();
                    }
                    _active = item;
                    item.activate();
                    _next = null;
                    if (withPosition) {
                        this.x = -item.x;
                        this.clipRect.x = item.x;
                    }
                    if (item is MessagesStage || item is AlarmsStage) {
                        EdoMobile.stopFadeTimer();
                    } else {
                        EdoMobile.startFadeTimer();
                    }
                    break;
                }
            }
        }
    }


    public function deactivatePrevStage():void {
        if (_prevStage != null) {
            _prevStage.deactivate();
        }
    }


    private function onTouchMove(e:Event):void {
        var x:Number = e.data.distance;
        var index:int = (x < 0) ? (_active.stageIndex + 1) : (_active.stageIndex - 1);
        if (index >= 0 && index < _container.length) {
            _next = _container[index];
            _next.visible = true;
            this.x = -_active.x + x;
            this.clipRect.x = _active.x - x;
        } else if (_next == null) {
            if (x > 0 && _active.stageIndex == 0) {
                _active.x = sumOfSwipe(x);
            } else if (x < 0 && _active.stageIndex == (_container.length - 1)) {
                _active.x = (_active.stageIndex * AppProperties.screenWidth) - sumOfSwipe(-x);
            }
        }
    }

    private function onTouchEnd(e:Event):void {
        if (_next != null) {
            var duration:Number = 0.2;//(Math.abs(x-this.width)/this.width)*0.2;
            var thisTween:Tween = new Tween(this, duration, Transitions.EASE_IN);
            var clipTween:Tween = new Tween(this.clipRect, duration, Transitions.EASE_IN);
            thisTween.onComplete = function () {
                deactivatePrevStage();
            };
            if (Math.abs(this.x + _active.x) > (AppProperties.screenWidth * 0.2)) {
                activateStage(_next.id, false);
            } else {
                _next = null;

            }
            thisTween.animate("x", -_active.x);
            clipTween.animate("x", _active.x);
            Starling.juggler.add(thisTween);
            Starling.juggler.add(clipTween);
        } else {
            pushBack();
        }
    }

    private function sumOfSwipe(x:Number):Number {
        var sum:Number = 0;
        while (x > EdoMobile.FINGER_SIZE) {
            sum += (1 / x) * 25;
            x--;
        }
        return sum;
    }

    private function pushBack():void {
        if (_active.stageIndex == 0) {
            Starling.juggler.tween(_active, 0.5, {
                transition: Transitions.EASE_OUT,
                x: 0
            });
        } else if (_active.stageIndex == (_container.length - 1)) {
            Starling.juggler.tween(_active, 0.5, {
                transition: Transitions.EASE_OUT,
                x: (_container.length - 1) * AppProperties.screenWidth
            });
        }
    }

    public function get length():int {
        return _container.length;
    }

    public function getTitle(index:int):String {
        return _container[index].title;
    }


    private function addStage(stage:EdoStage):void {
        var length:int = _container.length;
        for (var i:int = 0; i < length; i++) {
            if (_container[i].id === stage.id) {
                throw new Error("This stage has already added to stageContainer");
                return;
            }
        }

        stage.x = length * AppProperties.screenWidth;
        stage.stageIndex = _container.length;
        this.addChild(stage);

        _container.push(stage);
        _bg.width += AppProperties.screenWidth;

        stage.deactivate();

        EdoMobile.stageBottom.addStage();
        EdoMobile.menu.refreshMenuList();
    }

    private function drawBg():void {
        _bg = new Quad(AppProperties.screenWidth, AppProperties.screenHeight, Color.BLACK);
        this.addChild(_bg);
    }

    public function get container():Vector.<EdoStage> {
        return _container;
    }


    public function get active():EdoStage {
        return _active;
    }

    public function get messagesStage():MessagesStage {
        return _messagesStage;
    }

    public function get alarmsStage():AlarmsStage {
        return _alarmsStage;
    }

    public function getActiveStageElement(position:Point):BaseInstrument {
        position.y -= this.y;
        var instruments:Vector.<BaseInstrument> = _active.instruments;
        if (instruments == null) {
            return null;
        }

        var last:int = instruments.length - 1;
        var instrument:BaseInstrument;
        var threshold:Number = EdoMobile.FINGER_SIZE / 2;
        for (var i:int = last; i >= 0; i--) {
            instrument = instruments[i];
            if (position.x >= (instrument.x - threshold) && position.x <= (instrument.x + instrument.width + threshold) && position.y >= (instrument.y - threshold) && position.y <= (instrument.y + instrument.height + threshold)) {
                _active.swap(i);
                return instrument;
            }
        }

        return null;
    }

    public function setActiveStageFromMenu(index:int, fromMenu:Boolean = true):void {
        deactivatePrevStage();
        activateStage(_container[index].id);
        this.x = -_active.x + ((fromMenu) ? EdoMobile.menu.width : 0);
        this.clipRect.x = _active.x;
    }

    public function removePurchaseButtons(type:uint):void {
        var length:int = _container.length;
        var stage:EdoStage;
        for (var i:int = 0; i < length; i++) {
            stage = _container[i];
            if (stage.purchaseType == type) {
                stage.removePurchaseButton();
            }
        }
    }
}
}
