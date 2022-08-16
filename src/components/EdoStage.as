/**
 * Created by pepusz on 2014.09.03..
 */
package components {

import com.common.AppProperties;
import com.sailing.ParserNotifier;
import com.sailing.SailData;
import com.sailing.instruments.BaseInstrument;
import com.ui.StageBtn;
import com.utils.Assets;
import com.utils.SaveHandler;

import components.lists.List;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.system.System;
import flash.utils.getDefinitionByName;

import starling.display.Image;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class EdoStage extends Sprite {

    public static const PURCHASE_TYPE_ALARMS:uint = 0;
    public static const PURCHASE_TYPE_INSTRUMENTS:uint = 1;
    public static const PURCHASE_TYPE_POLAR:uint = 2;

    public static const WIDTH:int = AppProperties.screenWidth;
    public static const BOTTOM_HEIGHT:int = 40 + StageContainer.BOTTOM_HEIGHT;

    protected var _title:String;
    protected var _id:String;
    protected var _buttons:Vector.<StageBtn>;
    protected var _bottom:Sprite;
    protected var _list:List;

    private var _purchaseType:uint;
    private var _purchaseButton:Image;
    private var _touchPoint:Point;

    protected var _instruments:Vector.<BaseInstrument>;
    public var stageIndex:uint = -1;

    public function EdoStage(id:String, title:String) {
        super();
        this._title = title;
        this._id = id;
    }

//    public static function get width():Number {
//        return NATIVE_WIDTH*AppProperties.screenScaleRatio;
//    }

    public function activate():void {
        visible = true;
        EdoMobile.topBar.setTitle(_title);
        EdoMobile.stageBottom.setActualIndex(this.stageIndex);

        if (_instruments != null) {
            for (var i:int = 0; i < _instruments.length; i++) {
                InstrumentHandler.instance.addInstrument(_instruments[i]);
            }
        }
        ParserNotifier.instance.activate();
    }

    public function deactivate():void {
        visible = false;
        if (_instruments != null) {
            var keys:Array = SailData.ownProperties;
            var length:int = keys.length;
            for (var i:int = 0; i < _instruments.length; i++) {
                for (var j:int = 0; j < length; j++) {
                    _instruments[i].dataInvalidated(keys[j]);
                }
                InstrumentHandler.instance.removeInstrument(_instruments[i]);
            }
        }
        System.pauseForGCIfCollectionImminent(0.15);
    }

    public function addInstrument(instrument:BaseInstrument):void {
        if (_instruments == null) {
            _instruments = new Vector.<BaseInstrument>();
        }
        _instruments.push(instrument);
        this.addChild(instrument);
    }

    public function get instruments():Vector.<BaseInstrument> {
        return _instruments;
    }

    public function swap(index:int):void {
        var last:int = this.numChildren - 1;
        if (_instruments != null && index < last) {
            var swap:BaseInstrument = _instruments[last];
            this.setChildIndex(_instruments[index], last);
            _instruments[last] = _instruments[index];
            this.setChildIndex(swap, index);
            _instruments[index] = swap;
        }
    }

    protected function buildFromFile():void {
        var file:File = File.applicationDirectory.resolvePath("stages/" + AppProperties.screenScaleRatioName);

        if (file.exists) {
            var xml:XML = getStageByDiagonal(file, AppProperties.screenDiagonalInInch);

            if (xml != null) {
                var width:Number = parseFloat(xml.width);
                var height:Number = parseFloat(xml.height);

                var uids:Array = new Array();

                var scale:Number = AppProperties.screenWidth / width;
                for each(var item:XML in xml.instrument) {
                    var uid:String = item.uid;
                    var x:Number = int(parseFloat(item.x) * scale);
                    var y:Number = int(parseFloat(item.y) * scale);
                    var w:Number = int(parseFloat(item.w) * scale);
                    var h:Number = int(parseFloat(item.h) * scale);
                    var type:String = item.type;

                    var ClassReference:Class = getDefinitionByName(type) as Class;
                    var instrument:BaseInstrument = new ClassReference() as BaseInstrument;
                    instrument.id = uid;
                    instrument.x = x;
                    instrument.y = y;
                    instrument.width = w;
                    instrument.height = h;

                    if (SaveHandler.instance.hasState(uid)) {
                        instrument.updateState(SaveHandler.instance.getState(uid));
                    } else if (item.hasOwnProperty("actualState") && item.actualState != "") {
                        instrument.updateState(item.actualState);
                    }

                    this.addChild(instrument);

                    if (_instruments == null) {
                        _instruments = new Vector.<BaseInstrument>();
                    }
                    _instruments.push(instrument);
                    uids.push(uid);
                }

                SaveHandler.instance.clear(uids);
            }
        }
        System.pauseForGCIfCollectionImminent(0.15);
    }

    private function getStageByDiagonal(directory:File, inches:Number):XML {
        var files:Array = directory.getDirectoryListing();
        var length:int = files.length;
        var stream:FileStream = new FileStream();
        if (length == 0) {
            return null;
        }
        if (length == 1) {
            stream.open(files[0], FileMode.READ);
            stream.position = 0;
            return new XML(stream.readUTFBytes(stream.bytesAvailable));
        }

        var file:File;
        var name:String;
        var index:int;
        var inch:Number;
        var currentInches:Number = -1;
        var currentFile:File;
        for (var i:int = 0; i < length; i++) {
            file = files[i];
            name = file.name.substring(0, file.name.lastIndexOf("."));
            if (name.indexOf(_id) == 0) {
                index = name.lastIndexOf("@");
                if (index >= 0) {
                    inch = Number(name.substring(index + 1, name.length));
                    if (currentInches < inch && inches >= inch) {
                        currentFile = file;
                        currentInches = inch;
                    }
                } else {
                    if (currentInches < 0) {
                        currentFile = file;
                        currentInches = 0;
                    }
                }
            }
        }

        stream.open(currentFile, FileMode.READ);
        stream.position = 0;
        return new XML(stream.readUTFBytes(stream.bytesAvailable));
    }

    public function get title():String {
        return _title;
    }

    public function get id():String {
        return _id;
    }

    public function get bottom():Sprite {
        return _bottom;
    }


    public function get list():List {
        return _list;
    }

    public function addButton(button:StageBtn):void {
        if (_buttons == null) {
            _buttons = new Vector.<StageBtn>();
            _bottom = new Sprite();
            _bottom.y = AppProperties.screenHeight - BOTTOM_HEIGHT;
            _bottom.addChild(new Quad(AppProperties.screenWidth, BOTTOM_HEIGHT - StageContainer.BOTTOM_HEIGHT, 0x7b7b7b));
            this.addChild(_bottom);
        }

        button.y = 4;
        _buttons.push(button);
        _bottom.addChild(button);

        var length:int = _buttons.length;
        var item:StageBtn;
        var w:Number = AppProperties.screenWidth / length;
        for (var i:int = 0; i < length; i++) {
            item = _buttons[i];
            item.x = (i * w) + (w / 2) - (item.width / 2);
        }
    }

    public function get purchaseType():uint {
        return _purchaseType;
    }

    public function addPurchaseButton(type:uint):void {
        _purchaseType = type;

        if(type==PURCHASE_TYPE_ALARMS) {
            _purchaseButton = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("pur_alarm"));
            _purchaseButton.y = StoreSettings.alarmY + (_purchaseButton.height*0.4);
        } else if(type==PURCHASE_TYPE_INSTRUMENTS) {
            _purchaseButton = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("pur_instr"));
            _purchaseButton.y = StoreSettings.instrumentsY + (_purchaseButton.height*0.4);
        } else if(type==PURCHASE_TYPE_POLAR) {
            _purchaseButton = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("pur_polar"));
            _purchaseButton.y = StoreSettings.polarY + (_purchaseButton.height*0.4);
        }

        if(_purchaseButton!=null) {
            _purchaseButton.addEventListener(TouchEvent.TOUCH, onPurchaseTouch);
            this.addChildAt(_purchaseButton, this.numChildren);
        }
    }

    public function removePurchaseButton():void {
        if(_purchaseButton!=null) {
            _purchaseButton.visible = false;
            _purchaseButton.dispose();
        }
    }

    private function onPurchaseTouch(event:TouchEvent):void {
        var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
        var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
        if(began) {
            _touchPoint = new Point(began.globalX,began.globalY);
        } else if(ended) {
            if (Math.abs(_touchPoint.x-ended.globalX)<=(EdoMobile.FINGER_SIZE/2) && Math.abs(_touchPoint.y-ended.globalY)<=(EdoMobile.FINGER_SIZE/2) && !EdoMobile.onMove) {
                EdoMobile.menu.toStore();
            }
        }
    }
}
}
