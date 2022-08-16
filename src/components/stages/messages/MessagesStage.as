/**
 * Created by seamantec on 04/09/14.
 */
package components.stages.messages {
import com.common.AppProperties;
import com.sailing.SailData;
import com.sailing.datas.BaseSailData;
import com.ui.Badge;
import com.ui.StageBtn;
import com.utils.FontFactory;

import components.EdoStage;
import components.MessagesHandler;
import components.TopBar;
import components.lists.List;
import components.lists.ListButtonLg;
import components.lists.ListHeader;

import flash.geom.Point;

import starling.display.Image;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class MessagesStage extends EdoStage {

    public static const ID:String = "messages_stage";
    public static const HEADER_HEIGHT:uint= EdoMobile.FINGER_SIZE;

    private var _button:ListButtonLg;
    private var _touchPoint:Point;
    private var _isReverse:Boolean;

    private var _currentItem:MessagesListItem;

    private var _allBtn:StageBtn;
    private var _openedBtn:StageBtn;
    private var _validBtn:StageBtn;
    private var _validBadge:Badge;

    public function MessagesStage() {
        super(ID, "NMEA messages list");

        _list = new List(0,TopBar.HEIGHT, AppProperties.screenWidth,AppProperties.screenHeight - TopBar.HEIGHT - EdoStage.BOTTOM_HEIGHT, 0x656565,1);
        var header:ListHeader = new ListHeader(AppProperties.screenWidth, HEADER_HEIGHT, 0xffffff);
        header.addLabel("NMEA Sentence", FontFactory.getBlackLeftFont(AppProperties.screenWidth - 4, HEADER_HEIGHT, 16/AppProperties.screenScaleRatio), 4, 1);
        header.addEventListener(TouchEvent.TOUCH, onSortTouch);
//        addHeaderButton(header);
        _list.addHeader(header);
        _list.addScrollBar();
        this.addChild(_list);
        fillList();
        _isReverse = true;
        sort();

        createButtons();

        this.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public override function activate():void {
        super.activate();
        MessagesHandler.instance.addStage(this);
    }

    public override function deactivate():void {
        super.deactivate();
        MessagesHandler.instance.removeStage();
        MessagesDataChangeTimer.instance.deactivate();
    }

    public function createButtons():void {
        _allBtn = new StageBtn("All");
        _allBtn.selected = true;
        _allBtn.addEventListener(TouchEvent.TOUCH, allBtnHandler);
        this.addButton(_allBtn);
        _openedBtn = new StageBtn("Opened");
        _openedBtn.addEventListener(TouchEvent.TOUCH, openedBtnHandler);
        this.addButton(_openedBtn);
        _validBtn = new StageBtn("Valid");
        _validBtn.addEventListener(TouchEvent.TOUCH, validBtnHandler);
        this.addButton(_validBtn);
        _validBadge = new Badge(_validBtn.x + _validBtn.width - 20, _validBtn.y - 3);
        _validBadge.text = "0";
        _bottom.addChild(_validBadge);
    }

    public function dataChanged(key:String):void {
        _currentItem = itemOfKey(key);
        if (_currentItem != null) {
            _currentItem.dataChanged();
        }

        validCounter();
    }

    public function dataInvalidated(key:String):void {
        _currentItem = itemOfKey(key);
        if (_currentItem != null) {
            _currentItem.dataInvalidated();
        }

        validCounter();
    }

    public function dataPreInvalidated(key:String):void {
        _currentItem = itemOfKey(key);
        if (_currentItem != null) {
            _currentItem.dataPreInvalidated();
        }
    }

    private function fillList():void {
        var sailData:SailData = SailData.actualSailData;
        var parameters:Array = SailData.ownProperties;
        var key:String;
        var length:int = parameters.length;
        var parent:BaseSailData;
        var parentParameters:Array;
        var item:MessagesListItem;
        var parentLength:int;
        var ckey:Object;
        for (var i:int = 0; i < length; i++) {
            key = parameters[i];
            if (!(sailData[key] is BaseSailData) || key == "tripdata") {
                continue;
            }
            parent = sailData[key];
            parentParameters = parent.displayNames;
            item = itemOfKey(key);
            if (item == null) {
                item = new MessagesListItem(key, parent.displayName, _list);
                _list.addItem(item);
            }
            parentLength = parentParameters.length;
            for (var j:int = 0; j < parentLength; j++) {
                ckey = parentParameters[j];
                if (ckey === "isInValid" || ckey === "isInPreValid" || ckey === "lastTimestamp") {
                    continue;
                }
                item.addItem(ckey);
            }
            item.allItemAdded();
        }
    }

    private function addHeaderButton(header:ListHeader):void {
        _button = new ListButtonLg();
        _button.x = AppProperties.screenWidth - _button.width-5;
        _button.y = (HEADER_HEIGHT-_button.height)/2;
        _button.addEventListener(TouchEvent.TOUCH, onButtonTouch);
        header.addChild(_button);
    }

    private function itemOfKey(key:String):MessagesListItem {
        var length:int = _list.length;
        var item:MessagesListItem;
        for (var i:int = 0; i < length; i++) {
            item = _list.getItem(i) as MessagesListItem;
            if (item.key == key) {
                return item;
            }
        }
        return null;
    }

    private function sort():void {
        if (_isReverse) {
            _list.order = ascSort;
            _isReverse = false;

        } else {
            _list.order = descSort;
            _isReverse = true;
        }

        _list.redraw();
    }

    private function onTouch(e:TouchEvent):void {
        var began:Touch = e.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = e.getTouch(this, TouchPhase.ENDED);
        if (began) {
            _touchPoint = new Point(began.globalX, began.globalY);
        } else if (ended) {

        }
    }

    private function onButtonTouch(e:TouchEvent):void {
        var ended:Touch = e.getTouch(this, TouchPhase.ENDED);
        if (ended) {
            var p:Point = new Point(ended.globalX, ended.globalY);

            if (Math.abs(_touchPoint.x - p.x) <= 3 && Math.abs(_touchPoint.y - p.y) <= 3) {
                var item:MessagesListItem;
                var length:int = _list.length;

                _button.open = !_button.open;

                var i:int;
                if (_button.open) {
                    for (i = 0; i < length; i++) {
                        item = (_list.getItem(i) as MessagesListItem);
                        if (!item.content.visible) {
                            item.open();
                        }
                    }
                } else {
                    for (i = 0; i < length; i++) {
                        item = (_list.getItem(i) as MessagesListItem);
                        if (item.content.visible) {
                            item.close();
                        }
                    }
                }

                _list.redraw();
                _list.scrollBox(0);
            }
        }
    }

    private function onSortTouch(e:TouchEvent):void {
        var began:Touch = e.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = e.getTouch(this, TouchPhase.ENDED);
        if (began) {
            _touchPoint = new Point(began.globalX, began.globalY);
        } else if (ended) {
            var p:Point = new Point(ended.globalX, ended.globalY);
            if (Math.abs(_touchPoint.x - p.x) <= 3 && Math.abs(_touchPoint.y - p.y) <= 3 && !(e.target is Image)) {
                sort();
            }
        }
    }

    private function allBtnHandler(e:TouchEvent):void {
        var touch:Touch = e.getTouch(this.stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                _allBtn.selected = true;
                _openedBtn.selected = false;
                _validBtn.selected = false;

                _list.filters = null;
                _list.scrollToStart();
            }
        }
    }

    private function openedBtnHandler(e:TouchEvent):void {
        var touch:Touch = e.getTouch(this.stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                _allBtn.selected = false;
                _openedBtn.selected = true;
                _validBtn.selected = false;

                var filters:Vector.<Function> = new Vector.<Function>();
                filters.push(openedFilter);
                _list.filters = filters;
                _list.scrollToStart();
            }
        }
    }

    private function validBtnHandler(e:TouchEvent):void {
        var touch:Touch = e.getTouch(this.stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                _allBtn.selected = false;
                _openedBtn.selected = false;
                _validBtn.selected = true;

                var filters:Vector.<Function> = new Vector.<Function>();
                filters.push(validFilter);
                _list.filters = filters;
                _list.scrollToStart();
            }
        }
    }

    public function allIsActual():Boolean {
        return _allBtn.selected;
    }

    public function openedIsActual():Boolean {
        return _openedBtn.selected;
    }

    public function validIsActual():Boolean {
        return _validBtn.selected;
    }

    private function validCounter():void {
        var sum:int = 0;
        var length:int = _list.length;
        for (var i:int; i < length; i++) {
            if (validFilter(_list.getItem(i) as MessagesListItem)) {
                sum++;
            }
        }
        _validBadge.text = sum.toString();
    }

    private function ascSort(a:MessagesListItem, b:MessagesListItem):int {
        if (a.key < b.key) {
            return -1
        } else if (a.key > b.key) {
            return 1;
        } else {
            return 0
        }
    }

    private function descSort(a:MessagesListItem, b:MessagesListItem):int {
        if (a.key > b.key) {
            return -1
        } else if (a.key < b.key) {
            return 1;
        } else {
            return 0
        }
    }

    private function openedFilter(item:MessagesListItem):Boolean {
        return item.content.visible;
    }

    private function validFilter(item:MessagesListItem):Boolean {
        return item.isInValid();
    }

    public function set scrollable(value:Boolean):void {
        _list.scrollable = value;
    }
}
}
