/**
 * Created by seamantec on 13/02/15.
 */
package components.instruments {
import com.common.AppProperties;
import com.dynamicInstruments.InstrumentQuadBatcher;
import com.events.CloudEvent;
import com.harbor.CloudHandler;
import com.harbor.PolarFile;
import com.harbor.PolarFileEvent;
import com.harbor.PolarFileHandler;
import com.harbor.PolarHandlerEvent;
import com.polar.PolarContainer;
import com.sailing.SailData;
import com.sailing.instruments.BaseInstrument;
import com.ui.PolarListItem;
import com.utils.Assets;
import com.utils.FontFactory;
import com.utils.FontFactory;
import com.utils.ListContainer;

import components.lists.List;

import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.utils.VAlign;

public class PolarControl extends BaseInstrument {

    private static const MAX_LIST_LENGTH:int = 5;

    private var _control:InstrumentQuadBatcher;
    private var _label:TextField;
    private var _selector:Rectangle;

    private var _info:Sprite;

    private var _list:List;

    public function PolarControl() {
        super(Assets.getInstrument("digital_a"));

        _control.quadBatch.addEventListener(TouchEvent.TOUCH, onTouch);
        PolarFileHandler.instance.addEventListener(PolarHandlerEvent.POLAR_LIST_READY, onPolarListReady);

        CloudHandler.instance.addEventListener(CloudEvent.SIGNIN_COMPLETE, onSignIn);
        CloudHandler.instance.addEventListener(CloudEvent.SIGNOUT, onSignOut);
    }

    protected override function buildComponents():void {
        var texture:Texture = Assets.getAtlas("digital_common");

        var image:Image = _instrumentAtlas.getComponentAsImage(texture, "digital.instance2");
        var selector:Image = _instrumentAtlas.getComponentAsImage(texture, "digital.selector");
        var region:Rectangle = new Rectangle(0, 0, image.width, image.height * 0.25);
        var background:Image = new Image(Texture.fromTexture(image.texture, region));

        var ratio:Number = AppProperties.screenWidth / image.width;
        _selector = new Rectangle((selector.x - selector.pivotX) * ratio, (selector.y - selector.pivotY) * ratio, selector.width * ratio, selector.height * ratio);
        _label = _instrumentAtlas.getComponentAsTextField("digital.label1", VAlign.CENTER, HAlign.LEFT);
        _label.autoScale = true;
        _label.text = (CloudHandler.instance.signedIn) ? PolarContainer.instance.polarTableName.substring(0, PolarContainer.instance.polarTableName.lastIndexOf(".")) : "";

        _control = new InstrumentQuadBatcher(background.width, background.height, "polarControlBackground");
        _control.addDisplayObject(background);
        _control.addDisplayObject(selector);
        _control.addDisplayObject(_label);
        this.addChild(_control.quadBatch);

        _info = new Sprite();
        _info.addChild(new Quad(background.width,background.height, 0x5b5b5b));
        var infoField:TextField = new TextField(background.width,background.height, "Please sign in from the menu, or\ncreate a free account at www.seamantec.com", FontFactory.arialText, background.height/2, 0xffd200, true);
        infoField.autoScale = true;
        _info.addChild(infoField);
        _info.visible = !(CloudHandler.instance.email!=null && CloudHandler.instance.token!=null);
        this.addChild(_info);
    }

    public function get control():InstrumentQuadBatcher {
        return _control;
    }

    public function get label():TextField {
        return _label;
    }

    public function get selector():Rectangle {
        return _selector;
    }

    public function get list():List {
        return _list;
    }

    private function setPolarList():void {
        //delete items
        var item:PolarListItem;
        var lastDeletedActiveIndex:int = -1;
        for (var i:int = _list.length - 1; i >= 0; i--) {
            item = _list.getItem(i) as PolarListItem;
            if (!PolarFileHandler.instance.hasId(item.id)) {
                if (item.active) {
                    lastDeletedActiveIndex = i;
//                    _label.text = "";
//                    _control.render();
                }
                _list.removeIndex(i);
            }
        }
        //Add/refresh items
        var length:int = PolarFileHandler.instance.container.length;
        var polarFile:PolarFile;
        for (var i:int = 0; i < length; i++) {
            polarFile = PolarFileHandler.instance.container[i];
            if (!hasItemById(polarFile.id)) {
                polarFile.addEventListener(PolarFileEvent.FILE_READY, onPolarFileReady);
                _list.addItem(new PolarListItem(this, polarFile));
            }
        }


        var listLength:int = Math.floor(_list.height / PolarListItem.HEIGHT);
        if (length >= MAX_LIST_LENGTH) {
            if (listLength < MAX_LIST_LENGTH) {
                _list.height = MAX_LIST_LENGTH * PolarListItem.HEIGHT;
            }
        } else if (listLength != length) {
            _list.height = length * PolarListItem.HEIGHT;
        }

        _list.scrollBox(0);
        if (lastDeletedActiveIndex != -1) {
            var nextActiveIndex:int = lastDeletedActiveIndex == 0 ? 0 : lastDeletedActiveIndex - 1;
            var item:PolarListItem = _list.getItem(nextActiveIndex) as PolarListItem;
            if (item != null) {
                item.activate();
            } else {
                _label.text = "";
                _control.render();
                PolarContainer.instance.reset();
            }
        }
    }

    private function hasItemById(id:String):Boolean {
        for (var i:int = _list.length - 1; i >= 0; i--) {
            if ((_list.getItem(i) as PolarListItem).id == id) {
                return true;
            }
        }
        return false;
    }

    private function getPolarListItemById(index:String):PolarListItem {
        var length:int = _list.length;
        var item:PolarListItem;
        for (var i:int = 0; i < length; i++) {
            item = _list.getItem(i) as PolarListItem;
            if (index == item.id) {
                return item;
            }
        }

        return null;
    }

    private function onPolarFileReady(event:PolarFileEvent):void {

    }

    private function onPolarListReady(event:PolarHandlerEvent):void {
        if (_list == null) {
            initList();
        }
        setPolarList();
    }

    private function onTouch(event:TouchEvent):void {
        var touch:Touch = touchIsEnd(event);
        if (touch && PolarFileHandler.instance.container.length > 0 && !_info.visible) {
            var p:Point = touch.getLocation(this);
            if ((_list == null || ListContainer.instance.active != _list) && p.x >= _selector.x && p.y >= _selector.y && p.x <= (_selector.x + _selector.width) && p.y <= (_selector.y + _selector.height)) {
                if (_list == null) {
                    initList();
                    setPolarList();
                }

                _list.visible = true;
            }
        }
    }

    private function onSignIn(event:CloudEvent):void {
        _info.visible = false;
    }

    private function onSignOut(event:CloudEvent):void {
        _info.visible = true;
    }

    private function initList():void {
        _list = new List(this.x + _selector.x, this.y + _selector.y + _selector.height, _selector.width, MAX_LIST_LENGTH * PolarListItem.HEIGHT, 0xc9c9c9, 1);

        _list.visible = false;

        ListContainer.instance.add(_list);

        _list.addScrollBar();

        this.parent.addChild(_list);

        setPolarList();
    }

    public override function updateDatas(datas:SailData, needTween:Boolean = true):void {
    }

    public override function updateState(stateType:String):void {
    }

    public override function dataInvalidated(key:String):void {
    }

    public override function dataPreInvalidated(key:String):void {
    }

    public override function unitChanged():void {
    }

    public override function minMaxChanged():void {
    }
}
}
