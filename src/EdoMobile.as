/**
 * Created by pepusz on 2014.09.03..
 */
package {
import com.alarm.AlarmHandler;
import com.common.AppProperties;
import com.common.WindCorrection;
import com.events.HorizontalTouchEvent;
import com.events.ScaleTouchEvent;
import com.events.VerticalTouchEvent;
import com.harbor.CloudHandler;
import com.harbor.PolarFileHandler;
import com.harbor.WebsocketHandler;
import com.inAppPurchase.CommonStore;
import com.sailing.instruments.BaseInstrument;
import com.sailing.units.UnitHandler;
import com.store.SettingsConfigs;
import com.ui.AlarmSliderKnob;
import com.ui.MenuBtn;
import com.ui.SliderKnob;
import com.utils.Assets;
import com.utils.EdoLocalStore;
import com.utils.ListContainer;
import com.utils.SaveHandler;
import com.utils.SoundHandler;

import components.LoadingScreen;
import components.Menu;
import components.PolarLoadingScreen;
import components.ScreenSettings;
import components.StageBottom;
import components.StageContainer;
import components.TopBar;
import components.lists.List;
import components.stages.StoreStage;
import components.stages.alarms.AlarmsStage;
import components.stages.messages.MessagesStage;

import feathers.controls.TextInput;

import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.net.SharedObject;
import flash.system.System;
import flash.utils.Timer;
import flash.utils.getTimer;

import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.rad2deg;

public class EdoMobile extends Sprite {


    public static const FINGER_SIZE:int = 44;
    private const MULTITOUCH_THRESHOLD:int = 500;

    private static var _polarLoadingScreen:PolarLoadingScreen;
    private static var _menu:Menu;
    private static var _stageContainer:StageContainer;
    private static var _topBar:TopBar;

    private static var _notificationBackground:Quad;
    private static var _notifications:Sprite;

    private var _multiTouch:Boolean = false;
    private var _list:List = null;
    private var _target:BaseInstrument = null;
    private var _begin:Point;
    private var _touchTime:int;
    private var _moveDistance:Number = 0;
    private var _moveVertical:Boolean = false;
    private var _moveMenu:Boolean = false;
    private var _moveHorizontal:Boolean = false;
    private static var _onMove:Boolean = false;

    private static var _fadeTimer:Timer;

    private static var _stageBottom:StageBottom;
    private static var _loadingScreen:LoadingScreen;

    public function EdoMobile() {
        super();
//        DS::device{
            CommonStore.instance.loadBackValues();
//        }
        _loadingScreen = new LoadingScreen();
        this.addChild(loadingScreen);
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
//        SharedObject.preventBackup = true;
    }

    public static function reset():void {
        var localStoreObject:SharedObject = SharedObject.getLocal("edoMobile");
        localStoreObject.clear();
        EdoLocalStore.reset();
        var files:Array = File.applicationStorageDirectory.getDirectoryListing();
        for (var i:int = 0; i < files.length; i++) {
            if ((files[i] as File).isDirectory) {
                (files[i] as File).deleteDirectory(true);
            } else {
                (files[i] as File).deleteFile();
            }

        }
    }

    public function removeProgress():void {
        this.removeChild(loadingScreen);
        loadingScreen.disposeSprite();
        _loadingScreen = null;
    }

    private function initUI():void {
        SettingsConfigs.loadBackInstance();
        UnitHandler.instance.loadUnits();
        CloudHandler.instance.load();
        WindCorrection.instance.load();
        WebsocketHandler.instance.connect();
        PolarFileHandler.instance;
        System.pauseForGCIfCollectionImminent(0.15);
//        CloudHandler.instance.getActualPolar();
        SoundHandler.load();
        ScreenSettings.load();
        SaveHandler.instance.load();
        AlarmHandler.instance.importAlarms();

        _polarLoadingScreen = new PolarLoadingScreen();

        _topBar = new TopBar();
        _menu = new Menu();

        _stageBottom = new StageBottom();
        _stageContainer = new StageContainer();

        this.addChild(_menu);
        this.addChild(_stageContainer);
        this.addChild(_topBar);
        this.addChild(_stageBottom);

        this.addChild(_polarLoadingScreen.quadBatch);

        _notificationBackground = new Quad(AppProperties.screenWidth, AppProperties.screenHeight, 0x0);
        _notificationBackground.alpha = 0.5;
        notificationBackgroundChange();
        this.addChild(_notificationBackground);

        _notifications = new Sprite();
        this.addChild(_notifications);

        this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public static function get loadingScreen():LoadingScreen {
        return _loadingScreen;
    }

    public static function get polarLoadingScreen():PolarLoadingScreen {
        return _polarLoadingScreen
    }

    public static function get menu():Menu {
        return _menu;
    }

    public static function get stageContainer():StageContainer {
        return _stageContainer;
    }

    public static function get stageBottom():StageBottom {
        return _stageBottom;
    }

    public static function get topBar():TopBar {
        return _topBar;
    }

    public static function get notifications():Sprite {
        return _notifications;
    }

    public static function notificationBackgroundChange():void {
        _notificationBackground.visible = !_notificationBackground.visible;
    }

    public static function get onMove():Boolean {
        return _onMove;
    }

    private function onTouch(e:TouchEvent):void {
        if (!(e.target is SliderKnob) && !(e.target is AlarmSliderKnob) && !(e.target is MenuBtn) && !(e.target is TextInput)) {
            var begin:Touch = e.getTouch(this.stage, TouchPhase.BEGAN);
            var moves:Vector.<Touch> = e.getTouches(this.stage, TouchPhase.MOVED);
            var end:Touch = e.getTouch(this.stage, TouchPhase.ENDED);

            //Multitouch disabled
            if (e.touches.length > 1) {
                return;
            }

            if (begin) {
                _begin = begin.getLocation(this.stage);
                _touchTime = getTimer();
                _list = getParentIfList(begin.target);
                dispatchBeginVerticalTouchEvent();
                dispatchMenuBeginVerticalTouchEvent();

                if (_list == null) {
                    ListContainer.instance.close();
                }
            }

            if (moves.length == 1) {
                var moved:Touch = moves[0];
                _moveDistance += Math.sqrt(Math.pow(moved.globalX - moved.previousGlobalX, 2) + Math.pow(moved.globalY - moved.previousGlobalY, 2));
                if (_moveHorizontal) {
                    if (_moveMenu) {
                        dispatchMenuMoveHorizontalTouchEvent(moved);
                    } else {
                        (_menu.open) ? dispatchMenuMoveHorizontalTouchEvent(moved) : dispatchStageMoveHorizontalTouchEvent(moved);
                    }
                } else if (_moveVertical) {
                    (_menu.open) ? dispatchMenuMoveVerticalTouchEvent(moved) : dispatchMoveVerticalTouchEvent(moved);
                } else {
                    var p:Point = moved.getLocation(this.stage);
                    var dx:Number = p.x - _begin.x;
                    var dy:Number = _begin.y - p.y;
                    if (Math.sqrt((dx * dx) + (dy * dy)) > FINGER_SIZE / AppProperties.screenScaleRatio) {
                        _onMove = true;

                        var angle:Number = rad2deg(Math.atan2(dy, dx));
                        if ((angle > -45 && angle <= 45) || angle <= -135 || angle > 135) {
                            stopFadeTimer();

                            _moveHorizontal = true;
                            dispatchPushVerticalTouchEvent();
                            if (_begin.x < (FINGER_SIZE / 4) * AppProperties.screenScaleRatio) {
                                _moveMenu = true;
                                dispatchMenuMoveHorizontalTouchEvent(moved);
                            } else {
                                _moveMenu = false;
                                (_menu.open) ? dispatchMenuMoveHorizontalTouchEvent(moved) : dispatchStageMoveHorizontalTouchEvent(moved);
                            }
                        } else {
                            _moveVertical = true;
                            if (!_menu.open) {
                                dispatchMoveVerticalTouchEvent(moved);
                            }
                        }
                    }
                }

            }

            if (end) {
                if (_moveHorizontal) {
                    startFadeTimer();
                    _moveHorizontal = false;
                    if (_moveMenu) {
                        _moveMenu = false;
                        dispatchMenuEndHorizontalTouchEvent();
                    } else {
                        (_menu.open) ? dispatchMenuEndHorizontalTouchEvent() : dispatchStageEndHorizontalTouchEvent();
                    }
                } else if (_moveVertical) {
                    _moveVertical = false;
                    (_menu.open) ? dispatchMenuEndVerticalTouchEvent(end) : dispatchEndVerticalTouchEvent(end);
                }
                _list = null;
                _moveDistance = 0;
                _onMove = false;

            }

        }
    }

    private function dispatchMenuMoveHorizontalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new HorizontalTouchEvent(HorizontalTouchEvent.MENU_MOVE, {distance: touch.globalX - _begin.x}));
    }

    private function dispatchMenuEndHorizontalTouchEvent():void {
        this.dispatchEvent(new HorizontalTouchEvent(HorizontalTouchEvent.MENU_END));
    }

    private function dispatchStageMoveHorizontalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new HorizontalTouchEvent(HorizontalTouchEvent.STAGE_MOVE, {distance: touch.globalX - _begin.x}));
    }

    private function dispatchStageEndHorizontalTouchEvent():void {
        this.dispatchEvent(new HorizontalTouchEvent(HorizontalTouchEvent.STAGE_END));
    }

    private function dispatchBeginVerticalTouchEvent():void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.BEGIN, {target: _list}));
    }

    private function dispatchPushVerticalTouchEvent():void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.PUSH, {target: _list}));
    }

    private function dispatchMoveVerticalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.MOVE, {
            dy: -touch.getMovement(this).y,
            target: _list
        }));
    }

    private function dispatchEndVerticalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.END, {
            speed: (sgn(_begin.y - touch.globalY) * _moveDistance) / (getTimer() - _touchTime),
            target: _list
        }));
    }

    private function dispatchMenuBeginVerticalTouchEvent():void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.MENU_BEGIN));
    }

    private function dispatchMenuMoveVerticalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.MENU_MOVE, {distance: touch.globalY - touch.previousGlobalY}));
    }

    private function dispatchMenuEndVerticalTouchEvent(touch:Touch):void {
        this.dispatchEvent(new VerticalTouchEvent(VerticalTouchEvent.MENU_END, {
            speed: (sgn(_begin.y - touch.globalY) * _moveDistance) / (getTimer() - _touchTime)
        }));
    }

    private function dispatchMoveScaleTouchEvent(scale:Number):void {
        this.dispatchEvent(new ScaleTouchEvent(ScaleTouchEvent.SCALE, {target: _target, scale: scale}));
    }

    private function dispatchEndScaleTouchEvent():void {
        this.dispatchEvent(new ScaleTouchEvent(ScaleTouchEvent.END, {target: _target}));
    }

    private function isSameFinger(p:Point):Boolean {
        return Math.sqrt(Math.pow(p.x - _begin.x, 2) + Math.pow(_begin.y - p.y, 2)) < EdoMobile.FINGER_SIZE * 0.25;
    }

    public static function startFadeTimer():void {
        if (_stageContainer == null) {
            _topBar.visible = false;
            _stageBottom.visible = false;
        } else if (!(_stageContainer.active is StoreStage || _stageContainer.active is MessagesStage || _stageContainer.active is AlarmsStage)) {
            if (_fadeTimer == null) {
                _fadeTimer = new Timer(100, 10);
                _fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
            }

            _fadeTimer.start();
        }
    }

    private static function onFadeTimer(event:TimerEvent):void {
        var alpha:Number = (10 - _fadeTimer.currentCount) / 10;
        _topBar.alpha = alpha;
        _stageBottom.alpha = alpha;

        _topBar.visible = (alpha != 0);
        _stageBottom.visible = (alpha != 0);
    }

    public static function stopFadeTimer():void {
        if (_fadeTimer != null) {
            _fadeTimer.reset();
        }

        _topBar.alpha = 1;
        _stageBottom.alpha = 1;

        _topBar.visible = true;
        _stageBottom.visible = true;
    }

    private function addedToStageHandler(event:Event):void {
        Assets.loadAssets(initUI);
        System.pauseForGCIfCollectionImminent(0.15);
    }

    private function getParentIfList(object:DisplayObject):List {
        var prnt:DisplayObject;
        while (object != null) {
            prnt = object.parent;
            if (prnt is List) {
                return (prnt as List);
            }
            object = prnt;
        }
        return null;
    }

    private function sgn(value:Number):Number {
        return (value < 0) ? -1 : 1;
    }
}
}
