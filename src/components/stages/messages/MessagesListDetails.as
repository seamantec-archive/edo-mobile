/**
 * Created by seamantec on 04/09/14.
 */
package components.stages.messages {

import com.common.AppProperties;
import com.sailing.SailData;
import com.sailing.datas.BaseSailData;
import com.sailing.units.Unit;
import com.utils.Assets;
import com.utils.FontFactory;
import com.utils.QuadBatcher;

import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;

public class MessagesListDetails extends Sprite {

    private var _details:Vector.<Object>;
//    private var _quadBatcher:QuadBatcher;
    private var s:Sprite = new Sprite();

    public function MessagesListDetails() {
        _details = new Vector.<Object>();
    }

    public function initQuadButcher():void {
//        trace("Sprite width", s.width/2, s.height)
//        _quadBatcher = new QuadBatcher(s.width/2, s.height);
//        _quadBatcher.addDisplayObject(s);
//        _quadBatcher.render();
        this.addChild(s);
    }

    public function add(key:String, displayName:String, value:String):void {
        var detail:Object = { key: key, value: FontFactory.getWhiteLeftFont((AppProperties.screenWidth / 2) - 10, MessagesListItem.HEIGHT, 14) };
        _details.push(detail);

        var row:Sprite = new Sprite();
        row.y = s.height;
        var img:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("openedlist_element_bg"));
        img.width = AppProperties.screenWidth;
        img.height = MessagesListItem.HEIGHT;
        row.addChild(img);

        var displayNameField:TextField = FontFactory.getWhiteRightFont((AppProperties.screenWidth / 2) - 10, MessagesListItem.HEIGHT, 14);
        displayNameField.x = 10;
        displayNameField.y = 2;
        displayNameField.text = (displayName=="") ? key : displayName;
        row.addChild(displayNameField);
        detail.value.x = (AppProperties.screenWidth / 2) + 10;
        detail.value.y = 2;
        detail.value.text = value;
        row.addChild(detail.value);

        s.addChild(row);
    }

    public function update(key:String):void {
        var data:BaseSailData = SailData.actualSailData[key];
        if(data.isValid()) {
            var length:int = _details.length;
            for (var i:int = 0; i < length; i++) {
                if (data.hasOwnProperty(_details[i].key) && data[_details[i].key] != null) {
                    _details[i].value.text = toValue(data[_details[i].key]);
                }
            }
        }
//        _quadBatcher.render();
    }

    private function toValue(data:Object):String {
        var isUnit:Boolean = data is Unit;
        var digit:uint = (isUnit) ? 2 : 5;

        if (data is Number) {
            return (Number(data) % 1 != 0) ? data.toFixed(digit) : String(data);
        } else if (isUnit) {
            return (data as Unit).getValueWithShortUnitInString();
        } else if(data is Date) {
            return (data as Date).toUTCString();
        } else {
            return String(data);
        }
    }

    public function getDetailOfIndex(index:int):Object {
        return (index >= 0 && index < _details.length) ? _details[index] : null;
    }

    public function getDetailOfKey(key:String):Object {
        var length:int = _details.length;
        for (var i:int = 0; i < length; i++) {
            var detail:Object = _details[i];
            if (detail.key == key) {
                return detail;
            }
        }
        return null;
    }

    public function getKey(index:int):String {
        var detail:Object = getDetailOfIndex(index);
        return (detail != null) ? detail.key : null;
    }

    public function setValueOfIndex(index:int, value:String):void {
        var detail:Object = getDetailOfIndex(index);
        if (detail != null) {
            detail.value.text = value;
        }
    }

    public function setValueOfKey(key:String, value:String):void {
        var detail:Object = getDetailOfKey(key);
        if (detail != null) {
            detail.value.text = value;
        }
    }

    public function getValueOfIndex(index:int):String {
        var detail:Object = getDetailOfIndex(index);
        return (detail != null) ? detail.value.text : null;
    }

    public function getValueOfKey(key:String):String {
        var detail:Object = getDetailOfKey(key);
        return (detail != null) ? detail.value.text : null;
    }

    public function get details():Vector.<Object> {
        return _details;
    }

    public function invalidate():void {
        var length:int = _details.length;
        for(var i:int=0; i<length; i++) {
            _details[i].value.text = "---";
        }
//        _quadBatcher.render();
    }
}
}
