/**
 * Created by pepusz on 16. 04. 19..
 */
package components {
import com.common.AppProperties;
import com.events.CloudEvent;
import com.harbor.CloudHandler;
import com.loggers.NmeaLogger;
import com.ui.CheckBox;
import com.ui.StageBtn;
import com.utils.FontFactory;


import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.utils.VAlign;

public class LogFileSettings extends Sprite {
    private static var _label:TextField;
    private static var _checkbox:CheckBox;
    private static var _uploadBtn:StageBtn;
    private static var _labelFile:TextField;

    public function LogFileSettings() {
        super();
//        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addedToStageHandler();
        CloudHandler.instance.addEventListener(CloudEvent.SIGNIN_COMPLETE, onSignIn);
        CloudHandler.instance.addEventListener(CloudEvent.SIGNOUT, onSignOut);
        NmeaLogger.instance.addEventListener("fileSizeChanged", fileSizeChangedHandler);
    }

    private function addedToStageHandler():void {
        if (_checkbox == null) {
            _checkbox = new CheckBox();
            _checkbox.isSelected = AppProperties.saveLogFileEnabled;
            _checkbox.addEventListener(Event.CHANGE, onChange);
            this.addChild(_checkbox);
        }

        if (_label == null) {
            _label = FontFactory.getWhiteLeftFont(Menu.WIDTH - _checkbox.width - 10, _checkbox.height * 2, 16, VAlign.TOP);
            _label.text = "Save NMEA log file";
            _label.x = _checkbox.width + 10;
            _label.y = 0;
            this.addChild(_label);
        }

        //TODO disable enable button if user login or out
        if (_uploadBtn == null) {
            _uploadBtn = new StageBtn("Upload file");
            _uploadBtn.x = _checkbox.width + 10;
            _uploadBtn.y = _checkbox.y + _checkbox.height + 5;
            _uploadBtn.addEventListener(TouchEvent.TOUCH, uploadBtn_touchHandler);
            _uploadBtn.enabled = CloudHandler.instance.signedIn;
            this.addChild(_uploadBtn);
        }
        if (_labelFile == null) {
            _labelFile = FontFactory.getWhiteLeftFont(Menu.WIDTH - _checkbox.width - 20 - _uploadBtn.width, _checkbox.height * 2, 16, VAlign.TOP);
            _labelFile.x = _uploadBtn.x + _uploadBtn.width + 10;
            _labelFile.y = _uploadBtn.y + _uploadBtn.height / 2 - 8;
            setFileSizeLabelText()
            this.addChild(_labelFile);
        }


    }

    private function setFileSizeLabelText():void {
        try {
            _labelFile.text = "File size: " + Math.round((NmeaLogger.instance.getLogFile().size / (1024 * 1024)) * 100) / 100 + " MB";
        } catch (e:Error) {
            trace(e.message);
        }
    }

    private function onChange(event:Event):void {
        AppProperties.saveLogFileEnabled = !AppProperties.saveLogFileEnabled;
    }

    private function uploadBtn_touchHandler(event:TouchEvent):void {
        if (_uploadBtn.touchIsEnd(event)) {
            NmeaLogger.instance.uploadToServer();
        }
    }

    private function onSignIn(event:CloudEvent):void {
        _uploadBtn.enabled = true;
    }

    private function onSignOut(event:CloudEvent):void {
        _uploadBtn.enabled = false;
    }

    private function fileSizeChangedHandler(event:Event):void {
        setFileSizeLabelText();
    }
}
}
